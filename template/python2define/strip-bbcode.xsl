<?xml version="1.0" encoding="windows-1252"?>
<!-- writes body description

     @param ext:caller('curr-item') - a object which has description to write
   -->
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" />
    <xsl:namespace-alias stylesheet-prefix="ext" result-prefix="#default"/>
    <xsl:template match="/" >
        <xsl:apply-templates select="/r/*" />
    </xsl:template>

    <xsl:template match="t"><xsl:value-of select="ext:replaceentity(./text())" disable-output-escaping="yes" /></xsl:template>

    <xsl:template match="img"><xsl:element name="img"><xsl:attribute name="src"><xsl:value-of select="./@attr" /></xsl:attribute></xsl:element></xsl:template>
    <xsl:template match="br"></xsl:template>
    <xsl:template match="b"><xsl:apply-templates select="./*" /></xsl:template>
    <xsl:template match="i"><xsl:apply-templates select="./*" /></xsl:template>
    <xsl:template match="u"><xsl:apply-templates select="./*" /></xsl:template>
    <xsl:template match="s"><xsl:apply-templates select="./*" /></xsl:template>
    <xsl:template match="sub"><xsl:apply-templates select="./*" /></xsl:template>
    <xsl:template match="sup"><xsl:apply-templates select="./*" /></xsl:template>
    <xsl:template match="c"><xsl:apply-templates select="./*" /></xsl:template>
    <xsl:template match="gray"><xsl:apply-templates select="./*" /></xsl:template>
    <xsl:template match="red"><xsl:apply-templates select="./*" /></xsl:template>
    <xsl:template match="green"><xsl:apply-templates select="./*" /></xsl:template>
    <xsl:template match="blue"><xsl:apply-templates select="./*" /></xsl:template>
    <xsl:template match="size"><xsl:apply-templates select="./*" /></xsl:template>
    <xsl:template match="color"><xsl:apply-templates select="./*" /></xsl:template>
    <xsl:template match="link"><xsl:apply-templates select="./*" /></xsl:template>
    <xsl:template match="clink"><xsl:apply-templates select="./*" /></xsl:template>
    <xsl:template match="clink"><xsl:apply-templates select="./*" /></xsl:template>
    <xsl:template match="url"><xsl:apply-templates select="./*" /></xsl:template>
    <xsl:template match="eurl"><xsl:apply-templates select="./*" /></xsl:template>
    <xsl:template match="var"><xsl:apply-templates select="./*" /></xsl:template>
</xsl:stylesheet>

