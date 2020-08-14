<?xml version="1.0" encoding="windows-1252"?>
<!-- writes scripts to the page header -->
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" />
    <xsl:namespace-alias stylesheet-prefix="ext" result-prefix="#default"/>
    <xsl:template match="/" >
<xsl:choose>
<xsl:when test="ext:exist('external-resources') and ext:get('external-resources') = 'yes'">
    <script type="text/javascript" src="res/scripts.js" />
    <xsl:if test="ext:exist('add-custom-scripts') ">
        <xsl:element name="script">
            <xsl:attribute name="type">text/javascript</xsl:attribute>
            <xsl:attribute name="src"><xsl:value-of select="ext:get('add-custom-script')" /></xsl:attribute>
        </xsl:element>
    </xsl:if>
    <xsl:if test="ext:exist('enable-highlighter') and ext:get('enable-highlighter') = 'yes'">
    <script type="text/javascript">
        if (!window.location.href.indexOf('mk:') == 0) {
            initializeHighlighter();
        }
    </script>
    </xsl:if>
</xsl:when>
<xsl:otherwise>
    <xsl:if test="ext:exist('enable-highlighter') and ext:get('enable-highlighter') = 'yes'">
    <script type="text/javascript">
       if (!window.location.href.indexOf('mk:') == 0) {
               var head = document.getElementsByTagName('head')[0];

               var script1 = document.createElement('script');
               script1.type = 'text/javascript';
               script1.src = 'highlighter/highlight.pack.js';
               head.appendChild(script1);

               var script2 = document.createElement('script');
               script2.type = 'text/javascript';
               script2.src = 'highlighter/highlight.cshtml.js';
               head.appendChild(script2);

               window.onload=function() {
                   hljs.registerLanguage('cshtml-razor', window.hljsDefineCshtmlRazor);
                   x = document.querySelectorAll('pre code');
                   for (var i = 0; i &lt; x.length; i++) {
                        if (x[i].hasAttribute('class')) {
                            hljs.highlightBlock(x[i]);
                       }
                   }
               };
           }
    </script>
    </xsl:if>
<script language="javascript" type="text/javascript">
function hidediv( divname )
{
    document.getElementById( divname ).style.display = 'none';
}

function showdiv( divname )
{
    document.getElementById( divname ).style.display = 'inline';
}
</script>
</xsl:otherwise>
</xsl:choose>
    </xsl:template>
</xsl:stylesheet>

