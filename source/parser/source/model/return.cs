using System;
using System.Collections.Generic;
using System.Xml;

namespace GehtSoft.DocCreator.Parser
{


    /** Description of return value. */
    public class ReturnItem : DocItem, IXmlItem
    {
        /** constructor. */
        internal ReturnItem(string file, int line) : base(file, line)
        {
        }

        /** Saves item into XML node.

            @param doc     Xml document.

            @return Xml node with item data in it.
        */
        public XmlNode ItemToXml(XmlDocument doc, IDefinitionList defs)
        {
            XmlNode returnNode = doc.CreateNode(XmlNodeType.Element, "return", "");

            // no fields to save

            DescriptionToXml(returnNode, doc, defs);

            return returnNode;
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
            throw new UnknownTagError(file, line, "return", sName);
        }
    }

}
