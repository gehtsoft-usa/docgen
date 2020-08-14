<?xml version="1.0" encoding="windows-1252"?>
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" encoding="Windows-1252"/>
    <xsl:template match="/" >
#pragma once
        <xsl:for-each select="/root/class">
<xsl:value-of select="ext:let('docstring', '')" />
<xsl:if test="count(./@brief) > 0 and string-length(./@brief) > 0">
    <xsl:value-of select="ext:let('docstring', concat(ext:get('docstring'), '\n', ext:call('strip-bbcode.xsl', ext:parsebbcode(./@brief))))"/>
</xsl:if>
#define DOCSTRING_CLASS_<xsl:value-of select="ext:upper(./@name)" /> "<xsl:value-of select="ext:get('docstring')" />"
        <xsl:for-each select="./member" >
            <xsl:value-of select="ext:let('defname', concat('DOCSTRIGN_', ext:upper(../@name), '_', ext:upper(./@name)))" />
            <xsl:choose>
                <xsl:when test="./@type='method'">
                    <xsl:value-of select="ext:let('docstring', '')" />
                    <xsl:for-each select="./declaration[./@language='python']">
                        <xsl:value-of select="ext:let('prefix', ./@prefix)" />
                        <xsl:if test="string-length(ext:get('prefix')) > 0" ><xsl:value-of select="ext:let('prefix', concat(ext:get('prefix'), ' '))" /></xsl:if>
                        <xsl:value-of select="ext:let('return', ./@return)" />
                        <xsl:value-of select="ext:let('name', ./@name)" />
                        <xsl:value-of select="ext:let('name-suffix', ./@name-suffix)" />
                        <xsl:value-of select="ext:let('params', ./@params)" />
                        <xsl:value-of select="ext:let('suffix', ./@suffix)" />
                        <xsl:value-of select="ext:let('prefix', ext:call('strip-bbcode.xsl', ext:parsebbcode(ext:get('prefix')))) "/>
                        <xsl:value-of select="ext:let('return', ext:call('strip-bbcode.xsl', ext:parsebbcode(ext:get('return')))) "/>
                        <xsl:value-of select="ext:let('name',  ext:call('strip-bbcode.xsl', ext:parsebbcode(ext:get('name')))) "/>
                        <xsl:value-of select="ext:let('name-suffix',  ext:call('strip-bbcode.xsl', ext:parsebbcode(ext:get('name-suffix')))) "/>
                        <xsl:value-of select="ext:let('params',  ext:call('strip-bbcode.xsl', ext:parsebbcode(ext:get('params')))) "/>
                        <xsl:value-of select="ext:let('suffix',  ext:call('strip-bbcode.xsl', ext:parsebbcode(ext:get('suffix')))) "/>
                        <xsl:value-of select="ext:let('docstring', concat(ext:get('prefix'), ext:get('name'), '(', ext:get('params'), ')')) "/>
                        <xsl:if test="string-length(./@return) > 0"><xsl:value-of select="ext:let('docstring', concat(ext:get('docstring'), '->', ext:get('return')))" /></xsl:if>
                    </xsl:for-each>
                    <xsl:if test="count(./@brief) > 0 and string-length(./@brief) > 0">
                        <xsl:value-of select="ext:let('docstring', concat(ext:get('docstring'), '\n', ext:call('strip-bbcode.xsl', ext:parsebbcode(./@brief))))"/>
                    </xsl:if>
#define <xsl:value-of select="ext:get('defname')" /> "<xsl:value-of select="ext:get('docstring')" />"
                </xsl:when>
                <xsl:when test="./@type='field'">
<xsl:value-of select="ext:let('docstring', '')" />
<xsl:if test="count(./@brief) > 0 and string-length(./@brief) > 0">
    <xsl:value-of select="ext:let('docstring', concat(ext:get('docstring'), '\n', ext:call('strip-bbcode.xsl', ext:parsebbcode(./@brief))))"/>
</xsl:if>
#define <xsl:value-of select="ext:get('defname')" /> "<xsl:value-of select="ext:get('docstring')" />"
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>