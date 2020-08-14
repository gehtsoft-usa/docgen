<?xml version="1.0" encoding="windows-1252"?>
<!-- writes body description

     @param ext:caller('curr-item') - a object which has description to write
   -->
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" />
    <xsl:namespace-alias stylesheet-prefix="ext" result-prefix="#default"/>
    <xsl:template match="/" >
        <xsl:value-of select="ext:let('transform', ext:caller('transform'))" />
        <xsl:apply-templates select="ext:caller('curr-item')" />
    </xsl:template>
    <xsl:template match="list" >
        <xsl:choose>
            <xsl:when test="./@type='num'">
        <ol class="main">
            <xsl:apply-templates select="./*" />
        </ol>
            </xsl:when>
            <xsl:otherwise>
        <ul class="main">
            <xsl:apply-templates select="./*" />
        </ul>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="list-item" >
        <xsl:value-of select="ext:let('curr-item', .)" />
        <li><xsl:value-of select="ext:call('write-description.xsl', /)" disable-output-escaping="yes" /></li>
    </xsl:template>
</xsl:stylesheet>

