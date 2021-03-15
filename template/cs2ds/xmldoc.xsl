<?xml version="1.0" encoding="windows-1252"?>
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" />
    <xsl:template match="/" >
    <xsl:value-of select="ext:let('intag', '0')" />
    <xsl:value-of select="ext:let('target', ext:caller('p-target'))" />
    <xsl:value-of select="ext:let('mode', ext:caller('p-mode'))" />
    <xsl:value-of select="ext:let('sig', ext:get('target')/@signature)" />
    <xsl:if test="ext:exist('xmldoc') and count(ext:get('xmldoc')/doc/members/member[./@name=ext:get('sig')]) > 0">
        <xsl:value-of select="ext:let('doc', ext:get('xmldoc')/doc/members/member[./@name=ext:get('sig')])" />
    </xsl:if>

    <xsl:choose>
    <xsl:when test="ext:get('mode') = 'summary-class' or ext:get('mode') = 'summary-member'">
        <xsl:choose>
        <xsl:when test="ext:exist('doc')">
            <xsl:apply-templates select="ext:get('doc')/summary" />
        </xsl:when>
        <xsl:otherwise>
            <xsl:choose>
                <xsl:when test="ext:get('mode') = 'summary-class'">
    @brief=
                </xsl:when>
                <xsl:when test="ext:get('mode') = 'summary-member'">
        @brief=
                </xsl:when>
            </xsl:choose>
        </xsl:otherwise>
    </xsl:choose>
    </xsl:when>
    <xsl:when test="ext:get('mode') = 'type-params'">
        <xsl:for-each select="ext:get('target')/parameters/type">
        @param
            @name=<xsl:value-of select="./@name" /><xsl:text>&#13;&#10;</xsl:text>
            <xsl:value-of select="ext:let('name', ./@name)" />
            <xsl:if test="ext:exist('doc')">
            <xsl:apply-templates select="ext:get('doc')/typeparam[./@name=ext:get('name')]" />
            </xsl:if>
        @end
        </xsl:for-each>
    </xsl:when>
    <xsl:when test="ext:get('mode') = 'method-params'">
        <xsl:for-each select="ext:get('target')/generic-parameters/type">
            @param
                @name=<xsl:value-of select="./@name" /><xsl:text>&#13;&#10;</xsl:text>
                <xsl:value-of select="ext:let('name', ./@name)" />
                <xsl:if test="ext:exist('doc')">
                 <xsl:apply-templates select="ext:get('doc')/typeparam[./@name=ext:get('name')]" />
                </xsl:if>
            @end
        </xsl:for-each>
        <xsl:for-each select="ext:get('target')/parameters/parameter">
            @param
                @name=<xsl:value-of select="./@name" /><xsl:text>&#13;&#10;</xsl:text>
                <xsl:value-of select="ext:let('name', ./@name)" />
                <xsl:if test="ext:exist('doc')">
                    <xsl:apply-templates select="ext:get('doc')/param[./@name=ext:get('name')]" />
                </xsl:if>
            @end
        </xsl:for-each>
        <xsl:if test="ext:exist('doc') and count(ext:get('doc')/return) > 0">
            @return
                <xsl:apply-templates select="ext:get('doc')/return" />
            @end
        </xsl:if>
    </xsl:when>
    </xsl:choose>
    </xsl:template>
    <xsl:template match="summary">
        <xsl:value-of select="ext:let('briefdone', '0')" />
        <xsl:apply-templates />
    </xsl:template>
    <xsl:template match="para">
        <xsl:apply-templates />
        <xsl:text>&#13;&#10;&#13;&#10;</xsl:text>
        <xsl:value-of select="ext:let('briefdone', '1')" />
    </xsl:template>
    <xsl:template match="c">
       <xsl:value-of select="ext:let('intag', '1')" />
       [c]<xsl:apply-templates />[/c]
       <xsl:value-of select="ext:let('intag', '0')" />
    </xsl:template>
    <xsl:template match="code">
       <xsl:value-of select="ext:let('intag', '1')" />
       [c]<xsl:apply-templates />[/c]
       <xsl:value-of select="ext:let('intag', '0')" />
    </xsl:template>
    <xsl:template match="param">
        <xsl:apply-templates />
    </xsl:template>
    <xsl:template match="return">
        <xsl:apply-templates />
    </xsl:template>
    <xsl:template match="see">
       <xsl:value-of select="ext:let('intag', '1')" />
        <xsl:choose>
        <xsl:when test="count(./@cref) > 0">
          <xsl:value-of select="ext:let('sig1', ./@cref)" />
          <xsl:value-of select="ext:let('insertbb', '1')" />
          <xsl:choose>
              <xsl:when test="count(ext:get('g-data')/collection/assemblies/assembly/type[./@signature=ext:get('sig1')]) > 0">
                  <xsl:value-of select="ext:let('v', ext:get('g-data')/collection/assemblies/assembly/type[./@signature=ext:get('sig1')])" />
                  <xsl:value-of select="ext:let('refname', ext:get('v')/@name) "/>
                  <xsl:value-of select="ext:let('refkey', concat(ext:get('v')/@namespace, '.', ext:get('v')/@name)) "/>
              </xsl:when>
              <xsl:when test="count(ext:get('g-data')/collection/assemblies/assembly/type/members/member[./@signature=ext:get('sig1')]) > 0">
                  <xsl:value-of select="ext:let('v', ext:get('g-data')/collection/assemblies/assembly/type/members/member[./@signature=ext:get('sig1')])" />
                  <xsl:value-of select="ext:let('p', ext:get('g-data')/collection/assemblies/assembly/type[count(members/member[./@signature=ext:get('sig1')]) > 0])" />
                  <xsl:value-of select="ext:let('refname', concat(ext:get('p')/@name, '.', ext:get('v')/@name)) "/>
                  <xsl:value-of select="ext:let('refkey', concat(ext:get('p')/@namespace, '.', ext:get('p')/@name, '.', ext:get('v')/@name, '.', ext:get('v')/@crc)) "/>
              </xsl:when>
              <xsl:otherwise>
                  <xsl:message>cref <xsl:value-of select="ext:get('sig1')" /> is not found</xsl:message>
                  <xsl:apply-templates />
                  <xsl:value-of select="ext:let('insertbb', '0')" />
              </xsl:otherwise>
          </xsl:choose>
          <xsl:if test="ext:get('insertbb') = '1'">
          <xsl:choose>
              <xsl:when test="count(./*) > 0">[clink=<xsl:value-of select="ext:get('refkey')"/>]<xsl:apply-templates/>[/clink]</xsl:when>
              <xsl:otherwise>[clink=<xsl:value-of select="ext:get('refkey')"/>]<xsl:value-of select="ext:get('refname')" />[/clink]</xsl:otherwise>
          </xsl:choose>
          </xsl:if>
        </xsl:when>
        <xsl:when test="count(./@href) > 0">
          <xsl:value-of select="ext:let('link', ./@href)" />
          <xsl:choose>
           <xsl:when test="count(./*) > 0 or string-length(./text()) > 0">[eurl=<xsl:value-of select="ext:get('link')"/>]<xsl:apply-templates/>[/eurl]</xsl:when>
           <xsl:otherwise>[eurl=<xsl:value-of select="ext:get('link')"/>]link[/eurl]</xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        </xsl:choose>
        <xsl:value-of select="ext:let('intag', '0')" />
    </xsl:template>
    <xsl:template match="text()">
        <xsl:choose>
            <xsl:when test="ext:get('intag') = '1'"><xsl:value-of select="." /></xsl:when>
            <xsl:when test="ext:get('mode') = 'summary-class' and ext:get('briefdone') != '1'">
    @brief=<xsl:value-of select="ext:ltrim(.)" /><xsl:text xml:space="preserve">&#13;&#10;</xsl:text>
                <xsl:value-of select="ext:let('briefdone', '1')" />
            </xsl:when>
            <xsl:when test="ext:get('mode') = 'summary-member' and ext:get('briefdone') != '1'">
        @brief=<xsl:value-of select="ext:ltrim(.)" /><xsl:text xml:space="preserve">&#13;&#10;</xsl:text>
                <xsl:value-of select="ext:let('briefdone', '1')" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:text xml:space="preserve">            </xsl:text><xsl:value-of select="." />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
