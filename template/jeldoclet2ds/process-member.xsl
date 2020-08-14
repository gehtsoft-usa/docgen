<?xml version="1.0" encoding="windows-1252"?>
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://xml.jeldoclet.com">
    <xsl:output method="text" />
    <!-- eliminate ext declaration -->
    <xsl:namespace-alias stylesheet-prefix="ext" result-prefix="#default"/>
    <xsl:template match="/" >
    <!-- namespace name -->
    <xsl:value-of select="ext:let('p-package', ext:caller('p-package')) " />
    <!-- class name -->
    <xsl:value-of select="ext:let('p-class-name', ext:caller('p-class-name')) " />
    <!-- select member -->
    <xsl:value-of select="ext:let('member', ext:caller('member'))" />

    <xsl:if test="contains(ext:get('visibility'), ext:get('member')/@visibility)">
    <xsl:value-of select="ext:let('name', ext:get('member')/@name)" />
    <xsl:choose>
        <xsl:when test="local-name(ext:get('member'))='constructor'">
            <xsl:value-of select="ext:let('name', ext:get('p-class-name'))" />
        </xsl:when>
        <xsl:otherwise><xsl:value-of select="ext:let('name', ext:get('member')/@name)" /></xsl:otherwise>
    </xsl:choose>
    @member
        @name=<xsl:value-of select="ext:get('name')" />
        @key=<xsl:value-of select="concat(concat(concat(ext:get('member')/ancestor::xs:jelclass/@fulltype, '.'), ext:get('member')/@name), '.0')" />
        @divisor=.
        @brief=
        @scope=<xsl:choose><xsl:when test="ext:get('member')/@static='true'">class</xsl:when><xsl:when test="ext:get('member')/@static='false' or count(ext:get('member')/@static)=0">instance</xsl:when></xsl:choose>

        <xsl:choose>
            <xsl:when test="local-name(ext:get('member')) = 'constructor'" >
        @type=constructor
            <xsl:value-of select="ext:let('return', 'no') " />
            <xsl:value-of select="ext:call('decl-java.xsl', ext:get('member'))" />
            </xsl:when>
            <xsl:when test="local-name(ext:get('member')) = 'field'" >
        @type=field
            </xsl:when>
            <xsl:when test="local-name(ext:get('member')) = 'method'" >
        @type=method
            <xsl:value-of select="ext:let('return', 'yes') " />
            <xsl:value-of select="ext:call('decl-java.xsl', ext:get('member'))" />
            </xsl:when>
        </xsl:choose>

        <xsl:for-each select="ext:get('member')/xs:params/xs:param" >
        @param
            @name=<xsl:value-of select="./@name" />

        @end
        </xsl:for-each>
    @end
    </xsl:if>
    </xsl:template>
</xsl:stylesheet>

