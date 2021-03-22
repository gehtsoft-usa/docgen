<?xml version="1.0" encoding="windows-1252"?>
<!-- writes scripts to the page header -->
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" />
    <xsl:namespace-alias stylesheet-prefix="ext" result-prefix="#default"/>
    <xsl:template match="/" >
    <xsl:if test="ext:exist('enable-highlighter') and ext:get('enable-highlighter') = 'yes'">
    <link rel="stylesheet" href="highlighter/default.css"></link>
    </xsl:if>
<xsl:choose>
<xsl:when test="ext:exist('external-resources') and ext:get('external-resources') = 'yes'">
    <link rel="stylesheet" href="res/styles.css"></link>
</xsl:when>
<xsl:otherwise>
<style type="text/css">
    <xsl:value-of select="ext:readAllText('res/styles.css')" disable-output-escaping="yes" />
</style>
</xsl:otherwise>
</xsl:choose>
<link rel="stylesheet" href="res/dripicons.css"></link>
    </xsl:template>
</xsl:stylesheet>

