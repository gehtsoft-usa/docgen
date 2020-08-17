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
    public class TypeElement
    {
        [XmlAttribute(AttributeName = "name")]
        public string Name { get; set; }

        [XmlAttribute(AttributeName = "namespace")]
        public string Namespace { get; set; }


        [XmlAttribute(AttributeName = "signature")]
        public string Signature { get; set; }

        [XmlAttribute(AttributeName = "base-signature")]
        public string BaseSignature { get; set; }

        public bool ShouldSerializeBaseSignature() => !string.IsNullOrEmpty(BaseSignature);

        [XmlAttribute(AttributeName = "generic")]
        public string Generic { get; set; }


        [XmlAttribute(AttributeName = "type")]
        public string Type { get; set; }

        [XmlAttribute(AttributeName = "suffix")]
        public string Suffix { get; set; }

        public bool ShouldSerializeSuffix() => !string.IsNullOrEmpty(Suffix);

        [XmlAttribute(AttributeName = "prefix")]
        public string Prefix { get; set; }

        public bool ShouldSerializePrefix() => !string.IsNullOrEmpty(Prefix);

        [XmlAttribute(AttributeName = "abstract")]
        public string Abstract { get; set; }

        [XmlArray("parameters")]
        [XmlArrayItem(ElementName = "type")]
        public TypeElement[] Parameters { get; set; }
        public bool ShouldSerializeParameters() => Parameters?.Length > 0;

        [XmlArray("parents")]
        [XmlArrayItem(ElementName = "type")]
        public List<TypeElement> Parents { get; set; } = new List<TypeElement>();

        public bool ShouldSerializeParents() => Parents.Count > 0;

        [XmlArray("members")]
        [XmlArrayItem(ElementName = "member")]
        public List<MemberElement> Members { get; set; } = new List<MemberElement>();

        public bool ShouldSerializeMembers() => Members.Count > 0;

        public TypeElement()
        {

        }

        private readonly Type mType;

        private readonly bool mWithMembers;

        public TypeElement(Type type, bool withMembers = true)
        {
            mType = type;
            mWithMembers = withMembers;
            Initialize();
        }

        string GetName(Type type)
        {
            if (type.DeclaringType == null || type.IsGenericParameter)
                return type.Name.TrimTemplate();
            else
                return GetName(type.DeclaringType) + "." + type.Name.TrimTemplate();
        }

        void Initialize()
        {
            Signature = Namer.GetTypeName(mType.GetTypeInfo());
            Name = GetName(mType);
            Namespace = mType.Namespace;

            if (mType.IsByRef)
                Prefix = "ref";

            if (mType.IsPointer)
                Suffix = "*";

            if (mType.IsInterface)
                Type = "interface";
            else if (mType.IsEnum)
                Type = "enum";
            else if (mType.IsValueType)
                Type = "value";
            else
                Type = "class";

            if (mType.IsAbstract)
                Abstract = "true";
            else
                Abstract = "false";

            if (mType.IsArray)
                BaseSignature = Namer.GetTypeName(mType.GetElementType().GetTypeInfo());

            if (mType.IsGenericTypeDefinition)
                Generic = "definition";
            else if (mType.IsGenericParameter)
                Generic = "generic-parameter";
            else if (mType.IsGenericType)
            {
                BaseSignature = Namer.GetTypeName(mType.GetGenericTypeDefinition().GetTypeInfo());
                Generic = "true";
            }
            else
                Generic = "false";

            Type[] parameters = mType.GetGenericArguments();
            int i;
            if (parameters?.Length > 0)
            {
                Parameters = new TypeElement[parameters.Length];
                for (i = 0; i < parameters.Length; i++)
                    Parameters[i] = new TypeElement(parameters[i], false);
            }

            if (mWithMembers)
            {
                if (mType.BaseType != null)
                    Parents.Add(new TypeElement(mType.BaseType, false));

                var interfaces = mType.GetInterfaces();
                for (i = 0; i < interfaces.Length; i++)
                    Parents.Add(new TypeElement(interfaces[i], false));

                InitializeFields();
                if (!mType.IsEnum)
                {
                    InitializeProperties();
                    InitializeConstructors();
                    InitializeMethods();
                    InitializeEvents();
                }
            }
        }

        void InitializeFields()
        {
            foreach (FieldInfo member in mType.GetFields(BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance | BindingFlags.Static))
            {
                if (member.DeclaringType != mType)
                    continue;

                if (!(member.IsPublic || member.IsFamily))
                    continue;

                if (mType.IsEnum && !member.IsStatic)
                    continue;

                MemberElement memberElement = new MemberElement();
                memberElement.Name = member.Name;
                memberElement.Signature = Namer.GetMemberName(member);
                memberElement.Crc = Crc.GetCrc(memberElement.Signature);
                memberElement.MemberType = "field";
                memberElement.MemberScope = member.IsStatic ? "class" : "instance";
                memberElement.Type = new TypeElement(member.FieldType, false);

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
                    object v = member.GetRawConstantValue();
                    if (v is string s)
                    {
                        memberElement.Value = "\"" + s + "\"";
                    }
                    else
                    {
                        memberElement.Value = v.ToString();
                    }
                }
                catch (Exception )
                {
                    memberElement.Value = null;
                }

                Members.Add(memberElement);
            }
        }
        void InitializeProperties()
        {
            foreach (PropertyInfo member in mType.GetProperties(BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance | BindingFlags.Static))
            {
                if (member.DeclaringType != mType && (member.SetMethod == null || member.SetMethod?.DeclaringType != mType) && (member.GetMethod == null || member.GetMethod?.DeclaringType != mType))
                    continue;

                MemberElement memberElement = new MemberElement();
                memberElement.Name = member.Name;
                memberElement.Signature = Namer.GetMemberName(member);
                memberElement.MemberType = "property";
                memberElement.Type = new TypeElement(member.PropertyType, false);
                MethodInfo getter = member.GetMethod;
                memberElement.Crc = Crc.GetCrc(memberElement.Signature);

                if (getter != null)
                    memberElement.Getter = MethodToMemberElement(getter);

                MethodInfo setter = member.SetMethod;
                if (setter != null)
                    memberElement.Setter = MethodToMemberElement(setter);


                memberElement.MemberScope = (getter?.IsStatic ?? setter?.IsStatic ?? false) ? "class" : "instance";

                if (!((getter?.IsPublic ?? false) || (getter?.IsFamily ?? false) ||
                      (setter?.IsPublic ?? false) || (setter?.IsFamily ?? false)))
                        continue;


                Members.Add(memberElement);


            }

        }
        void InitializeConstructors()
        {
            foreach (ConstructorInfo member in mType.GetConstructors(BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance | BindingFlags.Static))
            {
                if (!(member.IsPublic || member.IsFamily))
                    continue;

                MemberElement memberElement = new MemberElement();
                memberElement.Name = member.Name;
                memberElement.Signature = Namer.GetMemberName(member);
                memberElement.Crc = Crc.GetCrc(memberElement.Signature);
                memberElement.MemberType = "constructor";
                memberElement.MemberScope = member.IsStatic ? "class" : "instance";

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

                ScanParams(member.GetParameters(), memberElement);
                Members.Add(memberElement);
            }

        }
        void ScanParams(ParameterInfo[] parameters, MemberElement memberElement)
        {
            foreach (ParameterInfo param in parameters)
            {
                ParameterElement paramElement = new ParameterElement();

                paramElement.Name = param.Name;
                paramElement.Type = new TypeElement(param.ParameterType, false);

                if (param.IsIn && !param.IsOut || !param.IsIn && !param.IsOut)
                    paramElement.ParameterType = "in";
                if (!param.IsIn && param.IsOut)
                    paramElement.ParameterType = "out";
                if (param.IsIn && param.IsOut)
                    paramElement.ParameterType = "inout";

                foreach (var attribute in param.GetCustomAttributes())
                {
                    if (attribute is ParamArrayAttribute)
                        paramElement.Prefix = "params";
                }

                if (param.HasDefaultValue)
                {
                    object value = param.DefaultValue;
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


        MemberElement MethodToMemberElement(MethodInfo member)
        {
            MemberElement memberElement = new MemberElement();
            memberElement.Name = member.Name;
            memberElement.Signature = Namer.GetMemberName(member);
            memberElement.Crc = Crc.GetCrc(memberElement.Signature);
            memberElement.MemberType = "method";
            memberElement.MemberScope = member.IsStatic ? "class" : "instance";
            memberElement.Type = new TypeElement(member.ReturnType, false);

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

            if (member.IsGenericMethod || member.IsGenericMethodDefinition)
            {
                var args = member.GetGenericArguments();
                memberElement.GenericParameters = new TypeElement[args.Length];
                for (int i = 0; i < args.Length; i++)
                    memberElement.GenericParameters[i] = new TypeElement(args[i], false);
            }

            ScanParams(member.GetParameters(), memberElement);
            var exa = member.GetCustomAttribute<ExtensionAttribute>();
            if (exa != null && memberElement.Parameters.Count > 0)
                memberElement.Parameters[0].Prefix = "this";
            return memberElement;
        }

        bool IsOverriden(MethodInfo m) => m.GetBaseDefinition().DeclaringType != m.DeclaringType;

        void InitializeMethods()
        {
            foreach (MethodInfo member in mType.GetMethods(BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance | BindingFlags.Static))
            {
                if (member.DeclaringType != mType)
                    continue;

                if (!(member.IsPublic || member.IsFamily))
                    continue;

                var props = mType.GetProperties(BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance | BindingFlags.Static);
                var events = mType.GetEvents();

                bool found = false;
                foreach (PropertyInfo property in props)
                {
                    if (property.GetMethod == member || property.SetMethod == member)
                    {
                        found = true;
                        break;
                    }
                }

                if (!found && events.Length > 0)
                {
                    foreach (EventInfo ev in events)
                    {
                        if (ev.AddMethod == member || ev.RaiseMethod == member || ev.RemoveMethod == member)
                        {
                            found = true;
                            break;
                        }
                    }
                }

                if (found)
                    continue;

                MemberElement element = MethodToMemberElement(member);
                Members.Add(element);
            }

        }

        void InitializeEvents()
        {
            foreach (EventInfo member in mType.GetEvents(BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance | BindingFlags.Static))
            {
                if (member.DeclaringType != mType)
                    continue;

                MemberElement memberElement = new MemberElement();
                memberElement.Name = member.Name;
                memberElement.Signature = Namer.GetMemberName(member);
                memberElement.Crc = Crc.GetCrc(memberElement.Signature);
                memberElement.MemberType = "event";
                memberElement.MemberScope = "instance";
                memberElement.Type = new TypeElement(member.EventHandlerType, false);

                Members.Add(memberElement);
            }
        }

    }
}
