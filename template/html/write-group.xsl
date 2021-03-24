<?xml version="1.0" encoding="windows-1252"?>
<!-- writes body description
     param: ext:caller('group') - a group to write
  -->
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" />
    <xsl:namespace-alias stylesheet-prefix="ext" result-prefix="#default"/>
    <xsl:template match="/" >
        <xsl:apply-templates select="ext:caller('group')" />
    </xsl:template>
    <xsl:template match="group" >
<xsl:value-of select="ext:registerkey(./@key)" />
<xsl:value-of select="ext:let('hhk-node', ext:xmladdelement('help-index', ext:get('g-help-index-root'), 'key'))" />
<xsl:value-of select="ext:xmladdattribute('help-index', ext:get('hhk-node'), 'keyword', ext:removehtml(./@title))" />
<xsl:value-of select="ext:xmladdattribute('help-index', ext:get('hhk-node'), 'name', ext:removehtml(./@title))" />
<xsl:value-of select="ext:xmladdattribute('help-index', ext:get('hhk-node'), 'local', concat(./@key, '.html'))" />
<xsl:value-of select="ext:let('content-node', ext:xmladdelement('help-content', ext:caller('content-node'), 'node'))" />
<xsl:value-of select="ext:xmladdattribute('help-content', ext:get('content-node'), 'name', ext:removehtml(./@title))" />
<xsl:value-of select="ext:xmladdattribute('help-content', ext:get('content-node'), 'local', concat(./@key, '.html'))" />
<xsl:value-of select="ext:let('transform', ext:get('default-transform', 'no'))" />
<xsl:for-each select="ancestor-or-self::*">
    <xsl:if test="count(./@transform) > 0 and ./@transform!='def'">
        <xsl:value-of select="ext:let('transform', ./@transform)" />
    </xsl:if>
</xsl:for-each>
<xsl:if test="./@import-hhc!=''"><xsl:value-of select="ext:call('copy-import.xsl', ext:document(./@import-hhc))" /></xsl:if>
<xsl:if test="./@import-hhk!=''"><xsl:value-of select="ext:call('copy-import-keys.xsl', ext:document(./@import-hhk))" /></xsl:if>
<xsl:value-of select="ext:let('p-title', ./@title)" />
<xsl:value-of select="ext:call('write-html-prolog.xsl', /)" disable-output-escaping="yes" />
<xsl:value-of select="ext:let('curr-group', ./@key)" />
<!-- write title and brief (if group is not briefless) -->
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
<!-- write description -->
<xsl:value-of select="ext:let('curr-item', .)" />
<xsl:value-of select="ext:call('write-description.xsl', /)" disable-output-escaping="yes" />
<!-- write list of enclosing groups and articles -->
<!-- variant 1: in case order of the articles and group is custom - write groups and articles togehter -->
<xsl:if test="./@order='custom' and count(ext:get('g-root')/*[(name(.)='article' or name(.)='group') and ./@in-group=ext:get('curr-group')]) > 0">
    <p/>
    <table class="tmain" width="100%">
    <tr><td colspan="2" class="thdr"><b><xsl:value-of select="ext:get('_string_articles')" /></b></td></tr>
    <xsl:for-each select="ext:get('g-root')/*[(name(.)='article' or name(.)='group') and ./@in-group=ext:get('curr-group')]">
        <xsl:value-of select="ext:let('curr-item', .)" />
        <xsl:value-of select="ext:call('write-group-list-item.xsl', /)" disable-output-escaping="yes" />
        <xsl:if test="name(.)='article'"><xsl:value-of select="ext:let('article', .) "/><xsl:value-of select="ext:call('write-article.xsl', /, concat(./@key, '.html'), ext:get('codepage')) "/></xsl:if>
        <xsl:if test="name(.)='group'"><xsl:value-of select="ext:let('group', .) "/><xsl:value-of select="ext:call('write-group.xsl', /, concat(./@key, '.html'), ext:get('codepage')) "/></xsl:if>
    </xsl:for-each>
    </table>
</xsl:if>

<!-- variant 2: in case order of the articles and group is sorted - write groups and articles separatelly -->
<xsl:if test="./@order='sorted' and count(ext:get('g-root')/article[./@in-group=ext:get('curr-group')])>0">
    <p></p>
    <table class="tmain"  width="100%">
    <tr><td colspan="2" class="thdr"><b><xsl:value-of select="ext:get('_string_articles')" /></b></td></tr>
    <xsl:choose>
    <xsl:when test="./@sort-articles='yes'">
        <xsl:for-each select="ext:get('g-root')/article[./@in-group=ext:get('curr-group')]">
            <xsl:sort select="./@title" order="ascending" />
            <xsl:value-of select="ext:let('curr-item', .)" />
            <xsl:value-of select="ext:call('write-group-list-item.xsl', /)" disable-output-escaping="yes" />
            <xsl:value-of select="ext:let('article', .) "/><xsl:value-of select="ext:call('write-article.xsl', /, concat(./@key, '.html'), ext:get('codepage')) "/>
        </xsl:for-each>
    </xsl:when>
    <xsl:otherwise>
        <xsl:for-each select="ext:get('g-root')/article[./@in-group=ext:get('curr-group')]">
            <xsl:value-of select="ext:let('curr-item', .)" />
            <xsl:value-of select="ext:call('write-group-list-item.xsl', /)" disable-output-escaping="yes" />
            <xsl:value-of select="ext:let('article', .) "/><xsl:value-of select="ext:call('write-article.xsl', /, concat(./@key, '.html'), ext:get('codepage')) "/>
        </xsl:for-each>
    </xsl:otherwise>
    </xsl:choose>
    </table>
</xsl:if>

<!-- write subgroups -->
<xsl:if test="./@order='sorted' and count(ext:get('g-root')/group[./@in-group=ext:get('curr-group')])>0">
    <p></p>
    <table class="tmain" width="100%">
    <tr><td colspan="2" class="thdr"><b><xsl:value-of select="ext:get('_string_groups')" /></b></td></tr>
    <xsl:choose>
    <xsl:when test="./@sort-groups='yes'">
        <xsl:for-each select="ext:get('g-root')/group[./@in-group=ext:get('curr-group')]">
            <xsl:sort select="./@title" order="ascending" />
            <xsl:value-of select="ext:let('curr-item', .)" />
            <xsl:value-of select="ext:call('write-group-list-item.xsl', /)" disable-output-escaping="yes" />
            <xsl:value-of select="ext:let('group', .) "/><xsl:value-of select="ext:call('write-group.xsl', /, concat(./@key, '.html'), ext:get('codepage')) "/>
        </xsl:for-each>
    </xsl:when>
    <xsl:otherwise>
        <xsl:for-each select="ext:get('g-root')/group[./@in-group=ext:get('curr-group')]">
            <xsl:value-of select="ext:let('curr-item', .)" />
            <xsl:value-of select="ext:call('write-group-list-item.xsl', /)" disable-output-escaping="yes" />
            <xsl:value-of select="ext:let('group', .) "/><xsl:value-of select="ext:call('write-group.xsl', /, concat(./@key, '.html'), ext:get('codepage')) "/>
        </xsl:for-each>
    </xsl:otherwise>
    </xsl:choose>
    </table>
</xsl:if>

<xsl:value-of select="ext:let('curr-item', .)" />
<xsl:value-of select="ext:call('write-group-class-list.xsl', /)" disable-output-escaping="yes" />

<xsl:value-of select="ext:call('write-seealso.xsl', /)" disable-output-escaping="yes" />

<xsl:if test="ext:strcmp(./@in-group, '')!=0"><p><center><xsl:element name="a"><xsl:attribute name="href"><xsl:value-of select="./@in-group" />.html</xsl:attribute><xsl:value-of select="ext:get('_string_back')" /></xsl:element></center></p></xsl:if>
<xsl:value-of select="ext:call('write-tail-scripts.xsl', /)" disable-output-escaping="yes" />
<xsl:value-of select="ext:call('write-html-epilog.xsl', /)" disable-output-escaping="yes" />
    </xsl:template>
</xsl:stylesheet>

