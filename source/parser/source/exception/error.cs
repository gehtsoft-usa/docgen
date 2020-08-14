using System;
using System.Collections.Generic;
using System.Xml;

namespace GehtSoft.DocCreator.Parser
{
    public class Error : Exception
    {
        internal Error() : base()
        {
        }

        internal Error(string message, Exception inner) : base(message, inner)
        {
        }
    }


    public class IOError : Error
    {
        private string mFileName;
        private string mMessage;

        public string FileName
        {
            get
            {
                return mFileName;
            }
        }

        override public string Message
        {
            get
            {
                if (mMessage == null)
                    mMessage = string.Format("Can't read the file {0} : {1}", mFileName, this.InnerException.Message);
                return mMessage;
            }
        }

        internal IOError(string fileName, Exception e) : base("", e)
        {
            mFileName = fileName;
            mMessage = null;
        }

        internal IOError(string fileName, string message, Exception e) : base("", e)
        {
            mFileName = fileName;
            mMessage = message;
        }
    }


    public class ParserError : Error
    {
        private int mLine;
        private string mFile;
        private string mText;
        private string mMessage;

        public int Line
        {
            get
            {
                return mLine;
            }
        }

        public string File
        {
            get
            {
                return mFile;
            }
        }

        public string Text
        {
            get
            {
                return mText;
            }
        }

        override public string Message
        {
            get
            {
                if (mMessage == null)
                    mMessage = string.Format("{0}({1}) : {2}", mFile, mLine, mText);
                return mMessage;
            }
        }

        internal ParserError(string file, int line, string text) : base()
        {
            mFile = file;
            mLine = line;
            mText = text;
        }
    }

    public class UnknownTagError : ParserError
    {
        internal UnknownTagError(string file, int line, string obj, string value) : base(file, line, string.Format("The tag {0} is not supported in the tag {1}", value, obj))
        {
        }
    }

    public class ValidationError : ParserError
    {
        internal ValidationError(string file, int line, string obj, string absentValues) : base(file, line, string.Format("The obligatory tag(s) {0} are not found in the tag {1}", absentValues, obj))
        {
        }
    }

    public class ValueError : ParserError
    {
        internal ValueError(string file, int line, string obj, string prop, string value) : base(file, line, string.Format("The value {0} of {1} is not supported in the tag {2}", value, prop, obj))
        {
        }
        internal ValueError(string file, int line, string obj, string prop, string value, string text) : base(file, line, string.Format("The value {0} of {1} is not supported in the tag {2}. {3}", value, prop, obj, text))
        {
        }
    }
}