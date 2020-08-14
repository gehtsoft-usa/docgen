<?xml version="1.0" encoding="windows-1252"?>
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" />
    <!-- eliminate ext declaration -->
    <xsl:namespace-alias stylesheet-prefix="ext" result-prefix="#default"/>
    <xsl:template match="/" >
    <xsl:choose>
        <xsl:when test="contains(ext:caller('p-class-id'), '`')">
            <xsl:value-of select="ext:let('name', substring(ext:caller('p-class-id'), 3, string-length(ext:caller('p-class-id')) - 4))" />
            <xsl:value-of select="ext:let('name', concat(ext:get('name'), '_'))" />
            <xsl:value-of select="ext:let('i', 0)" />
            <xsl:for-each select="ext:get('g-data')/reflection/apis/api[./@id=ext:caller('p-class-id')]/templates/template" >
                <xsl:if test="ext:get('i')!=0">
                    <xsl:value-of select="ext:let('name', concat(ext:get('name'), '_'))" />
                </xsl:if>
                <xsl:value-of select="ext:let('name', concat(ext:get('name'), ./@name))" />
                <xsl:value-of select="ext:let('i', ext:get('i') + 1)" />
            </xsl:for-each>
            <xsl:value-of select="ext:get('name')" />
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="substring(ext:caller('p-class-id'), 3)" />
        </xsl:otherwise>
    </xsl:choose>
    </xsl:template>
</xsl:stylesheet>

