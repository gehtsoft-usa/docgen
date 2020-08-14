using System;
using System.IO;
using System.Xml;
using System.Text;
using System.Globalization;
using System.Xml.XPath;
using System.Xml.Xsl;
using System.Collections;
using System.Collections.Generic;
using System.Reflection;


namespace GehtSoft.DocCreator.Output
{
    public class XsltTransform
    {
        static Dictionary<string, XslCompiledTransform> mCache = new Dictionary<string, XslCompiledTransform>();
        static Dictionary<string, object> mGlobal = new Dictionary<string, object>();

        public static void Reset()
        {
            mCache.Clear();
            mGlobal.Clear();
        }

        internal static void Transform(string xslt, IXPathNavigable doc, string output, string codepage, XsltExtensionObject caller)
        {
            Encoding encoding = null;

            try
            {
                if (codepage.Length > 0)
                {
                    int cp;
                    if (Int32.TryParse(codepage, out cp))
                        encoding = Encoding.GetEncoding(cp);
                    else
                        encoding = Encoding.GetEncoding(codepage);
                }
            }
            catch (Exception )
            {
                throw new XsltExceptionEx("Can't load encoding :" + codepage, xslt);
            }

            XslCompiledTransform transform;
            if (!mCache.TryGetValue(xslt, out transform))
            {
                transform = new XslCompiledTransform(true);
                try
                {
                    transform.Load(xslt);
                }
                catch (XsltException e)
                {
                    throw new XsltExceptionEx(e, xslt);
                }
                catch (Exception e)
                {
                    throw new XsltExceptionEx("Unexpected load exception", xslt, e);
                }
                mCache[xslt] = transform;
            }

            XmlWriterSettings settings = transform.OutputSettings.Clone();
            if (encoding != null)
                settings.Encoding = encoding;
            XmlWriter writer;
            try
            {
                if (output.Contains("null-file"))
                    writer = XmlWriter.Create(new StringBuilder(), settings);
                else
                    writer = XmlWriter.Create(output, settings);
            }
            catch (Exception )
            {
                throw new XsltExceptionEx("Can't create output :" + output, xslt);
            }
            XsltArgumentList args = new XsltArgumentList();
            args.AddExtensionObject("urn:gehtsoft-exslt", new XsltExtensionObject(caller));
            try
            {
                transform.Transform(doc, args, writer);
            }
            catch (XsltException e)
            {
                throw new XsltExceptionEx(e, xslt);
            }
            catch (Exception e)
            {
                throw new XsltExceptionEx("Unexpected execution exception", xslt, e);
            }
            writer.Close();
        }

        internal static void Transform(string xslt, IXPathNavigable doc, StringBuilder output, string codepage, XsltExtensionObject caller)
        {
            Encoding encoding = null;
            try
            {
                if (codepage.Length > 0)
                {
                    int cp;
                    if (Int32.TryParse(codepage, out cp))
                        encoding = Encoding.GetEncoding(cp);
                    else
                        encoding = Encoding.GetEncoding(codepage);
                }
            }
            catch (Exception )
            {
                throw new XsltExceptionEx("Can't load encoding :" + codepage, xslt);
            }


            XslCompiledTransform transform;
            if (!mCache.TryGetValue(xslt, out transform))
            {
                transform = new XslCompiledTransform(true);
                try
                {
                    transform.Load(xslt);
                }
                catch (XsltException e)
                {
                    throw new XsltExceptionEx(e, xslt);
                }
                catch (Exception e)
                {
                    throw new XsltExceptionEx("Unexpected load exception", xslt, e);
                }
                mCache[xslt] = transform;
            }

            XmlWriterSettings settings = transform.OutputSettings.Clone();
            if (encoding != null)
                settings.Encoding = encoding;
            XmlWriter writer;
            try
            {
                 writer = XmlWriter.Create(output, settings);
            }
            catch (Exception e)
            {
                throw new XsltExceptionEx("Can't create output :" + output, xslt, e);
            }
            XsltArgumentList args = new XsltArgumentList();
            args.AddExtensionObject("urn:gehtsoft-exslt", new XsltExtensionObject(caller));
            try
            {
                transform.Transform(doc, args, writer);
            }
            catch (XsltException e)
            {
                throw new XsltExceptionEx(e, xslt);
            }
            catch (Exception e)
            {
                throw new XsltExceptionEx("Unexpected execution exception", xslt, e);
            }
            writer.Close();
        }

        public static void Transform(string xslt, IXPathNavigable doc, string output, string codepage, Dictionary<string, object> props)
        {
            FileInfo fi;
            fi = new FileInfo(xslt);
            props["base-xslt-path"] = fi.DirectoryName + "\\";
            fi = new FileInfo(output);
            props["base-output-path"] = fi.DirectoryName + "\\";
            fi = new FileInfo(Assembly.GetExecutingAssembly().Location);
            props["application-path"] = fi.DirectoryName + "\\";
            props["codepage"] = codepage;
            Transform(xslt, doc, output, codepage, new XsltExtensionObject(props, mGlobal));
        }
    }
}

