using System;
using System.Collections.Generic;
using System.Xml;
using System.Text;
using System.Text.RegularExpressions;

namespace GehtSoft.DocCreator.Output
{
    /** On bb-coded element. */
    internal class BBElement
    {
        /** type of the element:
            r       root (subtree)
            t       plain text (arg)
            b       bold (subtree)
            i       italic (subtree)
            u       undeline (subtree)
            s       strike trough (subtree)
            c       code (subtree)
            sup     super index (subtree)
            sub     sub index (subtree)
            size    increase font size (arg) (subtree)
            red     color: red (subtree)
            green   color: green (subtree)
            blue    color: blue (subtree)
            gray    color: gray (subtree)
            color   specified color (arg) (subtree)
            link    link to (arg) (subtree)
            clink   link + code (arg) (subtree)
            url     external reference (arg) (subtree)
            eurl     external reference (arg) (subtree)
            img     image (arg)
            var     replace with defined value (arg)
            br
            nil     nil-tag (no close)

         */
        private string mType;
        private string mArg;
        private List<BBElement> mElements = new List<BBElement>();

        public string Type
        {
            get
            {
                return mType;
            }
        }


        /** Constructor. */
        public BBElement(string type, string arg)
        {
            mType = type;
            if (arg != null && arg.Length > 0)
                mArg = arg;
        }

        /** Add an element to the tree. */
        public void Add(BBElement element)
        {
            mElements.Add(element);
        }

        /** write element as an XML node. */
        public XmlNode toXML(XmlDocument doc)
        {
            XmlNode node = doc.CreateNode(XmlNodeType.Element, mType, "");
            XmlAttribute attr;

            if (mType == "t")
            {
                XmlNode content = doc.CreateNode(XmlNodeType.CDATA, "", "");
                content.Value = mArg;
                node.AppendChild(content);
                return node;
            }
            else if (mArg != null)
            {
                attr = doc.CreateAttribute("attr");
                attr.Value = mArg;
                node.Attributes.Append(attr);
            }

            foreach (BBElement element in mElements)
                node.AppendChild(element.toXML(doc));
            return node;
        }
    }

    /** Root element of the bbcoded string. */
    internal class BBRootElement : BBElement
    {
        /** Constructor. */
        public BBRootElement() : base("r", null)
        {
        }

        public XmlDocument toXML()
        {
            XmlDocument doc = new XmlDocument();
            doc.AppendChild(toXML(doc));
            return doc;
        }
    }


    /** Exception during the compilation. */
    internal class BBCompileException : Exception
    {
        string mError;

        public string Error
        {
            get
            {
                return mError;
            }
        }

        public BBCompileException(string error, string text) : base(String.Format("bbcode error: {0} compiling text:\n'{1}'", error, text))
        {
            mError = error;
        }
    }


    /** Parses a text into BB-coded element(s). */
    internal class BBCompile
    {
        static Regex mRe = null;

        BBRootElement mRoot = new BBRootElement();
        List<BBElement> mStack = new List<BBElement>();

        public BBRootElement Root
        {
            get
            {
                return mRoot;
            }
        }

        /** Constructor. */
        public BBCompile()
        {
            if (mRe == null)
                mRe = new Regex("(?'pre'.*)(?'wholetag'\\[(?'close'\\/?)(?'tag'nil|b|i|u|s|c|sup|sub|size|red|eurl|url|green|blue|gray|color|link|clink|img|br|var)(=(?'value'[^\\]]+))?\\])(?'post'.*)?");
            mStack.Add(mRoot);
        }

        static string[] mSplit = { "\r\n", "\r", "\n" };

        /** Compile a string. */
        public void Compile(string text)
        {
            string[] split = text.Split(mSplit, StringSplitOptions.None);
            for (int i = 0; i < split.Length; i++)
            {
                string _text = split[i];
                Match m = mRe.Match(_text);
                if (!m.Success)
                {
                    if (_text.Length > 0)
                    {
                        //there is no tag inside the specified text
                        mStack[mStack.Count - 1].Add(new BBElement("t", _text));
                    }
                }
                else
                {   //there is a tag inside the specified text
                    //1. compile the text prior the tag
                    try
                    {
                        if (m.Groups["pre"].Value != null && m.Groups["pre"].Value.Length > 0)
                            Compile(m.Groups["pre"].Value);
                    }
                    catch (BBCompileException e)
                    {
                        throw new BBCompileException(e.Error, text);
                    }

                    if (m.Groups["close"].Value != null && m.Groups["close"].Value.Length > 0)
                    {
                        //tag is closing tag
                        if (mStack[mStack.Count - 1].Type != m.Groups["tag"].Value)
                            throw new BBCompileException("Closing tag " + m.Groups["wholetag"].Value + " is not balanced. Current open tag is " + mStack[mStack.Count - 1].Type, text);
                        mStack.RemoveAt(mStack.Count - 1);
                    }
                    else
                    {
                        //tag is open tag
                        BBElement element = new BBElement(m.Groups["tag"].Value, m.Groups["value"].Value);
                        mStack[mStack.Count - 1].Add(element);
                        if (m.Groups["tag"].Value != "img" &&
                            m.Groups["tag"].Value != "br" &&
                            m.Groups["tag"].Value != "var" &&
                            m.Groups["tag"].Value != "nil")
                            mStack.Add(element);
                    }

                    //3. compile the text prior past the tag
                    try
                    {
                        if (m.Groups["post"].Value != null && m.Groups["post"].Value.Length > 0)
                            Compile(m.Groups["post"].Value);
                    }
                    catch (BBCompileException e)
                    {
                        throw new BBCompileException(e.Error, text);
                    }
                }
                if (i != split.Length - 1)
                    mStack[mStack.Count - 1].Add(new BBElement("t", "\r\n"));
            }
        }
    }
}

