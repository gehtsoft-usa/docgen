<?xml version="1.0" encoding="windows-1252"?>
<!-- writes body description -->
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" />
    <xsl:namespace-alias stylesheet-prefix="ext" result-prefix="#default"/>
    <xsl:template match="/" >
        <xsl:value-of select="ext:let('transform', ext:caller('transform'))" />
        <xsl:apply-templates select="ext:caller('curr-item')" />
    </xsl:template>
    <xsl:template match="*" >
        <xsl:if test="count(./@exclude-from-list)=0 or ./@exclude-from-list='false'">
        <tr><td colspan="2" class="tmain">
            <p><xsl:element name="a"><xsl:attribute name="href"><xsl:value-of select="./@key" />.html</xsl:attribute>
                <xsl:choose>
                    <xsl:when test="ext:get('transform')='yes'"><xsl:value-of select="ext:call('write-bbcode.xsl', ext:parsebbcode(./@title))" disable-output-escaping="yes"  /></xsl:when>
                    <xsl:otherwise><xsl:value-of select="./@title" /></xsl:otherwise>
                </xsl:choose></xsl:element></p>
            <p><xsl:choose>
                    <xsl:when test="ext:get('transform')='yes'"><xsl:value-of select="ext:call('write-bbcode.xsl', ext:parsebbcode(./@brief))" disable-output-escaping="yes"  /></xsl:when>
                    <xsl:otherwise><xsl:value-of select="./@brief" /></xsl:otherwise>
                </xsl:choose></p>
        </td></tr>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>

