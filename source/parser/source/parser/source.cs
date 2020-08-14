using System;
using System.IO;
using System.Collections;
using System.Collections.Generic;
using System.Xml;
using System.Text;

namespace GehtSoft.DocCreator.Parser
{
    public interface IParserSource
    {
        bool Changed
        {
            get;
            set;
        }

        string Name
        {
            get;
        }

        Encoding Encoding { get; }

        void Reset();
        void Stop();
        string ReadLine();
    }

    public class ParserSourceCollection : IEnumerable<IParserSource>
    {
        private List<IParserSource> mList = new List<IParserSource>();

        public IEnumerator<IParserSource> GetEnumerator()
        {
            return mList.GetEnumerator();
        }

        IEnumerator IEnumerable.GetEnumerator()
        {
            return mList.GetEnumerator();
        }

        public int Count
        {
            get
            {
                return mList.Count;
            }

        }

        public IParserSource this[int index]
        {
            get
            {
                return mList[index];
            }

        }

        internal ParserSourceCollection()
        {
        }

        internal void Add(IParserSource source)
        {
            mList.Add(source);
        }
    }

    public class FileParserSource : IParserSource
    {
        private bool mChanged = true;
        private StreamReader mStream = null;
        private string mFile;
        private Encoding mEncoding;

        public Encoding Encoding => mEncoding;

        public string Name
        {
            get
            {
                return mFile;
            }
        }

        public bool Changed
        {
            get
            {
                return mChanged;
            }
            set
            {
                mChanged = value;
            }
        }

        public void Reset()
        {
            if (mStream != null)
                mStream.Close();
            mStream = new StreamReader(mFile, mEncoding);
        }

        public string ReadLine()
        {
            if (mStream == null)
                return null;
            else
                return mStream.ReadLine();
        }

        public void Stop()
        {
            mStream.Close();
            mStream = null;
        }

        public FileParserSource(string filename, Encoding encoding)
        {
            mFile = filename;
            mEncoding = encoding;
        }
    }
}