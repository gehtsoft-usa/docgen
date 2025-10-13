<?xml version="1.0" encoding="utf-8"?>
<!-- Converts BBCode parsed XML to plain text (for code blocks)
     Strips all formatting, keeps only text content
-->
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" encoding="utf-8"/>
    <xsl:namespace-alias stylesheet-prefix="ext" result-prefix="#default"/>

    <xsl:template match="/">
        <xsl:apply-templates select="/r/*" />
    </xsl:template>

    <!-- Plain text with entity replacement -->
    <xsl:template match="t"><xsl:value-of select="ext:replaceentity(./text())" disable-output-escaping="yes" /></xsl:template>

    <!-- Image: just output nothing or alt text -->
    <xsl:template match="img"></xsl:template>

    <!-- Line break -->
    <xsl:template match="br">
<xsl:text>
</xsl:text></xsl:template>

    <!-- Bold: just output content without formatting -->
    <xsl:template match="b"><xsl:apply-templates select="./*" /></xsl:template>

    <!-- Italic: just output content without formatting -->
    <xsl:template match="i"><xsl:apply-templates select="./*" /></xsl:template>

    <!-- Underline: just output content without formatting -->
    <xsl:template match="u"><xsl:apply-templates select="./*" /></xsl:template>

    <!-- Strikethrough: just output content without formatting -->
    <xsl:template match="s"><xsl:apply-templates select="./*" /></xsl:template>

    <!-- Subscript: just output content without formatting -->
    <xsl:template match="sub"><xsl:apply-templates select="./*" /></xsl:template>

    <!-- Superscript: just output content without formatting -->
    <xsl:template match="sup"><xsl:apply-templates select="./*" /></xsl:template>

    <!-- Inline code: just output content without backticks -->
    <xsl:template match="c"><xsl:apply-templates select="./*" /></xsl:template>

    <!-- Colors: just output content -->
    <xsl:template match="gray"><xsl:apply-templates select="./*" /></xsl:template>
    <xsl:template match="red"><xsl:apply-templates select="./*" /></xsl:template>
    <xsl:template match="green"><xsl:apply-templates select="./*" /></xsl:template>
    <xsl:template match="blue"><xsl:apply-templates select="./*" /></xsl:template>

    <!-- Font size: just output content -->
    <xsl:template match="size"><xsl:apply-templates select="./*" /></xsl:template>

    <!-- Custom color: just output content -->
    <xsl:template match="color"><xsl:apply-templates select="./*" /></xsl:template>

    <!-- Internal link: just output text content, no link -->
    <xsl:template match="link"><xsl:apply-templates select="./*" /><xsl:value-of select="ext:registerlink(./@attr)" /></xsl:template>

    <!-- Internal code link: just output text content, no link -->
    <xsl:template match="clink"><xsl:apply-templates select="./*" /><xsl:value-of select="ext:registerlink(./@attr)" /></xsl:template>

    <!-- External URL: just output text content, no link -->
    <xsl:template match="url"><xsl:apply-templates select="./*" /></xsl:template>

    <!-- External URL (new window): just output text content, no link -->
    <xsl:template match="eurl"><xsl:apply-templates select="./*" /></xsl:template>

    <!-- Variable substitution -->
    <xsl:template match="var"><xsl:variable name="attr" select="./@attr"/><xsl:value-of select="ext:get($attr)"/><xsl:apply-templates select="./*" /></xsl:template>
</xsl:stylesheet>
