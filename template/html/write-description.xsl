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
        <xsl:value-of select="ext:let('transform', ext:caller('transform'))" />
        <xsl:apply-templates select="ext:caller('curr-item')/body" />
    </xsl:template>
    <xsl:template match="body" >
    <xsl:for-each select="./*">
        <xsl:value-of select="ext:let('curr-item', .)" />
        <xsl:choose>
            <xsl:when test="ext:strcmp(name(.), 'p')=0">
                <xsl:choose>
                    <xsl:when test="ext:get('transform')='yes'">
                        <p><xsl:value-of select="ext:call('write-bbcode.xsl', ext:parsebbcode(./text()))" disable-output-escaping="yes" /></p>
                    </xsl:when>
                    <xsl:otherwise>
                        <p><xsl:value-of select="./text()" disable-output-escaping="yes" /></p>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="ext:strcmp(name(.), 'header')=0">
                <xsl:value-of select="ext:let('item-text', '')" />
                <xsl:for-each select="./body/p">
                    <xsl:if test="string-length(ext:get('item-text')) > 0"><xsl:value-of select="ext:let('item-text', concat(ext:get('item-text'), '&lt;br&gt;'))" /></xsl:if>
                    <xsl:choose>
                        <xsl:when test="ext:get('transform')='yes'">
                            <p><xsl:value-of select="ext:let('text', ext:call('write-bbcode.xsl', ext:parsebbcode(./text())))" disable-output-escaping="yes" /></p>
                        </xsl:when>
                        <xsl:otherwise>
                            <p><xsl:value-of select="ext:let('text', ./text())" disable-output-escaping="yes" /></p>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:value-of select="ext:let('item-text', concat(ext:get('item-text'), ext:get('text')))" />
                </xsl:for-each>
                <xsl:choose>
                    <xsl:when test="./@level=1"><h1><xsl:value-of select="ext:get('item-text')" disable-output-escaping="yes" /></h1></xsl:when>
                    <xsl:when test="./@level=2"><h2><xsl:value-of select="ext:get('item-text')" disable-output-escaping="yes" /></h2></xsl:when>
                    <xsl:when test="./@level=3"><h3><xsl:value-of select="ext:get('item-text')" disable-output-escaping="yes" /></h3></xsl:when>
                    <xsl:when test="./@level=4"><h4><xsl:value-of select="ext:get('item-text')" disable-output-escaping="yes" /></h4></xsl:when>
                    <xsl:when test="./@level=5"><h5><xsl:value-of select="ext:get('item-text')" disable-output-escaping="yes" /></h5></xsl:when>
                    <xsl:when test="./@level=6"><h6><xsl:value-of select="ext:get('item-text')" disable-output-escaping="yes" /></h6></xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="ext:strcmp(name(.), 'example')=0">
                <xsl:value-of select="ext:call('write-example.xsl', /)" disable-output-escaping="yes" />
            </xsl:when>
            <xsl:when test="ext:strcmp(name(.), 'table')=0">
                <xsl:value-of select="ext:call('write-table.xsl', /)" disable-output-escaping="yes" />
            </xsl:when>
            <xsl:when test="ext:strcmp(name(.), 'list')=0">
                <xsl:value-of select="ext:call('write-list.xsl', /)" disable-output-escaping="yes" />
            </xsl:when>
        </xsl:choose>
    </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>

