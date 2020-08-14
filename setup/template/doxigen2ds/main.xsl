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
    <xsl:value-of select="ext:let('list', ext:document(ext:get('file-list')))" />
        <xsl:for-each select="ext:get('list')/files/file">
            <xsl:value-of select="ext:let('class-xml', ext:document(concat(ext:get('xml-path'), ./@name, '.xml')))" />
            <xsl:value-of select="ext:call('process-class.xsl', /, concat(ext:get('ds-path'), ./@name, '.ds'), ext:get('codepage'))" />
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
