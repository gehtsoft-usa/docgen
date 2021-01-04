using Microsoft.Build.Framework;
using System.Xml.Serialization;
using System.IO;
using System.Xml;
using System.Text;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using GehtSoft.DocCreator.Parser;

namespace Gehtsoft.Build.DocGen
{
    public class Asm2Xml : Microsoft.Build.Utilities.Task
    {
        public ITaskItem[] Assemblies { get; set; }
        public string OutputXml { get; set; }
        public string Mode { get; set; } = "net50";

        public override bool Execute()
        {
            Log.LogMessage("Scanning assemblies for the documentation data");

            if (Assemblies == null || Assemblies.Length == 0)
            {
                Log.LogError("There is no assemblies to scan");
                return false;
            }

            if (string.IsNullOrEmpty(OutputXml))
            {
                Log.LogError("There is no output file set");
                return false;
            }

            List<string> collection = new List<string>();

            foreach (var assembly in Assemblies)
            {
                if (!string.IsNullOrEmpty(assembly.ItemSpec))
                {
                    if (!File.Exists(assembly.ItemSpec))
                    {
                        Log.LogError($"Assembly {assembly.ItemSpec} does not exists");
                        return false;
                    }
                    collection.Add(assembly.ItemSpec);
                }
            }

            if (collection.Count == 0)
            {
                Log.LogError("There is no assemblies to scan");
                return false;
            }

            StringBuilder args = new StringBuilder();

            var fi = new FileInfo(this.GetType().Assembly.Location);
            var path = Path.GetFullPath(fi.DirectoryName);
            path = Path.GetFullPath(Path.Combine(path, $"../../Content/asm2xml/{Mode}/AssemblyToXml"));
            var di = new DirectoryInfo(path);
            path = di.FullName;

            path = path + ".exe";
            if (!File.Exists(path))
            {
                Log.LogError("The assembly compiler is expected to be at {0}", path);
                 return false;
            }

            foreach (string s in collection)
            {
                if (args.Length > 0)
                    args.Append(' ');
                if (s.IndexOf(' ') >= 0)
                {
                    args.Append('\"');
                    args.Append(s);
                    args.Append('\"');
                }
                else
                {
                    args.Append(s);
                }
            }

            args.Append(" /out:");
            args.Append(OutputXml);

            Log.LogMessage("{0}", path);
            Log.LogMessage("{0}", args.ToString());

            ProcessStartInfo psi = new ProcessStartInfo()
            {
                Arguments = args.ToString(),
                CreateNoWindow = true,
                WindowStyle = ProcessWindowStyle.Hidden,
                RedirectStandardError = true,
                RedirectStandardOutput = true,
                WorkingDirectory = Directory.GetCurrentDirectory(),
                FileName = path,
                UseShellExecute = false,
            };

            if (File.Exists(OutputXml))
                File.Delete(OutputXml);

            var process = Process.Start(psi);
            process.WaitForExit();

            var output = process.StandardOutput.ReadToEnd();

            if (!string.IsNullOrEmpty(output))
                Log.LogWarning("Process output: {0}", output);

            var errors = process.StandardError.ReadToEnd();
            if (!string.IsNullOrEmpty(errors))
            {
                Log.LogError("Process errors: {0}", errors);
                return false;
            }


            if (!File.Exists(OutputXml))
            {
                Log.LogError("Scan failed");
                return false;
            }

            return true;
        }
    }
}

