<?xml version="1.0" encoding="windows-1252"?>
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" />
    <!-- eliminate ext declaration -->
    <xsl:namespace-alias stylesheet-prefix="ext" result-prefix="#default"/>
    <xsl:template match="api" >
    <xsl:value-of select="ext:let('key', ext:caller('name'))" />
    <xsl:value-of select="ext:let('name', ./apidata/@name)" />
    <xsl:value-of select="ext:let('type', ./containers/type/@api)" />
    <xsl:value-of select="ext:let('count', count(preceding-sibling::api[./apidata/@name=ext:get('name') and ./containers/type/@api=ext:get('type')]))" />
    <xsl:if test="ext:get('count')>=0">
        <xsl:value-of select="ext:let('key', concat(ext:get('key'), '.', string(ext:get('count')))) " />
    </xsl:if>
    <xsl:value-of select="ext:get('key')" />
    </xsl:template>
</xsl:stylesheet>

