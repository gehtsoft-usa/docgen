using System;
using System.Collections.Generic;
using System.Xml;

namespace GehtSoft.DocCreator.Parser
{


    /** See also item. */
    internal class SeeAlsoItem : DocItem, IXmlItem, IConditionalItem
    {
        private string msKey;        //!< key
        private string msTitle;      //!< title of the line
        private string mIf = null;

        public string If
        {
            get
            {
                return mIf;
            }
        }

        /** Constructor. */
        internal SeeAlsoItem(string file, int line) : base(file, line)
        {
            msKey = "";
            msTitle = "";
        }

        /** Saves item into XML node.

            @param doc     Xml document.

            @return Xml node with item data in it.
        */
        public XmlNode ItemToXml(XmlDocument doc, IDefinitionList defs)
        {
            XmlNode seeAlsoNode = doc.CreateNode(XmlNodeType.Element, "see-also", "");
            XmlAttribute attr;

            attr = doc.CreateAttribute("title");
            attr.Value = msTitle;
            seeAlsoNode.Attributes.Append(attr);

            attr = doc.CreateAttribute("key");
            attr.Value = msKey;
            seeAlsoNode.Attributes.Append(attr);

            DescriptionToXml(seeAlsoNode, doc, defs);

            return seeAlsoNode;
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
                case "key":
                    if (sValue == null)
                        throw new ValueError(file, line, "see", sName, "(null)");
                    msKey = sValue;
                    break;
                case "title":
                    if (sValue == null)
                        throw new ValueError(file, line, "see", sName, "(null)");
                    msTitle = sValue;
                    break;
                case "if":
                    if (sValue == null)
                        throw new ValueError(file, line, "see", sName, "(null)");
                    mIf = sValue;
                    break;
                default:
                    throw new UnknownTagError(file, line, "see", sName);
            }
            return null;
        }

        /** Validate the content of the item. */
        override internal void validate(string file, int line)
        {
            base.validate(file, line);
            if (msKey.Length == 0 && msTitle.Length == 0)
                throw new ValidationError(file, line, "see", "either @key or @title");
            if (msTitle == null)
                msTitle = msKey;
            if (msKey.Length > 0)
                msTitle = string.Format("{0}", msTitle);
        }
    }

}
