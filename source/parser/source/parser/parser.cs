using System;
using System.IO;
using System.Collections;
using System.Collections.Generic;
using System.Xml;
using System.Text;

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

        public void ParseFile(IParserSource source, List<Error> errors, Stack<DocItem> parseStack)
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
                    while ((line = source.ReadLine()) != null)
                    {
                        ++iCurrLine;
                        line = line.Trim(TRIM);
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
                            if (line.Length > 0 && line[0] == '@')
                            {
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
                                        ParseFile(src, errors, parseStack);
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
                                    parseStack.Peek().appendDescription(line, file, iCurrLine);
                                }
                                catch (Error e)
                                {
                                    errors.Add(e);
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
            return;
        }

        public void UpdateFile(IParserSource source, List<Error> errors)
        {
            lock (mMutex)
            {
                if (source.Changed)
                {
                    mRoot.RemoveByFile(source.Name);
                    ParseFile(source, errors, null);
                    source.Changed = false;
                }
            }
        }
    }
}