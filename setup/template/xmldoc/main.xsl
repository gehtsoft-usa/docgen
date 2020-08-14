<?xml version="1.0" encoding="windows-1252"?>
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="xml" indent="yes"  />
    <!-- eliminate ext declaration -->
    <xsl:namespace-alias stylesheet-prefix="ext" result-prefix="#default"/>
    <xsl:template match="/" >
<doc>
    <assembly>
        <name><xsl:value-of select="ext:get('assembly')" /></name>
    </assembly>
    <members>
        <xsl:for-each select="./root/class">
            <xsl:if test="(not(ext:exist('namespace'))) or (ext:match(ext:get('namespace'), ./@sig))">
            <member>
                <xsl:attribute name="name"><xsl:value-of select="./@sig" /></xsl:attribute>
                <summary><xsl:value-of select="ext:removehtml(./@brief)" /></summary>
            </member>
            <xsl:for-each select="./member">
                    <xsl:if test="count(./sig) > 0" >
                        <xsl:for-each select="./sig">
            <member>
                            <xsl:attribute name="name"><xsl:value-of select="./text()" /></xsl:attribute>
                <summary><xsl:value-of select="ext:removehtml(../@brief)" /></summary>
                <xsl:for-each select="../param">
                <param>
                    <xsl:attribute name="name"><xsl:value-of select="./@name" /></xsl:attribute>
                    <xsl:if test="count(./body/p) > 0">
                        <xsl:value-of select="ext:removehtml(./body/p[position()=1]/text())" />
                    </xsl:if>
                </param>
                </xsl:for-each>
            </member>
                        </xsl:for-each>
                    </xsl:if>
            </xsl:for-each>
            </xsl:if>
        </xsl:for-each>
    </members>
</doc>
    </xsl:template>
</xsl:stylesheet>

