<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" encoding="utf-8"/>

    <xsl:template match="/">
        <!-- Initialize global variables -->
        <xsl:value-of select="ext:letglobal('g-root', /root)" />
        <xsl:value-of select="ext:letglobal('g-file-extension', '.md')" />

        <!-- Find root group -->
        <xsl:value-of select="ext:let('root-group', /root/group[./@is-root='true'])" />

        <!-- Validate root group -->
        <xsl:if test="count(ext:get('root-group')) != 1">
            <xsl:value-of select="ext:error('The number of root groups is not equal to 1')" />
        </xsl:if>

        <!-- Set default codepage if not provided -->
        <xsl:choose>
            <xsl:when test="ext:exist('codepage')" />
            <xsl:otherwise><xsl:value-of select="ext:let('codepage', 'utf-8')" /></xsl:otherwise>
        </xsl:choose>

        <!-- Generate file for root group using its key -->
        <xsl:for-each select="ext:get('root-group')">
            <xsl:value-of select="ext:let('group', .)" />
            <xsl:value-of select="ext:call('write-group.xsl', /, concat(./@key, '.md'), ext:get('codepage'))" />
        </xsl:for-each>

        <!-- Generate all groups (non-root) flat -->
        <xsl:for-each select="/root/group[./@is-root='false']">
            <xsl:value-of select="ext:let('group', .)" />
            <xsl:value-of select="ext:call('write-group.xsl', /, concat(./@key, '.md'), ext:get('codepage'))" />
        </xsl:for-each>

        <!-- Generate all articles flat -->
        <xsl:for-each select="/root/article">
            <xsl:value-of select="ext:let('article', .)" />
            <xsl:value-of select="ext:call('write-article.xsl', /, concat(./@key, '.md'), ext:get('codepage'))" />
        </xsl:for-each>

        <!-- Generate all classes flat -->
        <xsl:for-each select="/root/class">
            <xsl:value-of select="ext:let('class', .)" />
            <xsl:value-of select="ext:call('write-class.xsl', /, concat(./@key, '.md'), ext:get('codepage'))" />
        </xsl:for-each>

        <!-- Generate all class members grouped by class and name, flat -->
        <xsl:for-each select="/root/class">
            <xsl:value-of select="ext:let('curr-class', .)" />
            <xsl:value-of select="ext:let('curr-class-key', ./@key)" />

            <!-- Get unique member names for this class -->
            <xsl:for-each select="./member">
                <xsl:value-of select="ext:let('curr-name', ./@name)" />

                <!-- Only process if this is the first occurrence of this name in this class -->
                <xsl:if test="count(preceding-sibling::member[./@name=ext:get('curr-name')]) = 0">
                    <!-- Get all members with this name -->
                    <xsl:value-of select="ext:let('members', ../member[./@name=ext:get('curr-name')])" />
                    <xsl:value-of select="ext:let('member', ext:get('members')[1])" />
                    <xsl:value-of select="ext:let('parent-class', ext:get('curr-class'))"/>

                    <!-- Generate file flat: {class-key}.{member-name}.md -->
                    <xsl:value-of select="ext:call('write-member.xsl', /, concat(ext:get('curr-class-key'), '.', ./@name, '.md'), ext:get('codepage'))" />
                </xsl:if>
            </xsl:for-each>
        </xsl:for-each>

        <!-- Validate all links -->
        <xsl:value-of select="ext:checkkeys()" />
    </xsl:template>
</xsl:stylesheet>
