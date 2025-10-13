<?xml version="1.0" encoding="utf-8"?>
<!-- Converts BBCode parsed XML to Markdown format
     Accurate port of write-bbcode.xsl from HTML template

     @param ext:caller('curr-item') - an object which has description to write
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

    <!-- Image: ![](src) -->
    <xsl:template match="img"><xsl:text>![](</xsl:text><xsl:value-of select="./@attr" /><xsl:text>)</xsl:text></xsl:template>

    <!-- Line break: two spaces + newline -->
    <xsl:template match="br">
<xsl:text>
</xsl:text></xsl:template>

    <!-- Bold: **text** -->
    <xsl:template match="b"><xsl:text>**</xsl:text><xsl:apply-templates select="./*" /><xsl:text>**</xsl:text></xsl:template>

    <!-- Italic: *text* -->
    <xsl:template match="i"><xsl:text>*</xsl:text><xsl:apply-templates select="./*" /><xsl:text>*</xsl:text></xsl:template>

    <!-- Underline: HTML fallback since markdown doesn't support it natively -->
    <xsl:template match="u"><xsl:text>&lt;u&gt;</xsl:text><xsl:apply-templates select="./*" /><xsl:text>&lt;/u&gt;</xsl:text></xsl:template>

    <!-- Strikethrough: ~~text~~ -->
    <xsl:template match="s"><xsl:text>~~</xsl:text><xsl:apply-templates select="./*" /><xsl:text>~~</xsl:text></xsl:template>

    <!-- Subscript: HTML fallback -->
    <xsl:template match="sub"><xsl:text>&lt;sub&gt;</xsl:text><xsl:apply-templates select="./*" /><xsl:text>&lt;/sub&gt;</xsl:text></xsl:template>

    <!-- Superscript: HTML fallback -->
    <xsl:template match="sup"><xsl:text>&lt;sup&gt;</xsl:text><xsl:apply-templates select="./*" /><xsl:text>&lt;/sup&gt;</xsl:text></xsl:template>

    <!-- Inline code: `text` -->
    <xsl:template match="c"><xsl:text>`</xsl:text><xsl:apply-templates select="./*" /><xsl:text>`</xsl:text></xsl:template>

    <!-- Colors: markdown doesn't support colors, render as plain text -->
    <xsl:template match="gray"><xsl:apply-templates select="./*" /></xsl:template>

    <xsl:template match="red"><xsl:apply-templates select="./*" /></xsl:template>

    <xsl:template match="green"><xsl:apply-templates select="./*" /></xsl:template>

    <xsl:template match="blue"><xsl:apply-templates select="./*" /></xsl:template>

    <!-- Font size: markdown doesn't support font sizes, render as plain text -->
    <xsl:template match="size"><xsl:apply-templates select="./*" /></xsl:template>

    <!-- Custom color: markdown doesn't support colors, render as plain text -->
    <xsl:template match="color"><xsl:apply-templates select="./*" /></xsl:template>

    <!-- Internal link: [text](link.md) -->
    <xsl:template match="link"><xsl:text>[</xsl:text><xsl:apply-templates select="./*" /><xsl:text>](</xsl:text><xsl:value-of select="./@attr" /><xsl:text>.md)</xsl:text><xsl:value-of select="ext:registerlink(./@attr)" /></xsl:template>

    <!-- Internal code link: [`text`](link.md) -->
    <xsl:template match="clink"><xsl:text>[`</xsl:text><xsl:apply-templates select="./*" /><xsl:text>`](</xsl:text><xsl:value-of select="./@attr" /><xsl:text>.md)</xsl:text><xsl:value-of select="ext:registerlink(./@attr)" /></xsl:template>

    <!-- External URL: [text](url) -->
    <xsl:template match="url"><xsl:text>[</xsl:text><xsl:apply-templates select="./*" /><xsl:text>](</xsl:text><xsl:value-of select="./@attr" /><xsl:text>)</xsl:text></xsl:template>

    <!-- External URL (new window): [text](url) - markdown doesn't distinguish, same as url -->
    <xsl:template match="eurl"><xsl:text>[</xsl:text><xsl:apply-templates select="./*" /><xsl:text>](</xsl:text><xsl:value-of select="./@attr" /><xsl:text>)</xsl:text></xsl:template>

    <!-- Variable substitution -->
    <xsl:template match="var"><xsl:variable name="attr" select="./@attr"/><xsl:value-of select="ext:get($attr)"/><xsl:apply-templates select="./*" /></xsl:template>
</xsl:stylesheet>
