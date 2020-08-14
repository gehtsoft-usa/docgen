<?xml version="1.0" encoding="windows-1252"?>
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" />
    <!-- eliminate ext declaration -->
    <xsl:namespace-alias stylesheet-prefix="ext" result-prefix="#default"/>
<xsl:template match="/" >
@group
    @title=Index
    @key=index
    @brief=
    @ingroup=
    @transform=yes
@end
    <xsl:value-of select="ext:let('src', ext:document(ext:get('src-file')))" />
    <xsl:for-each select="ext:get('src')/DATABASE/TABLE">
        <xsl:value-of select="ext:call('process-table.xsl', ., concat(./TABLE_NAME/text(), '.ds'), ext:get('codepage'))" />
    </xsl:for-each>
</xsl:template>
</xsl:stylesheet>
