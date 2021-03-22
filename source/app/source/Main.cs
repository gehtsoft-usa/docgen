using System;
using System.Threading;
using System.IO;
using System.Text;
using System.Collections.Generic;
using System.Reflection;
using System.Xml;
using GehtSoft.DocCreator.Parser;
using GehtSoft.DocCreator.Output;

namespace GehtSoft.DocCreator
{
    public class Application
    {
        public static void Main(string[] args)
        {
#if NETCOREAPP
            Encoding.RegisterProvider(CodePagesEncodingProvider.Instance);
#endif

            if (args.Length == 0)
            {
                Console.WriteLine("usage: docgen project");
                Environment.ExitCode = -1;
                return ;
            }

            DsProject project = new DsProject();
            List<Exception> loadErrors = null;
            try
            {
                loadErrors = project.LoadProject(args[0]);
            }
            catch (Exception e)
            {
                Console.WriteLine("unexpected exception while loading project\n{0}", e.ToString());
                Environment.ExitCode = -2;
                return ;
            }

            if (loadErrors != null && loadErrors.Count > 0)
            {
                Console.WriteLine("Project loading errors");
                foreach (Exception e in loadErrors)
                    Console.WriteLine("{0}", e.ToString());
                Environment.ExitCode = -3;
                return ;
            }

            DsFileParser parser = new DsFileParser();
            int i, l;

            if (project.Sources.Count > 0)
            {
                Console.WriteLine("Parse project...");
                try
                {
                    List<Error> errors = new List<Error>();

                    int j, l1;
                    l = project.Sources.Count;
                    for (i = 0; i < l; i++)
                    {
                        DsProjectSource s = project.Sources[i];
                        l1 = s.Count;
                        for (j = 0; j < l1; j++)
                        {
                            string file = s[j];
                            FileParserSource src = new FileParserSource(file, s.Encoding);
                            parser.ParseFile(src, errors, null, project.CommonDefinitions);
                        }
                    }
                    if (errors.Count > 0)
                    {
                        Console.WriteLine("Project loading errors");
                        foreach (Error e in errors)
                            Console.WriteLine("{0}", e.Message);
                        Environment.ExitCode = -4;
                        return ;
                    }
                }
                catch (Exception e)
                {
                    Console.WriteLine("unexpected exception while parsing the project\n{0}", e.ToString());
                    Environment.ExitCode = -5;
                    return ;
                }
            }
            else
            {
                Console.WriteLine("Project contains no files");
                Environment.ExitCode = -6;
                return ;
            }



            if (parser.Root.Content.Count == 0)
            {
                Console.WriteLine("Project source contains no objects");
                Environment.ExitCode = -6;
                return ;
            }

            {
                List<Error> errors = new List<Error>();
                parser.Root.PostProcess(errors);
                if (errors.Count > 0)
                {
                    Console.WriteLine("Processing imports errors");
                    foreach (Error e in errors)
                        Console.WriteLine("{0}", e.Message);
                    Environment.ExitCode = -7;
                    return ;
                }
            }

            l = project.Outputs.Count;
            for (i = 0; i < l; i++)
            {
                DsProjectOutput output = project.Outputs[i];
                Console.WriteLine("Writing {0} using {1}", output.File, output.Template);
                XmlDocument doc = new XmlDocument();
                XmlNode root = parser.Root.ItemToXml(doc, output.Definitions);
                doc.AppendChild(root);
                Dictionary<string, object> settings = output.Definitions.CreateDictionary();

                try
                {
                    XsltTransform.Reset();
                    XsltTransform.Transform(output.Template, doc.CreateNavigator(), output.File, output.Encoding.WebName, settings);
                }
                catch (XsltExceptionEx e)
                {
                    Console.WriteLine("Xslt Transformation exception");
                    e.Dump();
                }
                catch (Exception e)
                {
                    Console.WriteLine("Unexpected exception:\n{0}", e.ToString());
                    Environment.ExitCode = -8;
                    return ;
                }
            }
        }
    }
}