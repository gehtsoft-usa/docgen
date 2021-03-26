<?xml version="1.0" encoding="windows-1252"?>
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" />
    <!-- eliminate ext declaration -->
    <xsl:namespace-alias stylesheet-prefix="ext" result-prefix="#default"/>
    <xsl:template match="type" >
        <xsl:apply-templates />
    </xsl:template>
    <xsl:template match="ref" >
        [link=<xsl:apply-templates />]<xsl:apply-templates />[/link]
    </xsl:template>
    <xsl:template match="text()" >
        <xsl:value-of select="." />
    </xsl:template>
</xsl:stylesheet>
