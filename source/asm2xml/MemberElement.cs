using System.Collections.Generic;
using System.Reflection;
using System.Xml.Serialization;

namespace AssemblyToXml
{
    public class MemberElement
    {
        [XmlAttribute(AttributeName = "name")]
        public string Name { get; set; }

        [XmlAttribute(AttributeName = "signature")]
        public string Signature { get; set; }

        [XmlAttribute(AttributeName = "crc")]
        public string Crc { get; set; }

        [XmlAttribute(AttributeName = "member-type")]
        public string MemberType { get; set; }

        [XmlAttribute(AttributeName = "member-scope")]
        public string MemberScope { get; set; }

        [XmlAttribute(AttributeName = "member-visibility")]
        public string Visibility { get; set; }

        [XmlAttribute(AttributeName = "generic")]
        public string Generic { get; set; }

        [XmlElement(ElementName = "type", IsNullable = true)]
        public TypeReferenceElement Type { get; set; }
        public bool ShouldSerializeType() => Type != null;

        [XmlArray(ElementName = "parameters")]
        [XmlArrayItem(ElementName = "parameter")]
        public List<ParameterElement> Parameters { get; set; } = new List<ParameterElement>();

        [XmlArray("generic-parameters")]
        [XmlArrayItem(ElementName = "type")]
        public TypeReferenceElement[] GenericParameters { get; set; }
        public bool ShouldSerializeGenericParameters() => GenericParameters?.Length > 0;

        [XmlAttribute(AttributeName = "readonly")]
        public string Readonly { get; set; }

        public bool ShouldSerializeParameters() => Parameters.Count > 0;

        [XmlAttribute(AttributeName = "value")]
        public string Value { get; set; }

        public bool ShouldSerializeValue() => !string.IsNullOrEmpty(Value);

        [XmlElement(ElementName = "getter", IsNullable = true)]
        public MemberElement Getter { get; set; }
        public bool ShouldSerializeGetter() => Getter != null;
        [XmlElement(ElementName = "setter", IsNullable = true)]
        public MemberElement Setter { get; set; }
        public bool ShouldSerializeSetter() => Setter != null;
    }
}