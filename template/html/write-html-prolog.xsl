<?xml version="1.0" encoding="windows-1252"?>
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" />
    <xsl:namespace-alias stylesheet-prefix="ext" result-prefix="#default"/>
    <xsl:template match="/" >
    <xsl:variable name="html"><![CDATA[<html>]]></xsl:variable>
    <xsl:variable name="body"><![CDATA[<body>]]></xsl:variable>
    <xsl:variable name="head1"><![CDATA[<head>]]></xsl:variable>
    <xsl:variable name="head2"><![CDATA[</head>]]></xsl:variable>
    <xsl:value-of select="ext:let('p-has-diagrams', count(ext:caller('p-curr-node')//example[@highlight='diagram']) > 0 or count(ext:caller('p-curr-node')//example-tab[@highlight='diagram']) > 0)" />
<xsl:value-of select="$html" disable-output-escaping="yes" />
<xsl:value-of select="$head1" disable-output-escaping="yes" />
    <xsl:value-of select="concat('&lt;meta http-equiv=&quot;Content-Type&quot; content=&quot;text/html; charset=', ext:get('codepage'), '&quot; /&gt;')" disable-output-escaping="yes" />
    <xsl:value-of select="'&lt;!DOCTYPE html PUBLIC &quot;-//W3C//DTD XHTML 1.0 Transitional//EN&quot; &quot;http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd&quot;&gt;'" disable-output-escaping="yes" />
    <title><xsl:value-of select="ext:removehtml(ext:caller('p-title'))" /></title>
    <xsl:value-of select="ext:call('write-css.xsl', /)" disable-output-escaping="yes" />
<xsl:if test="ext:exist('add-to-prolog-head')">
    <xsl:value-of select="ext:readAllText(ext:get('add-to-prolog-head'))" disable-output-escaping="yes" />
</xsl:if>
<xsl:value-of select="$head2" disable-output-escaping="yes" />
<xsl:value-of select="$body" disable-output-escaping="yes" />
    <xsl:value-of select="ext:call('write-scripts.xsl', /)" disable-output-escaping="yes" />
<xsl:if test="ext:exist('add-to-prolog-body')">
    <xsl:value-of select="ext:readAllText(ext:get('add-to-prolog-body'))" disable-output-escaping="yes" />
</xsl:if>
    </xsl:template>
</xsl:stylesheet>
