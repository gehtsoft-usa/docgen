<?xml version="1.0" encoding="windows-1252"?>
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" />
    <xsl:template match="/" >
    <xsl:variable name="namespace-org-name"><xsl:value-of select="/doxygen/compounddef/compoundname/text()"/></xsl:variable>
    <xsl:variable name="namespace-key"><xsl:value-of select="ext:replace($namespace-org-name, '::', '.')"/></xsl:variable>
    <xsl:variable name="namespace-name"><xsl:choose><xsl:when test="ext:get('divisor', '::') != '::'"><xsl:value-of select="ext:replace($namespace-org-name, '::', ext:get('divisor'))"/></xsl:when><xsl:otherwise><xsl:value-of select="$namespace-org-name"/></xsl:otherwise></xsl:choose></xsl:variable>
@group
    @title=Namespace <xsl:value-of select="$namespace-name" />
    @key=<xsl:value-of select="$namespace-key" />
    @ingroup=<xsl:value-of select="ext:get('group')" />
    @brief=
    @transform=yes
@end
    <xsl:value-of select="ext:let('namespace-key', $namespace-key)" />
    <xsl:for-each select="/doxygen/compounddef/innerclass">
        <xsl:value-of select="ext:let('class-xml', ext:document(concat(ext:get('xml-path'), ./@refid, '.xml')))" />
        <xsl:value-of select="ext:let('class-org-name', ext:get('class-xml')/doxygen/compounddef/compoundname/text())" />
        <xsl:value-of select="ext:let('class-key', ext:replace(ext:get('class-org-name'), '::', '.'))" />
        <xsl:value-of select="ext:call('process-class.xsl', /, concat(ext:get('ds-path'), ext:get('class-key'), '.ds'), ext:get('codepage'))" />
    </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>