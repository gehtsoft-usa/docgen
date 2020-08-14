using System;
using System.Collections.Generic;
using System.Xml;

namespace GehtSoft.DocCreator.Parser
{


    /** The table. */
    public class TableColItem : DocItem, IXmlItem
    {
        private string mWidth = null;
        private TableRowItem mRow;

        internal TableColItem(TableRowItem row, string file, int line) : base(file, line)
        {
            mRow = row;
        }

        /** Saves item into XML node.

            @param doc     Xml document.

            @return Xml node with item data in it.
        */
        public XmlNode ItemToXml(XmlDocument doc, IDefinitionList defs)
        {
            XmlNode tableColNode = doc.CreateNode(XmlNodeType.Element, "table-col", "");
            XmlAttribute attr;

            attr = doc.CreateAttribute("width");
            attr.Value = mWidth;
            tableColNode.Attributes.Append(attr);

            DescriptionToXml(tableColNode, doc, defs);
            return tableColNode;
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
            DocItem dt;
            if ((dt = base.appendNamedValue(sName, sValue, file, line)) != null)
                return dt;
            switch (sName)
            {
                case "width":
                    if (sValue == null)
                        throw new ValueError(file, line, "col", sName, "(null)");
                    mWidth = sValue;
                    return null;
                default:
                    throw new UnknownTagError(file, line, "col", sName);
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
