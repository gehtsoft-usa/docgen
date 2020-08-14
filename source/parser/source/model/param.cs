using System;
using System.Collections.Generic;
using System.Xml;

namespace GehtSoft.DocCreator.Parser
{


    /** Description of the parameter. */
    public class ParamItem : DocItem, IXmlItem, IConditionalItem
    {
        private string msName;                   //!< name of the parameter
        private bool mGray;                      //!< gray out the parameter
        private string mIf = null;

        public string If
        {
            get
            {
                return mIf;
            }
        }

        /** Constructor. */
        internal ParamItem(string file, int line) : base(file, line)
        {
            msName = null;
            mGray = false;
        }

        /** Saves item into XML node.

            @param doc     Xml document.

            @return Xml node with item data in it.
        */
        public XmlNode ItemToXml(XmlDocument doc, IDefinitionList defs)
        {
            XmlNode paramNode = doc.CreateNode(XmlNodeType.Element, "param", "");
            XmlAttribute attr;

            attr = doc.CreateAttribute("name");
            attr.Value = msName;
            paramNode.Attributes.Append(attr);

            attr = doc.CreateAttribute("gray");
            attr.Value = mGray ? "true" : "false";
            paramNode.Attributes.Append(attr);

            DescriptionToXml(paramNode, doc, defs);

            return paramNode;
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
                        throw new ValueError(file, line, "param", sName, "(null)");
                    msName = sValue;
                    break;
                case "gray":
                    if (sValue == null)
                        throw new ValueError(file, line, "param", sName, "(null)");
                    mGray = (sValue == "yes");
                    break;
                case "if":
                    if (sValue == null)
                        throw new ValueError(file, line, "param", sName, "(null)");
                    mIf = sValue;
                    break;
                default:
                    throw new UnknownTagError(file, line, "param", sName);
            }
            return null;
        }
        /** Validate the content of the item.

            @exception EParseValidate   In case of validation is not successful
         */
        override internal void validate(string file, int line)
        {
            base.validate(file, line);
            string sAbsent = "";

            if (msName == null)
                sAbsent += " @name";

            if (sAbsent.Length > 0)
                throw new ValidationError(file, line, "param", sAbsent);
        }
    }

}
