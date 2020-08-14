The template to convert of asm2xml output plus XML documentation into documentaton source.

The asm2xml can be obtained:
- via source code https://svnusa.gehtsoft.com:3333/develop/dev/apps/AssemblyToXml
- as binary http://docs.gehtsoftusa.com/bin/assembly2xml.zip

This template is designed to work with the version of docgen that supports partial classes definition,
so:

- the result of conversion contains all methods and the documentation exported from xml doc
- the result is included into the project as is into raw or similar folder of source
- the result is included into the project file AFTER manually created files
- so, if the documentation author copies some classes or methods into manually created folder
  and modifies/creates custom documentation - such documentation will be used
- but if raw folder has groups, methods or classes that aren't defined in the manually created
  documentation, it will be used.


How to use

1) Make sure that asm2xml is downloaded and installed

2) Create a prepare project

- create file null.ds and creatre an dummy index section inside

@group
    @title=Index
    @key=index
    @ingroup=
    @brief=
@end

- create file settings.xml and configure it

<settings>
    <!-- set location of xmldoc file for the assembly -->
    <assembly name="" xmldoc="" />
    <!-- exclude assembly from generation -->
    <assembly name="" skip="true" />
    <!-- put namespace in the specified group -->
    <namespace name="" group="" />
    <!-- do not show full class name for classes that belongs to a namespace -->
    <strip-namespace name="" />
</settings>

3) Create project file for preparation

<?xml version="1.0" ?>
<dg:help-project xmlns:dg="http://www.gehtsoft.com/docgen/project">
    <dg:source>
        <dg:file name="null.ds" encoding="windows-1252" />
    </dg:source>
    <dg:output template="%docgen%\template\cs2ds\main.xsl" file="src/raw/null-file" encoding="utf-8" >
        <!-- the output of asm2xml -->
        <dg:define name="source" value="out.xml" />
        <!-- the name of the settings file -->
        <dg:define name="settings" value="settings.xml" />
        <!-- the default group to put all namespaces in -->
        <dg:define name="default-group" value="index" />
    </dg:output>
</dg:help-project>
