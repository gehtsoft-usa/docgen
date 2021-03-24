<?xml version="1.0" encoding="windows-1252"?>
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" />
    <xsl:namespace-alias stylesheet-prefix="ext" result-prefix="#default"/>
    <xsl:template match="/" >
    <xsl:variable name="html"><![CDATA[</html>]]></xsl:variable>
    <xsl:variable name="body"><![CDATA[</body>]]></xsl:variable>
<xsl:if test="ext:exist('add-to-epilog')">
    <xsl:value-of select="ext:readAllText(ext:get('add-to-epilog'))" disable-output-escaping="yes" />
</xsl:if>
<xsl:value-of select="$body" />
<xsl:value-of select="$html" />
    </xsl:template>
</xsl:stylesheet>
