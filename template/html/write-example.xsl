<?xml version="1.0" encoding="windows-1252"?>
<!-- writes body description

     @param ext:caller('curr-item') - a object which has description to write
   -->
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" />
    <xsl:namespace-alias stylesheet-prefix="ext" result-prefix="#default"/>
    <xsl:template match="/" >
        <xsl:apply-templates select="ext:caller('curr-item')" />
    </xsl:template>
    <xsl:template match="example" >
        <xsl:value-of select="ext:let('transform', ext:get('default-transform', 'no'))" />
        <xsl:for-each select="ancestor-or-self::*">
            <xsl:if test="count(./@transform) > 0 and ./@transform!='def'">
                <xsl:value-of select="ext:let('transform', ./@transform)" />
            </xsl:if>
        </xsl:for-each>
        <xsl:value-of select="ext:let('item', .)" />
        <xsl:value-of select="ext:letglobal('g-example-serial', ext:get('g-example-serial') + 1)" />
        <xsl:choose>
            <xsl:when test="count(./@show)>0 and @show='always'">
                <xsl:if test="count(./@title)>0 and string-length(./@title) > 0">
                    <p><xsl:value-of select="ext:call('write-bbcode.xsl', ext:parsebbcode(./@title))" disable-output-escaping="yes"  /></p>
                </xsl:if>
                <xsl:call-template name="write-example-content" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                   <xsl:when test="count(./@show)=0 or @show='no'">
                       <xsl:value-of select="ext:let('style1', 'display:inline')" />
                       <xsl:value-of select="ext:let('style2', 'display:none')" />
                   </xsl:when>
                   <xsl:otherwise>
                       <xsl:value-of select="ext:let('style1', 'display:none')" />
                       <xsl:value-of select="ext:let('style2', 'display:inline')" />
                   </xsl:otherwise>
                </xsl:choose>
                <xsl:value-of select="ext:let('curr-item', .)" />
                <xsl:element name="div">
                    <xsl:attribute name="id">open<xsl:value-of select="ext:get('g-example-serial')" /></xsl:attribute>
                    <xsl:attribute name="style"><xsl:value-of select="ext:get('style1')" /></xsl:attribute>
                    <xsl:element name="p">
                        <xsl:choose>
                            <xsl:when test="ext:get('transform')='yes'">
                                <xsl:value-of select="ext:call('write-bbcode.xsl', ext:parsebbcode(./@title))" disable-output-escaping="yes"  />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="./@title" />
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:text disable-output-escaping="yes">&amp;nbsp;</xsl:text>
                        <xsl:element name="a">
                            <xsl:attribute name="href">javascript: showdiv('close<xsl:value-of select="ext:get('g-example-serial')" />'); hidediv('open<xsl:value-of select="ext:get('g-example-serial')" />');</xsl:attribute>
                            <xsl:attribute name="onclick">javascript: showdiv('close<xsl:value-of select="ext:get('g-example-serial')" />'); hidediv('open<xsl:value-of select="ext:get('g-example-serial')" />');</xsl:attribute>
                            <xsl:attribute name="class">action</xsl:attribute>
                            <xsl:text>Show</xsl:text>
                            <span class="side-icon dripicons-chevron-right"></span>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
                <xsl:element name="div">
                    <xsl:attribute name="id">close<xsl:value-of select="ext:get('g-example-serial')" /></xsl:attribute>
                    <xsl:attribute name="style"><xsl:value-of select="ext:get('style2')" /></xsl:attribute>
                    <xsl:element name="p">
                        <xsl:choose>
                            <xsl:when test="ext:get('transform')='yes'">
                                <xsl:value-of select="ext:call('write-bbcode.xsl', ext:parsebbcode(./@title))" disable-output-escaping="yes"  />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="./@title" />
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:text disable-output-escaping="yes">&amp;nbsp;</xsl:text>
                        <xsl:element name="a">
                            <xsl:attribute name="href">javascript: showdiv('open<xsl:value-of select="ext:get('g-example-serial')" />'); hidediv('close<xsl:value-of select="ext:get('g-example-serial')" />');</xsl:attribute>
                            <xsl:attribute name="onclick">javascript: showdiv('open<xsl:value-of select="ext:get('g-example-serial')" />'); hidediv('close<xsl:value-of select="ext:get('g-example-serial')" />');</xsl:attribute>
                            <xsl:attribute name="class">action</xsl:attribute>
                            <xsl:text>Hide</xsl:text>
                            <span class="side-icon dripicons-chevron-down"></span>
                        </xsl:element>
                    </xsl:element>
                    <xsl:call-template name="write-example-content" />
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="write-example-content">
        <xsl:value-of select="ext:let('gray', ext:get('item')/@gray)" />
        <xsl:choose>
            <xsl:when test="ext:get('item')/@tabs='true'">
                <xsl:value-of select="ext:let('link-text', '')" />
                <xsl:for-each select="ext:get('item')/example-tab" >
                    <xsl:value-of select="ext:let('link-text', concat(ext:get('link-text'), 'hidediv(&quot;tab', ext:get('g-example-serial'), '_', position(), '&quot;);'))" />
                </xsl:for-each>
                <xsl:for-each select="ext:get('item')/example-tab" >
                    <xsl:value-of select="ext:let('curr-position', position())" />
                    <xsl:choose>
                        <xsl:when test="position() = 1">
                            <xsl:value-of select="ext:let('bstyle', 'display:inline')" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="ext:let('bstyle', 'display:none')" />
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:element name="div">
                        <xsl:attribute name="id">tab<xsl:value-of select="ext:get('g-example-serial')" />_<xsl:value-of select="position()" /></xsl:attribute>
                        <xsl:attribute name="style"><xsl:value-of select="ext:get('bstyle')" /></xsl:attribute>
                        <xsl:value-of select="ext:let('body', .)"/>
                        <xsl:element name="pre">
                            <xsl:if test="ext:get('gray')='yes'">
                                <xsl:attribute name="class">example</xsl:attribute>
                                <xsl:attribute name="id">example<xsl:value-of select="ext:get('g-example-serial')" />_<xsl:value-of select="position()" /></xsl:attribute>
                            </xsl:if>
                            <xsl:for-each select="ext:get('item')/example-tab" >
                                <xsl:value-of select="ext:let('link-text-1', concat('javascript: ', ext:get('link-text'), 'showdiv(&quot;tab', ext:get('g-example-serial'), '_', position(), '&quot;);'))"/>
                                <xsl:element name="a">
                                    <xsl:attribute name="href"><xsl:value-of select="ext:get('link-text-1')" disable-output-escaping="yes" /></xsl:attribute>
                                    <xsl:attribute name="onclick"><xsl:value-of select="ext:get('link-text-1')"  disable-output-escaping="yes" /></xsl:attribute>
                                    <xsl:attribute name="class">actiontab</xsl:attribute>
                                    <xsl:choose>
                                        <xsl:when test="ext:get('curr-position') = position()">
                                          <xsl:choose>
                                              <xsl:when test="ext:get('transform')='yes'">
                                                  <b><xsl:value-of select="ext:call('write-bbcode.xsl', ext:parsebbcode(./@title))" disable-output-escaping="yes"  /></b>
                                              </xsl:when>
                                              <xsl:otherwise>
                                                  <b><xsl:value-of select="./@title" /></b>
                                              </xsl:otherwise>
                                          </xsl:choose>
                                        </xsl:when>
                                        <xsl:otherwise>
                                          <xsl:choose>
                                              <xsl:when test="ext:get('transform')='yes'">
                                                  <xsl:value-of select="ext:call('write-bbcode.xsl', ext:parsebbcode(./@title))" disable-output-escaping="yes"  />
                                              </xsl:when>
                                              <xsl:otherwise>
                                                  <xsl:value-of select="./@title" />
                                              </xsl:otherwise>
                                          </xsl:choose>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:element>
                            </xsl:for-each>
                        <xsl:call-template name="write-example-or-tab">
                            <xsl:with-param name="insideTag" select="'false'" />
                        </xsl:call-template>
                        </xsl:element>
                    </xsl:element>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="ext:let('body', .)"/>
                <xsl:call-template name="write-example-or-tab">
                    <xsl:with-param name="insideTag" select="'true'" />
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <xsl:template name="write-example-or-tab">
        <xsl:param name="insideTag" />
        <xsl:value-of select="ext:let('item-text', '')" />
        <xsl:for-each select="ext:get('body')/body/p">
            <xsl:choose>
                <xsl:when test="ext:get('transform')='yes'">
                    <xsl:value-of select="ext:let('text', ext:call('write-bbcode.xsl', ext:parsebbcode(./text())))" disable-output-escaping="yes" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="ext:let('text', ./text())" disable-output-escaping="yes" />
                </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="ext:let('item-text', concat(ext:get('item-text'), ext:get('text')))" />
        </xsl:for-each>
        <xsl:choose>
            <xsl:when test="$insideTag='false'">
                <hr />
                <xsl:element name="code">
                <xsl:if test="count(./@highlight) > 0">
                    <xsl:attribute name="class"><xsl:value-of select="./@highlight" /></xsl:attribute>
                </xsl:if>
                <xsl:value-of select="ext:get('item-text')" disable-output-escaping="yes" />
                </xsl:element>
                </xsl:when>
            <xsl:otherwise>
                <xsl:element name="pre">
                    <xsl:if test="ext:get('gray')='yes'">
                        <xsl:attribute name="class">example</xsl:attribute>
                    </xsl:if>
                    <xsl:attribute name="id">example<xsl:value-of select="ext:get('g-example-serial')" /></xsl:attribute>
                    <xsl:element name="code">
                    <xsl:if test="count(./@highlight) > 0">
                        <xsl:attribute name="class"><xsl:value-of select="./@highlight" /></xsl:attribute>
                    </xsl:if>
                    <xsl:value-of select="ext:get('item-text')" disable-output-escaping="yes" />
                    </xsl:element>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>

