<?xml version="1.0" encoding="windows-1252"?>
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" />
    <xsl:template match="/" >&lt;html&gt;
<!--Sitemap 1.0-->
&lt;OBJECT type="text/site properties"&gt;&lt;/OBJECT&gt;
&lt;UL&gt;
    <xsl:for-each select="/root/key" xml:space="preserve" >
    &lt;li&gt;&lt;object type="text/sitemap"&gt;
              &lt;param name="Keyword" value="<xsl:value-of select="ext:replaceentity(./@keyword)" disable-output-escaping="yes" />"&gt;
              &lt;param name="Name" value="<xsl:value-of select="ext:replaceentity(./@name)" disable-output-escaping="yes" />"&gt;
              &lt;param name="Local" value="<xsl:value-of select="./@local" />"&gt;
              &lt;/object&gt;
    </xsl:for-each>
&lt;/UL&gt;
&lt;/html&gt;
    </xsl:template>
</xsl:stylesheet>

