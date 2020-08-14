<?xml version="1.0" encoding="windows-1252"?>
<!-- common procedure for the member body
     param: ext:caller('curr-item') - a member to write

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
    <xsl:template match="member" >
<xsl:value-of select="ext:registerkey(concat(../@key, '.', ./@key))" />
<xsl:value-of select="ext:let('hhk-node', ext:xmladdelement('help-index', ext:get('g-help-index-root'), 'key'))" />
<xsl:value-of select="ext:xmladdattribute('help-index', ext:get('hhk-node'), 'keyword', ext:caller('help-index-keyword'))" />
<xsl:value-of select="ext:xmladdattribute('help-index', ext:get('hhk-node'), 'name', ext:caller('help-index-name'))" />
<xsl:value-of select="ext:xmladdattribute('help-index', ext:get('hhk-node'), 'local', concat(../@key, '.', ./@key, '.html'))" />
<xsl:if test="ext:exist('help-index-keyword1')">
    <xsl:value-of select="ext:let('hhk-node', ext:xmladdelement('help-index', ext:get('g-help-index-root'), 'key'))" />
    <xsl:value-of select="ext:xmladdattribute('help-index', ext:get('hhk-node'), 'keyword', ext:caller('help-index-keyword1'))" />
    <xsl:value-of select="ext:xmladdattribute('help-index', ext:get('hhk-node'), 'name', ext:caller('help-index-name'))" />
    <xsl:value-of select="ext:xmladdattribute('help-index', ext:get('hhk-node'), 'local', concat(../@key, '.', ./@key, '.html'))" />
</xsl:if>
<xsl:value-of select="ext:let('curr-member', .)" />
<p><b><xsl:value-of select="ext:get('_string_brief')" /></b></p>
<p><xsl:choose>
    <xsl:when test="ext:get('transform')='yes'"><xsl:value-of select="ext:call('write-bbcode.xsl', ext:parsebbcode(./@brief))" disable-output-escaping="yes"  /></xsl:when>
    <xsl:otherwise><xsl:value-of select="./@brief" /></xsl:otherwise>
</xsl:choose></p>
<!-- declaration -->
<xsl:if test="count(./declaration)>0">
 <table class="tmain" width="100%">
 <tr><td class="thdr"><b><xsl:value-of select="ext:get('_string_declaration')" /></b></td></tr>
 <xsl:for-each select="./declaration">
    <!-- find the proper template -->
    <xsl:value-of select="ext:let('decl-template', '')" />
    <xsl:value-of select="ext:let('curr-item', .)" />
    <xsl:choose>
    <xsl:when test="./@custom!=''">
        <xsl:value-of select="ext:let('node', ext:get('g-declarations')/declarations/declaration[./@language=ext:get('curr-item')/@language and ./@type=ext:get('curr-member')/@type and ./@custom=ext:get('curr-item')/@custom])" />
        <xsl:if test="count(ext:get('node'))>0">
            <xsl:value-of select="ext:let('decl-template', ext:get('node')/@file)" />
        </xsl:if>
    </xsl:when>
    <xsl:otherwise>
        <xsl:value-of select="ext:let('node', ext:get('g-declarations')/declarations/declaration[./@language=ext:get('curr-item')/@language and ./@type=ext:get('curr-member')/@type and (count(./@custom)=0 or ./@custom='')])" />
        <xsl:if test="count(ext:get('node'))>0">
            <xsl:value-of select="ext:let('decl-template', ext:get('node')/@file)" />
        </xsl:if>
    </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="ext:get('decl-template')=''">
        <xsl:value-of select="ext:error(concat('template for the ', ext:get('curr-member')/../@name, '.', ext:get('curr-member')/@name, ' in ', ./@language, ' is not found'))" />
    </xsl:if>
    <tr><td class="tmain"><xsl:value-of select="ext:call(ext:get('decl-template'), /)" disable-output-escaping="yes" /></td></tr>
 </xsl:for-each>
 </table>
</xsl:if>
<!-- parameters -->
<xsl:value-of select="ext:let('curr-item', .)" />
<xsl:value-of select="ext:call('write-params.xsl', /)" disable-output-escaping="yes" />
<!-- return -->
<xsl:if test="count(./return/body/*)>0">
  <p><b><xsl:value-of select="ext:get('_string_return')" /></b></p>
  <xsl:value-of select="ext:let('curr-item', ./return[1])" />
  <xsl:value-of select="ext:call('write-description.xsl', /)" disable-output-escaping="yes" />
</xsl:if>
<!-- exceptions -->
<xsl:if test="count(./exception)>0">
  <p></p>
  <table class="tmain" width="100%">
  <tr><td colspan="2" class="thdr"><b><xsl:value-of select="ext:get('_string_exceptions')" /></b></td></tr>
  <xsl:for-each select="./exception">
    <xsl:value-of select="ext:let('curr-item', .)" />
    <tr><td class="tmain_nw" width="31%"><code><xsl:value-of select="./@name" disable-output-escaping="yes" /></code></td>
        <td class="tmain" width="69%"><xsl:value-of select="ext:call('write-description.xsl', /)" disable-output-escaping="yes" /></td>
    </tr>
   </xsl:for-each>
  </table>
</xsl:if>
<!-- details -->
<xsl:if test="count(./body/*)>0">
<p><b><xsl:value-of select="ext:get('_string_details')" /></b></p>
<xsl:value-of select="ext:let('curr-item', .)" />
<xsl:value-of select="ext:call('write-description.xsl', /)" disable-output-escaping="yes" />
</xsl:if>
<xsl:value-of select="ext:call('write-seealso.xsl', /)" disable-output-escaping="yes" />

<xsl:if test="./@type != 'function'">
<!-- class reference -->
<p><xsl:value-of select="ext:get('_string_declaredin')" /> <xsl:element name="a"><xsl:attribute name="href"><xsl:value-of select="./@class" />.html</xsl:attribute><xsl:value-of select="./@class-name" /></xsl:element></p>
</xsl:if>

<!-- back -->
<p><center><xsl:element name="a"><xsl:attribute name="href"><xsl:value-of select="../@key" />.html</xsl:attribute><xsl:value-of select="ext:get('_string_back')" /></xsl:element></center></p>
<xsl:choose>
<xsl:when test="ext:exist('external-resources') and ext:get('external-resources') = 'yes'">
<script language="javascript" type="text/javascript">syncList1('<xsl:value-of select="../@key" />');</script>
</xsl:when>
<xsl:otherwise>
<script language="javascript" type="text/javascript">if(window.parent.frames[0]) window.parent.frames[0].selectItem(window.location.href, '<xsl:value-of select="../@key" />.html');</script>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
</xsl:stylesheet>

