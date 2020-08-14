<?xml version="1.0" encoding="windows-1252"?>
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" />
    <xsl:template match="/" >

    <xsl:value-of select="ext:let('ns', ext:caller('p-ns'))" />

    <xsl:choose>
        <xsl:when test="count(ext:get('g-settings')/settings/namespace[./@name=ext:get('ns')]/@group) > 0">
            <xsl:value-of select="ext:let('group', ext:get('g-settings')/settings/namespace[./@name=ext:get('ns')]/@group)" />
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="ext:let('group', ext:get('g-default-group'))" />
        </xsl:otherwise>
    </xsl:choose>

@group
    @title=Namespace <xsl:value-of select="ext:get('ns')" />
    @key=<xsl:value-of select="ext:get('ns')" />
    @ingroup=<xsl:value-of select="ext:get('group')" />
    @brief=
@end
    </xsl:template>
</xsl:stylesheet>

