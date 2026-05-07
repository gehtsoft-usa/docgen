# Working on docgen with Claude

This file tells Claude how to be useful when developing **the docgen tool itself** — the parser, output engine, MSBuild task, asm2xml, and bundled templates. If you came here to *use* docgen to author documentation for another project, see the public docs at <https://docs.gehtsoftusa.com/docgen/> and the AI skill at <https://github.com/nikolaygekht/gehtsoft-docgen-skill>.

## What this repository is

Docgen is a documentation generator: it reads `.ds` source files (a compact BBCode-flavored markup) and machine-extracted API metadata, builds a unified model keyed by `@key`, and renders the model through XSLT 1.0 templates into HTML, CHM, or Markdown.

The repository contains:

- The CLI tool (`docgen.exe`)
- The parser library (`docgen2.parser.dll`)
- The output/XSLT runtime (`docgen2.output.dll`)
- The MSBuild task NuGet package (`Gehtsoft.Build.DocGen`)
- A companion extractor for .NET assemblies (`asm2xml`)
- All bundled XSLT templates
- A VS Code extension for `.ds` syntax
- Docgen's own documentation built with itself

## Repository layout

```
docgen/
├── source/                       all .NET source code
│   ├── docgen.sln                solution file
│   ├── app/        docgen.csproj         CLI executable; targets net8.0
│   ├── parser/     docgen2.parser.csproj .ds and project.xml parser; netstandard2.0
│   ├── output/     docgen2.output.csproj XSLT engine and extension functions; netstandard2.0
│   ├── asm2xml/    AssemblyToXml.csproj  .NET assembly → XML extractor; multi-TFM
│   ├── msbuild/    Gehtsoft.Build.DocGen.csproj  MSBuild task; net472 + netstandard2.0
│   └── msbuild.test/             sample project exercising the MSBuild task
├── template/                     bundled XSLT templates (html, markdown, cs2ds, doxygen2ds, …)
├── test/                         test projects for templates and parser
├── integration/vscode/           VS Code extension for .ds files
├── doc1/                         docgen's own documentation, built via its own tool
├── bin/                          built CLI binaries — committed, consumed by doc1 build
├── TEMPLATE-DEVELOPMENT-GUIDE.md template authoring deep-dive
└── README.md
```

`/bin/` is committed on purpose — `doc1/project.proj` invokes `dotnet ../bin/docgen.dll` to build the project's own docs without requiring a fresh build of the tool.

## How the pieces fit together

```
.ds source files ──┐
                   ├─→ docgen2.parser ─→ XML model ─→ docgen2.output (XSLT) ─→ HTML / CHM / Markdown
project.xml ───────┘                          ▲
                                              │
            asm2xml (C# DLLs) ─→ raw.xml ──[cs2ds template]── auto-generated .ds
            doxygen (C++/Java) ─→ XML ─────[doxygen2ds template]── auto-generated .ds
```

Two separable subsystems share one pipeline:

1. **Authoring path.** Hand-written `.ds` files describe articles, namespaces, classes, members. The parser turns them into a model.
2. **Extraction path.** External tools (`asm2xml`, doxygen) emit raw XML, which a converter XSLT (`cs2ds`, `doxygen2ds`) renders into more `.ds` files. Same parser, same model.

Both feed the same model. The parser merges entries with the same `@key`: **first match wins** at the entry level, but for `@class` entries, non-conflicting `@member` entries from later files are added. That dual-source merge is the entire reason the tool exists in this shape — hand-written notes plus auto-extracted reference, in one site.

The merge is **silent**. No warning when one file shadows another. When debugging missing or stale content, grep every `<dg:source>` location for the `@key`, then look at load order.

## Build and test

```
# whole solution
cd source && dotnet build docgen.sln

# the CLI (auto-copies output to /bin/ via the CopyLastBuild target on net80)
cd source/app && dotnet build

# the MSBuild task NuGet
cd source/msbuild && dotnet build -c Release
```

Run the CLI against a test project:

```
cd test/markdown
dotnet ../../source/app/bin/Debug/net80/docgen.dll project.xml
```

Test projects under `test/`:

| Folder         | What it exercises                                       |
|----------------|---------------------------------------------------------|
| `markdown/`    | Pre-built XML model → Markdown output                   |
| `compile/`     | Hand-written + raw `.ds` → HTML pipeline                |
| `cs2ds/`       | `cs2ds` converter (assembly XML → `.ds`)                |
| `doxygen/`     | `doxygen2ds` converter (Doxygen XML → `.ds`)            |
| `classtree/`   | Class-tree comparison/match template                    |

These are integration-style tests; there is no xUnit suite. Run them by invoking docgen from the test folder and inspecting `dst/`.

## Where things live in the code

When changing behavior, start at the right file:

| Subsystem                                | File                                                                        |
|------------------------------------------|------------------------------------------------------------------------------|
| Project file (`project.xml`) loading     | `source/parser/source/project/project.cs`                                    |
| Project file XML schema bindings         | `source/parser/source/project/autoproject.cs` (generated from the XSD)       |
| `.ds` parsing — tags, structure          | `source/parser/source/parser/parser.cs`                                      |
| Model classes (groups, classes, members) | `source/parser/source/model/`                                                |
| BBCode parsing (`[b]`, `[link]`, …)      | `source/output/source/bbparser.cs`                                           |
| XSLT pipeline                            | `source/output/source/XsltTransform.cs`                                      |
| XSLT extension functions (`ext:` ns)     | `source/output/source/XsltExtensionObject.cs`                                |
| CRC for member-key suffixes              | `source/output/source/Crc.cs`, `source/asm2xml/Crc.cs`                       |
| CLI entry                                | `source/app/source/Main.cs`                                                  |
| MSBuild task                             | `source/msbuild/DocGen.cs`, `source/msbuild/Asm2Xml.cs`                      |
| Asm2Xml extractor                        | `source/asm2xml/Program.cs`, `*Element.cs`                                   |
| Bundled templates                        | `template/<format>/main.xsl` and friends                                     |

## Common development tasks

### Add a new BBCode tag
Open `source/output/source/bbparser.cs`, add a token rule, then surface it in the relevant `template/<format>/write-*.xsl`. BBCode renders inline; structural concerns belong in `.ds` tags, not BBCode.

### Add a new `@`-tag (top-level `.ds` element)
Add a model class under `source/parser/source/model/`, register it in `parser.cs`, and teach `ItemToXml` how to serialize it. Then add handling in the templates that consume it.

### Add a new XSLT extension function
Add the method to `XsltExtensionObject.cs` (the binding on the `ext:` namespace `urn:gehtsoft-exslt`). Mirror the existing pattern: scope-aware lookup via `let`/`get`/`letglobal`. Document it in `TEMPLATE-DEVELOPMENT-GUIDE.md`.

### Modify a template's HTML/Markdown output
Templates are XSLT 1.0 with the `ext:` extensions documented in `TEMPLATE-DEVELOPMENT-GUIDE.md`. Read that file first — the multi-file output flow and variable scoping aren't obvious from the XSLT alone.

### Bump the MSBuild task NuGet
Edit `source/msbuild/nuget/Gehtsoft.Build.DocGen.nuspec`: bump `<version>` and rewrite `<releaseNotes>` to describe what changed. Pack with `dotnet build -c Release` (the `.nuspec` is invoked by the build).

### Add a new target framework
The asm2xml csproj is the canonical multi-TFM example: `source/asm2xml/AssemblyToXml.csproj` lists every supported runtime. Add the new TFM there and verify it loads. The CLI (`source/app/docgen.csproj`) is single-TFM by design — bump the single value.

### Refresh `/bin/` after changing the CLI
Rebuild `source/app` — `CopyLastBuild` (gated on `TargetFramework == 'net80'`) copies the built artifacts into `/bin/`. If the gate ever drifts again (e.g., the project moves to net9), update the condition.

## Pitfalls and gotchas

- **`Source.Item` vs `Source.Items`.** The XML-serialized `<dg:source>` element exposes `Item` (single, for `<dg:xml-file>`) and `Items` (array, for `<dg:file>`/`<dg:folder>`). Code that checks `Item != null` to decide whether the project has sources is wrong — for `<file>`/`<folder>` projects only `Items` is populated. The branch in `project.cs` is now `if (mProject.source != null)` and walks both shapes; keep it that way.
- **Stale `/bin/`.** The committed CLI in `/bin/` is what `doc1/project.proj` runs. After changing parser or output code, rebuild `source/app` so the `CopyLastBuild` target refreshes `/bin/`. Forgetting this is the usual cause of "I fixed the bug but the test still fails."
- **Generated member keys carry CRC suffixes.** Overloaded methods have keys like `MyMethod.A1B2C3D4`. The CRC is computed in `output/source/Crc.cs` and `asm2xml/Crc.cs`. Don't change those algorithms casually — keys appear in checked-in `.ds` files across consumer projects, and changing the CRC silently breaks every override.
- **Silent merge.** `parser.cs` does not warn when two files define the same `@key`. When a contributor reports "my doc isn't appearing," reach for grep across `<dg:source>` files before assuming a parser bug.
- **`autoproject.cs` is generated.** It came from `xsd.exe` against the project schema. Don't hand-edit it; if the schema changes, regenerate.
- **GPL v3.** This repo and its outputs are GPLv3. When adding source files, keep file headers consistent with the rest of the file's directory.
- **No emojis in code, comments, or committed docs** unless explicitly requested.

## Style and conventions

- Match the existing C# style: braces on their own line, `m`-prefix for private fields, four-space indent, no `var` in places where the existing file spells out the type.
- The parser targets `netstandard2.0` — no C# language features that require a newer BCL.
- Templates are XSLT 1.0; do not introduce XSLT 2.0/3.0 constructs.
- New `<dg:define>` keys go through the templates that consume them — declare them in the relevant `template/<format>/*.xsl` and document in `TEMPLATE-DEVELOPMENT-GUIDE.md`.
- Tests are integration tests under `test/`. When adding behavior, add or extend the matching test project; do not introduce a new test framework without discussion.

## Reference

- `TEMPLATE-DEVELOPMENT-GUIDE.md` — XSLT extension functions, multi-file output flow, variable scoping, dictionary files, model schema. Read before touching templates.
- `source/parser/resource/` — bundled XSD schemas for `project.xml` and the model XML.
- Public user documentation: <https://docs.gehtsoftusa.com/docgen/>
- AI skill for authoring docs with docgen: <https://github.com/nikolaygekht/gehtsoft-docgen-skill>
