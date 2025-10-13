<?xml version="1.0" encoding="utf-8"?>
<!-- Writes a group page in Markdown format
     Param: ext:caller('group') - a group to write
-->
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" encoding="utf-8"/>

    <xsl:template match="/">
        <xsl:apply-templates select="ext:caller('group')" />
    </xsl:template>

    <xsl:template match="group">
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

        <!-- Child groups and articles -->
        <xsl:value-of select="ext:let('curr-group-key', ./@key)" />

        <!-- Count children -->
        <xsl:value-of select="ext:let('child-groups', ext:get('g-root')/group[./@in-group=ext:get('curr-group-key')])" />
        <xsl:value-of select="ext:let('child-articles', ext:get('g-root')/article[./@in-group=ext:get('curr-group-key')])" />
        <xsl:value-of select="ext:let('child-classes', ext:get('g-root')/class[./@in-group=ext:get('curr-group-key')])" />

        <!-- Groups section -->
        <xsl:if test="count(ext:get('child-groups')) > 0">
            <xsl:text>## Groups&#10;&#10;</xsl:text>
            <xsl:for-each select="ext:get('child-groups')">
                <xsl:sort select="./@title" order="ascending" />
                <xsl:text>- [</xsl:text>
                <xsl:value-of select="./@title" />
                <xsl:text>](</xsl:text>
                <xsl:value-of select="./@key" />
                <xsl:text>.md)</xsl:text>
                <xsl:if test="string-length(./@brief) > 0 and ./@briefless='false'">
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
            </xsl:for-each>
            <xsl:text>&#10;</xsl:text>
        </xsl:if>

        <!-- Articles section -->
        <xsl:if test="count(ext:get('child-articles')) > 0">
            <xsl:text>## Articles&#10;&#10;</xsl:text>
            <xsl:for-each select="ext:get('child-articles')">
                <xsl:sort select="./@title" order="ascending" />
                <xsl:text>- [</xsl:text>
                <xsl:value-of select="./@title" />
                <xsl:text>](</xsl:text>
                <xsl:value-of select="./@key" />
                <xsl:text>.md)</xsl:text>
                <xsl:if test="string-length(./@brief) > 0 and ./@briefless='false'">
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
            </xsl:for-each>
            <xsl:text>&#10;</xsl:text>
        </xsl:if>

        <!-- Classes section -->
        <xsl:if test="count(ext:get('child-classes')) > 0">
            <xsl:text>## Classes&#10;&#10;</xsl:text>
            <xsl:for-each select="ext:get('child-classes')">
                <xsl:sort select="./@name" order="ascending" />
                <xsl:text>- [</xsl:text>
                <xsl:value-of select="./@name" />
                <xsl:text>](</xsl:text>
                <xsl:value-of select="./@key" />
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
            </xsl:for-each>
            <xsl:text>&#10;</xsl:text>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
