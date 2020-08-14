<?xml version="1.0" encoding="windows-1252"?>
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" />
    <!-- eliminate ext declaration -->
    <xsl:namespace-alias stylesheet-prefix="ext" result-prefix="#default"/>
    <xsl:template match="/" >
    <!-- namespace name -->
    <xsl:value-of select="ext:let('p-ns', ext:caller('p-ns')) " />
    <!-- namespace signature -->
    <xsl:value-of select="ext:let('p-ns-id', ext:caller('p-ns-id')) " />
    <!-- class signature -->
    <xsl:value-of select="ext:let('p-class-id', ext:caller('p-class-id')) " />
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
    @type=<xsl:choose><xsl:when test="ext:get('class')/apidata[1]/@subgroup='class'">class</xsl:when><xsl:when test="ext:get('class')/apidata[1]/@subgroup='enumeration'">enum</xsl:when><xsl:when test="ext:get('class')/apidata[1]/@subgroup='interface'">interface</xsl:when></xsl:choose>
    @ingroup=<xsl:value-of select="ext:get('p-ns')" />
    @sig=<xsl:value-of select="ext:get('p-class-id')" />

    <!-- write the class parents and implements -->
<xsl:for-each select="ext:get('class')/family/ancestors/type[./@api!='T:System.Object']">
    <xsl:value-of select="ext:let('type', .)" />
    @parent=<xsl:value-of select="normalize-space(ext:call('process-type.xsl', /)) "/>
</xsl:for-each>
<xsl:for-each select="ext:get('class')/implements/type">
    <xsl:value-of select="ext:let('type', .)" />
    @parent=<xsl:value-of select="normalize-space(ext:call('process-type.xsl', /)) "/>
</xsl:for-each>

    <!-- write template parameters -->
<xsl:for-each select="ext:get('class')/templates/template">
    @param
        @name=<xsl:value-of select="./@name" />

    @end
</xsl:for-each>

    <!-- process members (only declared, do not process inherited) -->
    <xsl:for-each select="ext:get('class')/elements/element">
        <xsl:if test="count(./apidata)=0">
            <xsl:value-of select="ext:let('p-member-id', ./@api)" />
            <xsl:value-of select="ext:call('process-member.xsl', /) "/>
        </xsl:if>
    </xsl:for-each>

    <!-- write the class footer -->
    The type defined in the [c]<xsl:value-of select="ext:get('class')/containers/library/@module" />.dll[/c] assembly.
    The namespace is [clink=<xsl:value-of select="substring(ext:get('class')/containers/namespace/@api, 3)" />]<xsl:value-of select="substring(ext:get('class')/containers/namespace/@api, 3)" />[/clink].
@end
    </xsl:template>
</xsl:stylesheet>

