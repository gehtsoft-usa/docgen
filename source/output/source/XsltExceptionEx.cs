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
    public class XsltExceptionEx : Exception
    {
        private int mLine = -1;
        private int mColumn = -1;
        private string mURI = "unspecified";

        public int Line
        {
            get
            {
                return mLine;
            }
        }

        public int Column
        {
            get
            {
                return mColumn;
            }
        }

        public string URI
        {
            get
            {
                return mURI;
            }
        }

        public XsltExceptionEx(string message, string uri) : base(message)
        {
            mLine = mColumn = -1;
            mURI = uri;
        }

        public XsltExceptionEx(string message, string uri, Exception inner) : base(message, inner)
        {
            mLine = mColumn = -1;
            mURI = uri;
        }

        public XsltExceptionEx(XsltException e, string xslt) : base(e.Message, e.InnerException)
        {
            mLine = e.LineNumber;
            mColumn = e.LinePosition;
            if (e.SourceUri == null || e.SourceUri == "")
                mURI = xslt;
            else
                mURI = e.SourceUri;
        }

        public void Dump()
        {
            Exception e = this;
            XsltExceptionEx xe = this;
            while (e != null)
            {
                xe = e as XsltExceptionEx;
                if (xe != null)
                {
                   if (xe.Line > 0)
                       Console.WriteLine("{0}[{2},{3}] : error {1}", xe.URI, xe.Message, xe.Line, xe.Column);
                   else
                       Console.WriteLine("{0} : error {1}", xe.URI, xe.Message);
                }
                else
                    Console.WriteLine("{1}({0})", e.Message, e.GetType().Name);
                e = e.InnerException;
            }

        }
    }
}
