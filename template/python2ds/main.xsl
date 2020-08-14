<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" />

    <!-- eliminate ext declaration -->
    <xsl:namespace-alias stylesheet-prefix="ext" result-prefix="#default"/>
    <xsl:template match="/" >
        <xsl:value-of select="ext:letglobal('g-data', ext:document(ext:get('src-file')))" />
        <xsl:for-each select="ext:get('g-data')/classes/class[./@type='class']">
            <xsl:value-of select="ext:let('p-class', .)" />
            <xsl:value-of select="ext:call('process-class.xsl', /, concat(ext:get('p-class')/@name, '.ds'), ext:get('codepage'))" />
        </xsl:for-each>
        <xsl:for-each select="ext:get('g-data')/classes/class[./@type='enum']">
            <xsl:value-of select="ext:let('p-class', .)" />
            <xsl:value-of select="ext:call('process-enum.xsl', /, concat(ext:get('p-class')/@name, '.ds'), ext:get('codepage'))" />
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
