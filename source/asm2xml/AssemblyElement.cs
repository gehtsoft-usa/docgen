using System;
using System.Collections;
using System.Reflection;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;
using System.Xml.Serialization;
using Mono.Cecil;
using System.Collections.Generic;

namespace AssemblyToXml
{
    public class AssemblyElement 
    {
        private readonly Assembly mAssembly;

        [XmlAttribute(AttributeName = "path")]
        public string AssemblyPath { get; set; }

        [XmlAttribute(AttributeName = "location")]
        public string Location { get; set; }

        [XmlAttribute(AttributeName = "name")]
        public string Name { get; set; }

        [XmlElement(ElementName = "type")]
        public TypeElement[] Types { get; set; } 

        public AssemblyElement()
        {

        }

        public AssemblyElement(string assembly)
        {
            if (!Path.IsPathRooted(assembly))
                assembly = Path.GetFullPath(assembly);

            FileInfo fi = new FileInfo(assembly);
            if (!fi.Exists)
                throw new FileNotFoundException("Assembly is not found", assembly);

            ModuleDefinition module = ModuleDefinition.ReadModule(assembly);

            List<TypeElement> types = new List<TypeElement>();
            foreach (var type in module.GetTypes())
            {
                if (type.IsPublic)
                    types.Add(new TypeElement(type));
            }
            Types = types.ToArray();

        }
    }
}
