<?xml version="1.0" encoding="windows-1252"?>
<!-- writes article
     param: ext:caller('curr-item') - a class to write

  -->
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" />
    <xsl:namespace-alias stylesheet-prefix="ext" result-prefix="#default"/>
    <xsl:template match="/" >

        <xsl:value-of select="ext:let('p-title', concat(ext:escape(ext:caller('curr-item')/@name), '.', ext:escape(ext:caller('curr-name'))))" />
        <xsl:value-of select="ext:call('write-html-prolog.xsl', /)" disable-output-escaping="yes" />

        <h1>Method group <code><b><xsl:value-of select="ext:get('p-title')" disable-output-escaping="yes" /></b></code></h1>

        <xsl:value-of select="ext:let('list-template', 'member-list-1.xsl')" />
        <xsl:value-of select="ext:let('group-name', 'Method')" />
        <xsl:value-of select="ext:let('members', ext:caller('subset'))" />

        <xsl:value-of select="ext:let('transform', ext:caller('transform'))" />
        <xsl:value-of select="ext:let('content-node', ext:caller('content-node'))" />
        <xsl:value-of select="ext:let('write-signatures', ext:caller('write-signatures'))" />
        <xsl:value-of select="ext:let('curr-item', ext:caller('curr-item'))" />

        <xsl:value-of select="ext:call(ext:get('list-template'), /)" disable-output-escaping="yes" />
    </xsl:template>
</xsl:stylesheet>

