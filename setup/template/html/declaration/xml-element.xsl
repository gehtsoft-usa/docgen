<?xml version="1.0" encoding="windows-1252"?>
<!-- writes declaration
     param: ext:caller('curr-item') - a declaration to write

  -->
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
    <xsl:template match="declaration" >
<!-- collect declaration data -->
<xsl:value-of select="ext:let('prefix', ./@prefix)" />
<xsl:value-of select="ext:let('name', ./@name)" />
<xsl:value-of select="ext:let('name-suffix', ./@name-suffix)" />
<xsl:value-of select="ext:let('params', ./@params)" />
<xsl:value-of select="ext:let('suffix', ./@suffix)" />
<xsl:if test="ext:get('transform')='yes'" >
    <xsl:value-of select="ext:let('prefix', ext:call('write-bbcode.xsl', ext:parsebbcode(ext:get('prefix')))) "/>
    <xsl:value-of select="ext:let('name',  ext:call('write-bbcode.xsl', ext:parsebbcode(ext:get('name')))) "/>
    <xsl:value-of select="ext:let('name-suffix',  ext:call('write-bbcode.xsl', ext:parsebbcode(ext:get('name-suffix')))) "/>
    <xsl:value-of select="ext:let('params',  ext:call('write-bbcode.xsl', ext:parsebbcode(ext:get('params')))) "/>
    <xsl:value-of select="ext:let('suffix',  ext:call('write-bbcode.xsl', ext:parsebbcode(ext:get('suffix')))) "/>
</xsl:if>
<xsl:if test=""></xsl:if>
<xsl:if test="string-length(ext:get('prefix'))>0"><xsl:value-of select="ext:let('prefix', concat(ext:get('prefix'), ':')) "/></xsl:if>
<xsl:if test="string-length(ext:get('params'))>0"><xsl:value-of select="ext:let('params', concat(' ', ext:get('params'), ' ')) "/></xsl:if>
<!-- detect language -->
<table class="decl">
<xsl:choose>
    <xsl:when test="string-length(ext:get('suffix'))>0">
        <tr><td colspan="2"><code><xsl:value-of select="concat('&amp;lt;', ext:get('prefix'), ext:get('name'), ext:get('params'), '&amp;gt;')" disable-output-escaping="yes"/></code></td></tr>
        <tr><td width="5%"> </td><td><code><xsl:value-of select="ext:get('suffix')" disable-output-escaping="yes" /></code></td></tr>
        <tr><td colspan="2"><code><xsl:value-of select="concat('&amp;lt;/', ext:get('prefix'), ext:get('name'), '&amp;gt;')" disable-output-escaping="yes"/></code></td></tr>
    </xsl:when>
    <xsl:otherwise>
        <tr><td><code><xsl:value-of select="concat('&amp;lt;', ext:get('prefix'), ext:get('name'), ext:get('params'), '/&amp;gt;')" disable-output-escaping="yes"/></code></td></tr>
    </xsl:otherwise>
</xsl:choose>
</table>
    </xsl:template>
</xsl:stylesheet>

