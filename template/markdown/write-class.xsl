<?xml version="1.0" encoding="utf-8"?>
<!-- Writes a class page in Markdown format
     Param: ext:caller('class') - a class to write
-->
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" encoding="utf-8"/>

    <xsl:template match="/">
        <xsl:apply-templates select="ext:caller('class')" />
    </xsl:template>

    <xsl:template match="class">
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
        <xsl:value-of select="./@type" />
        <xsl:text> </xsl:text>
        <xsl:value-of select="./@name" />
        <xsl:text>&#10;&#10;</xsl:text>

        <!-- Parents -->
        <xsl:if test="count(./parent) > 0">
            <xsl:text>**Inherits**: </xsl:text>
            <xsl:for-each select="./parent">
                <xsl:choose>
                    <xsl:when test="ext:get('transform') = 'yes' and string-length(.) > 0">
                        <xsl:value-of select="ext:call('bbcode-to-markdown.xsl', ext:parsebbcode(.))" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="." />
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:if test="position() != last()">
                    <xsl:text>, </xsl:text>
                </xsl:if>
            </xsl:for-each>
            <xsl:text>&#10;&#10;</xsl:text>
        </xsl:if>

        <!-- Brief -->
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

        <!-- Type parameters -->
        <xsl:if test="count(./param) > 0">
            <xsl:text>## Type Parameters&#10;&#10;</xsl:text>
            <xsl:for-each select="./param">
                <xsl:text>- **</xsl:text>
                <xsl:value-of select="./@name" />
                <xsl:text>**</xsl:text>
                <xsl:if test="count(./body/p) > 0">
                    <xsl:text>: </xsl:text>
                    <xsl:value-of select="ext:let('curr-item', .)" />
                    <xsl:for-each select="./body/p">
                        <xsl:choose>
                            <xsl:when test="ext:get('transform') = 'yes' and string-length(.) > 0">
                                <xsl:value-of select="ext:call('bbcode-to-markdown.xsl', ext:parsebbcode(.))" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="." />
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="position() != last()">
                            <xsl:text> </xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:if>
                <xsl:text>&#10;</xsl:text>
            </xsl:for-each>
            <xsl:text>&#10;</xsl:text>
        </xsl:if>

        <!-- Description -->
        <xsl:if test="count(./body/*) > 0">
            <xsl:text>## Details&#10;&#10;</xsl:text>
            <xsl:value-of select="ext:let('curr-item', .)" />
            <xsl:value-of select="ext:call('write-description.xsl', /)" />
        </xsl:if>

        <!-- Members summary -->
        <xsl:if test="count(./member) > 0">
            <xsl:text>## Members&#10;&#10;</xsl:text>

            <!-- Group by type -->
            <xsl:value-of select="ext:let('constructors', ./member[./@type='constructor'])" />
            <xsl:value-of select="ext:let('properties', ./member[./@type='property'])" />
            <xsl:value-of select="ext:let('methods', ./member[./@type='method'])" />
            <xsl:value-of select="ext:let('fields', ./member[./@type='field'])" />

            <!-- Constructors -->
            <xsl:if test="count(ext:get('constructors')) > 0">
                <xsl:text>### Constructors&#10;&#10;</xsl:text>
                <xsl:for-each select="ext:get('constructors')">
                    <xsl:call-template name="member-link" />
                </xsl:for-each>
                <xsl:text>&#10;</xsl:text>
            </xsl:if>

            <!-- Properties -->
            <xsl:if test="count(ext:get('properties')) > 0">
                <xsl:text>### Properties&#10;&#10;</xsl:text>
                <xsl:for-each select="ext:get('properties')">
                    <xsl:call-template name="member-link" />
                </xsl:for-each>
                <xsl:text>&#10;</xsl:text>
            </xsl:if>

            <!-- Methods -->
            <xsl:if test="count(ext:get('methods')) > 0">
                <xsl:text>### Methods&#10;&#10;</xsl:text>
                <xsl:for-each select="ext:get('methods')">
                    <xsl:call-template name="member-link" />
                </xsl:for-each>
                <xsl:text>&#10;</xsl:text>
            </xsl:if>

            <!-- Fields -->
            <xsl:if test="count(ext:get('fields')) > 0">
                <xsl:text>### Fields&#10;&#10;</xsl:text>
                <xsl:for-each select="ext:get('fields')">
                    <xsl:call-template name="member-link" />
                </xsl:for-each>
                <xsl:text>&#10;</xsl:text>
            </xsl:if>
        </xsl:if>

        <!-- Back link to parent group -->
        <xsl:text>---&#10;&#10;</xsl:text>
        <xsl:text>**Group**: [</xsl:text>
        <xsl:value-of select="ext:get('g-root')/group[./@key=current()/@in-group]/@title" />
        <xsl:text>](</xsl:text>
        <xsl:value-of select="./@in-group" />
        <xsl:text>.md)&#10;</xsl:text>
    </xsl:template>

    <!-- Member link template -->
    <xsl:template name="member-link">
        <xsl:text>- [</xsl:text>
        <xsl:value-of select="./@name" />
        <xsl:text>](</xsl:text>
        <xsl:value-of select="../@key" />
        <xsl:text>.</xsl:text>
        <xsl:value-of select="./@name" />
        <xsl:text>.md)</xsl:text>
        <xsl:if test="string-length(./@brief) > 0">
            <xsl:text> - </xsl:text>
            <xsl:choose>
                <xsl:when test="ext:get('transform') = 'yes' and string-length(./@brief) > 0">
                    <xsl:value-of select="ext:call('bbcode-to-markdown.xsl', ext:parsebbcode(./@brief))" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="./@brief" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>
</xsl:stylesheet>
