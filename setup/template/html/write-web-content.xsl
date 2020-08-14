<?xml version="1.0" encoding="windows-1252"?>
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" />
    <xsl:namespace-alias stylesheet-prefix="ext" result-prefix="#default"/>
    <xsl:template match="/" >
<html>
    <head><title><xsl:value-of select="ext:get('help-title')" /></title></head>
    <xsl:value-of select="ext:call('write-css.xsl', /)" disable-output-escaping="yes" />
<frameset cols="30%, *" border="1" frameborder="no" framespacing="4" >
    <frame src="web-hhc.html" />
    <frame src="index.html" name="docframe" />
</frameset>
</html>
<xsl:choose>
<xsl:when test="ext:get('advanced-web-content', 'no')='yes'">
    <xsl:value-of select="ext:call('write-web-hhc-adv.xsl', ext:xmlgetdocument('help-content'), 'web-hhc.html', ext:get('codepage')) " />
</xsl:when>
<xsl:otherwise>
    <xsl:value-of select="ext:call('write-web-hhc.xsl', ext:xmlgetdocument('help-content'), 'web-hhc.html', ext:get('codepage')) " />
</xsl:otherwise>
</xsl:choose>
<xsl:value-of select="ext:call('write-web-hhk.xsl', ext:xmlgetdocument('help-index'), 'web-hhk.html', ext:get('codepage')) " />
    </xsl:template>
</xsl:stylesheet>

