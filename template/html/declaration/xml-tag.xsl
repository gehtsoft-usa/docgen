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
<xsl:if test="string-length(ext:get('prefix'))>0"><xsl:value-of select="ext:let('prefix', concat(ext:get('prefix'), ':')) "/></xsl:if>
<xsl:if test="string-length(ext:get('params'))>0"><xsl:value-of select="ext:let('params', concat(' ', ext:get('params'), ' ')) "/></xsl:if>
<xsl:if test="./@suffix = 'virtual'"><xsl:value-of select="ext:let('name', concat('&lt;i&gt;', ext:get('name'),' &lt;/i&gt;'))" /></xsl:if>
<!-- detect language -->
<table class="decl">
    <tr><td><code><xsl:value-of select="concat('&amp;lt;', ext:get('prefix'), '&lt;b&gt;', ext:get('name'), '&lt;/b&gt;', ext:get('params'), '/&amp;gt;')" disable-output-escaping="yes"/></code></td></tr>
</table>
    </xsl:template>
</xsl:stylesheet>

