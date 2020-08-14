using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO.Compression;
using System.Net;
using GehtSoft.DocCreator.Parser;
using System.Xml;
using GehtSoft.DocCreator.Output;

namespace Gehtsoft.Build.DocGen
{
    public class DocGen : Microsoft.Build.Utilities.Task
    {
        public string Project { get; set; }

        public override bool Execute()
        {
            //define/redefine docgen variable to point out the templates
            var p = Path.GetFullPath(this.GetType().Assembly.Location);
            p = Path.Combine(Directory.GetParent(p).Parent.Parent.FullName, "Content");
            if (!Directory.Exists(Path.Combine(p, "template")))
            {
                Log.LogError("The templates are expected to be in {0}", p);
                return false;
            }
            Environment.SetEnvironmentVariable("docgen", p);

            DsProject project = new DsProject();
            List<Exception> loadErrors = null;
            try
            {
                loadErrors = project.LoadProject(Project);
            }
            catch (Exception e)
            {
                Log.LogError("unexpected exception while loading project\n{0}", e.ToString());
                return false;
            }

            if (loadErrors != null && loadErrors.Count > 0)
            {
                Console.WriteLine("Project loading errors");
                foreach (Exception e in loadErrors)
                    Log.LogError("{0}", e.ToString());
                return false;
            }

            DsFileParser parser = new DsFileParser();
            int i, l;

            if (project.Sources.Count > 0)
            {
                Log.LogMessage("Parse project {0}...", Project);
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
                            parser.ParseFile(src, errors, null);
                        }
                    }
                    if (errors.Count > 0)
                    {
                        Log.LogError("Project loading errors:");
                        foreach (Error e in errors)
                            Log.LogError("{0}", e.Message);
                        return false;
                    }
                }
                catch (Exception e)
                {
                    Log.LogError("unexpected exception while parsing the project\n{0}", e.ToString());
                    return false;
                }
            }
            else
            {
                Log.LogError("Project {0} contains no files", Project);
                return false;
            }



            if (parser.Root.Content.Count == 0)
            {
                Log.LogError("Project {0} source contains no objects", Project);
                Environment.ExitCode = -6;
                return false;
            }

            {
                List<Error> errors = new List<Error>();
                parser.Root.PostProcess(errors);
                if (errors.Count > 0)
                {
                    Log.LogError("Processing imports errors");
                    foreach (Error e in errors)
                        Log.LogError("{0}", e.Message);
                    return false;
                }
            }

            l = project.Outputs.Count;
            for (i = 0; i < l; i++)
            {
                DsProjectOutput output = project.Outputs[i];
                Log.LogMessage("Writing {0} using {1}", output.File, output.Template);
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
                    Log.LogError("Xslt Transformation exception {0}", e.ToString());
                    return false;
                }
                catch (Exception e)
                {
                    Log.LogError("Unexpected exception:\n{0}", e.ToString());
                    Environment.ExitCode = -8;
                    return false;
                }
            }
            return true;
        }
    }
}

