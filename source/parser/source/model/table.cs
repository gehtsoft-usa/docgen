using System;
using System.Collections.Generic;
using System.Xml;

namespace GehtSoft.DocCreator.Parser
{


    /** The table. */
    public class TableItem : DocItem, IXmlItem, IConditionalItem
    {
        private List<DocItem> mRows = new List<DocItem>();
        private string mWidth = null;
        private string msIf;                     //!< conditional

        public string If
        {
            get
            {
                return msIf;
            }
        }

        internal TableItem(string file, int line) : base(file, line)
        {

        }

        /** Saves item into XML node.

            @param doc     Xml document.

            @return Xml node with item data in it.
        */
        public XmlNode ItemToXml(XmlDocument doc, IDefinitionList defs)
        {
            XmlNode tableNode = doc.CreateNode(XmlNodeType.Element, "table", "");
            XmlAttribute attr;

            attr = doc.CreateAttribute("width");
            attr.Value = mWidth == null ? "" : mWidth;
            tableNode.Attributes.Append(attr);

            ItemsToXml(mRows, tableNode, doc, defs);
            return tableNode;
        }

        /** Append new named value into the object.

            @param sName            Name of the value
            @param sValue           Value
            @return                 New object (enclosed into this object) in case of
                                    named value creates new level of hierarchy
            @exception EParseVal    In case of the value is not acceptable in current context
          */
        override internal DocItem appendNamedValue(string sName, string sValue, string file, int line)
        {
            switch (sName)
            {
                case "width":
                    if (sValue == null)
                        throw new ValueError(file, line, "table", sName, "(null)");
                    mWidth = sValue;
                    return null;
                case "row":
                    {
                        TableRowItem item = new TableRowItem(file, line);
                        mRows.Add(item);
                        return item;
                    }
                case "if":
                    if (sValue == null)
                        throw new ValueError(file, line, "table", sName, "(null)");
                    msIf = sValue;
                    return null;
                default:
                    throw new UnknownTagError(file, line, "table", sName);
            }
        }

        /** Validate the content of the item.

            @exception EParseValidate   In case of validation is not succesful
         */
        override internal void validate(string file, int line)
        {
            base.validate(file, line);
            if (mWidth == null)
                mWidth = "";
        }
    }
}
