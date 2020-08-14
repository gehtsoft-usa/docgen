<?xml version="1.0" encoding="windows-1252"?>
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" />
    <!-- eliminate ext declaration -->
    <xsl:namespace-alias stylesheet-prefix="ext" result-prefix="#default"/>
    <xsl:template match="api" >
        <xsl:value-of select="ext:let('p-ns-id', ext:caller('p-ns-id')) " />
        @declaration
            @language=cs
            @name=<xsl:value-of select="ext:caller('name')" />
            <xsl:if test="ext:caller('return')='yes'" >
            <xsl:choose>
            <xsl:when test="count(./returns)>0">
            <xsl:value-of select="ext:let('is-out', 'no')" />
            <xsl:value-of select="ext:let('base', ./returns)" />
            @return=<xsl:value-of select="normalize-space(ext:call('decode-type.xsl', /)) " />
            </xsl:when>
            <xsl:otherwise>
            @return=void
            </xsl:otherwise>
            </xsl:choose>
            </xsl:if>
            <xsl:if test="count(./parameters/parameter)>0">
                <xsl:value-of select="ext:let('i', 0)" />
                <xsl:value-of select="ext:let('params', '')" />
                <xsl:for-each select="./parameters/parameter">
                    <xsl:if test="ext:get('i') > 0"><xsl:value-of select="ext:let('params', concat(ext:get('params'), ', '))" /></xsl:if>
                    <xsl:value-of select="ext:let('i', ext:get('i') + 1)" />
                    <xsl:value-of select="ext:let('is-out', 'no')" />
                    <xsl:if test="./@out='true'"><xsl:value-of select="ext:let('params', concat(ext:get('params'), 'out '))" /><xsl:value-of select="ext:let('is-out', 'yes')" /></xsl:if>
                    <xsl:value-of select="ext:let('base', .)" />
                    <xsl:value-of select="ext:let('params', concat(ext:get('params'), normalize-space(ext:call('decode-type.xsl', /)), ' ')) "/>
                    <xsl:value-of select="ext:let('params', concat(ext:get('params'), ./@name)) "/>
                </xsl:for-each>
            @params=<xsl:value-of select="ext:get('params')" />
            </xsl:if>
            <xsl:if test="ext:caller('suffix')!=''">
            @suffix=<xsl:value-of select="ext:caller('suffix')" />
            </xsl:if>
        @end
    </xsl:template>
</xsl:stylesheet>

