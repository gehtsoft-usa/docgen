using System;
using System.Collections.Generic;
using System.Xml;

namespace GehtSoft.DocCreator.Parser
{

    /** Description of the article. */
    public class DeclarationItem : DocItem, IConditionalItem, IXmlItem
    {
        private string msLanguage;
        private string msName;
        private string msPrefix;
        private string msSuffix;
        private string msNameSuffix;
        private string msReturn;
        private string msParams;
        private string msIf;                 //!< conditional
        private string msCustom = "";        //!< conditional

        public string If
        {
            get
            {
                return msIf;
            }
        }

        /** Constructor. */
        internal DeclarationItem(string name, string file, int line) : base(file, line)
        {
            msName = name;
            msLanguage = null;
            msPrefix = "";
            msSuffix = "";
            msNameSuffix = "";
            msReturn = "";
            msParams = "";
        }

        /** Saves item into XML node.

            @param doc     Xml document.

            @return Xml node with item data in it.
        */
        public XmlNode ItemToXml(XmlDocument doc, IDefinitionList defs)
        {
            XmlNode declarationNode = doc.CreateNode(XmlNodeType.Element, "declaration", "");
            XmlAttribute attr;

            attr = doc.CreateAttribute("language");
            attr.Value = msLanguage;
            declarationNode.Attributes.Append(attr);

            attr = doc.CreateAttribute("name");
            attr.Value = msName;
            declarationNode.Attributes.Append(attr);

            attr = doc.CreateAttribute("prefix");
            attr.Value = msPrefix;
            declarationNode.Attributes.Append(attr);

            attr = doc.CreateAttribute("suffix");
            attr.Value = msSuffix;
            declarationNode.Attributes.Append(attr);

            attr = doc.CreateAttribute("name-suffix");
            attr.Value = msNameSuffix;
            declarationNode.Attributes.Append(attr);

            attr = doc.CreateAttribute("return");
            attr.Value = msReturn;
            declarationNode.Attributes.Append(attr);

            attr = doc.CreateAttribute("params");
            attr.Value = msParams;
            declarationNode.Attributes.Append(attr);

            attr = doc.CreateAttribute("custom");
            attr.Value = msCustom;
            declarationNode.Attributes.Append(attr);

            DescriptionToXml(declarationNode, doc, defs);

            return declarationNode;
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
                case "language":
                    if (sValue == null)
                        throw new ValueError(file, line, "declaration", sName, "(null)");
                    msLanguage = sValue;
                    return null;
                case "name":
                    if (sValue == null)
                        throw new ValueError(file, line, "declaration", sName, "(null)");
                    msName = sValue;
                    return null;
                case "prefix":
                    if (sValue == null)
                        throw new ValueError(file, line, "declaration", sName, "(null)");
                    msPrefix = sValue;
                    return null;
                case "custom":
                    if (sValue == null)
                        throw new ValueError(file, line, "declaration", sName, "(null)");
                    msCustom = sValue;
                    return null;
                case "suffix":
                    if (sValue == null)
                        throw new ValueError(file, line, "declaration", sName, "(null)");
                    msSuffix = sValue;
                    return null;
                case "name-suffix":
                    if (sValue == null)
                        throw new ValueError(file, line, "declaration", sName, "(null)");
                    msNameSuffix = sValue;
                    return null;
                case "params":
                    if (sValue == null)
                        throw new ValueError(file, line, "declaration", sName, "(null)");
                    msParams = sValue;
                    return null;
                case "return":
                    if (sValue == null)
                        throw new ValueError(file, line, "declaration", sName, "(null)");
                    msReturn = sValue;
                    return null;
                case "if":
                    if (sValue == null)
                        throw new ValueError(file, line, "declaration", sName, "(null)");
                    msIf = sValue;
                    return null;
                default:
                    throw new UnknownTagError(file, line, "declaration", sName);
            }
        }

        /** Validate the content of the item.

            @exception EParseValidate   In case of validation is not succesful
         */
        override internal void validate(string file, int line)
        {
            base.validate(file, line);

            string sAbsent = "";

            if (msLanguage == null)
                sAbsent += " @language";

            if (sAbsent.Length > 0)
                throw new ValidationError(file, line, "declaration", sAbsent);
        }


    }


}
