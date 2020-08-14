1) download, unpack and configude a sandcastle
- http://cloud.gehtsoft.com/index.php/s/cfLvokKZg9JRisB
- set sandcastle environment variable to Development folder of sandcastle

2) create a sandcastle's dump (must be .netframework dll, netcore isn't supported).

"%sandcastle%\ProductionTools\MrefBuilder.exe" dll list /out:dump.xml

3) configure project to prepare template

<?xml version="1.0" ?>
<dg:help-project xmlns:dg="http://www.gehtsoft.com/docgen/project">
    <dg:source>
        <dg:file name="null.ds" encoding="windows-1252" />
    </dg:source>
    <dg:output template="%docgen%\template\sandcastle2ds\main.xsl" file="src/null-file" encoding="windows-1252" >
        <!-- sandcastle output file -->
        <dg:define name="src-file" value="dump.xml" />
        <!-- if next variable is defined, the preparation process will
             compare current dump and old dump and will include
             only the members that does not exist in old dump -->
        <dg:define name="old-src-file" value="old-dump.xml" />
        <!-- the name of the parent group for namespaces' groups -->
        <dg:define name="group" value="index" />
        <!-- comma-separated list of visibilities to include into the help source -->
        <dg:define name="visibility" value="public,family" />
    </dg:output>
</dg:help-project>

3) Configure null-source file with the following content

@group
    @title=index
    @key=index
    @ingroup=
    @brief=
@end




