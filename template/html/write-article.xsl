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
        <xsl:apply-templates select="ext:caller('article')" />
    </xsl:template>
    <xsl:template match="article" >
<xsl:value-of select="ext:let('transform', ext:get('default-transform', 'no'))" />
<xsl:for-each select="ancestor-or-self::*">
    <xsl:if test="count(./@transform) > 0 and ./@transform!='def'">
        <xsl:value-of select="ext:let('transform', ./@transform)" />
    </xsl:if>
</xsl:for-each>
<xsl:value-of select="ext:registerkey(./@key)" />
<xsl:value-of select="ext:let('hhk-node', ext:xmladdelement('help-index', ext:get('g-help-index-root'), 'key'))" />
<xsl:value-of select="ext:xmladdattribute('help-index', ext:get('hhk-node'), 'keyword', ext:removehtml(./@title))" />
<xsl:value-of select="ext:xmladdattribute('help-index', ext:get('hhk-node'), 'name', ext:removehtml(./@title))" />
<xsl:value-of select="ext:xmladdattribute('help-index', ext:get('hhk-node'), 'local', concat(./@key, '.html'))" />
<xsl:value-of select="ext:let('content-node', ext:xmladdelement('help-content', ext:caller('content-node'), 'node'))" />
<xsl:value-of select="ext:xmladdattribute('help-content', ext:get('content-node'), 'name', ext:removehtml(./@title))" />
<xsl:value-of select="ext:xmladdattribute('help-content', ext:get('content-node'), 'local', concat(./@key, '.html'))" />
<xsl:value-of select="'&lt;!DOCTYPE html PUBLIC &quot;-//W3C//DTD XHTML 1.0 Transitional//EN&quot; &quot;http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd&quot;&gt;'" disable-output-escaping="yes" />
<html>
<head>
<title><xsl:value-of select="ext:removehtml(./@title)" /></title>
<xsl:value-of select="ext:call('write-scripts.xsl', /)" disable-output-escaping="yes" />
<xsl:value-of select="ext:call('write-css.xsl', /)" disable-output-escaping="yes" />
</head>
<body>
<h1><xsl:choose>
    <xsl:when test="ext:get('transform')='yes'"><xsl:value-of select="ext:call('write-bbcode.xsl', ext:parsebbcode(./@title))" disable-output-escaping="yes"  /></xsl:when>
    <xsl:otherwise><xsl:value-of select="./@title" /></xsl:otherwise>
</xsl:choose>
</h1>
<xsl:if test="./@briefless='false'">
<h2><xsl:value-of select="ext:get('_string_brief')" /></h2>
<p><xsl:choose>
    <xsl:when test="ext:get('transform')='yes'"><xsl:value-of select="ext:call('write-bbcode.xsl', ext:parsebbcode(./@brief))" disable-output-escaping="yes"  /></xsl:when>
    <xsl:otherwise><xsl:value-of select="./@brief" /></xsl:otherwise>
</xsl:choose></p>
<h2><xsl:value-of select="ext:get('_string_details')" /></h2>
</xsl:if>
<xsl:value-of select="ext:let('curr-item', .)" />
<xsl:value-of select="ext:call('write-description.xsl', /)" disable-output-escaping="yes" />
<xsl:value-of select="ext:let('curr-item', .)" />
<xsl:value-of select="ext:call('write-seealso.xsl', /)" disable-output-escaping="yes" />
<p><center><xsl:element name="a"><xsl:attribute name="href"><xsl:value-of select="./@in-group" />.html</xsl:attribute><xsl:value-of select="ext:get('_string_back')" /></xsl:element></center></p>
<xsl:value-of select="ext:call('write-tail-scripts.xsl', /)" disable-output-escaping="yes" />
</body>
</html>
    </xsl:template>
</xsl:stylesheet>

