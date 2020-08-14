<?xml version="1.0" encoding="windows-1252"?>
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" />

    <!-- eliminate ext declaration -->
    <xsl:namespace-alias stylesheet-prefix="ext" result-prefix="#default"/>
    <xsl:template match="/" >
    <xsl:if test="ext:exist('exclude')">
        <xsl:value-of select="ext:letglobal('exclude-doc', ext:document(ext:get('exclude')))" />
    </xsl:if>
    <xsl:value-of select="ext:letglobal('g-data', ext:document(ext:get('src-file')))" />
    <xsl:if test="ext:exist('old-src-file')">
        <xsl:value-of select="ext:letglobal('g-old-data', ext:document(ext:get('old-src-file')))" />
    </xsl:if>
<!-- look for all namespaces -->
<xsl:for-each select="ext:get('g-data')/reflection/apis/api[starts-with(./@id, 'N:')]">
    <xsl:value-of select="ext:let('p-ns', ./apidata[1]/@name)" />
    <xsl:value-of select="ext:let('p-ns-id', ./@id)" />
    <xsl:value-of select="ext:call('process-ns.xsl', /, concat(ext:get('p-ns'), '.ds'), ext:get('codepage'))" />
</xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
