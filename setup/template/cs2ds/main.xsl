<?xml version="1.0" encoding="windows-1252"?>
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" />

    <!-- eliminate ext declaration -->
    <xsl:namespace-alias stylesheet-prefix="ext" result-prefix="#default"/>
    <xsl:template match="/" >
    <xsl:value-of select="ext:letglobal('g-data', ext:document(ext:get('source')))" />
    <xsl:value-of select="ext:letglobal('g-settings', ext:document(ext:get('settings')))" />
    <xsl:value-of select="ext:letglobal('g-default-group', ext:get('default-group'))" />

    <xsl:for-each select="ext:get('g-data')/collection/namespaces/namespace">
        <xsl:value-of select="ext:let('p-ns', ./text())" />
        <xsl:value-of select="ext:call('process-ns.xsl', /, concat(ext:get('p-ns'), '.ds'), ext:get('codepage'))" />
    </xsl:for-each>

    <xsl:for-each select="ext:get('g-data')/collection/assemblies/assembly">
        <!-- load xmldoc for assembly -->
        <xsl:value-of select="ext:let('assembly', ./@name)" />
        <xsl:if test="count(ext:get('g-settings')/settings/assembly[./@name=ext:get('assembly')]/@skip) = 0 or ext:get('g-settings')/settings/assembly[./@name=ext:get('assembly')]/@skip != 'true'">
        <xsl:value-of select="ext:removeglobal('xmldoc')" />
        <xsl:if test="count(ext:get('g-settings')/settings/assembly[./@name=ext:get('assembly')]/@xmldoc) > 0">
            <xsl:value-of select="ext:letglobal('xmldoc', ext:document(ext:get('g-settings')/settings/assembly[./@name=ext:get('assembly')]/@xmldoc))" />
        </xsl:if>
        <xsl:for-each select="./type">
            <xsl:value-of select="ext:let('p-type', .)" />
            <xsl:value-of select="ext:call('process-type.xsl', /, concat(ext:get('p-type')/@namespace, '.', ext:get('p-type')/@name, '.ds'), ext:get('codepage'))" />
        </xsl:for-each>
        </xsl:if>
    </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
