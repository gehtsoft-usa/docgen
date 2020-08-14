1) Download doxygen from
   https://sourceforge.net/projects/doxygen/files/snapshots/ (binary)
   or
   http://www.stack.nl/~dimitri/doxygen/download.html (installer)


2) Create the doxygen project for the C++ source with the following settings
   - Switch to Expert Mode
   - Live configuration settings as default
   - Set your directories for sources and output
   - Disable all outputs except XML
   - Enable XML output

3) Run Doxygen

4) Remove all files
   - that ends with 8h.xml and 8cpp.xml - this is the source code reference
   - that starts with dir_ end ends with xml - this is directory reference
   - all files that does not end with xml
   -


5) Create a folder for docgen preparation project and create folder for DS files

6) Create null.ds source file to enable using docgen. Just put an empty index group there

7) Create the project like following:

<?xml version="1.0" ?>
<dg:help-project xmlns:dg="http://www.gehtsoft.com/docgen/project">
    <!-- dances with tambouring to make it working -->
    <dg:source>
        <dg:file name="null.ds" encoding="windows-1252" />
    </dg:source>

    <dg:output template="%docgen%\template\doxigen2ds\main.xsl" file="./null-file" encoding="utf-8" >
        <!-- where doxigen output is located -->
        <dg:define name="xml-path" value=".\xml\" />
        <!-- where to put ds files -->
        <dg:define name="ds-path" value=".\ds\" />
        <!-- the list of files -->
        <dg:define name="file-list" value="files.xml" />
        <!-- the output codepage (you may want to use 1252 instead of 65001 -->
        <dg:define name="codepage" value="65001" />
        <!-- the name of the group to include all classes to -->
        <dg:define name="group" value="index" />
    </dg:output>
</dg:help-project>


8) Create file list, e.g. using
   dir /b > files.xml
   to get list of the files
   and then use regular expression ^(.+)\.xml$ to convert into <file name="\1"/>
   and enclose resulting tags into <files> tag.

   NOTE: if encoding is not russian (e.g. UTF-8) AND there are russian in comments it may cause the exception.


