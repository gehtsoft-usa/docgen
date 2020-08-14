<?xml version="1.0" encoding="windows-1252"?>
<!-- writes all see also items

     @param ext:caller('curr-item') - a object which has see-also items to write
   -->
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" />
    <xsl:namespace-alias stylesheet-prefix="ext" result-prefix="#default"/>
    <xsl:template match="/" >
    <xsl:value-of select="ext:let('transform', ext:caller('transform'))" />
    <xsl:if test="count(ext:caller('curr-item')/see-also)>0">
    <p></p>
    <table class="tmain">
    <tr><td colspan="2" class="thdr"><b><xsl:value-of select="ext:get('_string_seealso')" /></b></td></tr>
    <xsl:apply-templates select="ext:caller('curr-item')/see-also" />
    </table>
    </xsl:if>
    </xsl:template>
    <xsl:template match="see-also" >
        <xsl:value-of select="ext:let('curr-item', .)" />
        <tr><td class="tmain" width="31%"><xsl:element name="a"><xsl:attribute name="href"><xsl:value-of select="./@key"/>.html</xsl:attribute><xsl:value-of select="./@title" disable-output-escaping="yes" /></xsl:element></td>
            <td class="tmain" width="69%"><xsl:value-of select="ext:call('write-description.xsl', /)"  disable-output-escaping="yes" /></td>
        </tr>
    </xsl:template>
</xsl:stylesheet>

