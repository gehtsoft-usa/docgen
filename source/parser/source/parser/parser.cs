using System;
using System.IO;
using System.Collections;
using System.Collections.Generic;
using System.Xml;
using System.Text;
using System.Runtime.InteropServices;
using System.Text.RegularExpressions;
using System.Threading;

namespace GehtSoft.DocCreator.Parser
{
    public class DsFileParser
    {
        private object mMutex = new object();

        public object Mutex
        {
            get
            {
                return mMutex;
            }
        }

        RootItem mRoot;

        public RootItem Root
        {
            get
            {
                return mRoot;
            }
        }

        public DsFileParser()
        {
            mRoot = new RootItem();
        }

        private readonly char[] TRIM = " \t\n\r".ToCharArray();
        private static Regex mTableRow = new Regex(@"\s*\|.+\|\s*\>?\s*$", RegexOptions.Singleline);
        private static Regex mTableColumn = new Regex(@"^((!?)(\d+%)?,)?(.*)$");
        private static Regex mCode = new Regex("`([^`]+)`");
        private static Regex mBold = new Regex("\\*\\*([^*]+)\\*\\*");
        private static Regex mItalic = new Regex("\\/\\/([^/]+)\\/\\/");
        private static Regex mUnderline = new Regex("__([^_]+)__");
        private static Regex mStrike = new Regex("\\~\\~([^~]+)\\~\\~");
        private static Regex mSup = new Regex("\\^\\^([^\\^]+)\\^\\^");
        private static Regex mRef = new Regex(@"\[<([^\>]+)>\]\<([^\>]+)\>");
        private static Regex mLink = new Regex("<(https?://[^>+]+)>");
        

        public void ParseFile(IParserSource source, List<Error> errors, Stack<DocItem> parseStack, IDefinitionList defs)
        {
            lock (mMutex)
            {
                string file = source.Name;
                source.Reset();
                try
                {
                    int iCurrLine = 0;
                    if (parseStack == null)
                    {
                        parseStack = new Stack<DocItem>();
                        parseStack.Push(mRoot);
                    }
                    int parseStackSizeAtBeginning = parseStack.Count;

                    //read file line by line
                    string line;
                    bool preformattedBlock = false;
                    int preformattedBlockIndent = 0;
                    bool simplifiedSyntax = defs?.Exists("simplified-text-syntax") ?? false;

                    while ((line = source.ReadLine()) != null)
                    {
                        ++iCurrLine;

                        var trimmedline = line.TrimStart(TRIM);

                        if (!simplifiedSyntax)
                            line = trimmedline;
                        else
                        {
                            if (trimmedline.Trim(TRIM).StartsWith("```"))
                            {
                                preformattedBlock = !preformattedBlock;
                                if (preformattedBlock)
                                    preformattedBlockIndent = Math.Max(0, line.Length - trimmedline.Length);

                                if (preformattedBlock)
                                {
                                    if (trimmedline.Trim(TRIM) != "```")
                                    {
                                        if (!SSTool.IsInAutoExample(parseStack.Peek(), out _))
                                        {
                                            var ee = parseStack.Peek().appendNamedValue("example", null, file, iCurrLine);
                                            parseStack.Push(ee);
                                            (ee as ExampleItem).Simplified = true;
                                            string syntax;
                                            if (trimmedline.Substring(3, 1) == "+")
                                            {
                                                ee.appendNamedValue("title", "Example", file, iCurrLine);
                                                ee.appendNamedValue("show", "yes", file, iCurrLine);
                                                syntax = trimmedline.Substring(4);
                                            }
                                            else if (trimmedline.Substring(3, 1) == "-")
                                            {
                                                ee.appendNamedValue("title", "Example", file, iCurrLine);
                                                ee.appendNamedValue("show", "no", file, iCurrLine);
                                                syntax = trimmedline.Substring(4);
                                            }
                                            else
                                            {
                                                ee.appendNamedValue("show", "always", file, iCurrLine);
                                                syntax = trimmedline.Substring(3);
                                            }
                                            ee.appendNamedValue("highlight", syntax, file, iCurrLine);
                                        }
                                        else if (parseStack.Peek() is ExampleItem)
                                        {
                                            parseStack.Peek().appendNamedValue("highlight", trimmedline.Substring(3), file, iCurrLine);
                                        }
                                    }
                                }
                                else
                                {
                                    if (SSTool.IsInAutoExample(parseStack.Peek(), out ExampleItem exampleItem))
                                        parseStack.Pop();
                                }
                                continue;
                            }
                            else
                            {
                                if (!preformattedBlock)
                                {
                                    line = trimmedline;
                                }
                                else
                                {
                                    if (preformattedBlockIndent > 0 &&
                                        line.Length > preformattedBlockIndent &&
                                        line.Substring(0, preformattedBlockIndent).Trim().Length == 0)
                                        line = line.Substring(preformattedBlockIndent);
                                }
                            }
                        }

                        if (line.Length > 0 && line[0] == '!')
                        {
                            line = line.Remove(0, 1);
                            if (line.Length == 0)
                                line = " ";
                            try
                            {
                                parseStack.Peek().appendDescription(line, file, iCurrLine);
                            }
                            catch (Error e)
                            {
                                errors.Add(e);
                            }
                        }
                        else
                        {
                            bool simplifiedHandled = false;
                            string r;
                            var peek = parseStack.Peek();

                            if (peek != null && !(peek is ExampleItem) && !(peek is ExampleTabItem) && simplifiedSyntax)
                            {
                                if (line.Contains("`"))
                                    line = mCode.Replace(line, m => $"[c]{m.Groups[1].Value}[/c]");

                                if (line.Contains("**"))
                                    line = mBold.Replace(line, m => $"[b]{m.Groups[1].Value}[/b]");

                                if (line.Contains("//"))
                                    line = mItalic.Replace(line, m => $"[i]{m.Groups[1].Value}[/i]");

                                if (line.Contains("__"))
                                    line = mUnderline.Replace(line, m => $"[u]{m.Groups[1].Value}[/u]");

                                if (line.Contains("~~"))
                                    line = mStrike.Replace(line, m => $"[s]{m.Groups[1].Value}[/s]");

                                if (line.Contains("^^"))
                                    line = mSup.Replace(line, m => $"[sup]{m.Groups[1].Value}[/sup]");

                                if (line.Contains(">]<"))
                                    line = mRef.Replace(line, m => $"[link={m.Groups[2].Value}]{m.Groups[1].Value}[/link]");

                                if (line.Contains("<http"))
                                    line = mLink.Replace(line, m => $"[eurl={m.Groups[1].Value}]{m.Groups[1].Value}[/eurl]");

                                if (SSTool.StartsWith(line, "* ", out r) || SSTool.StartsWith(line, "- ", out r) || SSTool.StartsWith(line, "0 ", out r))
                                {
                                    ListItem list;
                                    if (!SSTool.IsInAutoList(peek, out list))
                                    {
                                        list = peek.appendNamedValue("list", null, file, iCurrLine) as ListItem;
                                        if (line[0] == '0')
                                            list.appendNamedValue("type", "num", file, iCurrLine);
                                        list.Simplified = true;
                                    }

                                    var listItem = list.appendNamedValue("list-item", null, file, iCurrLine) as ListItemItem;
                                    listItem.Simplified = true;

                                    listItem.appendDescription(r, file, iCurrLine);
                                    simplifiedHandled = true;
                                }
                                else if (SSTool.StartsWith(line, "|", out r))
                                {
                                    Match m = mTableRow.Match(line);
                                    if (m.Success)
                                    {
                                        TableItem table;
                                        if (!SSTool.IsInAutoTable(peek, out table))
                                        {
                                            table = peek.appendNamedValue("table", null, file, iCurrLine) as TableItem;
                                            if (line.Trim(TRIM).EndsWith(">"))
                                                table.appendNamedValue("width", "100%", file, iCurrLine);
                                            table.Simplified = true;
                                        }

                                        string[] columns = line.Split('|');
                                        var row = table.appendNamedValue("row", null, file, iCurrLine);
                                        for (int i = 1; i < columns.Length - 1; i++)
                                        {
                                            Match m1 = mTableColumn.Match(columns[i]);
                                            var col = row.appendNamedValue("col", null, file, iCurrLine);
                                            if (m1.Groups[1].Value != null)
                                            {
                                                if (m1.Groups[2].Value == "!")
                                                    row.appendNamedValue("header", "yes", file, iCurrLine);
                                                if (m1.Groups[3].Value != "")
                                                    col.appendNamedValue("width", m1.Groups[3].Value, file, iCurrLine);
                                            }
                                            col.appendDescription(m1.Groups[4].Value ?? "", file, iCurrLine);
                                        }
                                        simplifiedHandled = true;
                                    }
                                }
                                else if (SSTool.StartsWith(line, "# ", out r) || SSTool.StartsWith(line, "## ", out r) || SSTool.StartsWith(line, "### ", out r))
                                {
                                    var he = peek.appendNamedValue("headline", null, file, iCurrLine);
                                    he.appendNamedValue("level", (line.Length - r.Length - 1).ToString(), file, iCurrLine);
                                    he.appendDescription(r, file, iCurrLine);
                                    simplifiedHandled = true;
                                }
                                else if (SSTool.StartsWith(line, "#### ", out r))
                                {
                                    peek.appendDescription($"[b]{r}[/b]", file, iCurrLine);
                                    simplifiedHandled = true;
                                }
                            }

                            if (!simplifiedHandled)
                            {
                                if (SSTool.IsInAutoTable(peek, out TableItem tableItem))
                                    tableItem.Simplified = false;

                                if (line.Length > 0 && line[0] == '@')
                                {
                                    line = line.TrimEnd(TRIM);
                                    //process value
                                    string sValName;
                                    string sValue;

                                    parseValue(line, out sValName, out sValue);

                                    if (sValName == "end")
                                    {
                                        if (parseStack.Count == 1)
                                        {
                                            errors.Add(new ParserError(file, iCurrLine, "@end is not balanced"));
                                        }
                                        else
                                        {
                                            DocItem lastItem = parseStack.Pop();
                                            try
                                            {
                                                lastItem.validate(file, iCurrLine);
                                            }
                                            catch (Error e)
                                            {
                                                errors.Add(e);
                                            }
                                        }
                                    }
                                    else if (sValName == "include")
                                    {
                                        FileInfo si = new FileInfo(source.Name);
                                        string includeName = Path.Combine(si.DirectoryName, sValue);
                                        if (!File.Exists(includeName))
                                            errors.Add(new ParserError(file, iCurrLine, string.Format("{0} file isn't found", includeName)));
                                        else
                                        {
                                            FileParserSource src = new FileParserSource(includeName, source.Encoding);
                                            ParseFile(src, errors, parseStack, defs);
                                        }
                                    }
                                    else
                                    {
                                        DocItem currItem, newItem;
                                        currItem = parseStack.Peek();
                                        try
                                        {
                                            newItem = currItem.appendNamedValue(sValName, sValue, file, iCurrLine);
                                            if (newItem != null)
                                                parseStack.Push(newItem);
                                        }
                                        catch (Error e)
                                        {
                                            errors.Add(e);
                                            if (sValue == null)
                                                parseStack.Push(new UnexpectedItem(file, iCurrLine));
                                        }
                                    }
                                }
                                else
                                {
                                    try
                                    {
                                        //process description
                                        if (simplifiedSyntax && SSTool.IsInAutoList(parseStack.Peek(), out ListItem li))
                                        {
                                            bool empty = line.Trim(TRIM).Length == 0;
                                            var lastItem = li.LastListItem();
                                            if (empty)
                                                lastItem.Simplified = false;
                                            else
                                            {
                                                if (lastItem.Simplified)
                                                    lastItem.appendDescription(line, file, iCurrLine);
                                                else
                                                {
                                                    li.Simplified = false;
                                                    parseStack.Peek().appendDescription(line, file, iCurrLine);
                                                }
                                            }
                                        }
                                        else
                                        {
                                            parseStack.Peek().appendDescription(line, file, iCurrLine);
                                        }
                                    }
                                    catch (Error e)
                                    {
                                        errors.Add(e);
                                    }
                                }
                            }
                        }
                    }
                    if (parseStack.Count != parseStackSizeAtBeginning)
                        errors.Add(new ParserError(file, iCurrLine, string.Format("{0} tags aren't closed at the end of the file", parseStack.Count - 1)));
                }
                finally
                {
                    source.Stop();
                }
            }
        }


        /** Parse line in the form @name=value into name and value. */
        static void parseValue(string sLine, out string sName, out string sValue)
        {
            StringBuilder name = new StringBuilder("");
            StringBuilder value = null;
            StringBuilder curr = name;

            bool bValue = false;
            int i, l;
            l = sLine.Length;
            for (i = 1; i < l; i++)
            {
                char cc = sLine[i];
                if (cc == '=' && !bValue)
                {
                    bValue = true;
                    value = new StringBuilder("");
                    curr = value;
                }
                else
                    curr.Append(cc, 1);
            }
            sName = name.ToString();
            if (bValue)
                sValue = value.ToString();
            else
                sValue = null;
        }

        public void UpdateFile(IParserSource source, List<Error> errors, IDefinitionList defs)
        {
            lock (mMutex)
            {
                if (source.Changed)
                {
                    mRoot.RemoveByFile(source.Name);
                    ParseFile(source, errors, null, defs);
                    source.Changed = false;
                }
            }
        }
    }
}