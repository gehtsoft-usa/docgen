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
    <!-- class key -->
    <xsl:value-of select="ext:let('p-class-key', ext:caller('p-class-key')) " />
    <!-- class node -->
    <xsl:value-of select="ext:let('class', ext:caller('class')) " />
@class
    <!-- write the class header -->
    @name=<xsl:value-of select="ext:get('p-class-name')" />
    @key=<xsl:value-of select="ext:get('p-class-key')" />
    @brief=
    @type=<xsl:choose><xsl:when test="ext:get('class')/@interface='true'">interface</xsl:when><xsl:when test="ext:get('class')/@superclass='Enum'">enum</xsl:when><xsl:otherwise>class</xsl:otherwise></xsl:choose>
    @ingroup=<xsl:value-of select="ext:get('p-package')" />

    <!-- write the class parents and implements -->
    <xsl:value-of select="ext:let('superclass', ext:get('g-data')/xs:jel/xs:jelclass[./@fulltype = ext:get('class')/@superclassfulltype])"/>
<xsl:if test="ext:get('superclass')/@fulltype != 'java.lang.Object'">
    <xsl:if test="ext:get('superclass')/@visibility = 'public'">
    <xsl:value-of select="ext:let('type', ext:get('superclass'))" />
    @parent=<xsl:value-of select="normalize-space(ext:call('process-type.xsl', /)) "/>
    </xsl:if>
</xsl:if>

<xsl:for-each select="ext:get('class')/xs:implements/xs:interface">
    <xsl:value-of select="ext:let('type', .)" />
    @parent=<xsl:value-of select="normalize-space(ext:call('process-type.xsl', /)) "/>
</xsl:for-each>

    <!-- process members (only declared, do not process inherited -->
<xsl:for-each select="ext:get('class')/xs:methods/* | ext:get('class')/xs:fields/*">
     <xsl:value-of select="ext:let('member',.)"/>
     <xsl:value-of select="ext:call('process-member.xsl', /) "/>
</xsl:for-each>

    <!-- write the class footer -->
    The namespace is [clink=<xsl:value-of select="ext:get('class')/@package" />]<xsl:value-of select="ext:get('class')/@package" />[/clink].
@end
    </xsl:template>
</xsl:stylesheet>

