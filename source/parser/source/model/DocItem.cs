using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.Xml;
using System.Text;
using System.Text.RegularExpressions;

namespace GehtSoft.DocCreator.Parser
{

    public interface IDefinitionList
    {
        bool Exists(string definition);
    }


    public interface IConditionalItem
    {
        string If
        {
            get;
        }
    }

    public interface IXmlItem
    {
        /** Saves item into XML node.

            @param doc     Xml document.

            @return Xml node with item data in it.
        */
        XmlNode ItemToXml(XmlDocument doc, IDefinitionList defs);
    }

    /** Abstract documentation item. */
    public abstract class DocItem
    {
        private List<object> maDescription;      //!< description
        private object lastobject = null;
        private static char[] trimchar = " \t\n\r".ToCharArray();
        protected bool trim = true;

        private string mFile;
        public string File
        {
            get
            {
                return mFile;
            }
        }

        private int mLine;
        public int Line
        {
            get
            {
                return mLine;
            }
        }

        private int mEndLine;
        public int EndLine
        {
            get
            {
                return mEndLine;
            }
        }

        /** Constructor. */
        internal DocItem(string file, int line)
        {
            mFile = file;
            mLine = line;
            maDescription = new List<object>();
        }

        /** Append the line into description.

            @param sDescription     Another line of the description (e.g. line doesn't contain
                                    any information)
            @exception EParseDesc   In case of description is not acceptable in current context
          */
        virtual internal void appendDescription(string sDescription, string file, int line)
        {
            if (trim)
                sDescription = sDescription.Trim(trimchar);

            if (trim && sDescription.Length == 0)
            {
                if (lastobject != null)
                    lastobject = null;
            }
            else
            {
                if (lastobject == null || !(lastobject is StringBuilder))
                {
                    lastobject = new StringBuilder(sDescription);
                    maDescription.Add(lastobject);
                }
                else
                {
                    StringBuilder s = lastobject as StringBuilder;
                    if (s.Length > 0)
                        s.Append("\n");
                    s.Append(sDescription);
                }
            }
        }

        /** Append new named value into the object.

            @param sName            Name of the value
            @param sValue           Value
            @return                 New object (enclosed into this object) in case of
                                    named value creates new level of hierarchy
            @exception EParseVal    In case of the value is not acceptable in current context
          */
        virtual internal DocItem appendNamedValue(string sName, string sValue, string file, int line)
        {
            if (sName == "table")
            {
                TableItem table = new TableItem(file, line);
                lastobject = table;
                maDescription.Add(table);
                return table;
            }
            else if (sName == "example")
            {
                ExampleItem ex = new ExampleItem(file, line);
                lastobject = ex;
                maDescription.Add(ex);
                return ex;
            }
            else if (sName == "list")
            {
                ListItem ex = new ListItem(file, line);
                lastobject = ex;
                maDescription.Add(ex);
                return ex;
            }
            else if (sName == "headline")
            {
                HeaderItem ex = new HeaderItem(file, line);
                lastobject = ex;
                maDescription.Add(ex);
                return ex;
            }
            return null;
        }

        /** Validate the content of the item.

            @exception EParseValidate   In case of validation is not succesful
         */
        internal virtual void validate(string file, int line)
        {
            mEndLine = line;
        }

        protected void ItemsToXml(IEnumerable<DocItem> items, XmlNode parent, XmlDocument doc, IDefinitionList defs)
        {
            foreach (DocItem item in items)
            {
                if (item is IXmlItem)
                {
                    if (item is IConditionalItem)
                    {
                        IConditionalItem ci = item as IConditionalItem;
                        if (ci.If != null && !defs.Exists(ci.If))
                            continue;
                    }
                    IXmlItem xi = item as IXmlItem;
                    parent.AppendChild(xi.ItemToXml(doc, defs));
                }
            }
        }

        protected void StringsToXml(IEnumerable<string> strings, XmlNode parent, XmlDocument doc, string element)
        {
            foreach (string s in strings)
            {
                XmlNode node = doc.CreateNode(XmlNodeType.Element, element, "");
                XmlNode content = doc.CreateNode(XmlNodeType.CDATA, "", "");
                content.Value = s;
                node.AppendChild(content);
                parent.AppendChild(node);
            }

        }

        private static Regex mListRegex = new Regex(@"^\s*[\-\*]\s*(\S.*\S?)\s*$", RegexOptions.Singleline);
        private static Regex mNumListRegex = new Regex(@"^\s*\#\s*(\S.*\S?)\s*$", RegexOptions.Singleline);
        private static Regex mTableRow = new Regex(@"\s*\|.+\|\s*$",RegexOptions.Singleline);
        //                                               1 2          3      4           5
        private static Regex mTableColumn = new Regex(@"^({(header)?,?((\d+%?))?})?(.*)$");

        private static char FirstChar(string s)
        {
            for (int i = 0; i < s.Length; i++)
                if (s[i] != ' ' && s[i] != '\t')
                    return s[i];
            return ' ';
        }

        private void PreprocessBodyForSimplifiedSyntax()
        {
            for (int i = 0; i < maDescription.Count; i++)
            {
                if (maDescription[i] is StringBuilder sb)
                    maDescription[i] = sb.ToString();

                if (maDescription[i] is string s) 
                {
                    char fc = FirstChar(s);
                    if ((fc == '*' || fc == '-' || fc == '#' || fc == '|') && s.IndexOf('\n') >= 0)
                    {
                        string[] all = s.Split('\n');
                        bool allMatch = true;
                        for (int k = 0; k < all.Length && allMatch; k++)
                            allMatch &= (FirstChar(all[k]) == fc);

                        if (allMatch)
                        {
                            maDescription.RemoveAt(i);
                            for (int k = 0; k < all.Length; k++)
                                maDescription.Insert(i + k, all[k]);
                            i--;
                            continue;
                        }
                    }

                    
                    Match m;
                    m = mListRegex.Match(s);
                    if (m.Success)
                    {
                        s = m.Groups[1].Value;
                        if (i == 0 || !(maDescription[i - 1] is ListItem list))
                        {
                            list = new ListItem(mFile, mLine);
                            list.appendNamedValue("type", "dot", mFile, mLine);
                            maDescription[i] = list;
                        }
                        else
                        {
                            maDescription.RemoveAt(i);
                            i--;
                        }

                        ListItemItem item = list.appendNamedValue("list-item", null, mFile, mLine) as ListItemItem;
                        item.maDescription.Add(s);
                        continue;
                    }

                    m = mNumListRegex.Match(s);
                    if (m.Success)
                    {
                        s = m.Groups[1].Value;

                        if (i == 0 || !(maDescription[i - 1] is ListItem list))
                        {
                            list = new ListItem(mFile, mLine);
                            list.appendNamedValue("type", "num", mFile, mLine);
                            maDescription[i] = list;
                        }
                        else
                        {
                                maDescription.RemoveAt(i);
                                i--;
                        }

                        ListItemItem item = list.appendNamedValue("list-item", null, mFile, mLine) as ListItemItem;
                        item.maDescription.Add(s);
                        continue;
                    }

                    m = mTableRow.Match(s);
                    if (m.Success)
                    {
                        if (i == 0 || !(maDescription[i - 1] is TableItem table))
                        {
                            table = new TableItem(mFile, mLine);
                            table.appendNamedValue("width", "100%", mFile, mLine);
                            maDescription[i] = table;
                        }
                        else
                        {
                            maDescription.RemoveAt(i);
                            i--;
                        }

                        TableRowItem row = table.appendNamedValue("row", null, mFile, mLine) as TableRowItem;
                        string[] cols = s.Split('|');
                        for (int j = 1; j < cols.Length - 1; j++)
                        {
                            string content = "";
                            string width = null;
                            m = mTableColumn.Match(cols[j]);
                            if (m.Success)
                            {
                                content = m.Groups[5].Value;
                                width = m.Groups[4].Value;
                                if (!string.IsNullOrEmpty(m.Groups[1].Value))
                                {
                                    row.appendNamedValue("header", "yes", mFile, mLine);
                                }
                            }
                            else
                                content = cols[j];

                            TableColItem col = row.appendNamedValue("col", null, mFile, mLine) as TableColItem;
                            if (!string.IsNullOrEmpty(width))
                                col.appendNamedValue("width", width, mFile, mLine);
                            col.appendDescription(content, mFile, mLine);
                        }
                        continue;
                    }
                }
            }
        }

        protected void DescriptionToXml(XmlNode parent, XmlDocument doc, IDefinitionList defs)
        {
            if (maDescription.Count != 0)
            {
                if (defs.Exists("simplified-text-syntax") && !(this is ExampleItem) && !(this is ExampleTabItem))
                    PreprocessBodyForSimplifiedSyntax();

                XmlNode body = doc.CreateNode(XmlNodeType.Element, "body", ""), item, content;
                parent.AppendChild(body);
                for (int i = 0; i < maDescription.Count; i++)
                {
                    object curr = maDescription[i];
                    if (curr is StringBuilder sb)
                    {
                        item = doc.CreateNode(XmlNodeType.Element, "p", "");
                        content = doc.CreateNode(XmlNodeType.CDATA, "", "");
                        content.Value = sb.ToString();
                        item.AppendChild(content);
                        body.AppendChild(item);
                    }
                    else if (curr is string str)
                    {
                        item = doc.CreateNode(XmlNodeType.Element, "p", "");
                        content = doc.CreateNode(XmlNodeType.CDATA, "", "");
                        content.Value = str;
                        item.AppendChild(content);
                        body.AppendChild(item);
                    }
                    else if (curr is IXmlItem)
                    {
                        if (curr is IConditionalItem)
                        {
                            IConditionalItem ci = curr as IConditionalItem;
                            if (ci.If != null && !defs.Exists(ci.If))
                                continue;
                        }
                        body.AppendChild(((IXmlItem)curr).ItemToXml(doc, defs));
                    }
                }
            }
        }
    }

}
