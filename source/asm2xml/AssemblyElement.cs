using System;
using System.Collections;
using System.Reflection;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;
using System.Xml.Serialization;

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

        public AssemblyElement(System.Reflection.Assembly assembly)
        {
            mAssembly = assembly;
            Initialize();
        }

        public AssemblyElement(string assembly)
        {
            if (!Path.IsPathRooted(assembly))
                assembly = Path.GetFullPath(assembly);

            

            FileInfo fi = new FileInfo(assembly);
            if (!fi.Exists)
                throw new FileNotFoundException("Assembly is not found", assembly);

            Location = fi.Directory.FullName;
            AssemblyPath = assembly;

            var assemblies = AppDomain.CurrentDomain.GetAssemblies();
            foreach (Assembly assembly1 in assemblies)
            {
                string codeBase = assembly1.CodeBase;
                UriBuilder uri = new UriBuilder(codeBase);
                string path = Uri.UnescapeDataString(uri.Path);
                if (string.Compare(path.Replace('/', '\\'), assembly.Replace('/', '\\'), StringComparison.OrdinalIgnoreCase) == 0)
                {
                    mAssembly = assembly1;
                    Initialize();
                    break;
                }
            }


            if (mAssembly == null)
            {
#if NETCORE
                using (var r = new AssemblyResolver(assembly))
                {
                    mAssembly = r.Assembly;
                    Initialize();
                }
#else
            AppDomain.CurrentDomain.AssemblyResolve += (object sender, ResolveEventArgs args) =>
            {
                string assemblyPath = Path.Combine(fi.DirectoryName, new AssemblyName(args.Name).Name + ".dll");
                if (!File.Exists(assemblyPath)) return null;
                return Assembly.LoadFrom(assemblyPath);
            };
            Directory.SetCurrentDirectory(fi.DirectoryName);
            mAssembly = Assembly.LoadFile(assembly);
            Initialize();
#endif
            }
        }

        private void Initialize()
        {
            Name = mAssembly.GetName().Name;

            Type[] types = mAssembly.GetExportedTypes();
            Types = new TypeElement[types.Length];
            for (int i = 0; i < types.Length; i++)
                Types[i] = new TypeElement(types[i], true);
        }


    }
}
