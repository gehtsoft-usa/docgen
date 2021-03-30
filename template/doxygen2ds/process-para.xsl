<?xml version="1.0" encoding="windows-1252"?>
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" />
    <!-- eliminate ext declaration -->
    <xsl:namespace-alias stylesheet-prefix="ext" result-prefix="#default"/>
    <xsl:template match="para" >
        <xsl:apply-templates />
    </xsl:template>
    <xsl:template match="bold" >[b]<xsl:apply-templates />[/b]</xsl:template>
    <xsl:template match="computeroutput" >[c]<xsl:apply-templates />[/c]</xsl:template>
    <xsl:template match="strike" >[s]<xsl:apply-templates />[/s]</xsl:template>
    <xsl:template match="sp" ><xsl:text xml:space="preserve"> </xsl:text></xsl:template>
    <xsl:template match="highlight" ><xsl:apply-templates /></xsl:template>
    <xsl:template match="codeline" ><xsl:apply-templates /><xsl:text>&#013;&#010;</xsl:text></xsl:template>
    <xsl:template match="programlisting" >
        @example
            @show=always
            <xsl:if test="count(./@filename) > 0 and string-length(./@filename) > 1">@highlight=<xsl:value-of select="substring(./@filename, 2)" /><xsl:text>&#013;&#010;</xsl:text></xsl:if>
            <xsl:apply-templates />
        @end
    </xsl:template>
    <xsl:template match="itemizedlist">
        @list
            <xsl:apply-templates />
        @end
    </xsl:template>
    <xsl:template match="listitem">
          @list-item
                <xsl:apply-templates />
          @end
    </xsl:template>
    <xsl:template match="table">
        @table
            <xsl:apply-templates />
        @end
    </xsl:template>
    <xsl:template match="row">
        @row
            <xsl:if test="count(./entry[@thead='yes'])>0">      @header=yes<xsl:text>&#013;&#010;</xsl:text></xsl:if>
            <xsl:apply-templates />
        @end
    </xsl:template>
    <xsl:template match="entry">
            @col
                <xsl:apply-templates />
            @end
    </xsl:template>
    <xsl:template match="image">[img=<xsl:value-of select="./@name"/>]</xsl:template>
    <xsl:template match="ulink">[eurl=<xsl:value-of select="./@url"/>]<xsl:apply-templates />[/eurl]</xsl:template>
    <xsl:template match="ref" >
        <xsl:value-of select="ext:remove('link-key')" />
        <xsl:if test="ext:match('class.+', ./@refid)">
            <xsl:value-of select="ext:let('file', concat(ext:get('xml-path'), ./@refid, '.xml'))" />
            <xsl:if test="ext:fileexists(ext:get('file'))">
                <xsl:value-of select="ext:let('reference', ext:document(ext:get('file')))" />
                <xsl:value-of select="ext:let('link-key', ext:replace(ext:get('reference')/doxygen/compounddef/compoundname/text(), '::', '.')) "/>
            </xsl:if>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="ext:exist('link-key')">[link=<xsl:value-of select="ext:get('link-key')" />]<xsl:apply-templates />[/link]</xsl:when>
            <xsl:otherwise>
        <xsl:apply-templates />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="text()" >
        <xsl:value-of select="." />
    </xsl:template>
</xsl:stylesheet>