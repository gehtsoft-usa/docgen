<?xml version="1.0" encoding="windows-1252"?>
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" />
    <xsl:namespace-alias stylesheet-prefix="ext" result-prefix="#default"/>
    <xsl:template match="/" >
<!--Sitemap 1.0-->
<html><head><title>Content</title>
    <xsl:value-of select="ext:call('write-css.xsl', /)" disable-output-escaping="yes" />
</head>
<body>
<p><b><xsl:value-of select="ext:get('_string_index')" /></b></p>
<xsl:value-of select="ext:let('prev-letter', '')" />
<xsl:for-each select="/root/key" xml:space="preserve" >
    <xsl:sort select="ext:upper(./@name)" />
        <xsl:value-of select="ext:let('curr-letter', ext:upper(substring(./@name, 1, 1)))" />
        <xsl:if test="ext:get('curr-letter')!=ext:get('prev-letter')">
            <xsl:if test="ext:get('prev-letter')!=''"><xsl:text disable-output-escaping="yes">&lt;/ul&gt;</xsl:text></xsl:if>
            <p><b><xsl:value-of select="ext:get('curr-letter')" /></b></p>
            <xsl:text disable-output-escaping="yes">&lt;ul class="hhc"&gt;</xsl:text>
            <xsl:value-of select="ext:let('prev-letter', ext:get('curr-letter'))" />
        </xsl:if>
        <li><xsl:element name="a"><xsl:attribute name="href"><xsl:value-of select="./@local" /></xsl:attribute>
            <xsl:value-of select="./@keyword" disable-output-escaping="yes" /></xsl:element></li>
</xsl:for-each>
<xsl:if test="ext:get('prev-letter')!=''"><xsl:text disable-output-escaping="yes">&lt;/ul&gt;</xsl:text></xsl:if>
</body>
</html>
    </xsl:template>
</xsl:stylesheet>

