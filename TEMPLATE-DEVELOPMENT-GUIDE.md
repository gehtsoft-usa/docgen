# DocGen Template Development Guide

## Overview

This guide explains how to create output templates for the DocGen documentation generation system. Templates use XSLT 1.0 with custom extension functions that enable a more procedural, multi-file output approach.

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Extension Functions Reference](#extension-functions-reference)
3. [Template Structure](#template-structure)
4. [Variable Scoping](#variable-scoping)
5. [Creating Multiple Output Files](#creating-multiple-output-files)
6. [Dictionary Files](#dictionary-files)
7. [XML Source Model](#xml-source-model)
8. [Best Practices](#best-practices)
9. [Example Templates](#example-templates)

---

## Architecture Overview

### Template System Components

```
template/
├── main.xsl              # Entry point - orchestrates the generation
├── write-*.xsl           # Individual output templates for different items
├── dictionary/           # Configuration and localization
│   ├── translation.xml   # Localized strings
│   ├── classes-groups.xml
│   ├── member-groups.xml
│   └── declarations.xml
├── declaration/          # Language-specific syntax templates
├── highlighter/          # Code highlighting support
├── menu/                 # Navigation generation
└── res/                  # Static resources (CSS, JS, images)
```

### Processing Flow

1. **Input**: XML model generated from DS documents (see `ds-document.xsd`)
2. **Main Template**: `main.xsl` initializes global variables and calls sub-templates
3. **Sub-Templates**: Each `write-*.xsl` generates output files using extension functions
4. **Output**: Multiple HTML/text files, content tree, and index

---

## Extension Functions Reference

All extension functions are in the `ext:` namespace (`urn:gehtsoft-exslt`).

### Variable Management

#### `ext:let(name, value)`
Sets a local variable in the current scope.
```xml
<xsl:value-of select="ext:let('curr-item', .)" />
```

#### `ext:letglobal(name, value)`
Sets a global variable accessible from all templates.
```xml
<xsl:value-of select="ext:letglobal('g-root', /root)" />
```

#### `ext:get(name)` / `ext:get(name, default)`
Retrieves a variable value. Search order: local → props → global.
```xml
<xsl:value-of select="ext:get('transform')" />
<xsl:value-of select="ext:get('text-language', 'en')" />
```

#### `ext:exist(name)`
Checks if a variable exists in any scope.
```xml
<xsl:if test="ext:exist('create-group-for-members-with-same-name')">
```

#### `ext:caller(name)`
Gets a variable from the calling template's scope (parent scope).
```xml
<xsl:apply-templates select="ext:caller('group')" />
```

#### `ext:remove(name)` / `ext:removeglobal(name)`
Removes variables from local or global scope.

### File and Template Operations

#### `ext:call(xslt, doc, output, codepage)`
Calls another XSL template and writes output to a file.
```xml
<xsl:value-of select="ext:call('write-article.xsl', /, concat(./@key, '.html'), ext:get('codepage'))" />
```

#### `ext:call(xslt, doc)` / `ext:call(xslt, doc, codepage)`
Calls a template and returns the output as a string.
```xml
<xsl:value-of select="ext:call('write-description.xsl', /)" disable-output-escaping="yes" />
```

#### `ext:document(name)`
Loads an external XML document.
```xml
<xsl:value-of select="ext:let('localization', ext:document('dictionary/translation.xml'))" />
```

### Dynamic XML Document Creation

These functions enable building XML documents during transformation (e.g., table of contents, index).

#### `ext:xmlcreate(docname, rootelement)`
Creates a new dynamic XML document and returns its root node ID.
```xml
<xsl:value-of select="ext:letglobal('g-help-index-root', ext:xmlcreate('help-index', 'root'))" />
```

#### `ext:xmladdelement(docname, parent-id, element-name)`
Adds a child element and returns its ID.
```xml
<xsl:value-of select="ext:let('content-node', ext:xmladdelement('help-content', ext:caller('content-node'), 'node'))" />
```

#### `ext:xmladdattribute(docname, node-id, name, value)`
Adds an attribute to a node.
```xml
<xsl:value-of select="ext:xmladdattribute('help-content', ext:get('content-node'), 'name', ./@title)" />
```

#### `ext:xmladdtext(docname, node-id, text)` / `ext:xmladdcdata(docname, node-id, text)`
Adds text or CDATA content to a node.

#### `ext:xmlgetdocument(docname)`
Retrieves a dynamic document as an XPathNodeIterator.
```xml
<xsl:value-of select="ext:call('write-hhc.xsl', ext:xmlgetdocument('help-content'), 'index.hhc', ext:get('codepage'))" />
```

### String Manipulation

#### `ext:upper(str)` / `ext:lower(str)` / `ext:tostring(obj)`
String transformation functions.

#### `ext:trim(str)` / `ext:ltrim(str)` / `ext:rtrim(str)`
Whitespace removal functions.

#### `ext:replace(text, pattern, value)`
String replacement (literal, not regex).

#### `ext:replaceentity(text)` / `ext:unreplaceentity(text)`
Entity encoding/decoding: `&`, `<`, `>`, `"`.

#### `ext:removehtml(text)`
Removes HTML/BBCode tags from text.

#### `ext:escape(text)`
HTML-encodes text (uses `WebUtility.HtmlEncode`).

### Regular Expressions

#### `ext:match(pattern, text)`
Tests if text matches a regex pattern.
```xml
<xsl:if test="ext:match('^[A-Z]', ./@name)">
```

#### `ext:parse(pattern, text)`
Parses text with regex and returns matches as XML:
```xml
<result count="N">
  <match>full match
    <group>group 1</group>
    <group>group 2</group>
  </match>
  ...
</result>
```

### BBCode Parsing

#### `ext:parsebbcode(text)`
Converts BBCode text to an XML structure for processing.
```xml
<xsl:value-of select="ext:call('write-bbcode.xsl', ext:parsebbcode(./@title))" />
```

### Link and Key Management

#### `ext:registerkey(key)`
Registers a documentation key (for link validation).

#### `ext:registerlink(link)`
Registers a link to a key.

#### `ext:checkkeys()`
Validates that all registered links point to existing keys.

### Utility Functions

#### `ext:trace(message)`
Outputs a message to the console (for debugging).

#### `ext:error(message)`
Throws an exception with the specified message.

#### `ext:strcmp(s1, s2)` / `ext:stricmp(s1, s2)`
String comparison (case-sensitive/insensitive). Returns -1, 0, or 1.

#### `ext:isnull(name)`
Checks if a variable is null.

#### `ext:fileexists(file)`
Checks if a file exists.

#### `ext:methodkey(signature)`
Generates a CRC-based key for a method signature.

---

## Template Structure

### Main Template (`main.xsl`)

The entry point that:
1. Initializes global variables
2. Loads dictionaries and configuration
3. Sets up localization
4. Calls sub-templates for content generation

```xml
<?xml version="1.0" encoding="windows-1252"?>
<xsl:stylesheet version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" encoding="Windows-1252"/>

    <xsl:template match="/">
        <!-- Initialize global variables -->
        <xsl:value-of select="ext:letglobal('g-root', /root)" />
        <xsl:value-of select="ext:letglobal('g-example-serial', 0)" />

        <!-- Load dictionaries -->
        <xsl:value-of select="ext:letglobal('g-classes-groups', ext:document('dictionary/classes-groups.xml'))" />

        <!-- Create dynamic documents -->
        <xsl:value-of select="ext:letglobal('g-help-index-root', ext:xmlcreate('help-index', 'root'))" />

        <!-- Start generation -->
        <xsl:value-of select="ext:call('write-group.xsl', /, concat(ext:get('group')/@key, '.html'), ext:get('codepage'))" />

        <!-- Validate links -->
        <xsl:value-of select="ext:checkkeys()" />
    </xsl:template>
</xsl:stylesheet>
```

### Sub-Template Pattern (`write-*.xsl`)

Individual templates follow this pattern:

```xml
<?xml version="1.0" encoding="windows-1252"?>
<!-- Description of what this template does
     Params: ext:caller('param-name') - description
-->
<xsl:stylesheet version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" />

    <xsl:template match="/">
        <xsl:apply-templates select="ext:caller('target-node')" />
    </xsl:template>

    <xsl:template match="target-element">
        <!-- Register this item's key -->
        <xsl:value-of select="ext:registerkey(./@key)" />

        <!-- Get inherited transform setting -->
        <xsl:value-of select="ext:let('transform', ext:get('default-transform', 'no'))" />
        <xsl:for-each select="ancestor-or-self::*">
            <xsl:if test="count(./@transform) > 0 and ./@transform!='def'">
                <xsl:value-of select="ext:let('transform', ./@transform)" />
            </xsl:if>
        </xsl:for-each>

        <!-- Generate output -->
        <h1><xsl:value-of select="./@title" /></h1>

        <!-- Call other templates -->
        <xsl:value-of select="ext:let('curr-item', .)" />
        <xsl:value-of select="ext:call('write-description.xsl', /)" disable-output-escaping="yes" />

        <!-- Generate child items -->
        <xsl:for-each select="./child-element">
            <xsl:value-of select="ext:call('write-child.xsl', /, concat(./@key, '.html'), ext:get('codepage'))" />
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
```

---

## Variable Scoping

### Three Variable Scopes

1. **Local** (`ext:let`): Variables in the current template only
2. **Global** (`ext:letglobal`): Variables accessible from all templates
3. **Caller** (`ext:caller`): Variables from the parent template that called this one
4. **Props**: Configuration properties passed from the command line

### Variable Resolution Order

`ext:get('name')` searches in this order:
1. Local variables (current template)
2. Props (from command line/configuration)
3. Global variables
4. Returns `null` if not found

### Example: Passing Data Between Templates

**Caller template:**
```xml
<xsl:value-of select="ext:let('article', .)" />
<xsl:value-of select="ext:call('write-article.xsl', /, 'output.html', 'utf-8')" />
```

**Called template:**
```xml
<xsl:template match="/">
    <xsl:apply-templates select="ext:caller('article')" />
</xsl:template>
```

---

## Creating Multiple Output Files

### Pattern 1: Direct File Writing

```xml
<!-- Write a single file -->
<xsl:value-of select="ext:call('template.xsl', /, 'output.html', 'utf-8')" />
```

### Pattern 2: Iterating Over Elements

```xml
<!-- Generate a file for each article -->
<xsl:for-each select="/root/article">
    <xsl:value-of select="ext:let('article', .)" />
    <xsl:value-of select="ext:call('write-article.xsl', /, concat(./@key, '.html'), ext:get('codepage'))" />
</xsl:for-each>
```

### Pattern 3: Recursive Navigation

```xml
<!-- Generate files for groups and all nested items -->
<xsl:template match="group">
    <!-- Write this group's page -->
    <xsl:value-of select="ext:call('write-group.xsl', /, concat(./@key, '.html'), 'utf-8')" />

    <!-- Write all child articles -->
    <xsl:for-each select="ext:get('g-root')/article[./@in-group=current()/@key]">
        <xsl:value-of select="ext:let('article', .)" />
        <xsl:value-of select="ext:call('write-article.xsl', /, concat(./@key, '.html'), 'utf-8')" />
    </xsl:for-each>

    <!-- Recurse into child groups -->
    <xsl:for-each select="ext:get('g-root')/group[./@in-group=current()/@key]">
        <xsl:apply-templates select="." />
    </xsl:for-each>
</xsl:template>
```

### Pattern 4: Building Table of Contents

```xml
<!-- Create dynamic XML document for TOC -->
<xsl:value-of select="ext:let('toc-root', ext:xmlcreate('toc', 'root'))" />

<!-- Add entries while processing -->
<xsl:for-each select="/root/article">
    <xsl:value-of select="ext:let('node', ext:xmladdelement('toc', ext:get('toc-root'), 'entry'))" />
    <xsl:value-of select="ext:xmladdattribute('toc', ext:get('node'), 'title', ./@title)" />
    <xsl:value-of select="ext:xmladdattribute('toc', ext:get('node'), 'href', concat(./@key, '.html'))" />
</xsl:for-each>

<!-- Write TOC file -->
<xsl:value-of select="ext:call('write-toc.xsl', ext:xmlgetdocument('toc'), 'toc.html', 'utf-8')" />
```

---

## Dictionary Files

### Translation Dictionary (`dictionary/translation.xml`)

Provides localized strings for the template.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<dictionary default-language="en">
    <string id="brief">
        <language id="en" value="Brief" />
        <language id="fr" value="Résumé" />
        <language id="ru" value="Резюме" />
    </string>
    <string id="details">
        <language id="en" value="Details" />
        <language id="fr" value="Détails" />
        <language id="ru" value="Описание" />
    </string>
</dictionary>
```

**Loading in main.xsl:**
```xml
<!-- Load localization -->
<xsl:value-of select="ext:let('localization', ext:document('dictionary/translation.xml'))" />
<xsl:value-of select="ext:let('default-language', ext:get('localization')/dictionary/@default-language)" />

<!-- Set current language (from props or default) -->
<xsl:choose>
    <xsl:when test="ext:exist('text-language')" />
    <xsl:otherwise>
        <xsl:value-of select="ext:let('text-language', ext:get('default-language'))" />
    </xsl:otherwise>
</xsl:choose>

<!-- Load all strings into global variables -->
<xsl:for-each select="ext:get('localization')/dictionary/string">
    <xsl:value-of select="ext:let('loc-name', concat('_string_', ./@id))" />
    <xsl:choose>
        <xsl:when test="count(./language[@id=ext:get('text-language')]) > 0">
            <xsl:value-of select="ext:let('loc-value', ./language[@id=ext:get('text-language')]/@value)" />
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="ext:let('loc-value', ./language[@id=ext:get('default-language')]/@value)" />
        </xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select="ext:letglobal(ext:get('loc-name'), ext:get('loc-value'))" />
</xsl:for-each>
```

**Using in templates:**
```xml
<h2><xsl:value-of select="ext:get('_string_brief')" /></h2>
<h2><xsl:value-of select="ext:get('_string_details')" /></h2>
```

### Configuration Dictionaries

**Classes Groups (`dictionary/classes-groups.xml`):**
Groups related class types together.

**Member Groups (`dictionary/member-groups.xml`):**
Defines how to group class members (properties, methods, constructors, etc.).

**Declarations (`dictionary/declarations.xml`):**
Maps declaration types to language-specific templates.

---

## XML Source Model

### Document Structure

See `source/parser/resource/ds-document.xsd` for complete schema.

**Root Elements:**
- `<root>` - Contains all documentation
  - `<group>` - Documentation groups
  - `<article>` - Individual articles
  - `<class>` - Type/class definitions

**Content Elements:**
- `<body>` - Rich content container
  - `<p>` - Paragraphs (can contain BBCode)
  - `<example>` - Code examples with syntax highlighting
  - `<list>` / `<list-item>` - Lists
  - `<table>` / `<table-row>` / `<table-col>` - Tables
  - `<header>` - Section headers
  - `<note>` - Note/warning boxes

**Member Elements:**
- `<member>` - Class member (method, property, field)
  - `<param>` - Parameter description
  - `<return>` - Return value description
  - `<declaration>` - Language-specific declaration
  - `<sig>` - Signature string

### Common Attributes

- `@key` - Unique identifier for cross-referencing
- `@transform` - BBCode transformation setting ("yes", "no", "def")
- `@in-group` - Parent group key
- `@if` - Conditional inclusion (requires definition)

---

## Best Practices

### 1. Transform Inheritance

Always check for transform setting in ancestor elements:

```xml
<xsl:value-of select="ext:let('transform', ext:get('default-transform', 'no'))" />
<xsl:for-each select="ancestor-or-self::*">
    <xsl:if test="count(./@transform) > 0 and ./@transform!='def'">
        <xsl:value-of select="ext:let('transform', ./@transform)" />
    </xsl:if>
</xsl:for-each>
```

### 2. Key Registration

Always register keys and links for validation:

```xml
<xsl:value-of select="ext:registerkey(./@key)" />
<xsl:value-of select="ext:registerlink($target-key)" />
```

### 3. Output Escaping

Use `disable-output-escaping="yes"` when inserting HTML from BBCode:

```xml
<xsl:value-of select="ext:call('write-bbcode.xsl', ext:parsebbcode(./@title))" disable-output-escaping="yes" />
```

### 4. Conditional Content

Check for element existence before processing:

```xml
<xsl:if test="count(./body/*)>0">
    <h2><xsl:value-of select="ext:get('_string_details')" /></h2>
    <xsl:value-of select="ext:call('write-description.xsl', /)" disable-output-escaping="yes" />
</xsl:if>
```

### 5. Serial Numbers

Use global counters for unique IDs:

```xml
<xsl:value-of select="ext:letglobal('g-example-serial', ext:get('g-example-serial') + 1)" />
<xsl:attribute name="id">example<xsl:value-of select="ext:get('g-example-serial')" /></xsl:attribute>
```

### 6. Error Handling

Validate critical conditions:

```xml
<xsl:if test="count(ext:get('group')) != 1">
    <xsl:value-of select="ext:error('The number of root groups is not equal to 1')" />
</xsl:if>
```

### 7. Resource Organization

Keep templates modular:
- One template per output type (`write-article.xsl`, `write-class.xsl`)
- Shared functionality in utility templates (`write-description.xsl`, `write-bbcode.xsl`)
- Static resources in `res/` directory
- Configuration in `dictionary/` directory

---

## Example Templates

### Simple Article Generator

**write-simple-article.xsl:**
```xml
<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" encoding="utf-8" />

    <xsl:template match="/">
        <xsl:apply-templates select="ext:caller('article')" />
    </xsl:template>

    <xsl:template match="article">
        <xsl:value-of select="ext:registerkey(./@key)" />

        <html>
            <head>
                <title><xsl:value-of select="./@title" /></title>
            </head>
            <body>
                <h1><xsl:value-of select="./@title" /></h1>

                <xsl:if test="./@briefless='false'">
                    <p class="brief"><xsl:value-of select="./@brief" /></p>
                </xsl:if>

                <xsl:for-each select="./body/p">
                    <p><xsl:value-of select="." disable-output-escaping="yes" /></p>
                </xsl:for-each>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>
```

### Markdown Output Template

**write-markdown.xsl:**
```xml
<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" encoding="utf-8" />

    <xsl:template match="/">
        <xsl:apply-templates select="ext:caller('article')" />
    </xsl:template>

    <xsl:template match="article">
        <xsl:value-of select="ext:registerkey(./@key)" />

        <xsl:text># </xsl:text><xsl:value-of select="./@title" /><xsl:text>&#10;&#10;</xsl:text>

        <xsl:if test="./@briefless='false'">
            <xsl:text>**</xsl:text><xsl:value-of select="./@brief" /><xsl:text>**&#10;&#10;</xsl:text>
        </xsl:if>

        <xsl:for-each select="./body/p">
            <xsl:value-of select="ext:call('strip-bbcode.xsl', .)" />
            <xsl:text>&#10;&#10;</xsl:text>
        </xsl:for-each>

        <xsl:for-each select="./body/example">
            <xsl:text>```</xsl:text>
            <xsl:value-of select="./@highlight" />
            <xsl:text>&#10;</xsl:text>
            <xsl:for-each select="./body/p">
                <xsl:value-of select="." />
                <xsl:text>&#10;</xsl:text>
            </xsl:for-each>
            <xsl:text>```&#10;&#10;</xsl:text>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
```

---

## Command Line Properties

Templates can access configuration via `ext:get()`:

**Common Properties:**
- `codepage` - Output encoding (e.g., "utf-8", "windows-1252")
- `text-language` - Current language code (e.g., "en", "ru", "fr")
- `base-output-path` - Output directory path
- `base-xslt-path` - Template directory path
- `write-web` - Whether to generate web content ("yes"/"no")
- `write-hhp` - Whether to generate HTML Help files ("yes"/"no")
- `default-transform` - Default BBCode transformation ("yes"/"no")

---

## Debugging Tips

1. **Use `ext:trace()`** to output debug messages:
   ```xml
   <xsl:value-of select="ext:trace(concat('Processing: ', ./@key))" />
   ```

2. **Check variable existence**:
   ```xml
   <xsl:if test="not(ext:exist('required-var'))">
       <xsl:value-of select="ext:error('Required variable not set')" />
   </xsl:if>
   ```

3. **Validate link integrity**:
   ```xml
   <xsl:value-of select="ext:checkkeys()" />
   ```
   Outputs warnings for broken links.

4. **Inspect XPath results**:
   ```xml
   <xsl:value-of select="ext:trace(concat('Count: ', count(./element)))" />
   ```

---

## Additional Resources

- **Source Model**: `source/parser/resource/ds-document.xsd`
- **Extension Functions**: `source/output/source/XsltExtensionObject.cs`
- **Example Templates**: `template/html/`
- **Test Model**: `test/model.xml`

---

## Template Checklist

When creating a new template:

- [ ] Create `main.xsl` entry point
- [ ] Initialize global variables (`g-root`, etc.)
- [ ] Load dictionaries (translation, configuration)
- [ ] Set up localization strings
- [ ] Create dynamic documents (TOC, index) if needed
- [ ] Implement `write-*.xsl` templates for each output type
- [ ] Register all keys with `ext:registerkey()`
- [ ] Register all links with `ext:registerlink()`
- [ ] Call `ext:checkkeys()` at the end
- [ ] Handle transform inheritance correctly
- [ ] Test with sample documentation
- [ ] Validate output files

---

*Generated for DocGen Template Development*
