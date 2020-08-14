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
    <!-- the type node is in the ascentors or in the parameters -->
    <xsl:value-of select="ext:let('curr-type', ext:caller('type'))" />
    <!-- the currently processed namespace -->
    <xsl:value-of select="ext:let('p-package', ext:caller('p-package')) " />
    <xsl:value-of select="ext:let('link', '')" />
    <xsl:choose>
        <xsl:when test="ext:get('g-data')/xs:jel/xs:jelclass[./@fulltype = ext:get('curr-type')/@fulltype]">
            <xsl:value-of select="ext:let('name', ext:get('curr-type')/@type) "/>
            <xsl:value-of select="ext:let('link', concat(ext:get('curr-type')/@fulltype,'.0'))" />
        </xsl:when>
        <xsl:otherwise>
            <!-- the class is not in the ref list. leave the full name. -->
            <xsl:value-of select="ext:let('name', ext:get('curr-type')/@fulltype) "/>
        </xsl:otherwise>
    </xsl:choose>
    <!-- decode the standard classes -->
    <xsl:choose>
        <xsl:when test="ext:get('name')='java.lang.Object'"><xsl:value-of select="ext:let('name', 'Object')" /></xsl:when>
        <xsl:when test="ext:get('name')='java.lang.String'"><xsl:value-of select="ext:let('name', 'String')" /></xsl:when>
        <xsl:when test="ext:get('name')='java.lang.Integer'"><xsl:value-of select="ext:let('name', 'int')" /></xsl:when>
        <xsl:when test="ext:get('name')='java.lang.Boolean'"><xsl:value-of select="ext:let('name', 'boolean')" /></xsl:when>
        <xsl:when test="ext:get('name')='java.lang.Calendar'"><xsl:value-of select="ext:let('name', 'Calendar')" /></xsl:when>
        <xsl:when test="ext:get('name')='java.lang.Double'"><xsl:value-of select="ext:let('name', 'double')" /></xsl:when>
    </xsl:choose>
    <xsl:if test="ext:get('link')!=''">[clink=<xsl:value-of select="ext:get('link')" />]</xsl:if><xsl:value-of select="ext:get('name')" /><xsl:if test="ext:get('link')!=''">[/clink]</xsl:if>
    </xsl:template>
</xsl:stylesheet>

