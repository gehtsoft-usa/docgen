<?xml version="1.0" encoding="utf-8"?>
<!-- Writes body description content in Markdown format
     Param: ext:caller('curr-item') - an object which has description to write
-->
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" encoding="utf-8"/>

    <xsl:template match="/">
        <!-- Copy transform value from the caller -->
        <xsl:value-of select="ext:let('transform', ext:caller('transform'))" />
        <xsl:apply-templates select="ext:caller('curr-item')/body" />
    </xsl:template>

    <xsl:template match="body">
        <xsl:apply-templates select="*" />
    </xsl:template>

    <!-- Paragraph -->
    <xsl:template match="p">
            <xsl:choose>
                <xsl:when test="ext:get('transform')='yes'">
                    <xsl:value-of select="ext:call('bbcode-to-markdown.xsl', ext:parsebbcode(./text()))" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="." />
                </xsl:otherwise>
            </xsl:choose>
        <xsl:text>&#10;&#10;</xsl:text>
    </xsl:template>

    <!-- Header -->
    <xsl:template match="header">
        <xsl:text>&#10;</xsl:text>
        <xsl:choose>
            <xsl:when test="./@level='1'"><xsl:text># </xsl:text></xsl:when>
            <xsl:when test="./@level='2'"><xsl:text>## </xsl:text></xsl:when>
            <xsl:when test="./@level='3'"><xsl:text>### </xsl:text></xsl:when>
            <xsl:when test="./@level='4'"><xsl:text>#### </xsl:text></xsl:when>
            <xsl:when test="./@level='5'"><xsl:text>##### </xsl:text></xsl:when>
            <xsl:when test="./@level='6'"><xsl:text>###### </xsl:text></xsl:when>
            <xsl:otherwise><xsl:text>## </xsl:text></xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="body/p" mode="inline" />
        <xsl:text>&#10;&#10;</xsl:text>
    </xsl:template>

    <!-- Note -->
    <xsl:template match="note">
        <xsl:text>&#10;> **</xsl:text>
        <xsl:choose>
            <xsl:when test="./@type='note'"><xsl:text>Note</xsl:text></xsl:when>
            <xsl:when test="./@type='warning'"><xsl:text>Warning</xsl:text></xsl:when>
            <xsl:when test="./@type='important'"><xsl:text>Important</xsl:text></xsl:when>
            <xsl:otherwise><xsl:value-of select="./@type" /></xsl:otherwise>
        </xsl:choose>
        <xsl:text>**: </xsl:text>
        <xsl:for-each select="body/p">
            <xsl:if test="position() > 1">
                <xsl:text>&#10;> </xsl:text>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="ext:get('transform')='yes' and string-length(./text()) > 0">
                    <xsl:value-of select="ext:call('bbcode-to-markdown.xsl', ext:parsebbcode(./text()))" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="." />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
        <xsl:text>&#10;&#10;</xsl:text>
    </xsl:template>

    <!-- Example / Code block -->
    <xsl:template match="example | new-declaration">
        <xsl:text>&#10;</xsl:text>
        <xsl:if test="string-length(./@title) > 0">
            <xsl:text>**</xsl:text>
            <xsl:choose>
                <xsl:when test="ext:get('transform')='yes' and string-length(./@title) > 0">
                    <xsl:value-of select="ext:call('bbcode-to-markdown.xsl', ext:parsebbcode(./@title))" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="./@title" />
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text>**</xsl:text>
            <xsl:text>&#10;&#10;</xsl:text>
        </xsl:if>

        <!-- Handle tabs or single example -->
        <xsl:choose>
            <xsl:when test="./@tabs='true'">
                <xsl:for-each select="./example-tab">
                    <xsl:if test="string-length(./@title) > 0">
                        <xsl:text>**</xsl:text>
                        <xsl:value-of select="./@title" />
                        <xsl:text>**</xsl:text>
                        <xsl:text>&#10;&#10;</xsl:text>
                    </xsl:if>
                    <xsl:call-template name="write-code-block">
                        <xsl:with-param name="highlight" select="../@highlight" />
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="write-code-block">
                    <xsl:with-param name="highlight" select="./@highlight" />
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Code block helper -->
    <xsl:template name="write-code-block">
        <xsl:param name="highlight" />
        <xsl:text>```</xsl:text>
        <xsl:if test="string-length($highlight) > 0">
            <xsl:value-of select="$highlight" />
        </xsl:if>
        <xsl:text>&#10;</xsl:text>
        <xsl:for-each select="./body/p">
            <xsl:choose>
                <xsl:when test="ext:get('transform')='yes' and string-length(./text()) > 0">
                    <xsl:value-of select="ext:call('bbcode-to-plaintext.xsl', ext:parsebbcode(./text()))" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="." />
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="position() != last()">
                <xsl:text>&#10;</xsl:text>
            </xsl:if>
        </xsl:for-each>
        <xsl:text>&#10;```&#10;&#10;</xsl:text>
    </xsl:template>

    <!-- List -->
    <xsl:template match="list">
        <xsl:text>&#10;</xsl:text>
        <xsl:apply-templates select="list-item">
            <xsl:with-param name="list-type" select="./@type" />
            <xsl:with-param name="depth" select="0" />
        </xsl:apply-templates>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>

    <!-- List item -->
    <xsl:template match="list-item">
        <xsl:param name="list-type" />
        <xsl:param name="depth" />

        <!-- Indent -->
        <xsl:call-template name="repeat">
            <xsl:with-param name="count" select="$depth * 2" />
            <xsl:with-param name="char" select="' '" />
        </xsl:call-template>

        <!-- Bullet or number -->
        <xsl:choose>
            <xsl:when test="$list-type='num'">
                <xsl:value-of select="position()" />
                <xsl:text>. </xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>- </xsl:text>
            </xsl:otherwise>
        </xsl:choose>

        <!-- Content -->
        <xsl:for-each select="body/p">
            <xsl:choose>
                <xsl:when test="ext:get('transform')='yes' and string-length(./text()) > 0">
                    <xsl:value-of select="ext:call('bbcode-to-markdown.xsl', ext:parsebbcode(./text()))" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="." />
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="position() != last()">
                <xsl:text> </xsl:text>
            </xsl:if>
        </xsl:for-each>
        <xsl:text>&#10;</xsl:text>

        <!-- Nested lists -->
        <xsl:apply-templates select="list/list-item">
            <xsl:with-param name="list-type" select="list/@type" />
            <xsl:with-param name="depth" select="$depth + 1" />
        </xsl:apply-templates>
    </xsl:template>

    <!-- Table -->
    <xsl:template match="table">
        <xsl:text>&#10;</xsl:text>
        <xsl:apply-templates select="table-row" />
        <xsl:text>&#10;</xsl:text>
    </xsl:template>

    <!-- Table row -->
    <xsl:template match="table-row">
        <xsl:text>| </xsl:text>
        <xsl:for-each select="table-col">
            <xsl:for-each select="body/p">
                <xsl:choose>
                    <xsl:when test="ext:get('transform')='yes' and string-length(./text()) > 0">
                        <xsl:value-of select="ext:call('bbcode-to-markdown.xsl', ext:parsebbcode(./text()))" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="." />
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:if test="position() != last()">
                    <xsl:text> </xsl:text>
                </xsl:if>
            </xsl:for-each>
            <xsl:text> | </xsl:text>
        </xsl:for-each>
        <xsl:text>&#10;</xsl:text>

        <!-- Header separator -->
        <xsl:if test="./@is-header='true'">
            <xsl:text>| </xsl:text>
            <xsl:for-each select="table-col">
                <xsl:text>--- | </xsl:text>
            </xsl:for-each>
            <xsl:text>&#10;</xsl:text>
        </xsl:if>
    </xsl:template>

    <!-- Inline paragraph (for headers) -->
    <xsl:template match="p" mode="inline">
        <xsl:choose>
            <xsl:when test="ext:get('transform')='yes' and string-length(./text()) > 0">
                <xsl:value-of select="ext:call('bbcode-to-markdown.xsl', ext:parsebbcode(./text()))" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="." />
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="position() != last()">
            <xsl:text> </xsl:text>
        </xsl:if>
    </xsl:template>

    <!-- Helper template to repeat a character -->
    <xsl:template name="repeat">
        <xsl:param name="count" />
        <xsl:param name="char" />
        <xsl:if test="$count > 0">
            <xsl:value-of select="$char" />
            <xsl:call-template name="repeat">
                <xsl:with-param name="count" select="$count - 1" />
                <xsl:with-param name="char" select="$char" />
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
