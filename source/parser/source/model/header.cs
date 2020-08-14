using System;
using System.Collections.Generic;
using System.Xml;

namespace GehtSoft.DocCreator.Parser
{

    /** The table. */
    public class HeaderItem : DocItem, IXmlItem
    {
        private int mLevel = 1;

        internal HeaderItem(string file, int line) : base(file, line)
        {
        }

        /** Saves item into XML node.

            @param doc     Xml document.

            @return Xml node with item data in it.
        */
        public XmlNode ItemToXml(XmlDocument doc, IDefinitionList defs)
        {
            XmlNode headerNode = doc.CreateNode(XmlNodeType.Element, "header", "");
            XmlAttribute attr;

            attr = doc.CreateAttribute("level");
            attr.Value = mLevel.ToString();
            headerNode.Attributes.Append(attr);

            DescriptionToXml(headerNode, doc, defs);
            return headerNode;
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
                case "level":
                    {
                        if (sValue == null)
                            throw new ValueError(file, line, "headline", sName, "(null)");
                        int level = 0;
                        bool rc = Int32.TryParse(sValue, out level);
                        if (!rc || level < 1 || level > 6)
                            throw new ValueError(file, line, "headline", sName, sValue, "The value must be an integer between 1 and 6.");
                        mLevel = level;
                    }
                    return null;
                default:
                    throw new UnknownTagError(file, line, "headline", sName);
            }
        }
    }
}
