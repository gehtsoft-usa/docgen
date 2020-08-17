using System.Collections.Generic;
using System.Xml.Serialization;

namespace AssemblyToXml
{
    [XmlRoot("collection")]
    public class AssemblyCollectionElement
    {
        [XmlArray(ElementName = "namespaces")]
        [XmlArrayItem(ElementName = "namespace")]
        public List<string> Namespaces { get; set; } = new List<string>();

        [XmlArray(ElementName = "assemblies")]
        [XmlArrayItem(ElementName = "assembly")]
        public List<AssemblyElement> Assemblies { get; set; } = new List<AssemblyElement>();
    }
}