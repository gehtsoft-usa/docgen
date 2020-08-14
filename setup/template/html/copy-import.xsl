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
        <xsl:value-of select="ext:let('curr-node', /help-content/node) "/>
        <xsl:value-of select="ext:let('curr-parent', ext:caller('content-node')) "/>
        <xsl:value-of select="ext:call('copy-import-node.xsl', /)"  disable-output-escaping="yes" />
    </xsl:template>
</xsl:stylesheet>

