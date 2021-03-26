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

        internal object LastItem()
        {
            if (maDescription.Count == 0)
                return null;

            return maDescription[maDescription.Count - 1];
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
            else if (sName == "note")
            {
                NoteItem ex = new NoteItem(file, line);
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

        protected void DescriptionToXml(XmlNode parent, XmlDocument doc, IDefinitionList defs)
        {
            if (maDescription.Count != 0)
            {
                
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
