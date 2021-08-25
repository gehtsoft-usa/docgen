using System;
using System.IO;
using System.Text;
using System.Xml;
using System.Xml.Serialization;

namespace AssemblyToXml
{
    static class Program
    {
        static void Main(string[] args)
        {
            AssemblyCollectionElement collection = new AssemblyCollectionElement();
            string outputFile = null;
            try
            {
                foreach (string arg in args)
                {
                    if (arg.StartsWith("/out:"))
                        outputFile = arg.Substring(5);
                    else
                        collection.Assemblies.Add(new AssemblyElement(arg, args));
                }

                foreach (AssemblyElement assembly in collection.Assemblies)
                {
                    foreach (TypeElement type in assembly.Types)
                    {
                        if (!collection.Namespaces.Contains(type.Namespace))
                            collection.Namespaces.Add(type.Namespace);
                    }
                }

                XmlSerializer serializer = new XmlSerializer(typeof(AssemblyCollectionElement));
                if (!string.IsNullOrEmpty(outputFile))
                {
                    if (File.Exists(outputFile))
                        File.Delete(outputFile);

                    using (FileStream fs = new FileStream(outputFile, FileMode.Create, FileAccess.Write, FileShare.None))
                    {
                        XmlWriterSettings settings = new XmlWriterSettings()
                        {
                            Encoding = Encoding.UTF8,
                            Indent = true,

                        };
                        using (XmlWriter writer = XmlWriter.Create(fs, settings))
                        {
                            serializer.Serialize(writer, collection);
                        }
                    }
                }
                else
                {
                    using (StringWriter sw = new StringWriter())
                    {
                        serializer.Serialize(sw, collection);
                        Console.Write(sw);
                    }
                }
            }
            catch (Exception e)
            {
                Console.Error.WriteLine(e.ToString());
            }
        }
    }
}
