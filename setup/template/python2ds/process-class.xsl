<?xml version="1.0" encoding="windows-1252"?>
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" />
    <!-- eliminate ext declaration -->
    <xsl:namespace-alias stylesheet-prefix="ext" result-prefix="#default"/>
    <xsl:template match="/" >
    <xsl:value-of select="ext:let('cname', ext:caller('p-class')/@name)" />
    <xsl:value-of select="ext:let('fname', ext:caller('p-class')/@key)" />
@class
    @name=<xsl:value-of select="ext:get('cname')" />
    @key=<xsl:value-of select="ext:get('fname')" />
    @brief=
    @type=class
    @ingroup=index
    <xsl:if test="count(ext:caller('p-class')/@parent) > 0 and ext:caller('p-class')/@parent != ''">
        <xsl:value-of select="ext:let('type', ext:caller('p-class')/@parent)" />
        <xsl:value-of select="ext:let('type', ext:call('process-type.xsl', /))" />
    @parent=<xsl:value-of select="ext:get('type')" />
    </xsl:if>

    <xsl:if test="count(ext:caller('p-class')/@iterable) > 0 and ext:caller('p-class')/@iterable = 'True'">
        The type is an iterable type.
    </xsl:if>

    <xsl:if test="count(ext:caller('p-class')/@collection) > 0 and ext:caller('p-class')/@iterable = 'True'">
        The type is an indexable collection type.
    </xsl:if>

    <xsl:if test="count(ext:caller('p-class')/@elements) > 0 and ext:caller('p-class')/@elements != ''">
        <xsl:value-of select="ext:let('type', ext:caller('p-class')/@elements)" />
        <xsl:value-of select="ext:let('type', ext:call('process-type.xsl', /))" />
        The type of an element is <xsl:value-of select="ext:get('type')" />
    </xsl:if>

    <xsl:for-each select="ext:caller('p-class')/field">
    @member
        @type=field
        @name=<xsl:value-of select="./@name" />
        @key=<xsl:value-of select="ext:get('cname')"/>.<xsl:value-of select="./@name"/>
        @divisor=.
        @brief=
        @scope=<xsl:choose><xsl:when test="count(./@staticfield) > 0 and ./@staticfield='True'">class</xsl:when><xsl:otherwise>instance</xsl:otherwise></xsl:choose>

        <xsl:if test="count(./@value) > 0 and ./@value != ''">
        <xsl:value-of select="ext:let('type', ./@value)" />
        <xsl:value-of select="ext:let('type', ext:call('process-type.xsl', /))" />
        The property value is <xsl:value-of select="ext:get('type')" />
        </xsl:if>




    @end
    </xsl:for-each>


    <xsl:for-each select="ext:caller('p-class')/method">
        <xsl:if test="not(starts-with(./@name, '_'))" >
    @member
        @name=<xsl:value-of select="./@name" />
        @key=<xsl:value-of select="ext:get('cname')"/>.<xsl:value-of select="./@name"/>
        @divisor=.
        @brief=
        @scope=<xsl:choose><xsl:when test="count(./@staticmethod) > 0 and ./@staticmethod='True'">class</xsl:when><xsl:otherwise>instance</xsl:otherwise></xsl:choose>
        @visibility=public

        @declaration
            @language=python
            @name=<xsl:value-of select="./@name" />
            @return=<xsl:choose><xsl:when test="count(./return) > 0"><xsl:value-of select="ext:let('type', ./return[1]/@type)"/><xsl:value-of select="ext:call('process-type.xsl', /)"/></xsl:when><xsl:otherwise>none</xsl:otherwise></xsl:choose>
            <xsl:value-of select="ext:let('params', '')" />
            <xsl:value-of select="ext:let('i', 0)" />
            <xsl:for-each select="./parameter">
                <xsl:choose>
                <xsl:when test="./@type = ../../@key and ./@name='arg1'" />
                <xsl:otherwise>
                <xsl:if test="ext:get('i') > 0"><xsl:value-of select="ext:let('params', concat(ext:get('params'), ', '))" /></xsl:if>
                <xsl:value-of select="ext:let('i', ext:get('i') + 1)" />
                <xsl:value-of select="ext:let('type', ./@type)" />
                <xsl:value-of select="ext:let('type', ext:call('process-type.xsl', /))" />
                <xsl:value-of select="ext:let('params', concat(ext:get('params'), '(', ext:get('type'), ')', ./@name)) "/>
                <xsl:if test="count(./@default) > 0 and ./@default != ''">
                    <xsl:value-of select="ext:let('params', concat(ext:get('params'), ' = ', ./@default)) "/>
                </xsl:if>
                </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
            @params=<xsl:value-of select="ext:get('params')" />
        @end

        <xsl:for-each select="./parameter" >
        @param
            @name=<xsl:value-of select="./@name" />
            <xsl:if test="count(./@default) > 0 and ./@default != ''">
            The default value of the parameter is <xsl:value-of select="./@default" /></xsl:if>
        @end
        </xsl:for-each>
    @end
        </xsl:if>
    </xsl:for-each>
@end
    </xsl:template>
</xsl:stylesheet>