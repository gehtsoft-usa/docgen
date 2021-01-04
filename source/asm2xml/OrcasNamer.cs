// Copyright (c) Microsoft Corporation.  All rights reserved.
//

using Mono.Cecil;
using Mono.Collections.Generic;
using System;
// using System.Collections.Generic;
using System.IO;
using System.Reflection;


namespace AssemblyToXml
{
    public static class Namer
    {
        public static string GetMemberName(IMemberDefinition member)
        {
            using (TextWriter writer = new StringWriter())
            {

                switch (member)
                {
                    case FieldDefinition f:
                        writer.Write("F:");
                        WriteField(f, writer);
                        break;
                    case PropertyDefinition p:
                        writer.Write("P:");
                        WriteProperty(p, writer);
                        break;
                    case MethodDefinition m:
                        writer.Write("M:");
                        WriteMethod(m, writer);
                        break;
                    case EventDefinition e:
                        writer.Write("E:");
                        WriteEvent(e, writer);
                        break;
                }

                return (writer.ToString());
            }

        }

        public static string GetTypeName(TypeReference type)
        {
            using (TextWriter writer = new StringWriter())
            {
                writer.Write("T:");
                WriteType(type, writer);
                return (writer.ToString());
            }
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

        private static void WriteEvent(EventDefinition trigger, TextWriter writer)
        {
            WriteType(trigger.DeclaringType, writer);
            writer.Write(".{0}", trigger.Name.TrimTemplate());
        }

        private static void WriteField(FieldDefinition field, TextWriter writer)
        {
            WriteType(field.DeclaringType, writer);
            writer.Write(".{0}", field.Name.TrimTemplate());
        }

        private static void WriteMethod(MethodDefinition method, TextWriter writer)
        {
            string name = method.Name.TrimTemplate();
            WriteType(method.DeclaringType, writer);
            writer.Write(".{0}", name);

            if (method.GenericParameters.Count > 0)
                writer.Write("``{0}", method.GenericParameters.Count);

            WriteParameters(method.Parameters, writer);

            // add ~ for conversion operators
            if ((name == "op_Implicit") || (name == "op_Explicit"))
            {
                writer.Write("~");
                WriteType(method.ReturnType, writer);
            }

        }

        private static void WriteParameters(Collection<ParameterDefinition> parameters, TextWriter writer)
        {
            if ((parameters == null) || (parameters.Count == 0))
                return;
            writer.Write("(");
            for (int i = 0; i < parameters.Count; i++)
            {
                if (i > 0) writer.Write(",");
                WriteType(parameters[i].ParameterType, writer);
            }
            writer.Write(")");
        }

        private static void WriteProperty(PropertyDefinition property, TextWriter writer)
        {
            WriteType(property.DeclaringType, writer);
            writer.Write("." + property.Name.TrimTemplate());

            if (property.GetMethod != null && property.GetMethod.Parameters.Count > 0)
                WriteParameters(property.GetMethod.Parameters, writer);
        }

        private static void WriteType(TypeReference type, TextWriter writer)
        {
            if (type.IsArray)
            {
                var array = type as ArrayType;

                WriteType(type.GetElementType(), writer);
                writer.Write("[");
                if (array.Rank > 1)
                {
                    for (int i = 0; i < array.Rank; i++)
                    {
                        if (i > 0) writer.Write(",");
                        writer.Write("0:");
                    }
                }
                writer.Write("]");
            }
            else if (type.IsGenericParameter)
            {
                var genericParam = type as GenericParameter;
                if (genericParam.DeclaringMethod != null)
                    writer.Write("``");
                else
                    writer.Write("`");
                writer.Write(genericParam.Position);
            }
            else
            {
                if (type.DeclaringType != null)
                {
                    WriteType(type.DeclaringType, writer);
                    writer.Write(".");
                }
                else if (!string.IsNullOrEmpty(type.Namespace))
                {
                    writer.Write(type.Namespace);
                    writer.Write(".");
                }

                writer.Write(type.Name.TrimTemplate());

                if (type.HasGenericParameters)
                {
                    writer.Write("`");
                    writer.Write(type.GenericParameters.Count);
                }

                if (type is GenericInstanceType genericInstance)
                {
                    if (genericInstance.HasGenericArguments)
                    {
                        writer.Write("{");
                        for (int i = 0; i < genericInstance.GenericArguments.Count; i++)
                        {
                            if (i > 0)
                                writer.Write(",");
                            WriteType(genericInstance.GenericArguments[i], writer);
                        }
                        writer.Write("}");
                    }
                }
            }
        }
    }
}
