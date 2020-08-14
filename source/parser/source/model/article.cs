using System;
using System.Collections.Generic;
using System.Xml;

namespace GehtSoft.DocCreator.Parser
{

    /** Description of the article. */
    public class ArticleItem : DocItem, IXmlItem, IConditionalItem
    {
        private string msTitle;              //!< title of article
        private string msKey;                //!< key name of article
        private string msInGroup;            //!< reference to group where article is located
        private string msBrief;              //!< brief description of the article
        private string msIf;                 //!< conditional
        private List<DocItem> maSees;        //!< list of the see also items
        private string msAliasId;            //!< associated context-help identifier. Can be null.
        private bool mbExcludeFromList;      //!< is this member should be exluded from the members list
        private bool mBriefless = false;                                   //!< Have the Brief section?
        private string mTransform = "def";

        public string Title
        {
            get
            {
                return msTitle;
            }
        }

        public string Key
        {
            get
            {
                return msKey;
            }
        }

        public string InGroup
        {
            get
            {
                return msInGroup;
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
        public ArticleItem(string file, int line) : base(file, line)
        {
            msTitle = null;
            msKey = null;
            msInGroup = "index";
            msBrief = null;
            maSees = new List<DocItem>();
            msAliasId = null;
            mbExcludeFromList = false;
        }

        /** Saves item into XML node.

            @param doc     Xml document.

            @return Xml node with item data in it.
        */
        public XmlNode ItemToXml(XmlDocument doc, IDefinitionList defs)
        {
            XmlNode articleNode = doc.CreateNode(XmlNodeType.Element, "article", "");
            XmlAttribute attr;

            attr = doc.CreateAttribute("title");
            attr.Value = msTitle;
            articleNode.Attributes.Append(attr);

            attr = doc.CreateAttribute("key");
            attr.Value = msKey;
            articleNode.Attributes.Append(attr);

            attr = doc.CreateAttribute("in-group");
            attr.Value = msInGroup;
            articleNode.Attributes.Append(attr);

            attr = doc.CreateAttribute("brief");
            attr.Value = msBrief;
            articleNode.Attributes.Append(attr);

            attr = doc.CreateAttribute("transform");
            attr.Value = mTransform;
            articleNode.Attributes.Append(attr);


            attr = doc.CreateAttribute("alias-id");
            attr.Value = msAliasId != null ? msAliasId : "null";
            articleNode.Attributes.Append(attr);

            attr = doc.CreateAttribute("exclude-from-list");
            attr.Value = mbExcludeFromList ? "true" : "false";
            articleNode.Attributes.Append(attr);

            attr = doc.CreateAttribute("briefless");
            attr.Value = mBriefless ? "true" : "false";
            articleNode.Attributes.Append(attr);


            DescriptionToXml(articleNode, doc, defs);

            ItemsToXml(maSees, articleNode, doc, defs);
            return articleNode;
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
                case "title":
                    msTitle = sValue;
                    return null;
                case "ingroup":
                    msInGroup = sValue;
                    return null;
                case "brief":
                    msBrief = sValue;
                    mBriefless = sValue.Trim().Length == 0;
                    return null;
                case "key":
                    msKey = sValue;
                    return null;
                case "if":
                    msIf = sValue;
                    return null;
                case "aliasId":
                    msAliasId = sValue;
                    return null;
                case "excludeFromList":
                    if (sValue != "yes" && sValue != "no")
                        throw new ValueError(file, line, "article", sName, sValue);
                    mbExcludeFromList = sValue == "yes";
                    return null;
                case "transform":
                    mTransform = sValue;
                    return null;
                default:
                    throw new UnknownTagError(file, line, "article", sName);
            }
        }

        /** Validate the content of the item.

            @exception EParseValidate   In case of validation is not succesful
         */
        override internal void validate(string file, int line)
        {
            base.validate(file, line);
            string sAbsent = "";
            if (msTitle == null)
                sAbsent += " @title";
            if (msKey == null)
                sAbsent += " @key";
            if (msBrief == null)
                sAbsent += " @brief";

            if (sAbsent.Length > 0)
                throw new ValidationError(file, line, "article", sAbsent);
        }
    }
}
