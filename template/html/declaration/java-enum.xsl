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
<xsl:value-of select="ext:let('return', ./@return)" />
<xsl:value-of select="ext:let('name', ./@name)" />
<xsl:value-of select="ext:let('name-suffix', ./@name-suffix)" />
<xsl:value-of select="ext:let('params', ./@params)" />
<xsl:value-of select="ext:let('suffix', ./@suffix)" />
<xsl:if test="ext:get('transform')='yes'" >
    <xsl:value-of select="ext:let('prefix', ext:call('write-bbcode.xsl', ext:parsebbcode(ext:get('prefix')))) "/>
    <xsl:value-of select="ext:let('return', ext:call('write-bbcode.xsl', ext:parsebbcode(ext:get('return')))) "/>
    <xsl:value-of select="ext:let('name',  ext:call('write-bbcode.xsl', ext:parsebbcode(ext:get('name')))) "/>
    <xsl:value-of select="ext:let('name-suffix',  ext:call('write-bbcode.xsl', ext:parsebbcode(ext:get('name-suffix')))) "/>
    <xsl:value-of select="ext:let('params',  ext:call('write-bbcode.xsl', ext:parsebbcode(ext:get('params')))) "/>
    <xsl:value-of select="ext:let('suffix',  ext:call('write-bbcode.xsl', ext:parsebbcode(ext:get('suffix')))) "/>
</xsl:if>
<xsl:if test="string-length(ext:get('prefix'))"><xsl:value-of select="ext:let('prefix', concat(ext:get('prefix'), '&amp;nbsp;')) "/></xsl:if>
<!-- build body depend on the member type -->
<!-- write declaration -->
<table class="decl">
 <tr><td>Java</td></tr>
 <tr><td><code><xsl:value-of select="concat(ext:get('name'), ext:get('suffix'))" disable-output-escaping="yes" /></code></td></tr>
 <xsl:if test="count(./body/*)>0">
    <xsl:value-of select="ext:let('curr-item', .)" />
    <tr><td><pre><xsl:value-of select="ext:call('write-description.xsl', /)" disable-output-escaping="yes" /></pre></td></tr>
 </xsl:if>
</table>
    </xsl:template>
</xsl:stylesheet>

