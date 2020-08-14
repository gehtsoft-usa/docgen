<?xml version="1.0" encoding="windows-1252"?>
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" />
    <xsl:template match="/" >
[OPTIONS]
Index file=index.hhk
Auto Index=Yes
Binary TOC=Yes
Compatibility=1.1 or later
Compiled file=<xsl:value-of select="ext:get('chm-file')" />
Contents file=index.hhc
Create CHI file=Yes
Default topic=index.html
Display compile progress=No
Full-text search=Yes
Language=<xsl:value-of select="ext:get('hhp-language')" />
Title=<xsl:value-of select="ext:get('help-title')" />

[FILES]
    </xsl:template>
</xsl:stylesheet>

