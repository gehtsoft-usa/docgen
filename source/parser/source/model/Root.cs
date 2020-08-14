using System;
using System.Collections;
using System.Collections.Generic;
using System.Xml;

namespace GehtSoft.DocCreator.Parser
{

    public class RootItemContent : IEnumerable<DocItem>
    {
        private List<DocItem> mItems;

        internal RootItemContent(List<DocItem> items)
        {
            mItems = items;
        }

        public int Count
        {
            get
            {
                return mItems.Count;
            }
        }

        public DocItem this[int index]
        {
            get
            {
                return mItems[index];
            }
        }

        public IEnumerator<DocItem> GetEnumerator()
        {
            return mItems.GetEnumerator();
        }

        IEnumerator IEnumerable.GetEnumerator()
        {
            return mItems.GetEnumerator();
        }


    }

    /** Pseudo-item "root". Used to interpret the content which is not included into one
        of top-level tags: @group, @article, @class. */
    public class RootItem : DocItem, IXmlItem
    {
        private List<DocItem> maItems;     //<! All items
        private RootItemContent mContent;

        public RootItemContent Content
        {
            get
            {
                return mContent;
            }
        }

        /** Constructor. */
        internal RootItem() : base("", 0)
        {
            maItems = new List<DocItem>();
            mContent = new RootItemContent(maItems);
        }

        /** Saves item into XML node.

            @param doc     Xml document.

            @return Xml node with item data in it.
        */
        public XmlNode ItemToXml(XmlDocument doc, IDefinitionList defs)
        {
            XmlNode rootNode = doc.CreateNode(XmlNodeType.Element, "root", "");
            ItemsToXml(maItems, rootNode, doc, defs);
            return rootNode;
        }

        /** Append the line into description.

            @param sDescription     Another line of the description (e.g. line doesn't contain
                                    any information)
            @exception EParseDesc   In case of description is not acceptable in current context
          */
        override internal void appendDescription(string sDescription, string file, int line)
        {
            if (sDescription.Length > 0)
                throw new ParserError(file, line, "The text cannot be placed outside a tag");
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
                case "group":
                    {
                        GroupItem item = new GroupItem(file, line);
                        maItems.Add(item);
                        return item;
                    }
                case "article":
                    {
                        ArticleItem item = new ArticleItem(file, line);
                        maItems.Add(item);
                        return item;
                    }
                case "class":
                    {
                        ClassItem item = new ClassItem(file, line);
                        maItems.Add(item);
                        return item;
                    }
                default:
                    throw new UnknownTagError(file, line, "root", sName);
            }
        }

        internal void RemoveByFile(string fileName)
        {
            for (int i = 0; i < maItems.Count; i++)
            {
                if (maItems[i].File.Equals(fileName, StringComparison.CurrentCultureIgnoreCase))
                {
                    maItems.RemoveAt(i);
                    i--;
                }
            }
        }

        private void processImports(List<Error> errors)
        {
            for (int i = 0; i < maItems.Count; i++)
            {
                DocItem _item = maItems[i];
                if (_item is ClassItem)
                    (_item as ClassItem).import(errors, this);
            }
        }

        private void copyMembers(ClassItem destination, ClassItem source)
        {
            for (int i = 0; i < source.Members.Count; i++)
            {
                bool found = false;
                for (int j = 0; j < destination.Members.Count && !found; j++)
                {
                    if (source.Members[i].Key == destination.Members[j].Key)
                        found = true;
                }
                if (!found)
                    destination.Members.Add(source.Members[i]);
            }
        }

        private void processPartialClasses(List<Error> errors)
        {
            for (int i = 1; i < maItems.Count; i++)
            {
                if (maItems[i] is ClassItem classItem)
                {
                    for (int j = 0; j < i; j++)
                    {
                        if (maItems[j] is ClassItem classItem1)
                        {
                            if (classItem.Key == classItem1.Key)
                            {
                                copyMembers(classItem1, classItem);
                                maItems.RemoveAt(i);
                                i--;
                            }
                        }
                    }
                }
                else if (maItems[i] is GroupItem groupItem)
                {
                    for (int j = 0; j < i; j++)
                    {
                        if (maItems[j] is GroupItem groupItem1)
                        {
                            if (groupItem.Key == groupItem1.Key)
                            {
                                maItems.RemoveAt(i);
                                i--;
                            }
                        }
                    }
                }
            }
        }

        public void PostProcess(List<Error> errors)
        {
            processPartialClasses(errors);
            processImports(errors);
            
        }
    }

}
