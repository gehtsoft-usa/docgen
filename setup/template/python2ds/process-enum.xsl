<?xml version="1.0" encoding="windows-1252"?>
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" />
    <!-- eliminate ext declaration -->
    <xsl:namespace-alias stylesheet-prefix="ext" result-prefix="#default"/>
    <xsl:template match="/" >
    <xsl:value-of select="ext:let('cname', ext:caller('p-class')/@name)" />
    <xsl:value-of select="ext:let('fname', ext:caller('p-class')/@key)" />
@class
    @name=<xsl:value-of select="ext:get('cname')" />
    @key=<xsl:value-of select="ext:get('fname')" />
    @brief=
    @type=enum
    @ingroup=index
    <xsl:for-each select="ext:caller('p-class')/field">
    @member
        @type=field
        @name=<xsl:value-of select="./@name" />
        @key=<xsl:value-of select="ext:get('cname')"/>.<xsl:value-of select="./@name"/>
        @divisor=.
        @brief=
        @scope=class
    @end
    </xsl:for-each>
@end
    </xsl:template>
</xsl:stylesheet>