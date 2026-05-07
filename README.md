# DocGen

DocGen is a documentation generator built around a lightweight, plain-text source format (`.ds`) and an XSLT-driven template engine. It turns hand-written docs and machine-extracted API metadata into a single, navigable help system — HTML, CHM, or Markdown.

## Why DocGen

Writing and shipping technical documentation usually means choosing between two unhappy paths: hand-written prose that drifts away from the code, or auto-generated API reference that no human enjoys reading. Most tools optimize for one and treat the other as a footnote.

DocGen is built on the assumption that real documentation is both. The same project can blend hand-authored articles, conceptual overviews, and tutorials with API reference extracted from .NET assemblies, Java sources, Doxygen output, or SQL schemas — all rendered through the same templates, cross-linked, indexed, and searchable as one cohesive site.

It exists because we needed a tool that:

- Lets writers work in plain text (`.ds`), versioned alongside the code it documents.
- Produces output that looks like a polished help system, not a wiki dump.
- Plugs into MSBuild so docs are built and validated as part of CI.
- Is fully customizable at the template level — you own the look, the structure, and the navigation.

## What it does

- **Authors documentation** from `.ds` source files (a compact, BBCode-flavored markup) with support for articles, tutorials, examples, diagrams, and embedded code.
- **Imports API reference** from external sources via converter templates: .NET (`asm2xml` + `cs2ds`), Java (`jeldoclet2ds`), Doxygen (`doxygen2ds`), Sandcastle (`sandcastle2ds`), SQL schema (`sql2ds`), and Python (`python2ds`).
- **Generates output** — HTML help sites, CHM, and Markdown — via XSLT 1.0 templates with a set of extension functions tailored for multi-file generation.
- **Integrates with MSBuild** through the `Gehtsoft.Build.DocGen` task, so doc builds are a normal step in your pipeline.
- **Ships a VS Code extension** for `.ds` syntax highlighting and authoring support.

## Documentation

Full user and template documentation lives at **<https://docs.gehtsoftusa.com/docgen/>**.

That site covers the `.ds` syntax, project file format, all converter and output templates, the MSBuild task, and the XSLT extension functions used by templates.

## Use with AI assistants

A genAI skill for using DocGen with Claude and Codex is published at **<https://github.com/nikolaygekht/gehtsoft-docgen-skill>**.

The skill teaches the assistant the `.ds` syntax, project layout, and conventions, so you can ask it to write or update documentation alongside your code.

## License

DocGen is released under the **GNU General Public License v3.0**. See [LICENSE](LICENSE) for the full text.
