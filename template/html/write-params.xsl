<?xml version="1.0" encoding="windows-1252"?>
<!-- writes article
     param: ext:caller('article') - an article to write

  -->
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" />
    <xsl:namespace-alias stylesheet-prefix="ext" result-prefix="#default"/>
    <xsl:template match="/" >
    <xsl:value-of select="ext:let('transform', ext:caller('transform'))" />
    <xsl:if test="count(ext:caller('curr-item')/param)>0">
    <p></p>
    <table class="tmain" width="100%">
    <tr><td colspan="2" class="thdr"><b><xsl:value-of select="ext:get('_string_parameters')" /></b></td></tr>
        <xsl:apply-templates select="ext:caller('curr-item')/param" />
    </table>
    </xsl:if>
    </xsl:template>
    <xsl:template match="param" >
    <xsl:value-of select="ext:let('curr-item', .)" />
    <tr><td class="tmain_nw" width="31%"><code><xsl:choose>
    <xsl:when test="./@gray='true'"><font color="#909090"><xsl:value-of select="./@name" disable-output-escaping="yes" /></font></xsl:when>
    <xsl:otherwise><xsl:value-of select="./@name" disable-output-escaping="yes" /></xsl:otherwise>
    </xsl:choose>
    </code></td><td class="tmain" width="69%"><xsl:choose>
    <xsl:when test="./@gray='true'"><font color="#909090"><xsl:value-of select="ext:call('write-description.xsl', /)" disable-output-escaping="yes" /></font></xsl:when>
    <xsl:otherwise><xsl:value-of select="ext:call('write-description.xsl', /)" disable-output-escaping="yes" /></xsl:otherwise>
    </xsl:choose>
    </td></tr>
    </xsl:template>
</xsl:stylesheet>
