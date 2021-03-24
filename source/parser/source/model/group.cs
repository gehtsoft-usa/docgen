using System;
using System.Collections.Generic;
using System.Xml;

namespace GehtSoft.DocCreator.Parser
{

    public class GroupItem : DocItem, IXmlItem, IConditionalItem
    {
        enum Order
        {
            Sorted, //!< the group should be placed into groups section.
            Custom  //!< the group should be placed in the same order as
                    //        it defined in .ds file. This is usefull when a big acticle
                    //        is divided into several smaller ones.
        };

        private string msTitle;                                            //!< title of the group
        private string msKey;                                              //!< key name of the group
        private string msBrief;                                            //!< brief description of the group
        private string msInGroup;                                          //!< group in group
        private string msSortArticles;                                     //!< do we need sort articles
        private string msSortGroups;                                       //!< do we need sort enclosed groups
        private string msSortClasses;                                      //!< do we need sort enclosed groups
        private List<DocItem> maSees;                                      //!< list of the see also items
        private string msIf;                                               //!< conditional
        private bool mBriefless = false;                                   //!< Have the Brief section?
        private Order mOrder;                                              //!< Group order
        private string mTransform = "def";
        private string mImportHHC = "";                                       //!< import native hhc subtree
        private string mImportHHK = "";                                       //!< import native hhk subtree

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
        internal GroupItem(string file, int line) : base(file, line)
        {
            msTitle = null;
            msKey = null;
            msBrief = null;
            msSortArticles = "no";
            msSortGroups = "no";
            msSortClasses = "yes";
            msInGroup = "index";
            maSees = new List<DocItem>();
            mOrder = Order.Sorted;
        }

        /** Saves item into XML node.

            @param doc     Xml document.

            @return Xml node with item data in it.
        */
        public XmlNode ItemToXml(XmlDocument doc, IDefinitionList defs)
        {
            XmlNode groupNode = doc.CreateNode(XmlNodeType.Element, "group", "");
            XmlAttribute attr;

            attr = doc.CreateAttribute("is-root");
            attr.Value = string.IsNullOrEmpty(msInGroup) ? "true" : "false";
            groupNode.Attributes.Append(attr);

            attr = doc.CreateAttribute("title");
            attr.Value = msTitle;
            groupNode.Attributes.Append(attr);

            attr = doc.CreateAttribute("key");
            attr.Value = msKey;
            groupNode.Attributes.Append(attr);

            attr = doc.CreateAttribute("brief");
            attr.Value = msBrief;
            groupNode.Attributes.Append(attr);

            attr = doc.CreateAttribute("in-group");
            attr.Value = msInGroup;
            groupNode.Attributes.Append(attr);

            attr = doc.CreateAttribute("sort-articles");
            attr.Value = msSortArticles;
            groupNode.Attributes.Append(attr);

            attr = doc.CreateAttribute("transform");
            attr.Value = mTransform;
            groupNode.Attributes.Append(attr);


            attr = doc.CreateAttribute("sort-groups");
            attr.Value = msSortGroups;
            groupNode.Attributes.Append(attr);

            attr = doc.CreateAttribute("sort-classes");
            attr.Value = msSortClasses;
            groupNode.Attributes.Append(attr);

            attr = doc.CreateAttribute("import-hhc");
            attr.Value = mImportHHC;
            groupNode.Attributes.Append(attr);
            attr = doc.CreateAttribute("import-hhk");
            attr.Value = mImportHHK;
            groupNode.Attributes.Append(attr);

            attr = doc.CreateAttribute("briefless");
            attr.Value = mBriefless ? "true" : "false";
            groupNode.Attributes.Append(attr);

            attr = doc.CreateAttribute("order");
            switch (mOrder)
            {
                case Order.Custom:
                    attr.Value = "custom";
                    break;
                case Order.Sorted:
                default:
                    attr.Value = "sorted";
                    break;
            }
            groupNode.Attributes.Append(attr);

            DescriptionToXml(groupNode, doc, defs);

            ItemsToXml(maSees, groupNode, doc, defs);

            return groupNode;
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
                    if (sValue == null)
                        throw new ValueError(file, line, "group", sName, "(null)");
                    msTitle = sValue;
                    return null;
                case "brief":
                    if (sValue == null)
                        throw new ValueError(file, line, "group", sName, "(null)");
                    msBrief = sValue;
                    mBriefless = sValue.Trim().Length == 0;
                    return null;
                case "ingroup":
                    if (sValue == null)
                        throw new ValueError(file, line, "group", sName, "(null)");
                    msInGroup = sValue;
                    return null;
                case "importhhc":
                    if (sValue == null)
                        throw new ValueError(file, line, "group", sName, "(null)");
                    mImportHHC = sValue;
                    return null;
                case "importhhk":
                    if (sValue == null)
                        throw new ValueError(file, line, "group", sName, "(null)");
                    mImportHHK = sValue;
                    return null;
                case "sortarticles":
                    if (sValue == null)
                        throw new ValueError(file, line, "group", sName, "(null)");
                    if (sValue != "yes" && sValue != "no")
                        throw new ValueError(file, line, "group", sName, sValue);
                    msSortArticles = sValue;
                    return null;
                case "sortgroups":
                    if (sValue == null)
                        throw new ValueError(file, line, "group", sName, "(null)");
                    msSortGroups = sValue;
                    return null;
                case "sortclasses":
                    if (sValue == null)
                        throw new ValueError(file, line, "group", sName, "(null)");
                    msSortClasses = sValue;
                    return null;
                case "key":
                    if (sValue == null)
                        throw new ValueError(file, line, "group", sName, "(null)");
                    msKey = sValue;
                    return null;
                case "if":
                    if (sValue == null)
                        throw new ValueError(file, line, "group", sName, "(null)");
                    msIf = sValue;
                    return null;
                case "order":
                    if (sValue == null)
                        throw new ValueError(file, line, "group", sName, "(null)");
                    switch (sValue)
                    {
                        case "sorted":
                            mOrder = Order.Sorted;
                            return null;
                        case "custom":
                            mOrder = Order.Custom;
                            return null;
                        default:
                            throw new ValueError(file, line, "group", sName, sValue);
                    }
                case "transform":
                    if (sValue == null)
                        throw new ValueError(file, line, "group", sName, "(null)");
                    mTransform = sValue;
                    return null;
                default:
                    throw new UnknownTagError(file, line, "group", sName);
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
                throw new ValidationError(file, line, "group", sAbsent);
        }


    }

}
