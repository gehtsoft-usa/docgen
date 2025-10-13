<?xml version="1.0" encoding="utf-8"?>
<!-- Writes a member (method/property/field) page in Markdown format
     Param: ext:caller('members') - all members with same name (overloads)
     Param: ext:caller('member') - fallback for single member
     Param: ext:caller('parent-class') - the parent class
-->
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" encoding="utf-8"/>

    <xsl:template match="/">
        <!-- Get all members (overloads) or single member -->
        <xsl:choose>
            <xsl:when test="count(ext:caller('members')) > 0">
                <xsl:apply-templates select="ext:caller('members')[1]">
                    <xsl:with-param name="all-members" select="ext:caller('members')" />
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="ext:caller('member')">
                    <xsl:with-param name="all-members" select="ext:caller('member')" />
                </xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="member">
        <xsl:param name="all-members" />
        <!-- Register the primary key: class.name -->
        <xsl:value-of select="ext:registerkey(concat(./@class, '.', ./@name))" />
        <!-- Register all member keys with hashes for all overloads -->
        <xsl:for-each select="$all-members">
            <xsl:value-of select="ext:registerkey(concat(./@class, '.', ./@key))" />
        </xsl:for-each>

        <!-- Get transform setting -->
        <xsl:value-of select="ext:let('transform', ext:get('default-transform', 'no'))" />
        <xsl:for-each select="ancestor-or-self::*">
            <xsl:if test="count(./@transform) > 0 and ./@transform!='def'">
                <xsl:value-of select="ext:let('transform', ./@transform)" />
            </xsl:if>
        </xsl:for-each>

        <!-- Title -->
        <xsl:text># </xsl:text>
        <xsl:value-of select="./@class-name" />
        <xsl:value-of select="./@divisor" />
        <xsl:value-of select="./@name" />
        <xsl:text>&#10;&#10;</xsl:text>

        <!-- Member type and visibility -->
        <xsl:text>**Type**: </xsl:text>
        <xsl:value-of select="./@type" />
        <xsl:text>  &#10;</xsl:text>
        <xsl:text>**Visibility**: </xsl:text>
        <xsl:value-of select="./@visibility" />
        <xsl:text>  &#10;</xsl:text>
        <xsl:text>**Scope**: </xsl:text>
        <xsl:value-of select="./@scope" />
        <xsl:text>&#10;&#10;</xsl:text>

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

        <!-- Overload notice if multiple signatures exist -->
        <xsl:if test="count($all-members) > 1">
            <xsl:text>**Overloads**: This member has </xsl:text>
            <xsl:value-of select="count($all-members)" />
            <xsl:text> overload(s).&#10;&#10;</xsl:text>
        </xsl:if>

        <!-- Declarations for all overloads -->
        <xsl:text>## Declaration</xsl:text>
        <xsl:if test="count($all-members) > 1">
            <xsl:text>s</xsl:text>
        </xsl:if>
        <xsl:text>&#10;&#10;</xsl:text>

        <xsl:for-each select="$all-members">
            <!-- Show overload number if multiple -->
            <xsl:if test="count($all-members) > 1">
                <xsl:text>### Overload </xsl:text>
                <xsl:value-of select="position()" />
                <xsl:text>&#10;&#10;</xsl:text>
            </xsl:if>

            <xsl:for-each select="./declaration">
                <xsl:if test="count(../declaration) > 1">
                    <xsl:text>**</xsl:text>
                    <xsl:value-of select="./@language" />
                    <xsl:text>**&#10;&#10;</xsl:text>
                </xsl:if>
                <xsl:text>```</xsl:text>
                <xsl:value-of select="./@language" />
                <xsl:text>&#10;</xsl:text>
                <xsl:if test="string-length(./@prefix) > 0">
                    <xsl:value-of select="./@prefix" />
                    <xsl:text> </xsl:text>
                </xsl:if>
                <xsl:if test="string-length(./@return) > 0">
                    <xsl:choose>
                        <xsl:when test="ext:get('transform') = 'yes' and string-length(./@return) > 0">
                            <xsl:value-of select="ext:call('bbcode-to-markdown.xsl', ext:parsebbcode(./@return))" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="./@return" />
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:text> </xsl:text>
                </xsl:if>
                <xsl:value-of select="./@name" />
                <xsl:if test="string-length(./@name-suffix) > 0">
                    <xsl:value-of select="./@name-suffix" />
                </xsl:if>
                <xsl:if test="string-length(./@params) > 0">
                    <xsl:text>(</xsl:text>
                    <xsl:choose>
                        <xsl:when test="ext:get('transform') = 'yes' and string-length(./@params) > 0">
                            <xsl:value-of select="ext:call('bbcode-to-markdown.xsl', ext:parsebbcode(./@params))" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="./@params" />
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:text>)</xsl:text>
                </xsl:if>
                <xsl:if test="string-length(./@suffix) > 0">
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="./@suffix" />
                </xsl:if>
                <xsl:text>&#10;```&#10;&#10;</xsl:text>
            </xsl:for-each>

            <!-- Show parameters for this overload -->
            <xsl:if test="count(./param) > 0">
                <xsl:text>**Parameters**&#10;&#10;</xsl:text>
                <xsl:for-each select="./param">
                    <xsl:text>**`</xsl:text>
                    <xsl:value-of select="./@name" />
                    <xsl:text>`**&#10;&#10;</xsl:text>
                    <xsl:if test="count(./body/*) > 0">
                        <xsl:value-of select="ext:let('curr-item', .)" />
                        <xsl:value-of select="ext:call('write-description.xsl', /)" />
                    </xsl:if>
                    <xsl:text>&#10;</xsl:text>
                </xsl:for-each>
            </xsl:if>

            <!-- Show return value for this overload -->
            <xsl:if test="count(./return/body/*) > 0">
                <xsl:text>**Returns**&#10;&#10;</xsl:text>
                <xsl:value-of select="ext:let('curr-item', ./return[1])" />
                <xsl:value-of select="ext:call('write-description.xsl', /)" />
                <xsl:text>&#10;</xsl:text>
            </xsl:if>

            <!-- Separator between overloads -->
            <xsl:if test="position() != last()">
                <xsl:text>---&#10;&#10;</xsl:text>
            </xsl:if>
        </xsl:for-each>

        <!-- Description (shown once for all overloads) -->
        <xsl:if test="count(./body/*) > 0">
            <xsl:text>## Details&#10;&#10;</xsl:text>
            <xsl:value-of select="ext:let('curr-item', .)" />
            <xsl:value-of select="ext:call('write-description.xsl', /)" />
        </xsl:if>

        <!-- Back link to parent class -->
        <xsl:text>---&#10;&#10;</xsl:text>
        <xsl:text>**Class**: [</xsl:text>
        <xsl:value-of select="./@class-name" />
        <xsl:text>](</xsl:text>
        <xsl:value-of select="./@class" />
        <xsl:text>.md)&#10;</xsl:text>
    </xsl:template>
</xsl:stylesheet>
