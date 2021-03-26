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
    <xsl:for-each select="ext:files(ext:get('xml-path'), '/namespace.+\.xml/')">
        <xsl:value-of select="ext:let('namespace', ext:document(./@name))" />
        <xsl:value-of select="ext:let('namespace-name', ext:get('namespace')/doxygen/compounddef/compoundname/text())" />
        <xsl:value-of select="ext:let('namespace-file-name', ext:replace(ext:get('namespace-name'), '::', '_'))" />

        <xsl:if test="not(ext:exist('exclude-namespace')) or not(ext:match(ext:get('exclude-namespace', 'nevermatch'), ext:get('namespace-name')))">
        <xsl:value-of select="ext:call('process-namespace.xsl', ext:get('namespace'), concat(ext:get('ds-path'), ext:get('namespace-file-name'), '.ds'), ext:get('codepage'))" />
        </xsl:if>
    </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
