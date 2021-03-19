<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" encoding="Windows-1252"/>
    <xsl:variable name="root" select="/" />
    <xsl:template match="/" >
@class
    @name=Document Source Format
    @brief=The section describes format of the documentation source tags.
    @key=modelDS
    @ingroup=sources
    @type=tags
    @membersToContent=true

    <xsl:call-template name="canContain1">
        <xsl:with-param name="list" select="/doc-schema/doc-element[./@top-level='true']" />
    </xsl:call-template>

    <xsl:for-each select="/doc-schema/doc-element">
    <xsl:call-template name="addProperty">
        <xsl:with-param name="item" select="." />
    </xsl:call-template>
    </xsl:for-each>
@end
    </xsl:template>

    <xsl:template name="addProperty">
        <xsl:param name="item" />
    @member
        @type=property
        @name=<xsl:value-of select="$item/@doc-tag" />
        @brief=<xsl:value-of select="$item/brief" />
        @custom=xml-tag

        <xsl:for-each select="$item/doc-attribute">
            <xsl:call-template name="addAttribute">
                <xsl:with-param name="item" select="$item" />
                <xsl:with-param name="attribute" select="." />
            </xsl:call-template>
        </xsl:for-each>

        <xsl:call-template name="canContain">
            <xsl:with-param name="list" select="/doc-schema/doc-element[@doc-tag=($item/doc-child/@name)] | /doc-schema/doc-element[./@format='true' and count($item/@no-content) = 0]" />
        </xsl:call-template>

    @end
    </xsl:template>


    <xsl:template name="canContain">
        <xsl:param name="list" />
        The element may contain the following elements:
        <xsl:call-template name="canContain2"><xsl:with-param name="list" select="$list" /></xsl:call-template>
    </xsl:template>

    <xsl:template name="canContain1">
        <xsl:param name="list" />
        At the top level of the documentation file only following elements may be used
        <xsl:call-template name="canContain2"><xsl:with-param name="list" select="$list" /></xsl:call-template>
    </xsl:template>

    <xsl:template name="canContain2">
        <xsl:param name="list" />
        <xsl:for-each select="$list"><xsl:if test="position() > 1">, </xsl:if>[clink=modelDS.<xsl:value-of select="./@doc-tag"/>]<xsl:value-of select="./@doc-tag"/>[/clink]</xsl:for-each>
    </xsl:template>

    <xsl:template name="addAttribute">
        <xsl:param name="item" />
        <xsl:param name="attribute" />
        <xsl:variable name="brief">
            <xsl:choose>
                <xsl:when test="count($root/doc-schema/common-attributes/doc-attribute[@name=$attribute/@name]) > 0">
                    <xsl:value-of select="$root/doc-schema/common-attributes/doc-attribute[@name=$attribute/@name]/brief/text()"  />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$attribute/brief/text()"  />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        @param
            @name=<xsl:value-of select="$attribute/@name" /><xsl:text xml:space="preserve">&#13;&#10;</xsl:text>
<xsl:text xml:space="preserve">            </xsl:text><xsl:value-of select="$brief" />
        @end
    </xsl:template>
</xsl:stylesheet>