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
<xsl:value-of select="ext:let('param', ./@params)" />
<xsl:value-of select="ext:let('suffix', ./@suffix)" />
<xsl:if test="ext:get('transform')='yes'" >
    <xsl:value-of select="ext:let('prefix', ext:call('write-bbcode.xsl', ext:parsebbcode(ext:get('prefix')))) "/>
    <xsl:value-of select="ext:let('return', ext:call('write-bbcode.xsl', ext:parsebbcode(ext:get('return')))) "/>
    <xsl:value-of select="ext:let('name',  ext:call('write-bbcode.xsl', ext:parsebbcode(ext:get('name')))) "/>
    <xsl:value-of select="ext:let('name-suffix',  ext:call('write-bbcode.xsl', ext:parsebbcode(ext:get('name-suffix')))) "/>
    <xsl:value-of select="ext:let('param',  ext:call('write-bbcode.xsl', ext:parsebbcode(ext:get('param')))) "/>
    <xsl:value-of select="ext:let('suffix',  ext:call('write-bbcode.xsl', ext:parsebbcode(ext:get('suffix')))) "/>
</xsl:if>
<xsl:if test="string-length(ext:get('prefix'))"><xsl:value-of select="ext:let('prefix', concat(ext:get('prefix'), '&amp;nbsp;')) "/></xsl:if>
<!-- build body depend on the member type -->
<table class="decl">
 <tr><td colspan="2">IDL</td></tr>
<xsl:choose>
    <!-- method -->
    <xsl:when test="../@type='method'">
        <xsl:if test="./@return!='' and not(contains(ext:get('return'), 'void'))">
            <xsl:if test="string-length(ext:get('param'))>0">
                <xsl:value-of select="ext:let('param', concat(ext:get('param'), ', '))" />
            </xsl:if>
            <xsl:value-of select="ext:let('param', concat(ext:get('param'), '[out, retval] ', ext:get('return'), '* retVal'))" />
        </xsl:if>
        <xsl:value-of select="ext:let('decl-body', concat(ext:get('param'), ') ')) " />
 <tr><td width="1%" nowrap="" valign="top"><code><xsl:value-of select="concat(ext:get('prefix'), 'HRESULT', '&amp;nbsp;', '&lt;b&gt;', ext:get('name'), ext:get('name-suffix'), '&lt;/b&gt;(')" disable-output-escaping="yes" /></code></td>
     <td width="99%" valign="top"><code><xsl:value-of select="ext:get('decl-body')" disable-output-escaping="yes" /></code></td></tr>
    </xsl:when>
    <!-- field or property -->
    <xsl:otherwise>
        <xsl:value-of select="ext:let('param1', ext:get('param'))" />
        <xsl:value-of select="ext:let('param2', ext:get('param'))" />
        <xsl:if test="string-length(ext:get('param'))>0">
            <xsl:value-of select="ext:let('param1', concat(ext:get('param1'), ', '))" />
            <xsl:value-of select="ext:let('param2', concat(ext:get('param2'), ', '))" />
        </xsl:if>
        <xsl:value-of select="ext:let('param1', concat(ext:get('param1'), '[out, retval] ', ext:get('return'), '* retVal'))" />
        <xsl:value-of select="ext:let('param2', concat(ext:get('param2'), '[in] ', ext:get('return'), ' value'))" />
        <xsl:value-of select="ext:let('decl-body1', concat(ext:get('param1'), ') ')) " />
        <xsl:value-of select="ext:let('decl-body2', concat(ext:get('param2'), ') ')) " />
        <xsl:if test="contains(ext:get('suffix'), 'r')" >
          <tr><td width="1%" nowrap=""  valign="top"><code><xsl:value-of select="concat(ext:get('prefix'), '[propget]&amp;nbsp;', 'HRESULT', '&amp;nbsp;', '&lt;b&gt;', ext:get('name'), ext:get('name-suffix'), '&lt;/b&gt;(')" disable-output-escaping="yes" /></code></td>
              <td width="99%"  valign="top"><code><xsl:value-of select="ext:get('decl-body1')" disable-output-escaping="yes" /></code></td></tr>
        </xsl:if>
        <xsl:if test="contains(ext:get('suffix'), 'w')" >
          <tr><td width="1%" nowrap="" valign="top"><code><xsl:value-of select="concat(ext:get('prefix'), '[propput]&amp;nbsp;', 'HRESULT', '&amp;nbsp;', '&lt;b&gt;', ext:get('name'), ext:get('name-suffix'), '&lt;/b&gt;(')" disable-output-escaping="yes" /></code></td>
              <td width="99%" valign="top"><code><xsl:value-of select="ext:get('decl-body2')" disable-output-escaping="yes" /></code></td></tr>
        </xsl:if>
    </xsl:otherwise>
</xsl:choose>
<!-- write declaration -->
 <xsl:if test="count(./body/*)>0">
    <xsl:value-of select="ext:let('curr-item', .)" />
    <tr><td width="1%"></td><td><pre><xsl:value-of select="ext:call('write-description.xsl', /)" disable-output-escaping="yes" /></pre></td></tr>
 </xsl:if>
</table>
    </xsl:template>
</xsl:stylesheet>

