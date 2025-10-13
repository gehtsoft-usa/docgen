<?xml version="1.0" encoding="utf-8"?>
<!-- Writes an article page in Markdown format
     Param: ext:caller('article') - an article to write
-->
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" encoding="utf-8"/>

    <xsl:template match="/">
        <xsl:apply-templates select="ext:caller('article')" />
    </xsl:template>

    <xsl:template match="article">
        <xsl:value-of select="ext:registerkey(./@key)" />

        <!-- Get transform setting -->
        <xsl:value-of select="ext:let('transform', ext:get('default-transform', 'no'))" />
        <xsl:for-each select="ancestor-or-self::*">
            <xsl:if test="count(./@transform) > 0 and ./@transform!='def'">
                <xsl:value-of select="ext:let('transform', ./@transform)" />
            </xsl:if>
        </xsl:for-each>

        <!-- Title -->
        <xsl:text># </xsl:text>
        <xsl:value-of select="./@title" />
        <xsl:text>&#10;&#10;</xsl:text>

        <!-- Brief (if not briefless) -->
        <xsl:if test="./@briefless='false'">
            <xsl:text>## Brief&#10;&#10;</xsl:text>
            <xsl:choose>
                <xsl:when test="ext:get('transform') = 'yes' and string-length(./@brief) > 0">
                    <xsl:value-of select="ext:call('bbcode-to-markdown.xsl', ext:parsebbcode(./@brief))" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="./@brief" />
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text>&#10;&#10;</xsl:text>

            <xsl:if test="count(./body/*) > 0">
                <xsl:text>## Details&#10;&#10;</xsl:text>
            </xsl:if>
        </xsl:if>

        <!-- Description -->
        <xsl:if test="count(./body/*) > 0">
            <xsl:value-of select="ext:let('curr-item', .)" />
            <xsl:value-of select="ext:call('write-description.xsl', /)" />
        </xsl:if>

        <!-- Back link to parent group -->
        <xsl:text>---&#10;&#10;</xsl:text>
        <xsl:text>**Group**: [</xsl:text>
        <xsl:value-of select="ext:get('g-root')/group[./@key=current()/@in-group]/@title" />
        <xsl:text>](</xsl:text>
        <xsl:value-of select="./@in-group" />
        <xsl:text>.md)&#10;</xsl:text>
    </xsl:template>
</xsl:stylesheet>
