using System;
using System.Collections;
using System.Reflection;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;
using System.Xml.Serialization;
using Mono.Cecil;
using System.Collections.Generic;
using System.Linq;

namespace AssemblyToXml
{
    class AssemblyResolver : DefaultAssemblyResolver
    {
        public AssemblyResolver(string[] allAssembliesToProcess)
        {
            foreach (string assemblyName in allAssembliesToProcess)
            {
                if (File.Exists(assemblyName))
                {
                    var assembly = AssemblyDefinition.ReadAssembly(assemblyName);
                    RegisterAssembly(assembly);
                }
            }
        }

        public override AssemblyDefinition Resolve(AssemblyNameReference name)
        {
            ;
            return base.Resolve(name);
        }
    }

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

        public AssemblyElement(string assembly, string[] allAssemblies)
        {
            if (!Path.IsPathRooted(assembly))
                assembly = Path.GetFullPath(assembly);

            FileInfo fi = new FileInfo(assembly);
            if (!fi.Exists)
                throw new FileNotFoundException("Assembly is not found", assembly);

            AssemblyPath = assembly;
            Location = fi.DirectoryName;
            Name = fi.Name.Substring(0, fi.Name.Length - fi.Extension.Length);

            var readParameters = new ReaderParameters()
            {
                AssemblyResolver = new AssemblyResolver(allAssemblies)
            };
            ModuleDefinition module = ModuleDefinition.ReadModule(assembly, readParameters);

            List<TypeElement> types = new List<TypeElement>();
            foreach (var type in module.GetTypes())
                AddTypes(types, type);
            Types = types.ToArray();

        }

        private static void AddTypes(ICollection<TypeElement> types, TypeDefinition type)
        {
            if (type.IsPublic || type.IsNestedPublic)
            {
                if (type.CustomAttributes.FirstOrDefault(ci => ci.AttributeType.Name == "DocgenIgnoreAttribute") == null)
                {
                    types.Add(new TypeElement(type));
                    if (type.NestedTypes != null)
                        foreach (var ntype in type.NestedTypes)
                            AddTypes(types, ntype);
                }
            }
        }
    }
}
