using System.Reflection;
using System.Xml.Serialization;

namespace AssemblyToXml
{
    public class ParameterElement
    {
        [XmlAttribute(AttributeName = "name")]
        public string Name { get; set; }

        [XmlElement(ElementName = "type")]
        public TypeElement Type { get; set; }

        [XmlAttribute(AttributeName = "parameter-type")]
        public string ParameterType { get; set; }

        [XmlAttribute(AttributeName = "prefix")]
        public string Prefix { get; set; }

        public bool ShouldSerializePrefix() => !string.IsNullOrEmpty(Prefix);

        [XmlElement(ElementName = "value")]
        public string Value { get; set; }

        public bool ShouldSerializeValue() => !string.IsNullOrEmpty(Value);
    }
}