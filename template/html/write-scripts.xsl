<?xml version="1.0" encoding="windows-1252"?>
<!-- writes scripts to the page header -->
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" />
    <xsl:namespace-alias stylesheet-prefix="ext" result-prefix="#default"/>
    <xsl:template match="/" >
<script>
    var highlighterEnabled = <xsl:choose><xsl:when test="ext:exist('enable-highlighter') and ext:get('enable-highlighter') = 'yes'">true</xsl:when><xsl:otherwise>false</xsl:otherwise></xsl:choose>;
</script>
<xsl:if test="ext:exist('enable-highlighter') and ext:get('enable-highlighter') = 'yes'">
    <script type="text/javascript" src="highlighter/highlight.pack.js" />
    <script type="text/javascript" src="highlighter/highlight.cshtml.js" />
</xsl:if>
<xsl:choose>
<xsl:when test="ext:exist('external-resources') and ext:get('external-resources') = 'yes'">
    <script type="text/javascript" src="res/page-scripts.js" />
</xsl:when>
<xsl:otherwise>
    <script type="text/javascript">
       <xsl:value-of select="ext:readAllText('res/page-scripts.js')" disable-output-escaping="yes" />
    </script>
</xsl:otherwise>
</xsl:choose>

<xsl:if test="ext:exist('add-custom-script') ">
    <xsl:element name="script">
        <xsl:attribute name="type">text/javascript</xsl:attribute>
        <xsl:attribute name="src"><xsl:value-of select="ext:get('add-custom-script')" /></xsl:attribute>
    </xsl:element>
</xsl:if>

<script type="text/javascript">
    loadStarted();
</script>

</xsl:template>
</xsl:stylesheet>

