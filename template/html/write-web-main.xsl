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
  </head>
  <body >
    <table class="HelpCaption" height="100%" width="100%">
        <tr><td class="HelpCaption">
            <b><xsl:value-of select="ext:get('help-title')" /></b>
        </td></tr>
        <tr><td>
            <iframe id="webcontent" frameborder="no" width="100%" height="100%">your browser doesn't support 'iframe' tag</iframe>
        </td></tr>
    </table>
  </body>
<script src="res/index.js" type="text/javascript"></script>
</html>
    </xsl:template>
</xsl:stylesheet>

