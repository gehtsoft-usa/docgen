<?xml version="1.0" encoding="windows-1252"?>
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" />
    <xsl:template match="/" >

    <xsl:value-of select="ext:let('type', ext:caller('p-type'))" />

@class
    @name=<xsl:value-of select="ext:get('type')/@name" /><xsl:if test="count(ext:get('type')/parameters/type) > 0">&lt;<xsl:for-each select="ext:get('type')/parameters/type"><xsl:if test="position() > 1">, </xsl:if><xsl:value-of select="./@name"/></xsl:for-each>&gt;</xsl:if>
    @key=<xsl:value-of select="ext:get('type')/@namespace" />.<xsl:value-of select="ext:get('type')/@name" />
    @ingroup=<xsl:value-of select="ext:get('type')/@namespace" />
    @sig=<xsl:value-of select="ext:get('type')/@signature" />
    <xsl:choose>
        <xsl:when test="ext:get('type')/@type='enum'">
    @type=enum
        </xsl:when>
        <xsl:when test="ext:get('type')/@type='interface'">
    @type=interface
        </xsl:when>
        <xsl:when test="ext:get('type')/@type='value' and (count(ext:get('type')/@readonly) = 0 or ext:get('type')/@readonly!='readonly')">
    @type=struct
        </xsl:when>
        <xsl:when test="ext:get('type')/@type='value' and (ext:get('type')/@readonly ='readonly')">
    @type=readonly struct
        </xsl:when>
        <xsl:when test="ext:get('type')/@type='class'">
    @type=class
        </xsl:when>
    </xsl:choose>
    <xsl:for-each select="ext:get('type')/parents/type">
        <xsl:value-of select="ext:let('p-type', .) "/>
    @parent=<xsl:value-of select="normalize-space(ext:call('process-type-reference.xsl', /))" />
    </xsl:for-each>
    <xsl:value-of select="ext:let('p-target', ext:get('type'))" />
    <xsl:value-of select="ext:let('p-mode', 'summary-class')" />
    <xsl:value-of select="ext:call('xmldoc.xsl', /)" />
    <xsl:value-of select="ext:let('p-mode', 'type-params')" />
    <xsl:value-of select="ext:call('xmldoc.xsl', /)" />

    <xsl:for-each select="ext:get('type')/members/member" >
        <xsl:if test="./@member-type='event' or ./@member-visibility='public' or ./getter/@member-visibility='public' or ./setter/@member-visibility='public' or count(ext:get('g-settings')/settings/include) = 0 or ext:get('g-settings')/settings/include/@type = 'all'">
    @member
        <xsl:choose>
        <xsl:when test="./@member-type='event'">
        @type=field
        @custom=event

        </xsl:when>
        <xsl:otherwise>
        @type=<xsl:value-of select="./@member-type" />
        </xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
        <xsl:when test="./@member-type='constructor'">
        @name=<xsl:value-of select="../../@name" />
        </xsl:when>
        <xsl:otherwise>
        @name=<xsl:value-of select="./@name" />
        </xsl:otherwise>
        </xsl:choose>
        @key=<xsl:value-of select="./@name" />.<xsl:value-of select="./@crc" />
        @divisor=.
        @sig=<xsl:value-of select="./@signature" />
        <xsl:choose>
        <xsl:when test="./@member-type='property'">
        <xsl:choose>
            <xsl:when test="./getter/@member-visibility='public' or ./setter/@member-visibility='public'">
        @visibility=public
            </xsl:when>
            <xsl:otherwise>
        @visibility=protected
            </xsl:otherwise>
        </xsl:choose>
        </xsl:when>
        <xsl:when test="./@member-type='event'">
        @visibility=public
        </xsl:when>
        <xsl:otherwise>
        @visibility=<xsl:value-of select="./@member-visibility" />
        </xsl:otherwise>
        </xsl:choose>
        @scope=<xsl:value-of select="./@member-scope" />

       <xsl:value-of select="ext:let('p-target', .)" />
       <xsl:value-of select="ext:let('p-mode', 'summary-member')" />
       <xsl:value-of select="ext:call('xmldoc.xsl', /)" />

        <xsl:choose>
            <xsl:when test="./@member-type='field'">
            @declaration
                @language=cs
                @name=<xsl:value-of select="./@name" />
                <xsl:value-of select="ext:let('p-type', ./type) "/>
                @return=<xsl:value-of select="normalize-space(ext:call('process-type-reference.xsl', /))" />
                <xsl:if test="count(./@value) > 0">
                @suffix=<xsl:value-of select="concat(' = ', ./@value)" />
                </xsl:if>
                <xsl:if test="count(./@readonly) > 0 and ./@readonly='readonly'">
                @prefix=readonly
                </xsl:if>
            @end
            </xsl:when>
            <xsl:when test="./@member-type='property'">
            @declaration
                @language=cs
                <xsl:value-of select="ext:let('p-type', ./type) "/>
                @return=<xsl:value-of select="normalize-space(ext:call('process-type-reference.xsl', /))" />
                <xsl:choose>
                <xsl:when test="./@name='Item'">
                @name=this
                    <xsl:value-of select="ext:let('p-method', ./getter)" />
                @suffix=[<xsl:value-of select="ext:trim(ext:call('process-params.xsl', /))"/>] <xsl:if test="count(./getter) > 0"> <xsl:value-of select="./getter/@member-visibility"/> get; </xsl:if><xsl:if test="count(./setter) > 0"> <xsl:value-of select="./setter/@member-visibility"/> set;</xsl:if>
                </xsl:when>
                <xsl:otherwise>
                @name=<xsl:value-of select="./@name" />
                @suffix= <xsl:if test="count(./getter) > 0"><xsl:value-of select="./getter/@member-visibility"/> get; </xsl:if> <xsl:if test="count(./setter) > 0"><xsl:value-of select="./setter/@member-visibility"/> set;</xsl:if>
                </xsl:otherwise>
                </xsl:choose>
            @end
            </xsl:when>

            <xsl:when test="./@member-type='constructor'">
            @declaration
                @language=cs
                @name=<xsl:value-of select="../../@name" />
                <xsl:value-of select="ext:let('p-type', ./type) "/>
                @return=
                <xsl:value-of select="ext:let('p-method', .)" />
                @params=<xsl:value-of select="ext:trim(ext:call('process-params.xsl', /))"/>
            @end
            </xsl:when>

            <xsl:when test="./@member-type='method'">
            @declaration
                @language=cs
                @name=<xsl:value-of select="./@name" /><xsl:if test="count(./generic-parameters/type) > 0">&lt;<xsl:for-each select="./generic-parameters/type"><xsl:if test="position() > 1">, </xsl:if><xsl:value-of select="./@name"/></xsl:for-each>&gt;</xsl:if>
                <xsl:value-of select="ext:let('p-type', ./type) "/>
                @return=<xsl:value-of select="normalize-space(ext:call('process-type-reference.xsl', /))" />
                <xsl:value-of select="ext:let('p-method', .)" />
                @params=<xsl:value-of select="ext:trim(ext:call('process-params.xsl', /))"/>
            @end
            </xsl:when>

            <xsl:when test="./@member-type='event'">
            @declaration
                @language=cs
                @name=<xsl:value-of select="./@name" />
                <xsl:value-of select="ext:let('p-type', ./type) "/>
                @return=<xsl:value-of select="normalize-space(ext:call('process-type-reference.xsl', /))" />
                @prefix=event
            @end
            </xsl:when>
        </xsl:choose>

        <xsl:choose>
            <xsl:when test="./@member-type='method' or ./@member-type='constructor'">
               <xsl:value-of select="ext:let('p-mode', 'method-params')" />
                <xsl:value-of select="ext:call('xmldoc.xsl', /)" />
            </xsl:when>
            <xsl:when test="./@member-type='property' and count(./getter/parameters) > 0">
                <xsl:value-of select="ext:let('p-target', ./getter)" />
               <xsl:value-of select="ext:let('p-mode', 'method-params')" />
                <xsl:value-of select="ext:call('xmldoc.xsl', /)" />
            </xsl:when>
       </xsl:choose>
    @end
    </xsl:if>
    </xsl:for-each>
@end
    </xsl:template>
</xsl:stylesheet>

