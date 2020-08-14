<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" encoding="Windows-1252"/>
    <xsl:template match="/" >
    <xsl:for-each select="/root/article">
        <xsl:if test="ext:strcmp(./@alias-id, 'null')!=0"><xsl:value-of select="./@alias-id" />=<xsl:value-of select="./@key" />.html<xsl:text>&#13;&#10;</xsl:text></xsl:if>
    </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>

