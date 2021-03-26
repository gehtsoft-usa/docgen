using System;
using System.IO;
using System.Xml;
using System.Text;
using System.Text.RegularExpressions;
using System.Globalization;
using System.Xml.XPath;
using System.Xml.Xsl;
using System.Collections;
using System.Collections.Generic;
using System.Net;

namespace GehtSoft.DocCreator.Output
{
    internal class XsltExtensionObject
    {
        protected Dictionary<string, object> mVariables;
        protected Dictionary<string, object> mCaller;
        protected Dictionary<string, object> mProps;
        protected Dictionary<string, object> mGlobal;

        public XsltExtensionObject(Dictionary<string, object> props, Dictionary<string, object> global)
        {
            mVariables = new Dictionary<string, object>();
            mCaller = null;
            mGlobal = global;
            mProps = props;
        }

        public XsltExtensionObject(XsltExtensionObject caller)
        {
            mVariables = new Dictionary<string, object>();
            mCaller = caller.mVariables;
            mGlobal = caller.mGlobal;
            mProps = caller.mProps;
        }

        public XPathNodeIterator document(string name)
        {
            name = FindName(name);
            XmlDocument document = new XmlDocument();
            XmlReaderSettings settings = new XmlReaderSettings();
            settings.ConformanceLevel = ConformanceLevel.Document;
            XmlReader reader = XmlReader.Create(name, settings);
            document.Load(reader);
            reader.Close();
            return (document.CreateNavigator().Select("/"));
        }

        public void let(string name, object value)
        {
            mVariables[name] = value;
        }

        public void letglobal(string name, object value)
        {
            mGlobal[name] = value;
        }

        public void remove(string name)
        {
            mVariables.Remove(name);
        }

        public void removeglobal(string name)
        {
            mGlobal.Remove(name);
        }

        public object get(string name)
        {
            object value;
            if (mVariables.TryGetValue(name, out value))
                return value;
            else
                if (mProps.TryGetValue(name, out value))
                    return value;
                else if (mGlobal.TryGetValue(name, out value))
                    return value;
                else
                {
                    Console.WriteLine("trace: {0}:=null", name);
                    return null;
                }
        }

        public object get(string name, object def)
        {
            object value;
            if (mVariables.TryGetValue(name, out value))
                return value;
            else
                if (mProps.TryGetValue(name, out value))
                    return value;
                else if (mGlobal.TryGetValue(name, out value))
                    return value;
                else
                    return def;
        }

        public bool exist(string name)
        {
            object value;
            if (mVariables.TryGetValue(name, out value))
                return true;
            else if (mProps.TryGetValue(name, out value))
                return true;
            else if (mGlobal.TryGetValue(name, out value))
                return true;
            else if (mCaller != null && mCaller.TryGetValue(name, out value))
                return true;
            else
                return false;
        }

        public object caller(string name)
        {
            object value;
            if (mCaller != null && mCaller.TryGetValue(name, out value))
                return value;
            else
            {
                Console.WriteLine("trace: {0}:=null", name);
                return null;
            }
        }

        public string call(string xslt, IXPathNavigable doc)
        {
            xslt = FindName(xslt);
            StringBuilder output = new StringBuilder();
            XsltTransform.Transform(xslt, doc, output, "utf-8", this);
            return output.ToString();
        }

        public string call(string xslt, IXPathNavigable doc, string codepage)
        {
            xslt = FindName(xslt);
            StringBuilder output = new StringBuilder();
            XsltTransform.Transform(xslt, doc, output, codepage, this);
            return output.ToString();
        }

        public void call(string xslt, IXPathNavigable doc, string output, string codepage)
        {
            xslt = FindName(xslt);
            if (mProps.ContainsKey("base-output-path"))
                output = Path.Combine((string)mProps["base-output-path"], output);
            XsltTransform.Transform(xslt, doc, output, codepage, this);
        }

        public void trace(string output)
        {
            Console.WriteLine("{0}", output);
        }

        public void error(string message)
        {
            throw new Exception(message);
        }

        Dictionary<string, Regex> mRegExs = new Dictionary<string, Regex>();

        public bool match(string pattern, string text)
        {
            Regex re;
            if (!mRegExs.TryGetValue(pattern, out re))
            {
                re = new Regex(pattern);
                mRegExs[pattern] = re;
            }
            return re.IsMatch(text);
        }

        /** The xml tree for matches result. */
        internal class Matches : XmlDocument
        {
            internal Matches(Match m)
            {
                LoadXml("<result/>");
                XmlNode root = DocumentElement;
                int cc = 0;
                XmlNode m1, m2, t;
                while (m.Success)
                {
                    cc++;
                    m1 = CreateNode("element", "match", "");
                    t = CreateNode("text", "", "");
                    t.Value = m.Groups[0].Value;
                    m1.AppendChild(t);
                    for(int i = 1; i < m.Groups.Count; i++)
                    {
                        Group group = m.Groups[i];
                        m2 = CreateNode("element", "group", "");
                        t = CreateNode("text", "", "");
                        t.Value = group.Value;
                        m2.AppendChild(t);
                        m1.AppendChild(m2);
                    }
                    root.AppendChild(m1);
                    m = m.NextMatch();
                }
                XmlAttribute attr = CreateAttribute("count");
                attr.Value = cc.ToString();
                root.Attributes.Append(attr);
            }
        }

        public XPathNodeIterator parse(string pattern, string text)
        {
            Regex re;
            if (!mRegExs.TryGetValue(pattern, out re))
            {
                re = new Regex(pattern);
                mRegExs[pattern] = re;
            }
            Match m = re.Match(text);
            return (new Matches(m)).CreateNavigator().Select("/");
        }

        static protected Dictionary<string, XmlDocument> mDynDocs = new Dictionary<string, XmlDocument>();
        static protected Dictionary<int, XmlNode> mDynDocsTagId = new Dictionary<int, XmlNode>();
        static int mTagId = -1;
        static object mMutex = new object();

        public int xmlcreate(string docname, string rootelement)
        {
            lock (mMutex)
            {
                XmlDocument doc;
                XmlNode node;
                doc = new XmlDocument();
                node = doc.CreateNode(XmlNodeType.Element, rootelement, "");
                ++mTagId;
                mDynDocsTagId[mTagId] = node;
                mDynDocs[docname] = doc;
                doc.AppendChild(node);
                return mTagId;
            }
        }

        public XPathNodeIterator xmlgetdocument(string name)
        {
            lock (mMutex)
            {
                XmlDocument document;
                if (mDynDocs.TryGetValue(name, out document))
                    return document.CreateNavigator().Select("/");
                else
                    throw new Exception("There is no dynamic document");
            }
        }

        public XPathNodeIterator parsebbcode(string text)
        {
            BBCompile c = new BBCompile();
            c.Compile(text);
            return c.Root.toXML().CreateNavigator().Select("/");
        }

        public int xmladdelement(string docname, int parent, string element)
        {
            lock (mMutex)
            {
                XmlDocument document = null;
                if (!mDynDocs.TryGetValue(docname, out document))
                    throw new Exception("There is no dynamic document with name:" + docname);
                XmlNode node = null;
                if (!mDynDocsTagId.TryGetValue(parent, out node))
                    throw new Exception("There is no specified tag");
                XmlNode child = document.CreateNode(XmlNodeType.Element, element, "");
                ++mTagId;
                mDynDocsTagId[mTagId] = child;
                node.AppendChild(child);
                return mTagId;
            }
        }

        public void xmladdtext(string docname, int parent, string text)
        {
            lock (mMutex)
            {
                XmlDocument document = null;
                if (!mDynDocs.TryGetValue(docname, out document))
                    throw new Exception("There is no dynamic document with name:" + docname);
                XmlNode node = null;
                if (!mDynDocsTagId.TryGetValue(parent, out node))
                    throw new Exception("There is no specified tag");
                XmlNode child = document.CreateNode(XmlNodeType.Text, "", "");
                child.Value = text;
                node.AppendChild(child);
            }
        }

        public void xmladdcdata(string docname, int parent, string text)
        {
            lock (mMutex)
            {
                XmlDocument document = null;
                if (!mDynDocs.TryGetValue(docname, out document))
                    throw new Exception("There is no dynamic document with name:" + docname);
                XmlNode node = null;
                if (!mDynDocsTagId.TryGetValue(parent, out node))
                    throw new Exception("There is no specified tag");
                XmlNode child = document.CreateNode(XmlNodeType.CDATA, "", "");
                child.Value = text;
                node.AppendChild(child);
            }
        }

        public void xmladdattribute(string docname, int parent, string name, string value)
        {
            lock (mMutex)
            {
                XmlDocument document = null;
                if (!mDynDocs.TryGetValue(docname, out document))
                    throw new Exception("There is no dynamic document with name:" + docname);
                XmlNode node = null;
                if (!mDynDocsTagId.TryGetValue(parent, out node))
                    throw new Exception("There is no specified tag");
                XmlAttribute attr = document.CreateAttribute(name);
                attr.Value = value;
                node.Attributes.Append(attr);
            }
        }

        public int strcmp(string s1, string s2)
        {
            return string.Compare(s1, s2);
        }

        public int stricmp(string s1, string s2)
        {
            return string.Compare(s1, s2, true);
        }

        public string tostring(object x)
        {
            return x.ToString();
        }

        public string upper(string x)
        {
            return x.ToUpper();
        }

        public string lower(string x)
        {
            return x.ToLower();
        }

        public string removehtml(string text)
        {
            StringBuilder res = new StringBuilder();
            StringBuilder temp = null;
            int mode = 0;       //0 == plain text
                                //1 == inside the tag <>
                                //2 == inside the tag []
            int i;
            for (i = 0; i < text.Length; i++)
            {
                switch (mode)
                {
                case    0:
                        if (text[i] == '<')
                        {
                            temp = new StringBuilder();
                            mode = 1;
                        }
                        else if (text[i] == '[')
                        {
                            temp = new StringBuilder();
                            mode = 2;
                        }
                        else
                            res.Append(text[i]);
                        break;
                case    1:
                        if (text[i] == '>')
                        {
                            mode = 0;
                            temp = null;
                        }
                        else if (text[i] == '<')
                        {
                            res.Append("&lt;");
                            res.Append(temp);
                            temp = new StringBuilder();
                        }
                        else if (text[i] == '[')
                        {
                            res.Append("&lt;");
                            res.Append(temp);
                            temp = new StringBuilder();
                            mode = 2;
                        }
                        else
                            temp.Append(text[i]);
                        break;
                case    2:
                        if (text[i] == ']')
                        {
                            mode = 0;
                            temp = null;
                        }
                        else
                            temp.Append(text[i]);
                        break;
                }
            }
            if (mode == 1 || mode == 2)
            {
                res.Append("&lt;");
                res.Append(temp);
            }
            return res.ToString();
        }

        public string replaceentity(string text)
        {
            string tmp = text.Replace("&&", "&amp;").Replace("<", "&lt;").Replace(">", "&gt;").Replace("\"", "&quot;");
            return tmp;
        }

        public string replace(string text, string pattern, string value)
        {
            return text.Replace(pattern, value);
        }

        public void registerlink(string link)
        {
            object _links = null;
            Dictionary<string, bool> links = null;
            if (mGlobal.TryGetValue("$$linkdict", out _links))
                links = _links as Dictionary<string, bool>;
            if (links == null)
            {
                links = new Dictionary<string, bool>();
                mGlobal["$$linkdict"] = links;
            }
            links[link] = true;
        }

        public void registerkey(string key)
        {
            object _keys = null;
            Dictionary<string, bool> keys = null;
            if (mGlobal.TryGetValue("$$keydict", out _keys))
                keys = _keys as Dictionary<string, bool>;
            if (keys == null)
            {
                keys = new Dictionary<string, bool>();
                mGlobal["$$keydict"] = keys;
            }
            if (keys.ContainsKey(key))
                Console.WriteLine("warning: attempt to the second registration of the key {0}. an attempt to overwrite the file?", key);
            keys[key] = true;
        }

        public void checkkeys()
        {
            object _links = null;
            Dictionary<string, bool> links = null;
            if (mGlobal.TryGetValue("$$linkdict", out _links))
                links = _links as Dictionary<string, bool>;
            object _keys = null;
            Dictionary<string, bool> keys = null;
            if (mGlobal.TryGetValue("$$keydict", out _keys))
                keys = _keys as Dictionary<string, bool>;
            if (links != null && keys != null)
            {
                Console.WriteLine("Check links integrity");
                foreach (string link in links.Keys)
                    if (!keys.ContainsKey(link))
                        Console.WriteLine("warning: the link {0} points to unknown key", link);
            }
        }

        private string FindName(string name)
        {
            if (File.Exists(name))
                return name;

            if (mProps.ContainsKey("base-xslt-path"))
            {
                if (File.Exists(Path.Combine((string)mProps["base-xslt-path"], name)))
                    return Path.Combine((string)mProps["base-xslt-path"], name);
            }

            if (mProps.ContainsKey("parent-template"))
            {
                if (File.Exists(Path.Combine((string)mProps["parent-template"], name)))
                    return Path.Combine((string)mProps["parent-template"], name);
            }

            throw new Exception("File " + name + " is not found");
        }

        public void writeBase64(string file, string base64, int length)
        {
            byte[] b = Convert.FromBase64String(base64);
            if (b.Length < length)
                return ;
            using (FileStream stream = new FileStream(file, FileMode.Create))
            {
                stream.Write(b, 0, length);
                stream.Close();
            }
        }

        public string readAllText(string file)
        {
            file = FindName(file);
            return File.ReadAllText(file);
        }

        public XPathNodeIterator files(string folder, string mask)
        {
            Regex re = null;
            if (mask.StartsWith("/"))
            {
                re = new Regex(mask.Substring(1, mask.Length - 2));
                mask = "*.*";
            }

            string[] files = Directory.GetFiles(folder, mask);

            XmlDocument r = new XmlDocument();
            XmlElement root = r.CreateElement("files");
            r.AppendChild(root);

            foreach (string file in files)
            {
                if (re != null && !re.IsMatch(file))
                    continue;

                XmlElement f = r.CreateElement("file");
                XmlAttribute a = r.CreateAttribute("name");
                a.Value = file;
                f.Attributes.Append(a);
                root.AppendChild(f);
            }

            return r.CreateNavigator().Select("/files/file");
        }

        public string trim(string s) => s.Trim();
        public string ltrim(string s) => s.TrimStart();
        public string rtrim(string s) => s.TrimEnd();

        public bool isnull(string name) => get(name) == null;

        public string escape(string toEscape) => WebUtility.HtmlEncode(toEscape);

        public string methodkey(string signature) => Crc.GetCrc(signature);

        public bool fileexists(string file) => File.Exists(file);
    }
}
