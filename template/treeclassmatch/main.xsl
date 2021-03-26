<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="xml" indent="yes" encoding="utf-8"  />
    <xsl:template match="/" >
     <xsl:element name="comparison">
        <xsl:variable name="model1" select="ext:document(ext:get('model1'))" />
        <xsl:variable name="model2" select="ext:document(ext:get('model2'))" />
        <xsl:call-template name="matchClasses">
            <xsl:with-param name="run" select="'first'" />
            <xsl:with-param name="first" select="$model1" />
            <xsl:with-param name="first-name" select="'model1'" />
            <xsl:with-param name="second" select="$model2" />
            <xsl:with-param name="second-name" select="'model2'" />
        </xsl:call-template>
        <xsl:call-template name="matchClasses">
            <xsl:with-param name="run" select="'second'" />
            <xsl:with-param name="first" select="$model2" />
            <xsl:with-param name="first-name" select="'model2'" />
            <xsl:with-param name="second" select="$model1" />
            <xsl:with-param name="second-name" select="'model1'" />
        </xsl:call-template>
      </xsl:element>
    </xsl:template>
    <xsl:template name="matchClasses">
        <xsl:param name="run" />
        <xsl:param name="first" />
        <xsl:param name="first-name" />
        <xsl:param name="second" />
        <xsl:param name="second-name" />
        <xsl:for-each select="$first/root/class" >
            <xsl:variable name="first-class" select="." />
            <xsl:variable name="second-class" select="$second/root/class[@key=$first-class/@key]" />
            <xsl:choose>
                <xsl:when test="count($second-class) = 0">
<xsl:element name="class-not-exist">
    <xsl:attribute name="class"><xsl:value-of select="$first-class/@key" /></xsl:attribute>
    <xsl:attribute name="exist-in"><xsl:value-of select="$first-name" /></xsl:attribute>
    <xsl:attribute name="not-exist-in"><xsl:value-of select="$second-name" /></xsl:attribute>
</xsl:element>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="matchMethods">
                        <xsl:with-param name="run" select="$run" />
                        <xsl:with-param name="first-class" select="$first-class" />
                        <xsl:with-param name="first-name" select="$first-name" />
                        <xsl:with-param name="second-class" select="$second-class[1]" />
                        <xsl:with-param name="second-name" select="$second-name" />
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    <xsl:template name="matchMethods">
        <xsl:param name="run" />
        <xsl:param name="first-class" />
        <xsl:param name="first-name" />
        <xsl:param name="second-class" />
        <xsl:param name="second-name" />
        <xsl:for-each select="$first-class/member">
            <xsl:variable name="first-member" select="." />
            <xsl:choose>
                <xsl:when test="ext:get('member-find-mode', 'key') = 'key'">
                    <xsl:value-of select="ext:let('second-member', $second-class/member[@key=$first-member/@key])" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="ext:let('second-member', $second-class/member[@name=$first-member/@name])" />
                </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="count(ext:get('second-member')) = 0">
<xsl:element name="member-not-exist">
    <xsl:attribute name="member"><xsl:value-of select="$first-class/@key" />.<xsl:value-of select="$first-member/@key" /></xsl:attribute>
    <xsl:attribute name="exist-in"><xsl:value-of select="$first-name" /></xsl:attribute>
    <xsl:attribute name="not-exist-in"><xsl:value-of select="$second-name" /></xsl:attribute>
</xsl:element>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="$run = 'first' and ext:get('compare-parameters', 'no') = 'yes' and $first-member/declaration/@params != ext:get('second-member')/declaration/@params">
<xsl:element name="params-not-match">
    <xsl:attribute name="member"><xsl:value-of select="$first-class/@key" />.<xsl:value-of select="$first-member/@key" /></xsl:attribute>
    <xsl:element name="params">
        <xsl:attribute name="location"><xsl:value-of select="$first-name" /></xsl:attribute>
        <xsl:attribute name="params"><xsl:value-of select="$first-member/declaration/@params" /></xsl:attribute>
    </xsl:element>
    <xsl:element name="params">
        <xsl:attribute name="location"><xsl:value-of select="$second-name" /></xsl:attribute>
        <xsl:attribute name="params"><xsl:value-of select="ext:get('second-member')/declaration/@params" /></xsl:attribute>
    </xsl:element>
</xsl:element>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
