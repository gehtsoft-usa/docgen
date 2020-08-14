using System;
using System.Collections.Generic;
using System.Xml;

namespace GehtSoft.DocCreator.Parser
{

    [System.Diagnostics.DebuggerDisplay("MemberItem({msName})")]
    /** Description of the method. */
    public class MemberItem : DocItem, IConditionalItem, IXmlItem
    {
        private string msName;                   //!< name of the proprty
        private string msVisibility;             //!< visiblity of the property (public, protected)
        private string msScope;                  //!< scope of the property (class, instance)
        private string msBrief;                  //!< brief description of the property
        private string msKey;                    //!< alternative key of the method (for the methods with the same names)
        private string msType;                   //!< type of member (field | property | method | constructor)
        private string msCustom;                 //!< custom type of the member
        private List<string> maSig;              //!< class signature(s)
        private string msIf;                     //!< conditional
        private string msDivisor;                //!< divisor
        private bool mbExcludeFromList;          //!< is this member should be exluded from the members list
        private string mTransform = "def";
        private ReturnItem mReturn;              //!< return item
        private List<DocItem> maSees;        //!< list of see also
        private List<DocItem> maEx;        //!< list of exceptions
        private List<DocItem> maParams;        //!< list of the parameters
        private List<DocItem> maDecls;   //!< language-depended declarations
        private List<string> maIndexKeys;      //!< index keys
        private ClassItem mClass;

        public string Type
        {
            get
            {
                return msType;
            }
        }

        public string Name
        {
            get
            {
                return msName;
            }
        }

        public string Key
        {
            get
            {
                return msKey;
            }
        }

        public string If
        {
            get
            {
                return msIf;
            }
        }

        /** Constructor. */
        internal MemberItem(ClassItem cls, string file, int line) : base(file, line)
        {
            mClass = cls;
            msName = null;
            msVisibility = "public";
            msScope = "instance";
            msBrief = null;
            msType = "method";
            msCustom = "";
            msDivisor = ".";
            mbExcludeFromList = false;
            mReturn = new ReturnItem(file, line);
            msKey = null;
            maSees = new List<DocItem>();
            maEx = new List<DocItem>();
            maParams = new List<DocItem>();
            maDecls = new List<DocItem>();
            maIndexKeys = new List<string>();
            maSig = new List<string>();
        }

        /** Saves item into XML node.

            @param doc     Xml document.

            @return Xml node with item data in it.
        */
        public XmlNode ItemToXml(XmlDocument doc, IDefinitionList defs)
        {
            XmlNode memberNode = doc.CreateNode(XmlNodeType.Element, "member", "");
            XmlAttribute attr;

            attr = doc.CreateAttribute("name");
            attr.Value = msName;
            memberNode.Attributes.Append(attr);

            attr = doc.CreateAttribute("visibility");
            attr.Value = msVisibility;
            memberNode.Attributes.Append(attr);

            attr = doc.CreateAttribute("scope");
            attr.Value = msScope;
            memberNode.Attributes.Append(attr);

            attr = doc.CreateAttribute("brief");
            attr.Value = msBrief;
            memberNode.Attributes.Append(attr);

            attr = doc.CreateAttribute("key");
            attr.Value = msKey;
            memberNode.Attributes.Append(attr);

            attr = doc.CreateAttribute("type");
            attr.Value = msType;
            memberNode.Attributes.Append(attr);

            attr = doc.CreateAttribute("transform");
            attr.Value = mTransform;
            memberNode.Attributes.Append(attr);

            attr = doc.CreateAttribute("custom");
            attr.Value = msCustom;
            memberNode.Attributes.Append(attr);

            attr = doc.CreateAttribute("divisor");
            attr.Value = msDivisor;
            memberNode.Attributes.Append(attr);

            attr = doc.CreateAttribute("class");
            attr.Value = mClass.Key;
            memberNode.Attributes.Append(attr);

            attr = doc.CreateAttribute("class-name");
            attr.Value = mClass.Name;
            memberNode.Attributes.Append(attr);

            attr = doc.CreateAttribute("exclude-from-list");
            attr.Value = mbExcludeFromList ? "true" : "false";
            memberNode.Attributes.Append(attr);

            DescriptionToXml(memberNode, doc, defs);

            memberNode.AppendChild(mReturn.ItemToXml(doc, defs));

            ItemsToXml(maSees, memberNode, doc, defs);
            ItemsToXml(maEx, memberNode, doc, defs);
            ItemsToXml(maParams, memberNode, doc, defs);
            ItemsToXml(maDecls, memberNode, doc, defs);

            StringsToXml(maSig, memberNode, doc, "sig");
            StringsToXml(maIndexKeys, memberNode, doc, "index-key");
            return memberNode;
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
                case "see":
                    {
                        SeeAlsoItem item = new SeeAlsoItem(file, line);
                        maSees.Add(item);
                        return item;
                    }
                case "exception":
                    {
                        ExceptionItem item = new ExceptionItem(file, line);
                        maEx.Add(item);
                        return item;
                    }
                case "declaration":
                    {
                        DeclarationItem item = new DeclarationItem(msName, file, line);
                        maDecls.Add(item);
                        return item;
                    }
                case "param":
                    {
                        ParamItem item = new ParamItem(file, line);
                        maParams.Add(item);
                        return item;
                    }
                case "name":
                    if (sValue == null)
                        throw new ValueError(file, line, "member", sName, "(null)");
                    msName = sValue;
                    return null;
                case "sig":
                    if (sValue == null)
                        throw new ValueError(file, line, "member", sName, "(null)");
                    maSig.Add(sValue);
                    return null;
                case "visibility":
                    if (sValue == null)
                        throw new ValueError(file, line, "member", sName, "(null)");
                    if (sValue != "public" && sValue != "protected" && sValue != "package" && sValue != "private")
                        throw new ValueError(file, line, "member", sName, sValue, "The value must be public, protected, package or private.");
                    msVisibility = sValue;
                    return null;
                case "scope":
                    if (sValue == null)
                        throw new ValueError(file, line, "member", sName, "(null)");
                    if (sValue != "class" && sValue != "instance")
                        throw new ValueError(file, line, "member", sName, sValue, "The value must be class or instance.");
                    msScope = sValue;
                    return null;
                case "brief":
                    if (sValue == null)
                        throw new ValueError(file, line, "member", sName, "(null)");
                    msBrief = sValue;
                    return null;
                case "return":
                    mReturn = new ReturnItem(file, line);
                    return mReturn;
                case "type":
                    if (sValue == null)
                        throw new ValueError(file, line, "member", sName, "(null)");
                    if (sValue != "property" && sValue != "method" && sValue != "constructor" && sValue != "field" && sValue != "function")
                        throw new ValueError(file, line, "member", sName, sValue, "The value must be property, method, constructor of field.");
                    msType = sValue;
                    return null;
                case "key":
                    if (sValue == null)
                        throw new ValueError(file, line, "member", sName, "(null)");
                    msKey = sValue;
                    return null;
                case "divisor":
                    if (sValue == null)
                        throw new ValueError(file, line, "member", sName, "(null)");
                    msDivisor = sValue;
                    return null;
                case "custom":
                    if (sValue == null)
                        throw new ValueError(file, line, "member", sName, "(null)");
                    msCustom = sValue;
                    return null;
                case "if":
                    if (sValue == null)
                        throw new ValueError(file, line, "member", sName, "(null)");
                    msIf = sValue;
                    return null;
                case "excludeFromList":
                    if (sValue == null)
                        throw new ValueError(file, line, "member", sName, "(null)");
                    if (sValue != "yes" && sValue != "no")
                        throw new ValueError(file, line, "member", sName, sValue, "The value must be yes or no.");
                    mbExcludeFromList = sValue == "yes";
                    return null;
                case "index":
                    if (sValue == null)
                        throw new ValueError(file, line, "member", sName, "(null)");
                    maIndexKeys.Add(sValue);
                    return null;
                case "transform":
                    if (sValue == null)
                        throw new ValueError(file, line, "member", sName, "(null)");
                    mTransform = sValue;
                    return null;
                default:
                    throw new UnknownTagError(file, line, "method", sName);
            }
        }

        /** Validate the content of the item.

            @exception EParseValidate   In case of validation is not succesful
         */
        override internal void validate(string file, int line)
        {
            base.validate(file, line);
            string sAbsent = "";

            if (msName == null)
                sAbsent += " @name";
            if (msBrief == null)
                sAbsent += " @brief";


            if (sAbsent.Length > 0)
                throw new ValidationError(file, line, "method", sAbsent);

            if (msKey == null)
                msKey = msName;
        }
    }


}
