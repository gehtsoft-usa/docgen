using System.Xml;

namespace GehtSoft.DocCreator.Parser
{
    public class NoteItem : DocItem, IXmlItem, IConditionalItem
    {
        private string mType = "note";

        internal bool Simplified { get; set; } = false;

        private string mIf = null;

        public string If => mIf;

        internal NoteItem(string file, int line) : base(file, line)
        {

        }

        /** Saves item into XML node.

            @param doc     Xml document.

            @return Xml node with item data in it.
        */
        public XmlNode ItemToXml(XmlDocument doc, IDefinitionList defs)
        {
            XmlNode node = doc.CreateNode(XmlNodeType.Element, "note", "");
            XmlAttribute attr;
            attr = doc.CreateAttribute("type");
            attr.Value = mType;
            node.Attributes.Append(attr);

            DescriptionToXml(node, doc, defs);
            return node;
        }

        override internal DocItem appendNamedValue(string sName, string sValue, string file, int line)
        {
            DocItem dt;
            if ((dt = base.appendNamedValue(sName, sValue, file, line)) != null)
                return dt;

            switch (sName)
            {
                case "type":
                    if (sValue == null)
                        throw new ValueError(file, line, "note", sName, "(null)");
                    mType = sValue;
                    return null;
                case "if":
                    if (sValue == null)
                        throw new ValueError(file, line, "note", sName, "(null)");
                    mIf = sValue;
                    return null;
                default:
                    throw new UnknownTagError(file, line, sName, sValue);
            }
        }
    }
}

