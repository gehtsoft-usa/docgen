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
        <xsl:for-each select="/help-index/key" >
           <xsl:value-of select="ext:let('hhk-node', ext:xmladdelement('help-index', ext:get('g-help-index-root'), 'key'))" />
           <xsl:value-of select="ext:xmladdattribute('help-index', ext:get('hhk-node'), 'keyword', ./@keyword)" />
           <xsl:value-of select="ext:xmladdattribute('help-index', ext:get('hhk-node'), 'name', ./@name)" />
           <xsl:value-of select="ext:xmladdattribute('help-index', ext:get('hhk-node'), 'local', ./@local)" />
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>

