<?xml version="1.0" encoding="windows-1252"?>
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://xml.jeldoclet.com">
    <xsl:output method="text" />
    <!-- eliminate ext declaration -->
    <xsl:namespace-alias stylesheet-prefix="ext" result-prefix="#default"/>
    <xsl:template match="/" >
<xsl:value-of select="ext:letglobal('g-data', ext:document(ext:get('src-file')))" />
<!-- look for all namespaces -->
<xsl:for-each select="ext:get('g-data')/xs:jel/xs:jelclass[not(@package = preceding-sibling::xs:jelclass/@package)]">
    <xsl:value-of select="ext:let('p-package', ./@package)" />
    <xsl:value-of select="ext:call('process-package.xsl', /, concat(ext:get('p-package'), '.ds'), ext:get('codepage'))" />
</xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
