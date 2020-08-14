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
    <xsl:value-of select="ext:let('p-package', ext:caller('p-package')) " />
    <xsl:value-of select="ext:let('package', ext:get('g-data')/xs:jel/xs:jelclass[./@package=ext:get('p-package')])" />

@group
    @title=Namespace <xsl:value-of select="ext:get('p-package')" />
    @key=<xsl:value-of select="ext:get('p-package')" />
    @ingroup=<xsl:value-of select="ext:get('group')" />
    @brief=
    <xsl:for-each select="ext:get('package')" >
        <xsl:value-of select="ext:let('class', .)" />
        <xsl:if test="./@visibility = 'public'">
        <xsl:value-of select="ext:let('p-class-name', ./@type)" />
        <xsl:value-of select="ext:let('p-class-key', concat(./@fulltype, '.0'))" />
        <xsl:value-of select="ext:call('process-class.xsl', /, concat(./@fulltype, '.ds'), ext:get('codepage'))" />
        </xsl:if>
    </xsl:for-each>
@end
    </xsl:template>
</xsl:stylesheet>

