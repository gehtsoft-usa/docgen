<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" />
    <xsl:namespace-alias stylesheet-prefix="ext" result-prefix="#default"/>
    <xsl:template match="/" >
var highlighterEnabled = <xsl:choose><xsl:when test="ext:exist('enable-highlighter') and ext:get('enable-highlighter') = 'yes'">true</xsl:when><xsl:otherwise>false</xsl:otherwise></xsl:choose>;
var maintopic = '<xsl:value-of select="ext:get('g-root')/group[./@is-root='true']/@key" />';
var helptitle = '<xsl:value-of select="ext:get('help-title')" />';
    </xsl:template>
</xsl:stylesheet>