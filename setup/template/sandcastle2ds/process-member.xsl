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
    <!-- member signature -->
    <xsl:value-of select="ext:let('p-member-id', ext:caller('p-member-id')) " />



    <!-- select member -->
    <xsl:value-of select="ext:let('member', ext:get('g-data')/reflection/apis/api[./@id=ext:get('p-member-id')][1])" />
    <xsl:choose>
        <xsl:when test="ext:exist('g-old-data')">
            <xsl:value-of select="ext:let('curr-sig', ext:get('member')/@id)" />
            <xsl:choose>
                <xsl:when test="count(ext:get('g-old-data')/reflection/apis/api[./@id=ext:get('curr-sig')]) > 0">
                    <xsl:value-of select="ext:let('process', '0')" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="ext:let('process', '1')" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="ext:let('process', '1')" />
        </xsl:otherwise>
    </xsl:choose>

    <xsl:if test="ext:get('process') = '1'">
    <xsl:if test="contains(ext:get('visibility'), ext:get('member')/memberdata/@visibility) and (ext:get('member')/containers/type/@api=ext:get('p-class-id'))">
    <xsl:value-of select="ext:let('name', ext:get('member')/apidata/@name)" />
    <xsl:choose>
        <xsl:when test="ext:get('name')='.ctor'">
            <xsl:value-of select="ext:let('name', ext:get('p-class-name'))" />
            <xsl:if test="contains(ext:get('name'), '&amp;') " >
                <xsl:value-of select="ext:let('name', substring-before(ext:get('name'), '&amp;'))" />
            </xsl:if>
        </xsl:when>
        <xsl:otherwise><xsl:value-of select="ext:let('name', ext:get('member')/apidata/@name)" /></xsl:otherwise>
    </xsl:choose>
    <xsl:choose>
        <xsl:when test="ext:exist('exclude-doc')">
            <xsl:choose>
                <xsl:when test="count(ext:get('exclude-doc')/root/class/member/sig[text()=ext:get('member')/@id]) > 0">
                    <xsl:value-of select="ext:let('process', 0)" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="ext:let('process', 1)" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="ext:let('process', 1)" />
        </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="ext:get('process') != 0">
    @member
        @name=<xsl:value-of select="ext:get('name')" />
        @sig=<xsl:value-of select="ext:get('member')/@id" />
        @key=<xsl:value-of select="normalize-space(ext:call('get-member-key.xsl', ext:get('member'))) " />
        @divisor=.
        @brief=
        @scope=<xsl:choose><xsl:when test="ext:get('member')/memberdata/@static='true'">class</xsl:when><xsl:when test="ext:get('member')/memberdata/@static='false' or count(ext:get('member')/memberdata/@static)=0">instance</xsl:when></xsl:choose>
        <xsl:if test="count(ext:get('member')/templates/template)>0">
            <xsl:value-of select="ext:let('name', concat(ext:get('name'), '&lt;'))" />
            <xsl:value-of select="ext:let('i', 0)" />
            <xsl:for-each select="ext:get('member')/templates/template">
                <xsl:if test="ext:get('i')!=0">
                    <xsl:value-of select="ext:let('name', concat(ext:get('name'), ','))" />
                </xsl:if>
                <xsl:value-of select="ext:let('i', ext:get('i') + 1)" />
                <xsl:value-of select="ext:let('name', concat(ext:get('name'), ./@name))" />
            </xsl:for-each>
            <xsl:value-of select="ext:let('name', concat(ext:get('name'), '&gt;'))" />
        </xsl:if>
        <xsl:choose>
            <xsl:when test="ext:get('member')/memberdata/@visibility = 'public'">
        @visibility=public
            </xsl:when>
            <xsl:when test="ext:get('member')/memberdata/@visibility = 'family'">
        @visibility=protected
            </xsl:when>
        </xsl:choose>
        <xsl:choose>
            <xsl:when test="ext:get('member')/apidata/@subgroup='constructor'" >
        @type=constructor
            <xsl:value-of select="ext:let('return', 'no') " />
            <xsl:value-of select="ext:let('suffix', '') " />
            <xsl:value-of select="ext:call('decl-cs.xsl', ext:get('member'))" />
            </xsl:when>
            <xsl:when test="ext:get('member')/apidata/@subgroup='property'" >
        @type=property
            <xsl:if test="ext:get('member')/apidata/@subgroup='property' and ext:get('member')/memberdata/@default='true'">
                <xsl:value-of select="ext:let('name', 'this') " />
            </xsl:if>
            <xsl:value-of select="ext:let('return', 'yes') " />
            <xsl:value-of select="ext:let('suffix', '') " />
            <xsl:if test="count(ext:get('member')/getter)>0">
                <xsl:value-of select="ext:let('suffix', concat(ext:get('suffix'), ' get;')) " />
            </xsl:if>
            <xsl:if test="count(ext:get('member')/setter)>0">
                <xsl:value-of select="ext:let('suffix', concat(ext:get('suffix'), ' set;')) " />
            </xsl:if>
            <xsl:value-of select="ext:call('decl-cs.xsl', ext:get('member'))" />
            </xsl:when>
            <xsl:when test="ext:get('member')/apidata/@subgroup='field'" >
            <xsl:value-of select="ext:let('return', 'yes') " />
            <xsl:value-of select="ext:let('suffix', '') " />
        @type=field
            <xsl:value-of select="ext:call('decl-cs.xsl', ext:get('member'))" />
            </xsl:when>
            <xsl:when test="ext:get('member')/apidata/@subgroup='method'" >
        @type=method
            <xsl:value-of select="ext:let('return', 'yes') " />
            <xsl:value-of select="ext:let('suffix', '') " />
            <xsl:value-of select="ext:call('decl-cs.xsl', ext:get('member'))" />
            </xsl:when>
        </xsl:choose>

        <xsl:for-each select="ext:get('member')/parameters/parameter" >
        @param
            @name=<xsl:value-of select="./@name" />

        @end
        </xsl:for-each>
    @end
    </xsl:if>
    </xsl:if>
    </xsl:if>
    </xsl:template>
</xsl:stylesheet>

