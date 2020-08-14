using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Reflection;
using System.Resources;
using System.Text;
using System.Text.RegularExpressions;
using System.Xml;
using System.Xml.Serialization;
using System.Xml.Schema;

namespace GehtSoft.DocCreator.Parser
{
    public class DsProjectDefine
    {
        private string mName;

        public string Name
        {
            get
            {
                return mName;
            }
        }

        private string mValue;

        public string Value
        {
            get
            {
                return mValue;
            }
        }

        internal DsProjectDefine(Define define)
        {
            mName = define.name;
            mValue = define.value;
        }
    }

    public class DsProjectDefineCollection : IEnumerable<DsProjectDefine>, IDefinitionList
    {
        private List<DsProjectDefine> mList = new List<DsProjectDefine>();
        private Dictionary<string, DsProjectDefine> mDict = new Dictionary<string, DsProjectDefine>();

        public IEnumerator<DsProjectDefine> GetEnumerator()
        {
            return mList.GetEnumerator();
        }

        public Dictionary<string, object> CreateDictionary()
        {
            Dictionary<string, object> props = new Dictionary<string, object>();
            foreach (DsProjectDefine define in mList)
                props[define.Name] = define.Value;
            return props;
        }

        IEnumerator IEnumerable.GetEnumerator()
        {
            return mList.GetEnumerator();
        }

        public int Count
        {
            get
            {
                return mList.Count;
            }

        }

        public DsProjectDefine this[int index]
        {
            get
            {
                return mList[index];
            }

        }

        public bool Exists(string name)
        {
            return mDict.ContainsKey(name);
        }

        internal void Add(DsProjectDefine define)
        {
            mList.Add(define);
            mDict[define.Name] = define;
        }

        internal void Add(DsProjectDefineCollection coll)
        {
            foreach (DsProjectDefine def in coll)
                Add(def);
        }

        internal void Add(Define[] arr)
        {
            foreach (Define def in arr)
                Add(new DsProjectDefine(def));
        }
    }

    public abstract class DsProjectSource
    {
        public abstract int Count
        {
            get;
        }

        public abstract string this[int index]
        {
            get;
        }

        public abstract void Refresh();

        public abstract bool Contains(string file);

        private Encoding mEncoding;

        public Encoding Encoding
        {
            get
            {
                return mEncoding;
            }
        }

        private string mName;

        public string Name
        {
            get
            {
                return mName;
            }
        }


        internal DsProjectSource(string projectPath, bool dir, string name, string encoding)
        {
            try
            {
                if (dir)
                {
                    DirectoryInfo di = new DirectoryInfo(Path.Combine(projectPath, name));
                    if (!di.Exists)
                        throw new FileNotFoundException("Directory is not found", name);
                    mName = di.FullName;
                }
                else
                {
                    FileInfo fi = new FileInfo(Path.Combine(projectPath, name));
                    if (!fi.Exists)
                        throw new FileNotFoundException("File is not found", name);
                    mName = fi.FullName;
                }
                mEncoding = Encoding.GetEncoding(encoding);
            }
            catch (Exception e)
            {
                throw new IOError(name, e);
            }
        }
    }

    public class DsProjectSourceCollection : IEnumerable<DsProjectSource>
    {
        private List<DsProjectSource> mList = new List<DsProjectSource>();

        public IEnumerator<DsProjectSource> GetEnumerator()
        {
            return mList.GetEnumerator();
        }

        IEnumerator IEnumerable.GetEnumerator()
        {
            return mList.GetEnumerator();
        }

        public int Count
        {
            get
            {
                return mList.Count;
            }

        }

        public DsProjectSource this[int index]
        {
            get
            {
                return mList[index];
            }
        }

        internal DsProjectSourceCollection()
        {
        }

        internal void Add(DsProjectSource src)
        {
            mList.Add(src);
        }

        public bool Contains(string file)
        {
            for (int i = 0; i < mList.Count; i++)
                if (mList[i].Contains(file))
                    return true;
            return false;
        }

    }

    internal class DsProjectFileSource : DsProjectSource
    {
        override public bool Contains(string file)
        {
            return file.Equals(Name, StringComparison.CurrentCultureIgnoreCase);
        }

        override public int Count
        {
            get
            {
                return 1;
            }
        }

        override public string this[int index]
        {
            get
            {
                if (index != 0)
                    throw new ArgumentOutOfRangeException("index");
                return Name;
            }
        }

        override public void Refresh()
        {
            return ;
        }

        internal DsProjectFileSource(string projectPath, SourceFile file) : base(projectPath, false, file.name, file.encoding)
        {
        }
    }

    internal class DsProjectFolderSource : DsProjectSource
    {
        private Regex mMaskRe;
        private string mMask;
        private bool mRecursive;
        private List<string> mFiles = null;

        override public void Refresh()
        {
            if (mFiles == null)
                mFiles = new List<string>();
            else
                mFiles.Clear();
            Scan(Name);
        }

        private void Scan(string folder)
        {
            string[] files = Directory.GetFiles(folder);
            for (int i = 0; i < files.Length; i++)
            {
                FileInfo fi = new FileInfo(files[i]);
                if (mMaskRe.IsMatch(fi.Name))
                    mFiles.Add(fi.FullName);
            }

            if (mRecursive)
            {
                string[] dirs = Directory.GetDirectories(folder);
                for (int i = 0; i < dirs.Length; i++)
                    Scan(dirs[i]);
            }
        }

        override public bool Contains(string file)
        {
            if (mFiles == null)
                Refresh();
            for (int i = 0; i < mFiles.Count; i++)
                if (file.Equals(mFiles[i], StringComparison.CurrentCultureIgnoreCase))
                    return true;
            return false;
        }

        override public int Count
        {
            get
            {
                if (mFiles == null)
                    Refresh();
                return mFiles.Count;
            }
        }

        override public string this[int index]
        {
            get
            {
                if (mFiles == null)
                    Refresh();
                return mFiles[index];
            }
        }

        internal DsProjectFolderSource(string projectPath, SourceFolder folder) : base(projectPath, true, folder.name, folder.encoding)
        {
            try
            {
                mMaskRe = new Regex(folder.mask);
            }
            catch (Exception e)
            {
                throw new IOError(folder.name, "The mask regular expression is invalid for the folder " + folder.name + ":" + e.Message, e);
            }
            mRecursive = folder.recursive;
            mMask = folder.mask;
        }
    }

    public class DsProjectOutput
    {
        private DsProjectDefineCollection mDefinitions;

        public DsProjectDefineCollection Definitions
        {
            get
            {
                return mDefinitions;
            }
        }

        private string mTemplate;

        public string Template
        {
            get
            {
                return mTemplate;
            }
        }

        private string mFile;

        public string File
        {
            get
            {
                return mFile;
            }
        }

        private Encoding mEncoding;

        public Encoding Encoding
        {
            get
            {
                return mEncoding;
            }
        }

        internal DsProjectOutput(DsProjectDefineCollection commonDefs, Output output)
        {
            mDefinitions = new DsProjectDefineCollection();
            mDefinitions.Add(commonDefs);
            if (output.define != null)
                mDefinitions.Add(output.define);

            if (output.template.Contains("%"))
                output.template = Environment.ExpandEnvironmentVariables(output.template);

            mTemplate = output.template;

            if (output.file.Contains("%"))
                output.file = Environment.ExpandEnvironmentVariables(output.file);

            mFile = output.file;
            try
            {
                mEncoding = Encoding.GetEncoding(output.encoding);
            }
            catch (Exception e)
            {
                throw new IOError(output.file, e);
            }
        }
    }

    public class DsProjectOutputCollection : IEnumerable<DsProjectOutput>
    {
        private List<DsProjectOutput> mList = new List<DsProjectOutput>();

        public IEnumerator<DsProjectOutput> GetEnumerator()
        {
            return mList.GetEnumerator();
        }

        IEnumerator IEnumerable.GetEnumerator()
        {
            return mList.GetEnumerator();
        }

        public int Count
        {
            get
            {
                return mList.Count;
            }

        }

        public DsProjectOutput this[int index]
        {
            get
            {
                return mList[index];
            }

        }

        internal DsProjectOutputCollection()
        {
        }

        internal void Add(DsProjectOutput output)
        {
            mList.Add(output);
        }

        internal void Add(DsProjectDefineCollection commonDefs, Output[] outputs)
        {
            for (int i = 0; i < outputs.Length; i++)
                mList.Add(new DsProjectOutput(commonDefs, outputs[i]));
        }
    }


    public class DsProject
    {
        private Project mProject = null;
        private string mFileName = null;
        private List<Exception> mErrors = null;
        private object mMutex = new object();
        private DsProjectDefineCollection mCommonDefinitions;
        DsProjectSourceCollection mSources;
        DsProjectOutputCollection mOutputs;

        public DsProjectDefineCollection CommonDefinitions
        {
            get
            {
                return mCommonDefinitions;
            }
        }

        public DsProjectSourceCollection Sources
        {
            get
            {
                return mSources;
            }
        }

        public DsProjectOutputCollection Outputs
        {
            get
            {
                return mOutputs;
            }
        }

        public DsProject()
        {
        }

        public List<Exception> LoadProject(string projectFile)
        {
            lock (mMutex)
            {
                List<Exception> errors = new List<Exception>();
                XmlSchemaSet schemas = null;
                try
                {
                    Stream stream = this.GetType().Assembly.GetManifestResourceStream("docgen2.parser.resource.resources.resources");
                    ResourceReader reader = new ResourceReader(stream);
                    MemoryStream schemeStream;
                    XmlReader schemeReader;
                    schemas = new XmlSchemaSet();

                    byte[] data = null;
                    string type = "";

                    reader.GetResourceData("project", out type, out data);
                    schemeStream = new MemoryStream(data, 4, data.Length - 4);
                    schemeReader = XmlReader.Create(schemeStream);
                    schemas.Add(null, schemeReader);

                    schemeReader.Close();
                    schemeStream.Close();

                    reader.Close();
                    stream.Close();
                }
                catch (Exception e)
                {
                    errors.Add(new IOError("docgen2.parser.dll/project.xsd", e));
                    return errors;
                }

                mErrors = errors;
                mFileName = projectFile;
                try
                {
                    XmlReaderSettings settings = new XmlReaderSettings();
                    settings.ValidationType = ValidationType.Schema;
                    settings.Schemas = schemas;
                    settings.ValidationEventHandler += new ValidationEventHandler(validationEvent);
                    XmlReader reader = XmlReader.Create(projectFile, settings);
                    XmlSerializer serializer = new XmlSerializer(typeof(Project));
                    mProject = (Project)serializer.Deserialize(reader);
                    reader.Close();
                }
                catch (Exception e)
                {
                    errors.Add(new IOError(projectFile, e));
                    return errors;
                }

                if (errors.Count > 0)
                    return errors;

                mCommonDefinitions = new DsProjectDefineCollection();
                if (mProject.common != null && mProject.common.define != null)
                    mCommonDefinitions.Add(mProject.common.define);

                FileInfo fi = new FileInfo(projectFile);
                string projectPath = fi.Directory.FullName;

                mSources = new DsProjectSourceCollection();

                if (mProject.source != null && mProject.source.Items != null)
                {
                    for (int i = 0; i < mProject.source.Items.Length; i++)
                    {
                        try
                        {
                            if (mProject.source.Items[i] is SourceFile)
                                mSources.Add(new DsProjectFileSource(projectPath, mProject.source.Items[i] as SourceFile));
                            else if (mProject.source.Items[i] is SourceFolder)
                                mSources.Add(new DsProjectFolderSource(projectPath, mProject.source.Items[i] as SourceFolder));
                        }
                        catch (Error e)
                        {
                            errors.Add(e);
                        }
                    }
                }

                mOutputs = new DsProjectOutputCollection();

                if (mProject.output != null && mProject.output.Length != 0)
                {
                    for (int i = 0; i < mProject.output.Length; i++)
                    {
                        try
                        {
                            mOutputs.Add(new DsProjectOutput(mCommonDefinitions, mProject.output[i]));
                        }
                        catch (Error e)
                        {
                            errors.Add(e);
                        }
                    }
                }



                return errors;
            }


        }

        private void validationEvent(Object sender, ValidationEventArgs args)
        {
            mErrors.Add(new IOError(mFileName, String.Format("{0} [{1}, {2}] : {3}", mFileName, args.Exception.LineNumber, args.Exception.LinePosition, args.Exception.Message), args.Exception));
        }
    }
}