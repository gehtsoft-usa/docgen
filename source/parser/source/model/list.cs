using System;
using System.Collections.Generic;
using System.Xml;

namespace GehtSoft.DocCreator.Parser
{

    /** The table. */
    public class ListItem : DocItem, IXmlItem
    {
        private List<DocItem> mItems = new List<DocItem>();
        private string mType = "dot";

        internal bool Simplified { get; set; } = false;

        internal ListItem(string file, int line) : base(file, line)
        {
        }

        /** Saves item into XML node.

            @param doc     Xml document.

            @return Xml node with item data in it.
        */
        public XmlNode ItemToXml(XmlDocument doc, IDefinitionList defs)
        {
            XmlNode node = doc.CreateNode(XmlNodeType.Element, "list", "");
            XmlAttribute attr;
            attr = doc.CreateAttribute("type");
            attr.Value = mType;
            node.Attributes.Append(attr);

            ItemsToXml(mItems, node, doc, defs);
            return node;
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
                case "type":
                    if (sValue == null)
                        throw new ValueError(file, line, "list", sName, "(null)");
                    if (sValue == "num" || sValue == "dot")
                        mType = sValue;
                    else
                        throw new ValueError(file, line, "list", sName, sValue, "The value must be either dot or num");
                    return null;
                case "list-item":
                    {
                        ListItemItem item = new ListItemItem(file, line);
                        mItems.Add(item);
                        return item;
                    }
                case "list":
                    {
                        ListItem item = new ListItem(file, line);
                        mItems.Add(item);
                        return item;
                    }
                default:
                    throw new UnknownTagError(file, line, sName, sValue);
            }
        }

        public ListItemItem LastListItem()
        {
            if (mItems.Count == 0)
                return null;
            return mItems[mItems.Count - 1] as ListItemItem;
        }
    }
}

