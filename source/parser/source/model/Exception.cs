using System;
using System.Collections.Generic;
using System.Xml;

namespace GehtSoft.DocCreator.Parser
{

    /** Exception description. */
    public class ExceptionItem : DocItem, IXmlItem
    {
        private string msName;           //!< name of the exception

        /** Constructor. */
        internal ExceptionItem(string file, int line) : base(file, line)
        {
            msName = null;
        }

        /** Saves item into XML node.

            @param doc     Xml document.

            @return Xml node with item data in it.
        */
        public XmlNode ItemToXml(XmlDocument doc, IDefinitionList defs)
        {
            XmlNode exceptionNode = doc.CreateNode(XmlNodeType.Element, "exception", "");
            XmlAttribute attr;

            attr = doc.CreateAttribute("name");
            attr.Value = msName;
            exceptionNode.Attributes.Append(attr);

            DescriptionToXml(exceptionNode, doc, defs);

            return exceptionNode;
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
                case "name":
                    if (sValue == null)
                        throw new ValueError(file, line, "exception", sName, "(null)");
                    msName = sValue;
                    break;
                default:
                    throw new UnknownTagError(file, line, "exception", sName);
            }
            return null;
        }
        /** Validate the content of the item.

            @exception EParseValidate   In case of validation is not succesful
         */
        override internal void validate(string file, int line)
        {
            base.validate(file, line);
            if (msName == null)
                throw new ValidationError(file, line, "exception", "@name");
        }
    }

}
