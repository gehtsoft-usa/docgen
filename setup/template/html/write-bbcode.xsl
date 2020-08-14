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

    <xsl:template match="br"><br/></xsl:template>

    <xsl:template match="b"><b><xsl:apply-templates select="./*" /></b></xsl:template>

    <xsl:template match="i"><i><xsl:apply-templates select="./*" /></i></xsl:template>

    <xsl:template match="u"><u><xsl:apply-templates select="./*" /></u></xsl:template>

    <xsl:template match="s"><s><xsl:apply-templates select="./*" /></s></xsl:template>

    <xsl:template match="sub"><sub><xsl:apply-templates select="./*" /></sub></xsl:template>

    <xsl:template match="sup"><sup><xsl:apply-templates select="./*" /></sup></xsl:template>

    <xsl:template match="c"><code><xsl:apply-templates select="./*" /></code></xsl:template>

    <xsl:template match="gray"><font color="#7f7f7f"><xsl:apply-templates select="./*" /></font></xsl:template>

    <xsl:template match="red"><font color="red"><xsl:apply-templates select="./*" /></font></xsl:template>

    <xsl:template match="green"><font color="green"><xsl:apply-templates select="./*" /></font></xsl:template>

    <xsl:template match="blue"><font color="blue"><xsl:apply-templates select="./*" /></font></xsl:template>

    <xsl:template match="size"><xsl:element name="font"><xsl:attribute name="size"><xsl:value-of select="./@attr" /></xsl:attribute><xsl:apply-templates select="./*" /></xsl:element></xsl:template>

    <xsl:template match="color"><xsl:element name="font"><xsl:attribute name="color">#<xsl:value-of select="./@attr" /></xsl:attribute><xsl:apply-templates select="./*" /></xsl:element></xsl:template>

    <xsl:template match="link"><xsl:element name="a"><xsl:attribute name="href"><xsl:value-of select="./@attr" />.html</xsl:attribute><xsl:apply-templates select="./*" /></xsl:element><xsl:value-of select="ext:registerlink(./@attr)" /></xsl:template>

    <xsl:template match="clink"><xsl:element name="a"><xsl:attribute name="href"><xsl:value-of select="./@attr" />.html</xsl:attribute><code><xsl:apply-templates select="./*" /></code></xsl:element><xsl:value-of select="ext:registerlink(./@attr)" /></xsl:template>

    <xsl:template match="url"><xsl:element name="a"><xsl:attribute name="href"><xsl:value-of select="./@attr" /></xsl:attribute><xsl:apply-templates select="./*" /></xsl:element></xsl:template>

    <xsl:template match="eurl"><xsl:element name="a"><xsl:attribute name="href"><xsl:value-of select="./@attr" /></xsl:attribute><xsl:attribute name="target">_blank</xsl:attribute><xsl:apply-templates select="./*" /></xsl:element></xsl:template>

    <xsl:template match="var"><xsl:variable name="attr" select="./@attr"/><xsl:value-of select="ext:get($attr)"/><xsl:apply-templates select="./*" /></xsl:template>
</xsl:stylesheet>

