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
<link rel="stylesheet" href="res/dripicons.css"></link>
<link rel="stylesheet" href="res/content.css"></link>
<script type="text/javascript" src="res/mktree.js"></script>
<script type="text/javascript" src="res/content.js"></script>
<script type="text/javascript" src="res/content1.js"></script>
</head>
<body>
<ul class="mktree" id="hhc_tree">
    <xsl:apply-templates select="/root/node" />
    <li><a href="web-hhk.html" target="docframe"><xsl:value-of select="ext:get('_string_index')" /></a></li>
</ul>
<script language="javascript" type="text/javascript">createIds();</script>
</body>
</html>
    </xsl:template>
    <xsl:template match="node">
        <xsl:element name="li">
            <xsl:choose>
                <xsl:when test="count(./@local) > 0 and count(./node) = 0">
                    <xsl:element name="a">
                        <xsl:attribute name="href"><xsl:value-of select="./@local" /></xsl:attribute>
                        <xsl:attribute name="target">docframe</xsl:attribute>
                        <xsl:value-of select="./@name" disable-output-escaping="yes" />
                    </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="./@name" disable-output-escaping="yes" />
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="count(./node) > 0">
                <xsl:element name="ul">
                    <xsl:if test="count(./@local) > 0">
                        <xsl:element name="li">
                            <xsl:element name="a">
                                <xsl:attribute name="href"><xsl:value-of select="./@local" /></xsl:attribute>
                                <xsl:attribute name="target">docframe</xsl:attribute>
                                <xsl:value-of select="./@name" disable-output-escaping="yes" />
                            </xsl:element>
                        </xsl:element>
                    </xsl:if>
                    <xsl:apply-templates select="./node" />
                </xsl:element>

            </xsl:if>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>