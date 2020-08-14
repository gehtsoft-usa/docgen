<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" />
    <!-- eliminate ext declaration -->
    <xsl:namespace-alias stylesheet-prefix="ext" result-prefix="#default"/>
    <xsl:template match="/" >
        <xsl:choose>
            <xsl:when test="ext:match('(.*?)(forexconnect\.[\.\w]+)(.*)', ext:caller('type'))">
                <xsl:value-of select="ext:let('reres', ext:parse('(.*?)(forexconnect\.[\.\w]+)(.*)', ext:caller('type')))" />
                <xsl:value-of select="ext:let('retype', ext:get('reres')/result/match/group[1])" />
                <xsl:choose>
                    <xsl:when test="count(/classes/class[@key=ext:get('reres')/result/match/group[2]]) > 0">
                        <xsl:value-of select="ext:let('retype', concat(ext:get('retype'), '[clink=', ext:get('reres')/result/match/group[2], ']', /classes/class[@key=ext:get('reres')/result/match/group[2]]/@name, '[/clink]'))" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="ext:let('retype', concat(ext:get('retype'), ext:get('reres')/result/match/group[2]))" />
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:value-of select="ext:let('type', ext:get('reres')/result/match/group[3])" />
                <xsl:value-of select="ext:let('retype', concat(ext:get('retype'), ext:call('process-type.xsl', /)))" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="ext:let('retype', ext:caller('type'))" />
            </xsl:otherwise>
        </xsl:choose>
        <xsl:value-of select="ext:get('retype')" />
    </xsl:template>
</xsl:stylesheet>