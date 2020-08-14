<?xml version="1.0" encoding="windows-1252"?>
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://xml.jeldoclet.com">
    <xsl:output method="text" />
    <!-- eliminate ext declaration -->
    <xsl:namespace-alias stylesheet-prefix="ext" result-prefix="#default"/>
    <xsl:template match="*" >
    <!-- namespace name -->
    <xsl:value-of select="ext:let('p-package', ext:caller('p-package')) " />

    <xsl:value-of select="ext:let('member', ext:caller('member')) " />
        @declaration
            @language=java
            @name=<xsl:value-of select="ext:caller('name')" />
            <xsl:if test="ext:caller('return') = 'yes'" >
            <xsl:value-of select="ext:let('type', ext:get('member'))"/>
            @return=<xsl:value-of select="ext:call('process-type.xsl', /)" />
            </xsl:if>
            <xsl:if test="count(ext:get('member')/xs:params/xs:param) > 0">
                <xsl:value-of select="ext:let('i', 0)" />
                <xsl:value-of select="ext:let('params', '')" />
                <xsl:for-each select="ext:get('member')/xs:params/xs:param">
                    <xsl:if test="ext:get('i') > 0"><xsl:value-of select="ext:let('params', concat(ext:get('params'), ', '))" /></xsl:if>
                    <xsl:value-of select="ext:let('i', ext:get('i') + 1)" />
                    <xsl:value-of select="ext:let('type', .)"/>
                    <xsl:value-of select="ext:let('params', concat(ext:get('params'), normalize-space(ext:call('process-type.xsl', /)), ' ')) "/>
                    <xsl:value-of select="ext:let('params', concat(ext:get('params'), ./@name)) "/>
                </xsl:for-each>
            @params=<xsl:value-of select="ext:get('params')" />
            </xsl:if>
        @end
    </xsl:template>
</xsl:stylesheet>

