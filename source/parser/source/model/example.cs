using System;
using System.Collections.Generic;
using System.Xml;

namespace GehtSoft.DocCreator.Parser
{

    public class ExampleTabItem : DocItem, IXmlItem, IConditionalItem
    {
        private string mTitle = "";
        private string mHighlight = null;
        private string mIf = null;

        public string If
        {
            get
            {
                return mIf;
            }
        }

        public ExampleTabItem(string file, int line) : base(file, line)
        {
            trim = false;
        }

        /** Saves item into XML node.

            @param doc     Xml document.

            @return Xml node with item data in it.
        */
        public XmlNode ItemToXml(XmlDocument doc, IDefinitionList defs)
        {
            XmlNode exampleNode = doc.CreateNode(XmlNodeType.Element, "example-tab", "");
            XmlAttribute attr;

            attr = doc.CreateAttribute("title");
            attr.Value = mTitle;
            exampleNode.Attributes.Append(attr);

            if (!string.IsNullOrEmpty(mHighlight))
            {
                attr = doc.CreateAttribute("highlight");
                attr.Value = mHighlight;
                exampleNode.Attributes.Append(attr);
            }

            DescriptionToXml(exampleNode, doc, defs);

            return exampleNode;
        }

        /** Append new named value into the object.

            @param sName            Name of the value
            @param sValue           Value
            @return                 New object (enclosed into this object) in case of
                                    named value creates new level of hierarchy
            @exception EParseVal    In case of the value is not acceptable in current context
          */
        internal override DocItem appendNamedValue(string sName, string sValue, string file, int line)
        {
            DocItem dt;

            if ((dt = base.appendNamedValue(sName, sValue, file, line)) != null)
                return dt;

            switch (sName)
            {
                case "title":
                    if (sValue == null)
                        throw new ValueError(file, line, "tab", sName, "(null)");
                    mTitle = sValue;
                    return null;
                case "highlight":
                    if (sValue == null)
                        throw new ValueError(file, line, "tab", sName, "(null)");
                    mHighlight = sValue;
                    return null;
                case "if":
                    if (sValue == null)
                        throw new ValueError(file, line, "tab", sName, "(null)");
                    mIf = sValue;
                    return null;
                default:
                    throw new UnknownTagError(file, line, "tab", sName);
            }
        }

        /** Validate the content of the item.

            @exception EParseValidate   In case of validation is not succesful
         */
        override internal void validate(string file, int line)
        {
            base.validate(file, line);
            if (mTitle == null)
                throw new ValidationError(file, line, "tab", "@title");
        }


    }

    /** The table. */
    public class ExampleItem : DocItem, IXmlItem, IConditionalItem
    {
        private string mTitle = "";
        private string mTransform = "def";      //if == "yes",
                                                // 1) the XML character (<, >, &) will be transformed into &lt;, &gt;, &amp;
                                                // 2) the formatting constructions [b], [/b], [i], [/i], [gray], [/gray],
                                                //    [red], [/red], [green], [/green], [blue], [/blue] will be transformed
                                                //    into HTML tags
        private string mShow = "no";            //yes or no, no by default
        private string mIf = null;
        private string mGray = "yes";
        private string mHighlight = null;
        private bool mTabs = false;
        private List<DocItem> maTabs;           //!< list of the see also items

        public string If
        {
            get
            {
                return mIf;
            }
        }

        public ExampleItem(string file, int line) : base(file, line)
        {
            trim = false;
        }

        /** Saves item into XML node.

            @param doc     Xml document.

            @return Xml node with item data in it.
        */
        public XmlNode ItemToXml(XmlDocument doc, IDefinitionList defs)
        {
            XmlNode exampleNode = doc.CreateNode(XmlNodeType.Element, "example", "");
            XmlAttribute attr;

            attr = doc.CreateAttribute("title");
            attr.Value = mTitle;
            exampleNode.Attributes.Append(attr);

            attr = doc.CreateAttribute("transform");
            attr.Value = mTransform;
            exampleNode.Attributes.Append(attr);

            attr = doc.CreateAttribute("show");
            attr.Value = mShow;
            exampleNode.Attributes.Append(attr);

            attr = doc.CreateAttribute("gray");
            attr.Value = mGray;
            exampleNode.Attributes.Append(attr);

            attr = doc.CreateAttribute("tabs");
            attr.Value = mTabs ? "true" : "false";
            exampleNode.Attributes.Append(attr);

            if (!string.IsNullOrEmpty(mHighlight))
            {
                attr = doc.CreateAttribute("highlight");
                attr.Value = mHighlight;
                exampleNode.Attributes.Append(attr);
            }

            if (mTabs)
                ItemsToXml(maTabs, exampleNode, doc, defs);
            else
                DescriptionToXml(exampleNode, doc, defs);

            return exampleNode;
        }

        /** Append new named value into the object.

            @param sName            Name of the value
            @param sValue           Value
            @return                 New object (enclosed into this object) in case of
                                    named value creates new level of hierarchy
            @exception EParseVal    In case of the value is not acceptable in current context
          */
        internal override DocItem appendNamedValue(string sName, string sValue, string file, int line)
        {
            DocItem dt;

            if ((dt = base.appendNamedValue(sName, sValue, file, line)) != null)
                return dt;

            switch (sName)
            {
                case "title":
                    if (sValue == null)
                        throw new ValueError(file, line, "example", sName, "(null)");
                    mTitle = sValue;
                    return null;
                case "transform":
                    if (sValue == null)
                        throw new ValueError(file, line, "example", sName, "(null)");
                    mTransform = sValue;
                    return null;
                case "show":
                    if (sValue == null)
                        throw new ValueError(file, line, "example", sName, "(null)");
                    mShow = sValue;
                    return null;
                case "if":
                    if (sValue == null)
                        throw new ValueError(file, line, "example", sName, "(null)");
                    mIf = sValue;
                    return null;
                case "gray":
                    if (sValue == null)
                        throw new ValueError(file, line, "example", sName, "(null)");
                    mGray = sValue;
                    return null;
                case "tabs":
                    if (sValue == null)
                        throw new ValueError(file, line, "example", sName, "(null)");
                    if (sValue == "yes")
                    {
                        mTabs = true;
                        maTabs = new List<DocItem>();
                    }
                    else
                    {
                        mTabs = false;
                    }
                    return null;
                case "tab":
                    {
                        ExampleTabItem item = new ExampleTabItem(file, line);
                        maTabs.Add(item);
                        return item;
                    }
                case "highlight":
                    if (sValue == null)
                        throw new ValueError(file, line, "example", sName, "(null)");
                    mHighlight = sValue;
                    return null;
                default:
                    throw new UnknownTagError(file, line, "example", sName);
            }
        }

        /** Append the line into description.

            @param sDescription     Another line of the description (e.g. line doesn't contain
                                    any information)
            @exception EParseDesc   In case of description is not acceptable in current context
          */
        override internal void appendDescription(string sDescription, string file, int line)
        {
            if (sDescription.Length > 0 && mTabs)
                throw new ParserError(file, line, "The text cannot be placed inside tabbed example");
            else
                base.appendDescription(sDescription, file, line);
        }


        /** Validate the content of the item.

            @exception EParseValidate   In case of validation is not succesful
         */
        override internal void validate(string file, int line)
        {
            base.validate(file, line);
            if (mTitle == null)
                throw new ValidationError(file, line, "example", "@title");
        }
    }
}
