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
        <xsl:choose>
            <xsl:when test="ext:match('class.+', ./@refid)"><xsl:value-of select="ext:let('reference', ext:document(concat(ext:get('xml-path'), ./@refid, '.xml')))" />[link=<xsl:value-of select="ext:replace(ext:get('reference')/doxygen/compounddef/compoundname/text(), '::', '.')" />]<xsl:apply-templates />[/link]</xsl:when>
            <xsl:otherwise>
        <xsl:apply-templates />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="text()" >
        <xsl:value-of select="." />
    </xsl:template>
</xsl:stylesheet>
