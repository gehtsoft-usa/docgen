<?xml version="1.0" encoding="windows-1252"?>
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" />
    <!-- eliminate ext declaration -->
    <xsl:namespace-alias stylesheet-prefix="ext" result-prefix="#default"/>
    <xsl:template match="/" >
    <xsl:value-of select="ext:let('p-ns', ext:caller('p-ns')) " />
    <xsl:value-of select="ext:let('p-ns-id', ext:caller('p-ns-id')) " />
    <xsl:value-of select="ext:let('ns', ext:get('g-data')/reflection/apis/api[./@id=ext:get('p-ns-id')]) " />
@group
    @title=Namespace <xsl:value-of select="ext:get('p-ns')" />
    @key=<xsl:value-of select="ext:get('p-ns')" />
    @ingroup=<xsl:value-of select="ext:get('group')" />
    @brief=
    <xsl:for-each select="ext:get('ns')/elements/element[starts-with(./@api, 'T:')] " >
        <xsl:value-of select="ext:let('p-class-id', ./@api)" />
        <xsl:value-of select="ext:let('class', ext:get('g-data')/reflection/apis/api[./@id=ext:get('p-class-id')])" />
        <xsl:value-of select="ext:let('p-class-name', normalize-space(ext:call('get-class-name.xsl', /)))" />
        <xsl:value-of select="ext:let('p-class-key', normalize-space(ext:call('get-class-key.xsl', /)))" />
        <xsl:value-of select="ext:call('process-class.xsl', /, concat(ext:get('p-class-key'), '.ds'), ext:get('codepage'))" />
    </xsl:for-each>
@end
    </xsl:template>
</xsl:stylesheet>

