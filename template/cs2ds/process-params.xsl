<?xml version="1.0" encoding="windows-1252"?>
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" />
    <xsl:template match="/" >
        <xsl:value-of select="ext:let('method', ext:caller('p-method'))" />
        <xsl:for-each select="ext:get('method')/parameters/parameter">
            <xsl:if test="position() > 1">, </xsl:if>
            <xsl:value-of select="ext:let('prefix', '')" />
            <xsl:if test="./@parameter-type='out'">
                <xsl:value-of select="ext:let('prefix', concat(ext:get('prefix'), 'out '))" />
            </xsl:if>
            <xsl:if test="count(./@prefix) > 0">
                <xsl:value-of select="ext:let('prefix', concat(ext:get('prefix'), ./@prefix, ' '))" />
            </xsl:if>
            <xsl:if test="./@parameter-type!='out' and ./type/@prefix='ref'">
                <xsl:value-of select="ext:let('prefix', concat(ext:get('prefix'), 'ref '))" />
            </xsl:if>
            <xsl:value-of select="ext:let('p-type', ./type)" />
            <xsl:value-of select="concat(ext:get('prefix'), normalize-space(ext:call('process-type-reference.xsl', /)), ' ', ./@name) "/><xsl:if test="count(./value) > 0"> = <xsl:value-of select="./value/text()" /></xsl:if>

        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
