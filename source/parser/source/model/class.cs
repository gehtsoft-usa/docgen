using System;
using System.Collections;
using System.Collections.Generic;
using System.Xml;

namespace GehtSoft.DocCreator.Parser
{

    public class MemberList : IEnumerable<MemberItem>, IEnumerable<DocItem>
    {
        internal class EnumHelper : IEnumerator<DocItem>
        {
            IEnumerator<MemberItem> r;

            internal EnumHelper(IEnumerator<MemberItem> _r)
            {
                r = _r;
            }

            public DocItem Current
            {
                get
                {
                    return (DocItem)r.Current;
                }
            }

            object IEnumerator.Current
            {
                get
                {
                    return r.Current;
                }
            }

            public void Reset()
            {
                r.Reset();
            }

            public bool MoveNext()
            {
                return r.MoveNext();
            }

            public void Dispose()
            {
                r.Dispose();
            }
        }


        private List<MemberItem> mList = new List<MemberItem>();

        public int Count
        {
            get
            {
                return mList.Count;
            }
        }

        public MemberItem this[int index]
        {
            get
            {
                return mList[index];
            }
        }

        public IEnumerator<MemberItem> GetEnumerator()
        {
            return mList.GetEnumerator();
        }

        IEnumerator<DocItem> IEnumerable<DocItem>.GetEnumerator()
        {
            return new EnumHelper(mList.GetEnumerator());
        }

        IEnumerator IEnumerable.GetEnumerator()
        {
            return mList.GetEnumerator();
        }

        internal void Add(MemberItem item)
        {
            mList.Add(item);
        }
    }

    /** Description of the class. */
    public class ClassItem : DocItem, IXmlItem, IConditionalItem
    {
        private string msName;                   //!< class name
        private string msSig;                    //!< signature name
        private string msKey;                    //!< key name of the class
        private List<string> maParents;          //!< parent classes
        private List<DocItem> maParams;          //!< class parameters
        private string msBrief;                  //!< brief description of the class
        private string msType;                   //!< type of the class
        private string msPrefix;                 //!< the prefix of the class
        private string msInGroup;                //!< group of the class
        private List<DocItem> maSees;            //!< list of the see also items
        private MemberList maMembers;            //!< list of the members
        private List<DocItem> maDecls;           //!< language-depended declarations
        private string msIf;                     //!< conditional
        private string mDeclName;
        private bool mSort = true;               //!< flag indicating whether members shall be sorted
        private string mClassNameInKey = "true"; //!< do we need to add class name to the keyword?
        private string mTransform = "def";
        private List<string> maImports;          //list of imports
        private string mMembersToContent = "false";        //

        public string Name
        {
            get
            {
                return msName;
            }
        }

        public string Key
        {
            get
            {
                return msKey;
            }
        }

        public MemberList Members
        {
            get
            {
                return maMembers;
            }
        }

        public string If
        {
            get
            {
                return msIf;
            }
        }

        public string MembersToContent
        {
            get
            {
                return mMembersToContent;
            }
        }

        /** Constructor. */
        internal ClassItem(string file, int line) : base(file, line)
        {
            msName = null;
            msSig = "";
            msKey = null;
            maParents = new List<string>();
            maParams = new List<DocItem>();
            msBrief = null;
            msPrefix = "";
            msType = "ref class";
            msInGroup = "index";
            maSees = new List<DocItem>();
            maMembers = new MemberList();
            maDecls = new List<DocItem>();
            maImports = new List<string>();
        }

        /** Saves item into XML node.

            @param doc     Xml document.

            @return Xml node with item data in it.
        */
        public XmlNode ItemToXml(XmlDocument doc, IDefinitionList defs)
        {
            XmlNode classNode = doc.CreateNode(XmlNodeType.Element, "class", "");
            XmlAttribute attr;

            attr = doc.CreateAttribute("name");
            attr.Value = msName;
            classNode.Attributes.Append(attr);

            attr = doc.CreateAttribute("sig");
            attr.Value = msSig;
            classNode.Attributes.Append(attr);

            attr = doc.CreateAttribute("key");
            attr.Value = msKey;
            classNode.Attributes.Append(attr);

            attr = doc.CreateAttribute("brief");
            attr.Value = msBrief;
            classNode.Attributes.Append(attr);

            attr = doc.CreateAttribute("type");
            attr.Value = msType;
            classNode.Attributes.Append(attr);

            attr = doc.CreateAttribute("prefix");
            attr.Value = msPrefix;
            classNode.Attributes.Append(attr);

            attr = doc.CreateAttribute("in-group");
            attr.Value = msInGroup;
            classNode.Attributes.Append(attr);

            attr = doc.CreateAttribute("decl-name");
            attr.Value = mDeclName;
            classNode.Attributes.Append(attr);

            attr = doc.CreateAttribute("sort");
            attr.Value = mSort ? "true" : "false";
            classNode.Attributes.Append(attr);

            attr = doc.CreateAttribute("class-name-in-key");
            attr.Value = mClassNameInKey;
            classNode.Attributes.Append(attr);

            attr = doc.CreateAttribute("transform");
            attr.Value = mTransform;
            classNode.Attributes.Append(attr);

            attr = doc.CreateAttribute("members-to-content");
            attr.Value = mMembersToContent;
            classNode.Attributes.Append(attr);


            DescriptionToXml(classNode, doc, defs);

            ItemsToXml(maSees, classNode, doc, defs);
            ItemsToXml(maMembers, classNode, doc, defs);
            ItemsToXml(maDecls, classNode, doc, defs);
            ItemsToXml(maParams, classNode, doc, defs);

            StringsToXml(maParents, classNode, doc, "parent");
            return classNode;
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
                case "member":
                    {
                        MemberItem item = new MemberItem(this, file, line);
                        maMembers.Add(item);
                        return item;
                    }
                case "param":
                    {
                        ParamItem item = new ParamItem(file, line);
                        maParams.Add(item);
                        return item;
                    }
                case "parent":
                    if (sValue == null)
                        throw new ValueError(file, line, "class", sName, "(null)");
                    maParents.Add(sValue);
                    return null;
                case "import":
                    if (sValue == null)
                        throw new ValueError(file, line, "class", sName, "(null)");
                    maImports.Add(sValue);
                    return null;
                case "declaration":
                    {
                        if (msType != "enum")
                            throw new UnknownTagError(file, line, "class", sName);
                        DeclarationItem item = new DeclarationItem(msName, file, line);
                        maDecls.Add(item);
                        return item;
                    }
                case "name":
                    if (sValue == null)
                        throw new ValueError(file, line, "class", sName, "(null)");
                    msName = sValue;
                    if (msKey == null)
                        msKey = msName;
                    return null;
                case "sig":
                    if (sValue == null)
                        throw new ValueError(file, line, "class", sName, "(null)");
                    msSig = sValue;
                    return null;
                case "prefix":
                    if (sValue == null)
                        throw new ValueError(file, line, "class", sName, "(null)");
                    msPrefix = sValue;
                    return null;
                case "key":
                    if (sValue == null)
                        throw new ValueError(file, line, "class", sName, "(null)");
                    msKey = sValue;
                    return null;
                case "brief":
                    if (sValue == null)
                        throw new ValueError(file, line, "class", sName, "(null)");
                    msBrief = sValue;
                    return null;
                case "type":
                    if (sValue == null)
                        throw new ValueError(file, line, "class", sName, "(null)");
                    msType = sValue;
                    return null;
                case "membersToContent":
                    if (sValue == null)
                        throw new ValueError(file, line, "class", sName, "(null)");
                    mMembersToContent = sValue;
                    return null;
                case "ingroup":
                    if (sValue == null)
                        throw new ValueError(file, line, "class", sName, "(null)");
                    msInGroup = sValue;
                    return null;
                case "if":
                    if (sValue == null)
                        throw new ValueError(file, line, "class", sName, "(null)");
                    msIf = sValue;
                    return null;
                case "sort":
                    if (sValue == null)
                        throw new ValueError(file, line, "class", sName, "(null)");
                    mSort = (sValue == "yes");
                    return null;
                case "classnameinkey":
                    if (sValue == null)
                        throw new ValueError(file, line, "class", sName, "(null)");
                    mClassNameInKey = sValue;
                    return null;
                case "declname":
                    if (sValue == null)
                        throw new ValueError(file, line, "class", sName, "(null)");
                    mDeclName = sValue;
                    return null;
                case "transform":
                    if (sValue == null)
                        throw new ValueError(file, line, "class", sName, "(null)");
                    mTransform = sValue;
                    return null;
                default:
                    throw new UnknownTagError(file, line, "class", sName);
            }
        }

        /** Validate the content of the item.

            @exception EParseValidate   In case of validation is not succesful
         */
        override internal void validate(string file, int line)
        {
            base.validate(file, line);
            string sAbsent = "";

            if (msName == null)
                sAbsent += " @name";
            if (msBrief == null)
                sAbsent += " @brief";
            if (mDeclName == null)
                mDeclName = msName;
            if (sAbsent.Length > 0)
                throw new ValidationError(file, line, "class", sAbsent);
        }

        internal void import(List<Error> errors, RootItem root)
        {

            for (int i = 0; i < maImports.Count; i++)
            {
                string import = maImports[i];
                RootItemContent c = root.Content;
                bool found = false;
                for (int j = 0; j < c.Count && !found; j++)
                {
                    DocItem _item = c[j];
                    if (_item is ClassItem)
                    {
                        ClassItem item = _item as ClassItem;
                        if (item.Key == import)
                        {
                            found = true;
                            item.import(errors, root);
                            for (int k = 0; k < item.Members.Count; k++)
                            {
                                if (item.Members[k].Type == "constructor")
                                    continue;
                                bool exists = false;
                                for (int l = 0; l < maMembers.Count && !exists; l++)
                                    if (maMembers[l].Key == item.Members[k].Key)
                                        exists = true;
                                if (!exists)
                                    maMembers.Add(item.Members[k]);
                            }
                        }
                    }
                }
                if (!found)
                {
                    Error error = new ParserError(this.File, this.Line, string.Format("@import key {0} is not found", import));
                    errors.Add(error);
                }
            }
            maImports.Clear();
        }
    }

}
