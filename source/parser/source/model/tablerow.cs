using System;
using System.Collections.Generic;
using System.Xml;

namespace GehtSoft.DocCreator.Parser
{

    /** The table. */
    public class TableRowItem : DocItem, IXmlItem, IConditionalItem
    {
        public List<DocItem> mCols = new List<DocItem>();
        public bool mIsHeader = false;
        public string msIf;                     //!< conditional

        public string If
        {
            get
            {
                return msIf;
            }
        }

        internal TableRowItem(string file, int line) : base(file, line)
        {
            msIf = null;
        }

        /** Saves item into XML node.

            @param doc     Xml document.

            @return Xml node with item data in it.
        */
        public XmlNode ItemToXml(XmlDocument doc, IDefinitionList defs)
        {
            XmlNode tableRowNode = doc.CreateNode(XmlNodeType.Element, "table-row", "");
            XmlAttribute attr;

            attr = doc.CreateAttribute("is-header");
            attr.Value = mIsHeader ? "true" : "false";
            tableRowNode.Attributes.Append(attr);

            ItemsToXml(mCols, tableRowNode, doc, defs);
            return tableRowNode;
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
                case "header":
                    if (sValue == null)
                        throw new ValueError(file, line, "row", sName, "(null)");
                    if (sValue == "true" || sValue == "yes")
                        mIsHeader = true;
                    return null;
                case "col":
                    {
                        TableColItem item = new TableColItem(this, file, line);
                        mCols.Add(item);
                        return item;
                    }
                case "if":
                    if (sValue == null)
                        throw new ValueError(file, line, "row", sName, "(null)");
                    msIf = sValue;
                    return null;
                default:
                    throw new UnknownTagError(file, line, "row", sName);
            }
        }
    }
}
