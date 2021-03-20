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
        <xsl:apply-templates select="ext:caller('curr-item')" />
    </xsl:template>
    <xsl:template match="class" >
<xsl:value-of select="ext:let('transform', ext:get('default-transform', 'no'))" />
<xsl:for-each select="ancestor-or-self::*">
    <xsl:if test="count(./@transform) > 0 and ./@transform!='def'">
        <xsl:value-of select="ext:let('transform', ./@transform)" />
    </xsl:if>
</xsl:for-each>
<xsl:value-of select="ext:registerkey(./@key)" />

<!-- add class to the content and key tables -->

<xsl:value-of select="ext:let('hhk-node', ext:xmladdelement('help-index', ext:get('g-help-index-root'), 'key'))" />
<xsl:value-of select="ext:xmladdattribute('help-index', ext:get('hhk-node'), 'keyword', ext:escape(ext:removehtml(./@name)))" />
<xsl:value-of select="ext:xmladdattribute('help-index', ext:get('hhk-node'), 'name', ext:escape(ext:removehtml(./@name)))" />
<xsl:value-of select="ext:xmladdattribute('help-index', ext:get('hhk-node'), 'local', concat(./@key, '.html'))" />

<xsl:value-of select="ext:let('content-node', ext:xmladdelement('help-content', ext:caller('content-node'), 'node'))" />
<xsl:value-of select="ext:xmladdattribute('help-content', ext:get('content-node'), 'name', ext:escape(ext:removehtml(./@name)))" />
<xsl:value-of select="ext:xmladdattribute('help-content', ext:get('content-node'), 'local', concat(./@key, '.html'))" />
<xsl:value-of select="ext:let('body-template', ext:caller('body-template'))" />
<xsl:choose>
<xsl:when test="count(./@write-signatures) > 0 and ./@write-signatures != 'def'">
<xsl:value-of select="ext:let('write-signatures', ./@write-signatures) = 'yes'"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="ext:let('write-signatures', ext:get('add-signature-to-brief', 'no') = 'yes')"/>
</xsl:otherwise>
</xsl:choose>


<html>
<head>
    <title><xsl:value-of select="ext:escape(./@name)" disable-output-escaping="yes" /></title>
    <xsl:value-of select="ext:call('write-scripts.xsl', /)" disable-output-escaping="yes" />
    <xsl:value-of select="ext:call('write-css.xsl', /)" disable-output-escaping="yes" />
</head>
<body>
<h1><code><xsl:value-of select="ext:caller('curr-item-type')" /><xsl:text xml:space="preserve"> </xsl:text><b><xsl:value-of select="ext:escape(./@decl-name)" disable-output-escaping="yes" /></b></code></h1>
<!-- class parents -->
<xsl:if test="count(./parent)>0">
  <p></p>
  <table class="tmain" width="100%">
  <tr><td colspan="2" class="thdr"><b><xsl:value-of select="ext:get('_string_parents')" /></b></td></tr>
  <xsl:for-each select="./parent">
    <tr><td class="tmain" width="30" style="border-right: none;"></td>
<xsl:choose>
    <xsl:when test="ext:get('transform')='yes'">
        <td class="tmain"  style="border-left: none;"><p><code><xsl:value-of select="ext:call('write-bbcode.xsl', ext:parsebbcode(./text()))" disable-output-escaping="yes"  /></code></p></td>
    </xsl:when>
    <xsl:otherwise>
        <td class="tmain" style="border-left: none;"><p><code><xsl:value-of select="./text()" disable-output-escaping="yes" /></code></p></td>
    </xsl:otherwise>
</xsl:choose>
    </tr>
  </xsl:for-each>
  </table>
</xsl:if>
<h2><xsl:value-of select="ext:get('_string_brief')" /></h2>
<p><xsl:choose>
    <xsl:when test="ext:get('transform')='yes'"><xsl:value-of select="ext:call('write-bbcode.xsl', ext:parsebbcode(./@brief))" disable-output-escaping="yes"  /></xsl:when>
    <xsl:otherwise><xsl:value-of select="./@brief" /></xsl:otherwise>
</xsl:choose></p>
<xsl:value-of select="ext:let('curr-item', .)" />
<xsl:value-of select="ext:call('write-params.xsl', /)" disable-output-escaping="yes" />
<xsl:if test="count(./body/*)>0">
<h2><xsl:value-of select="ext:get('_string_details')" /></h2>
<xsl:value-of select="ext:call('write-description.xsl', /)" disable-output-escaping="yes" />
</xsl:if>
<xsl:value-of select="ext:call('write-seealso.xsl', /)" disable-output-escaping="yes" />
<!-- write members -->
<xsl:for-each select="ext:get('g-member-groups')/member-groups/member-group" >
    <xsl:value-of select="ext:let('curr-group', .)" />
    <xsl:value-of select="ext:let('list-template', 'member-list.xsl')" />
    <xsl:value-of select="ext:let('group-name', ./@name)" />
    <xsl:if test="count(./@list) > 0"><xsl:value-of select="ext:let('list-template', ./@list)" /></xsl:if>
    <xsl:choose>
        <xsl:when test="count(./@custom)>0">
            <xsl:value-of select="ext:let('members', ext:get('curr-item')/member[./@scope=ext:get('curr-group')/@scope and ./@visibility=ext:get('curr-group')/@visibility and  ./@type=ext:get('curr-group')/@type and ./@custom=ext:get('curr-group')/@custom])"/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="ext:let('members', ext:get('curr-item')/member[./@scope=ext:get('curr-group')/@scope and ./@visibility=ext:get('curr-group')/@visibility and ./@type=ext:get('curr-group')/@type and ext:strcmp(./@custom, '')=0])"/>
        </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="count(ext:get('members'))>0">
            <xsl:if test="ext:get('curr-item')/@members-to-content='true'">
                <xsl:for-each select="ext:get('members')" >
                    <xsl:sort select="./@key" />
                    <xsl:value-of select="ext:let('content-subnode', ext:xmladdelement('help-content', ext:get('content-node'), 'node'))" />
                    <xsl:value-of select="ext:xmladdattribute('help-content', ext:get('content-subnode'), 'name', ext:removehtml(./@name))" />
                    <xsl:value-of select="ext:xmladdattribute('help-content', ext:get('content-subnode'), 'local', concat(ext:get('curr-item')/@key, '.', ./@key, '.html'))" />
                </xsl:for-each>
            </xsl:if>
            <xsl:value-of select="ext:call(ext:get('list-template'), /)" disable-output-escaping="yes" />
    </xsl:if>
</xsl:for-each>
<p><center><xsl:element name="a"><xsl:attribute name="href"><xsl:value-of select="./@in-group" />.html</xsl:attribute><xsl:value-of select="ext:get('_string_back')" /></xsl:element></center></p>
<xsl:value-of select="ext:call('write-tail-scripts.xsl', /)" disable-output-escaping="yes" />
</body>
</html>
    </xsl:template>
</xsl:stylesheet>

