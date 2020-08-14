<?xml version="1.0" encoding="windows-1252"?>
<!-- copies hhc into the current content
     param: ext:caller('article') - an article to write

  -->
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" />
    <xsl:namespace-alias stylesheet-prefix="ext" result-prefix="#default"/>
    <xsl:template match="/" >
        <xsl:apply-templates select="ext:caller('curr-node')" />
    </xsl:template>
    <xsl:template match="node" >
        <xsl:value-of select="ext:let('curr-parent', ext:xmladdelement('help-content', ext:caller('curr-parent'), 'node'))" />
        <xsl:value-of select="ext:xmladdattribute('help-content', ext:get('curr-parent'), 'name', ./@name)" />
        <xsl:value-of select="ext:xmladdattribute('help-content', ext:get('curr-parent'), 'local', ./@local)"  disable-output-escaping="yes"  />
        <xsl:for-each select="./node">
            <xsl:value-of select="ext:let('curr-node', .) "/>
            <xsl:value-of select="ext:call('copy-import-node.xsl', /)"  disable-output-escaping="yes" />
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>

