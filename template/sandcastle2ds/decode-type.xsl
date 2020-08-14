<?xml version="1.0" encoding="windows-1252"?>
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" />
    <!-- eliminate ext declaration -->
    <xsl:namespace-alias stylesheet-prefix="ext" result-prefix="#default"/>
    <xsl:template match="/" >
        <xsl:value-of select="ext:let('p-ns-id', ext:caller('p-ns-id')) " />
        <xsl:value-of select="ext:let('is-out', ext:caller('is-out')) " />
        <xsl:apply-templates select="ext:caller('base')" />
    </xsl:template>
    <xsl:template match="argument" />
    <xsl:template match="type" >
        <xsl:value-of select="ext:let('type', .)" />
        <xsl:value-of select="normalize-space(ext:call('process-type.xsl', /)) " />
    </xsl:template>
    <xsl:template match="template" >
        <xsl:value-of select="./@name" />
    </xsl:template>
    <xsl:template match="referenceTo" >
        <xsl:if test="ext:get('is-out')!='yes'">ref </xsl:if><xsl:apply-templates select="./*" />
    </xsl:template>
    <xsl:template match="arrayOf" >
        <xsl:apply-templates select="./*" />[<xsl:value-of select="substring(',,,,,,,', 1, number(./@rank) - 1)" />]
    </xsl:template>
</xsl:stylesheet>

