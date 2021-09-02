<?xml version="1.0" encoding="windows-1252"?>
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" encoding="Windows-1252"/>
    <xsl:template match="/" >
<xsl:value-of select="ext:letglobal('g-root', /root)" />
<xsl:value-of select="ext:letglobal('g-example-serial', 0)" />
<xsl:value-of select="ext:letglobal('g-classes-groups', ext:document('dictionary/classes-groups.xml'))" />
<xsl:value-of select="ext:letglobal('g-member-groups', ext:document('dictionary/member-groups.xml'))" />
<xsl:value-of select="ext:letglobal('g-declarations', ext:document('dictionary/declarations.xml'))" />
<xsl:value-of select="ext:letglobal('g-help-index-root', ext:xmlcreate('help-index', 'root'))" />
<xsl:value-of select="ext:let('content-node', ext:xmlcreate('help-content', 'root'))" />
<xsl:value-of select="ext:let('group', /root/group[./@is-root='true'])" />
<xsl:if test="not(ext:exist('create-group-for-members-with-same-name'))">
    <xsl:value-of select="ext:letglobal('create-group-for-members-with-same-name', 'no')"/>
</xsl:if>
<xsl:if test="count(ext:get('group')) != 1">
<xsl:value-of select="ext:error('The number of root groups is not equal to 1')" />
</xsl:if>
<!-- load localization strings -->
<xsl:value-of select="ext:let('localization', ext:document('dictionary/translation.xml'))" />
<xsl:value-of select="ext:let('default-language', ext:get('localization')/dictionary/@default-language)" />
<xsl:choose>
    <xsl:when test="ext:exist('text-language')" />
    <xsl:otherwise><xsl:value-of select="ext:let('text-language', ext:get('default-language'))" /></xsl:otherwise>
</xsl:choose>
<xsl:for-each select="ext:get('localization')/dictionary/string">
    <xsl:value-of select="ext:let('loc-name', concat('_string_', ./@id)) " />
    <xsl:choose>
        <xsl:when test="count(./language[@id=ext:get('text-language') and string-length(@value) > 0]) > 0">
            <xsl:value-of select="ext:let('loc-value', concat('', ./language[@id=ext:get('text-language') and string-length(@value) > 0][position() = 1]/@value)) " />
        </xsl:when>
        <xsl:otherwise>
            <xsl:choose>
                <xsl:when test="count(./language[@id=ext:get('default-language') and string-length(@value) > 0]) > 0">
                    <xsl:value-of select="ext:let('loc-value', concat('', ./language[@id=ext:get('default-language') and string-length(@value) > 0][position() = 1]/@value)) " />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="ext:trace(concat('localization warning: value ', ./@id, ' is not defined for the language ', ext:get('text-language')))"/>
                    <xsl:value-of select="ext:let('loc-value', concat('__unknown_resource_', ./@id)) " />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select="ext:letglobal(ext:get('loc-name'), ext:get('loc-value')) "/>
</xsl:for-each>
<xsl:value-of select="ext:call('write-group.xsl', /, concat(ext:get('group')/@key, '.html'), ext:get('codepage')) " />
<xsl:if test="ext:get('write-web', 'yes')='yes'">
    <xsl:value-of select="ext:call('write-web-content.xsl', /, 'web-content-main.html', ext:get('codepage')) " />
    <xsl:value-of select="ext:let('web-content', ext:get('web-content-file-name', 'web-content'))" />
    <xsl:value-of select="ext:call('write-web-main.xsl', /, concat(ext:get('web-content'), '.html'), ext:get('codepage')) " />
    <xsl:if test="ext:get('web-content-file-name-backward-compatibility', 'no') = 'yes'">
        <xsl:value-of select="ext:call('write-web-main.xsl', /, 'web-content.html', ext:get('codepage')) " />
    </xsl:if>
</xsl:if>
<xsl:if test="ext:get('write-hhp', 'yes')='yes'">
    <xsl:value-of select="ext:call('write-hhc.xsl', ext:xmlgetdocument('help-content'), 'index.hhc', ext:get('codepage')) " />
    <xsl:value-of select="ext:call('write-hhk.xsl', ext:xmlgetdocument('help-index'), 'index.hhk', ext:get('codepage')) " />
    <xsl:value-of select="ext:call('write-hhp.xsl', /, 'project.hhp', ext:get('hhp-codepage', 'windows-1252')) " />
</xsl:if>
<xsl:value-of select="ext:call('write-script-settings.xsl', /, 'settings.js', ext:get('codepage')) " />
<xsl:value-of select="ext:checkkeys()" />
    </xsl:template>
</xsl:stylesheet>

