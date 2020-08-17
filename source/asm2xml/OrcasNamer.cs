// Copyright (c) Microsoft Corporation.  All rights reserved.
//

using System;
// using System.Collections.Generic;
using System.IO;
using System.Reflection;


namespace AssemblyToXml
{
    public static class Namer
    {
        public static string GetMemberName(MemberInfo member)
        {
            using (TextWriter writer = new StringWriter())
            {

                switch (member.MemberType)
                {
                    case MemberTypes.Field:
                        writer.Write("F:");
                        WriteField((FieldInfo) member, writer);
                        break;
                    case MemberTypes.Property:
                        writer.Write("P:");
                        WriteProperty((PropertyInfo) member, writer);
                        break;
                    case MemberTypes.Method:
                        writer.Write("M:");
                        WriteMethod((MethodInfo) member, writer);
                        break;
                    case MemberTypes.Constructor:
                        writer.Write("M:");
                        WriteConstructor((ConstructorInfo) member, writer);
                        break;
                    case MemberTypes.Event:
                        writer.Write("E:");
                        WriteEvent((EventInfo)member, writer);
                        break;
                }

                return (writer.ToString());
            }

        }

        public static string GetTypeName(TypeInfo type)
        {
            using (TextWriter writer = new StringWriter())
            {
                writer.Write("T:");
                WriteType(type, writer);
                return (writer.ToString());
            }
        }

        private static void WriteConstructor(ConstructorInfo constructor, TextWriter writer)
        {
            WriteType(constructor.DeclaringType.GetTypeInfo(), writer);
            if (constructor.IsStatic)
                writer.Write(".#cctor");
            else
                writer.Write(".#ctor");
            WriteParameters(constructor.GetParameters(), writer);
        }

        public static string TrimTemplate(this string name)
        {
            int index = name.IndexOf('`');
            if (index >= 0)
                name = name.Substring(0, index);

            index = name.IndexOf('&');
            if (index >= 0)
                name = name.Substring(0, index);

            return name;
        }

        private static void WriteEvent(EventInfo trigger, TextWriter writer)
        {
            WriteType(trigger.DeclaringType.GetTypeInfo(), writer);
            writer.Write(".{0}", trigger.Name.TrimTemplate());
        }

        private static void WriteField(FieldInfo field, TextWriter writer)
        {
            WriteType(field.DeclaringType.GetTypeInfo(), writer);
            writer.Write(".{0}", field.Name.TrimTemplate());
        }

        private static void WriteMethod(MethodInfo method, TextWriter writer)
        {
            string name = method.Name.TrimTemplate();
            WriteType(method.DeclaringType.GetTypeInfo(), writer);
            writer.Write(".{0}", name);

            if (method.IsGenericMethod)
            {
                var genericParameters = method.GetGenericArguments();
                if (genericParameters != null)
                    writer.Write("``{0}", genericParameters.Length);
            }

            WriteParameters(method.GetParameters(), writer);

            // add ~ for conversion operators
            if ((name == "op_Implicit") || (name == "op_Explicit"))
            {
                writer.Write("~");
                WriteType(method.ReturnType.GetTypeInfo(), writer);
            }

        }

        private static void WriteParameters(ParameterInfo[] parameters, TextWriter writer)
        {
            if ((parameters == null) || (parameters.Length == 0))
                return;
            writer.Write("(");
            for (int i = 0; i < parameters.Length; i++)
            {
                if (i > 0) writer.Write(",");
                WriteType(parameters[i].ParameterType.GetTypeInfo(), writer);
            }
            writer.Write(")");
        }

        private static void WriteProperty(PropertyInfo property, TextWriter writer)
        {
            WriteType(property.DeclaringType.GetTypeInfo(), writer);
            writer.Write("." + property.Name.TrimTemplate());
            if (property.GetMethod != null && property.GetMethod.GetParameters()?.Length > 0)
                WriteParameters(property.GetMethod.GetParameters(), writer);
        }

        private static void WriteType(TypeInfo type, TextWriter writer)
        {
            if (type.IsArray)
            {
                WriteType(type.GetElementType().GetTypeInfo(), writer);
                writer.Write("[");
                if (type.GetArrayRank() > 1)
                {
                    for (int i = 0; i < type.GetArrayRank(); i++)
                    {
                        if (i > 0) writer.Write(",");
                        writer.Write("0:");
                    }
                }

                writer.Write("]");
            }
            else if (type.IsGenericParameter)
            {
                if (type.DeclaringMethod != null)
                    writer.Write("``");
                else
                    writer.Write("`");
                writer.Write(type.GenericParameterPosition);
            }
            else
            {
                if (type.DeclaringType != null)
                {
                    WriteType(type.DeclaringType.GetTypeInfo(), writer);
                    writer.Write(".");
                }
                else if (!string.IsNullOrEmpty(type.Namespace))
                {
                    writer.Write(type.Namespace);
                    writer.Write(".");
                }

                writer.Write(type.Name.TrimTemplate());
                if (type.IsGenericType)
                {
                    if (type.IsGenericTypeDefinition)
                    {
                        if (type.Name.IndexOf('`') >= 0)
                        {
                            writer.Write(type.Name.Substring(type.Name.IndexOf('`')));
                        }
                        else
                        {
                            writer.Write("`");
                            var args = type.GetGenericArguments();
                            writer.Write(args.Length);
                        }
                    }
                    else
                    {
                        writer.Write("{");
                        var args = type.GetGenericArguments();
                        for (int i = 0; i < args.Length; i++)
                        {
                            if (i > 0)
                                writer.Write(",");
                            WriteType(args[i].GetTypeInfo(), writer);
                        }

                        writer.Write("}");
                    }
                }
            }
        }
    }
}
