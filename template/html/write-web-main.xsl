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
    <style type="text/css">
        .HelpCaption
        {
            background-image: url(pageImages/header-bg.gif);
            height: 43px;
            font-family:Trebuchet MS, Arial;
            padding : 10px;
            color: #f1f1f1;
        }
    </style>
  </head>
  <body style="padding:0px; margin:0px;" >
	<table border="0" cellpadding="0" cellspacing="0" width="100%" height="100%">
		<tr><td class="HelpCaption">
	      	<b><xsl:value-of select="ext:get('help-title')" /></b>
		</td></tr>
		<tr><td>
			<iframe id="webcontent" frameborder="no" width="100%" height="100%">your browser doesn't support 'iframe' tag</iframe>
		</td></tr>
	</table>
  </body>
<script language="javascript" type="text/javascript">
function getHash() {
    return window.parent.location.hash.slice(1);
}
function getQueryParam(name)
<xsl:text disable-output-escaping="yes">
<![CDATA[
{
  var query = window.parent.location.search.substring(1);
  var params = query.split("&");
  for (var i = 0;i < params.length; i++) {
    var pair = params[i].split("=");
    if (pair[0] == name) {
      return pair[1];
    }
  }
  return null;
}
var src = getHash() || getQueryParam('key') || 'index.html';
var iframe = document.getElementById("webcontent");
iframe.src = "web-content-main.html?key=" + src;
]]>
</xsl:text>
</script>
</html>
    </xsl:template>
</xsl:stylesheet>

