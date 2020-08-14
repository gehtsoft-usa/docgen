<?xml version="1.0" encoding="windows-1252"?>
<!-- writes article
     param: ext:caller('curr-item') - a class to write

  -->
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" />
    <xsl:namespace-alias stylesheet-prefix="ext" result-prefix="#default"/>

    <xsl:template match="/" >
    <xsl:value-of select="ext:let('transform', ext:caller('transform'))" />
    <xsl:value-of select="ext:let('body-template', ext:caller('body-template'))" />
    <xsl:value-of select="ext:let('content-node', ext:caller('content-node'))" />
        <p></p>
        <table class="tmain" width="100%">
        <tr><td colspan="2" class="thdr"><b><xsl:value-of select="ext:caller('group-name')" /></b></td></tr>
        <xsl:choose>
            <xsl:when test="ext:caller('curr-item')/@sort='true'">
                <xsl:apply-templates select="ext:caller('members')" >
                    <xsl:sort select="./@name" />
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="ext:caller('members')" />
            </xsl:otherwise>
        </xsl:choose>
        </table>
    </xsl:template>
    <xsl:template match="member">
            <xsl:if test="./@exclude-from-list='false'" >
                <tr><td class="tmain_nw"><p><xsl:element name="a"><xsl:attribute name="href"><xsl:value-of select="concat(../@key, '.', ./@key)" />.html</xsl:attribute><xsl:value-of select="./@name" disable-output-escaping="yes" /></xsl:element></p></td>
                <td class="tmain" width="69%"><p><xsl:choose>
                    <xsl:when test="ext:get('transform')='yes'"><xsl:value-of select="ext:call('write-bbcode.xsl', ext:parsebbcode(./@brief))" disable-output-escaping="yes"  /></xsl:when>
                    <xsl:otherwise><xsl:value-of select="./@brief" /></xsl:otherwise>
                    </xsl:choose>
                </p></td></tr>
            </xsl:if>
            <xsl:value-of select="ext:let('curr-member', .)" />
            <xsl:value-of select="ext:call(ext:get('body-template'), /, concat(../@key, '.', ./@key, '.html'), ext:get('codepage'))" />
    </xsl:template>
</xsl:stylesheet>

