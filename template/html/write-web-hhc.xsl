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
<script type="text/javascript" src="res/content1.js"></script>
<body>
<p><b><xsl:value-of select="ext:get('help-title')" /></b></p>
<ul class="hhc">
    <xsl:apply-templates select="/root/node" />
    <li><a href="web-hhk.html" target="docframe"><xsl:value-of select="ext:get('_string_index')" /></a></li>
</ul>
</body>
</html>
    </xsl:template>
    <xsl:template match="node">
        <xsl:choose>
        <xsl:when test="count(./@local)>0">
            <li class="hhc"><xsl:element name="a">
                <xsl:attribute name="href"><xsl:value-of select="./@local" /></xsl:attribute>
                <xsl:attribute name="target">docframe</xsl:attribute>
                <xsl:value-of select="./@name" disable-output-escaping="yes" /></xsl:element></li>
        </xsl:when>
        <xsl:otherwise>
            <li class="hhc"><xsl:value-of select="./@name" disable-output-escaping="yes" /></li>
        </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="count(./node)>0">
        <ul class="hhc">
            <xsl:apply-templates select="./node" />
        </ul>
    </xsl:if>
    </xsl:template>
</xsl:stylesheet>

