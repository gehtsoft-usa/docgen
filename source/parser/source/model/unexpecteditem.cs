using System;
using System.Collections;
using System.Collections.Generic;
using System.Xml;

namespace GehtSoft.DocCreator.Parser
{

    /** Description of the class. */
    public class UnexpectedItem : DocItem
    {
        /** Constructor. */
        internal UnexpectedItem(string file, int line) : base(file, line)
        {
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
            if (sValue == null)
                return new UnexpectedItem(file, line);
            else
                return null;
        }
    }

}
