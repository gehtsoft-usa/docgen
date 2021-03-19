using System;
using System.Collections.Generic;
using System.Xml;

namespace GehtSoft.DocCreator.Parser
{
    /** The table. */
    public class ListItemItem : DocItem, IXmlItem
    {
        public bool Simplified { get; set; } = false;

        internal ListItemItem(string file, int line) : base(file, line)
        {
        }

        /** Saves item into XML node.

            @param doc     Xml document.

            @return Xml node with item data in it.
        */
        public XmlNode ItemToXml(XmlDocument doc, IDefinitionList defs)
        {
            XmlNode tableColNode = doc.CreateNode(XmlNodeType.Element, "list-item", "");
            DescriptionToXml(tableColNode, doc, defs);
            return tableColNode;
        }
    }
}
