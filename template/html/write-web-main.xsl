<?xml version="1.0" encoding="windows-1252"?>
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" />
    <xsl:namespace-alias stylesheet-prefix="ext" result-prefix="#default"/>
    <xsl:template match="/" >
<html>
  <head>
    <title>Index</title>
    <link rel="stylesheet" href="res/index.css" ></link>
<xsl:if test="ext:exist('add-to-container-prolog-head')">
    <xsl:value-of select="ext:readAllText(ext:get('add-to-container-prolog-head'))" disable-output-escaping="yes" />
</xsl:if>
  </head>
  <body >
<table class="HelpCaption" height="100%" width="100%">
<tr>
<xsl:choose>
    <xsl:when test="ext:exist('replace-container-prolog-title')">
        <xsl:value-of select="ext:readAllText(ext:get('replace-container-prolog-title'))" disable-output-escaping="yes" />
    </xsl:when>
    <xsl:otherwise>
        <td class="HelpCaption">
            <b><xsl:value-of select="ext:get('help-title')" /></b>
        </td>
    </xsl:otherwise>
</xsl:choose>
</tr>
<tr><td>
    <iframe id="webcontent" frameborder="no" width="100%" height="100%">your browser doesn't support 'iframe' tag</iframe>
</td></tr>
</table>
  </body>
<script src="settings.js" type="text/javascript"></script>
<script src="res/index.js" type="text/javascript"></script>
</html>
    </xsl:template>
</xsl:stylesheet>

