<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" encoding="Windows-1252"/>
    <xsl:variable name="root" select="/" />
    <xsl:template match="/" >
@class
    @name=Documentation XML Model
    @brief=The section describes XML model that is passed to the output templates
    @key=modelXML
    @ingroup=authoringTemplates
    @type=tags
    @membersToContent=true

    @member
        @type=property
        @name=root
        @brief=The root element of the documentation model
        @custom=xml-tag

        <xsl:call-template name="canContain">
            <xsl:with-param name="list" select="/doc-schema/doc-element[./@top-level='true']" />
        </xsl:call-template>
    @end

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
        @name=<xsl:value-of select="$item/xml-element/@name" />
        @brief=<xsl:value-of select="$item/brief" />
        @custom=xml-tag

        <xsl:for-each select="$item/xml-element/xml-attribute">
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
        <xsl:for-each select="$list"><xsl:if test="position() > 1">, </xsl:if>[clink=modelXML.<xsl:value-of select="./xml-element/@name"/>]<xsl:value-of select=".//xml-element/@name"/>[/clink]</xsl:for-each>
    </xsl:template>

    <xsl:template name="addAttribute">
        <xsl:param name="item" />
        <xsl:param name="attribute" />
        <xsl:variable name="reference">
            <xsl:choose>
                <xsl:when test="count($attribute/@reference) > 0"><xsl:value-of select="$attribute/@reference"/></xsl:when>
                <xsl:otherwise><xsl:value-of select="$attribute/@name"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="brief">
            <xsl:choose>
                <xsl:when test="count($root/doc-schema/common-attributes/doc-attribute[@name=$reference]) > 0">
                    <xsl:value-of select="$root/doc-schema/common-attributes/doc-attribute[@name=$reference]/brief/text()"  />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$item/doc-attribute[@name=$reference]/brief/text()"  />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        @param
            @name=<xsl:value-of select="$attribute/@name" /><xsl:text xml:space="preserve">&#13;&#10;</xsl:text>
<xsl:text xml:space="preserve">            </xsl:text><xsl:value-of select="$brief" />
        @end
    </xsl:template>
</xsl:stylesheet>