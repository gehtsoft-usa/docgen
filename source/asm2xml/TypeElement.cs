using Mono.Cecil;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;
using System.Xml;
using System.Xml.Serialization;

namespace AssemblyToXml
{
    public class TypeReferenceElement
    {
        [XmlAttribute(AttributeName = "name")]
        public string Name { get; set; }

        [XmlAttribute(AttributeName = "namespace")]
        public string Namespace { get; set; }


        [XmlAttribute(AttributeName = "signature")]
        public string Signature { get; set; }

        [XmlAttribute(AttributeName = "suffix")]
        public string Suffix { get; set; }

        public bool ShouldSerializeSuffix() => !string.IsNullOrEmpty(Suffix);

        [XmlAttribute(AttributeName = "prefix")]
        public string Prefix { get; set; }

        public bool ShouldSerializePrefix() => !string.IsNullOrEmpty(Prefix);

        [XmlAttribute(AttributeName = "base-signature")]
        public string BaseSignature { get; set; }

        public bool ShouldSerializeBaseSignature() => !string.IsNullOrEmpty(BaseSignature);

        [XmlAttribute(AttributeName = "generic")]
        public string Generic { get; set; }

        [XmlArray("parameters")]
        [XmlArrayItem(ElementName = "type")]
        public TypeReferenceElement[] Parameters { get; set; }
        public bool ShouldSerializeParameters() => Parameters?.Length > 0;


        public TypeReferenceElement()
        {

        }

        public TypeReferenceElement(TypeReference type)
        {
            Signature = Namer.GetTypeName(type);
            Name = GetName(type);
            Namespace = type.Namespace;

            if (type.IsByReference)
            {
                if (type is ByReferenceType byRefType)
                    type = byRefType.ElementType;
                Prefix = "ref";
            }

            if (type.IsPointer)
                Suffix = "*";


            if (type.IsArray)
                BaseSignature = Namer.GetTypeName(type.GetElementType());

            if (type.IsGenericParameter)
                Generic = "generic-parameter";
            else if (type is GenericInstanceType genericType)
            {
                {
                    Generic = "true";
                    BaseSignature = Namer.GetTypeName(genericType.ElementType);
                    if (genericType.GenericArguments.Count > 0)
                    {
                        var parameters = genericType.GenericArguments;
                        Parameters = new TypeReferenceElement[parameters.Count];
                        for (int i = 0; i < parameters.Count; i++)
                            Parameters[i] = new TypeReferenceElement(parameters[i]);

                    }
                }
            }
            else if (type.GenericParameters.Count > 0)
                Generic = "definition";
            else
                Generic = "false";

            {
                var parameters = type.GenericParameters;
                int i;
                if (parameters?.Count > 0)
                {
                    Parameters = new TypeReferenceElement[parameters.Count];
                    for (i = 0; i < parameters.Count; i++)
                        Parameters[i] = new TypeReferenceElement(parameters[i]);
                }
            }
        }

        protected string GetName(TypeReference type)
        {
            if (type.DeclaringType == null || type.IsGenericParameter)
                return type.Name.TrimTemplate();
            else
                return GetName(type.DeclaringType) + "." + type.Name.TrimTemplate();
        }

    }

    public class TypeElement : TypeReferenceElement
    {
        [XmlAttribute(AttributeName = "type")]
        public string Type { get; set; }

        [XmlAttribute(AttributeName = "abstract")]
        public string Abstract { get; set; }


        [XmlArray("parents")]
        [XmlArrayItem(ElementName = "type")]
        public List<TypeReferenceElement> Parents { get; set; } = new List<TypeReferenceElement>();

        public bool ShouldSerializeParents() => Parents.Count > 0;

        [XmlArray("members")]
        [XmlArrayItem(ElementName = "member")]
        public List<MemberElement> Members { get; set; } = new List<MemberElement>();

        public TypeElement()
        {

        }

        public TypeElement(TypeDefinition type) : base(type)
        {
            if (type.IsInterface)
                Type = "interface";
            else if (type.IsEnum)
                Type = "enum";
            else if (type.IsValueType)
                Type = "value";
            else
                Type = "class";

            if (type.IsAbstract)
                Abstract = "true";
            else
                Abstract = "false";


            if (type.BaseType != null)
                Parents.Add(new TypeReferenceElement(type.BaseType));

            var interfaces = type.Interfaces;
            foreach (var iface in interfaces)
                Parents.Add(new TypeReferenceElement(iface.InterfaceType));

            InitializeFields(type);
            if (!type.IsEnum)
            {
                InitializeProperties(type);
                InitializeMethods(type);
                InitializeEvents(type);
            }
        }



        void InitializeFields(TypeDefinition type)
        {
            foreach (var member in type.Fields)
            {
                if (member.DeclaringType != type)
                    continue;

                if (!(member.IsPublic || member.IsFamily))
                    continue;

                if (type.IsEnum && !member.IsStatic)
                    continue;

                MemberElement memberElement = new MemberElement();
                memberElement.Name = member.Name;
                memberElement.Signature = Namer.GetMemberName(member);
                memberElement.Crc = Crc.GetCrc(memberElement.Signature);
                memberElement.MemberType = "field";
                memberElement.MemberScope = member.IsStatic ? "class" : "instance";
                memberElement.Type = new TypeReferenceElement(member.FieldType);

                if (member.IsPublic)
                    memberElement.Visibility = "public";
                else if (member.IsFamilyAndAssembly)
                    memberElement.Visibility = "protected internal";
                else if (member.IsFamily)
                    memberElement.Visibility = "protected";
                else if (member.IsAssembly)
                    memberElement.Visibility = "internal";
                else if (member.IsPrivate)
                    memberElement.Visibility = "private";

                try
                {
                    object v = member.Constant;
                    memberElement.Value = null;
                    if (v != null)
                    {
                        if (v is string s)
                        {
                            memberElement.Value = "\"" + s + "\"";
                        }
                        else
                        {
                            memberElement.Value = v.ToString();
                        }
                    }
                }
                catch (Exception )
                {
                }

                Members.Add(memberElement);
            }
        }
        void InitializeProperties(TypeDefinition type)
        {
            foreach (var member in type.Properties)
            {
                if (!(member.GetMethod?.IsPublic ?? false) &&
                    !(member.GetMethod?.IsFamily ?? false) &&
                    !(member.SetMethod?.IsPublic ?? false) &&
                    !(member.SetMethod?.IsFamily ?? false))
                    continue;

                if (member.DeclaringType != type && 
                    (member.SetMethod == null || member.SetMethod?.DeclaringType != type) && 
                    (member.GetMethod == null || member.GetMethod?.DeclaringType != type))
                    continue;

                MemberElement memberElement = new MemberElement();
                memberElement.Name = member.Name;
                memberElement.Signature = Namer.GetMemberName(member);
                memberElement.MemberType = "property";
                memberElement.Type = new TypeReferenceElement(member.PropertyType);
                var getter = member.GetMethod;
                memberElement.Crc = Crc.GetCrc(memberElement.Signature);

                if (getter != null)
                    memberElement.Getter = MethodToMemberElement(getter);

                var setter = member.SetMethod;
                if (setter != null)
                    memberElement.Setter = MethodToMemberElement(setter);


                memberElement.MemberScope = (getter?.IsStatic ?? setter?.IsStatic ?? false) ? "class" : "instance";

                if (!((getter?.IsPublic ?? false) || (getter?.IsFamily ?? false) ||
                      (setter?.IsPublic ?? false) || (setter?.IsFamily ?? false)))
                        continue;


                Members.Add(memberElement);


            }

        }
        void ScanParams(IEnumerable<ParameterDefinition> parameters, MemberElement memberElement)
        {
            foreach (var param in parameters)
            {
                ParameterElement paramElement = new ParameterElement();

                paramElement.Name = param.Name;
                paramElement.Type = new TypeReferenceElement(param.ParameterType);

                if (param.IsIn && !param.IsOut || !param.IsIn && !param.IsOut)
                    paramElement.ParameterType = "in";
                if (!param.IsIn && param.IsOut)
                    paramElement.ParameterType = "out";
                if (param.IsIn && param.IsOut)
                    paramElement.ParameterType = "inout";

                foreach (var attribute in param.CustomAttributes)
                {
                    if (attribute.AttributeType.Name == nameof(ParamArrayAttribute))
                        paramElement.Prefix = "params";
                }

                if (param.HasDefault)
                {
                    object value = param.Constant;
                    if (value == null)
                        paramElement.Value = "null";
                    else if (value is string s)
                        paramElement.Value = "\"" + s + "\"";
                    else
                        paramElement.Value = value.ToString();
                }

                memberElement.Parameters.Add(paramElement);
            }
        }


        private MemberElement MethodToMemberElement(MethodDefinition member)
        {
            MemberElement memberElement = new MemberElement();
            memberElement.Name = member.Name;
            memberElement.Signature = Namer.GetMemberName(member);
            memberElement.Crc = Crc.GetCrc(memberElement.Signature);
            memberElement.MemberType = (member.Name == ".ctor" || member.Name == ".cctor") ? "constructor" : "method";
            memberElement.MemberScope = member.IsStatic ? "class" : "instance";
            memberElement.Type = new TypeReferenceElement(member.ReturnType);

            if (member.IsPublic)
                memberElement.Visibility = "public";
            else if (member.IsFamilyAndAssembly)
                memberElement.Visibility = "protected internal";
            else if (member.IsFamily)
                memberElement.Visibility = "protected";
            else if (member.IsAssembly)
                memberElement.Visibility = "internal";
            else if (member.IsPrivate)
                memberElement.Visibility = "private";

            if (member.GenericParameters?.Count > 0)
            {
                var args = member.GenericParameters.ToArray();
                memberElement.GenericParameters = new TypeReferenceElement[args.Length];
                for (int i = 0; i < args.Length; i++)
                    memberElement.GenericParameters[i] = new TypeReferenceElement(args[i]);
            }

            ScanParams(member.Parameters, memberElement);
            foreach (var attribute in member.CustomAttributes)
            {
                if (attribute.AttributeType.Name == nameof(ExtensionAttribute))
                    memberElement.Parameters[0].Prefix = "this";
            }

            return memberElement;
        }

        bool IsOverriden(MethodInfo m) => m.GetBaseDefinition().DeclaringType != m.DeclaringType;

        void InitializeMethods(TypeDefinition type)
        {
            foreach (var member in type.Methods)
            {
                if (member.DeclaringType != type)
                    continue;

                if (!(member.IsPublic || member.IsFamily))
                    continue;

                if (member.IsSetter || member.IsGetter || member.IsAddOn || member.IsRemoveOn || member.IsFire || member.IsFinal)
                    continue;

                MemberElement element = MethodToMemberElement(member);
                Members.Add(element);
            }

        }

        void InitializeEvents(TypeDefinition type)
        {
            foreach (var member in type.Events)
            {
                if (member.DeclaringType != type)
                    continue;

                MemberElement memberElement = new MemberElement();
                memberElement.Name = member.Name;
                memberElement.Signature = Namer.GetMemberName(member);
                memberElement.Crc = Crc.GetCrc(memberElement.Signature);
                memberElement.MemberType = "event";
                memberElement.MemberScope = "instance";
                memberElement.Type = new TypeReferenceElement(member.EventType);
                Members.Add(memberElement);
            }
        }

    }
}
