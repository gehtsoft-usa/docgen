<?xml version="1.0" encoding="windows-1252"?>
<!-- writes in-body table.

     @param ext:caller('curr-item') - a table object
  -->
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" />
    <xsl:namespace-alias stylesheet-prefix="ext" result-prefix="#default"/>
    <xsl:template match="/" >
        <xsl:value-of select="ext:let('transform', ext:caller('transform'))" />
        <xsl:apply-templates select="ext:caller('curr-item')" />
    </xsl:template>
    <xsl:template match="table" >
<xsl:element name="table">
    <xsl:attribute name="class">tmain</xsl:attribute>
    <xsl:if test="ext:strcmp(./@width,'')!=0"><xsl:attribute name="width"><xsl:value-of select="./@width" /></xsl:attribute></xsl:if>
<xsl:for-each select="./table-row" >
<tr>
<xsl:for-each select="./table-col" >
<xsl:element name="td">
    <xsl:choose>
        <xsl:when test="../@is-header='true'"><xsl:attribute name="class">thdr</xsl:attribute></xsl:when>
        <xsl:when test="../@is-header='false'"><xsl:attribute name="class">tmain</xsl:attribute></xsl:when>
    </xsl:choose>
    <xsl:if test="ext:strcmp(./@width,'')!=0"><xsl:attribute name="width"><xsl:value-of select="./@width" /></xsl:attribute></xsl:if>
    <xsl:value-of select="ext:let('curr-item', .)" />
    <xsl:value-of select="ext:call('write-description.xsl', /)" disable-output-escaping="yes" />
</xsl:element>
</xsl:for-each>
</tr>
</xsl:for-each>
</xsl:element>
    </xsl:template>
</xsl:stylesheet>

