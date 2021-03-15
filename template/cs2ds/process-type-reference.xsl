<?xml version="1.0" encoding="windows-1252"?>
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" />
    <xsl:template match="/" >
        <xsl:value-of select="ext:let('type', ext:caller('p-type'))" />
        <xsl:choose>
            <xsl:when test="count(ext:get('type')/@base-signature) > 0">
                <xsl:value-of select="ext:let('sig', ext:get('type')/@base-signature)" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="ext:let('sig', ext:get('type')/@signature)" />
            </xsl:otherwise>
        </xsl:choose>
        <!-- make type reference if needed -->
        <xsl:value-of select="ext:let('has-key', '0')" />
        <xsl:if test="ext:get('type')/@generic != 'generic-parameter' and count(ext:get('g-data')/collection/assemblies/assembly/type[./@signature=ext:get('sig')]) > 0">
            <xsl:value-of select="ext:let('def', ext:get('g-data')/collection/assemblies/assembly/type[./@signature=ext:get('sig')])" />
            <xsl:value-of select="ext:let('target-key', concat(ext:get('def')/@namespace, '.', ext:get('def')/@name)) "/>
            <xsl:value-of select="ext:let('has-key', '1')" />
        </xsl:if>
        <!-- make type full name -->
        <xsl:choose>
        <xsl:when test="ext:get('type')/@namespace='System' and ext:get('type')/@name='Void'">
            <xsl:value-of select="ext:let('name', 'void')"/>
        </xsl:when>
        <xsl:when test="ext:get('type')/@namespace='System' and ext:get('type')/@name='String'">
            <xsl:value-of select="ext:let('name', 'string')"/>
        </xsl:when>
        <xsl:when test="ext:get('type')/@namespace='System' and ext:get('type')/@name='Object'">
            <xsl:value-of select="ext:let('name', 'object')"/>
        </xsl:when>
        <xsl:when test="ext:get('type')/@namespace='System' and ext:get('type')/@name='Int32'">
            <xsl:value-of select="ext:let('name', 'int')"/>
        </xsl:when>
        <xsl:when test="ext:get('type')/@namespace='System' and ext:get('type')/@name='Byte'">
            <xsl:value-of select="ext:let('name', 'byte')"/>
        </xsl:when>
        <xsl:when test="ext:get('type')/@namespace='System' and ext:get('type')/@name='UInt32'">
            <xsl:value-of select="ext:let('name', 'uint')"/>
        </xsl:when>
        <xsl:when test="ext:get('type')/@namespace='System' and ext:get('type')/@name='Double'">
            <xsl:value-of select="ext:let('name', 'double')"/>
        </xsl:when>
        <xsl:when test="ext:get('type')/@namespace='System' and ext:get('type')/@name='Single'">
            <xsl:value-of select="ext:let('name', 'float')"/>
        </xsl:when>
        <xsl:when test="ext:get('type')/@namespace='System' and ext:get('type')/@name='Char'">
            <xsl:value-of select="ext:let('name', 'char')"/>
        </xsl:when>
        <xsl:when test="ext:get('type')/@namespace='System' and ext:get('type')/@name='Boolean'">
            <xsl:value-of select="ext:let('name', 'bool')"/>
        </xsl:when>
        <xsl:when test="ext:get('type')/@namespace='System' and ext:get('type')/@name='Nullable'">
            <xsl:value-of select="ext:let('p-type', ext:get('type')/parameters/type[1])" />
            <xsl:value-of select="ext:let('name', concat(ext:trim(ext:call('process-type-reference.xsl', /)), '?')) "/>
        </xsl:when>
        <xsl:otherwise>
        <xsl:choose>
            <xsl:when test="count(ext:get('g-settings')/settings/strip-namespace[./@name=ext:get('type')/@namespace]) > 0 or string-length(ext:get('type')/@namespace) = 0">
                <xsl:value-of select="ext:let('name', ext:get('type')/@name)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="ext:let('name', concat(ext:get('type')/@namespace, '.', ext:get('type')/@name))"/>
            </xsl:otherwise>
        </xsl:choose>
        </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="count(ext:get('type')/parameters/type) > 0 and not(ext:get('type')/@namespace='System' and ext:get('type')/@name='Nullable')">
            <xsl:value-of select="ext:let('name', concat(ext:get('name'), '&lt;')) "/>
            <xsl:for-each select="ext:get('type')/parameters/type">
                <xsl:if test="position() > 1">
                    <xsl:value-of select="ext:let('name', concat(ext:get('name'), ',')) "/>
                </xsl:if>
                <xsl:value-of select="ext:let('p-type', .)" />
                <xsl:value-of select="ext:let('name', concat(ext:get('name'), ext:trim(ext:call('process-type-reference.xsl', /)))) "/>
            </xsl:for-each>
            <xsl:value-of select="ext:let('name', concat(ext:get('name'), '&gt;')) "/>
        </xsl:if>
        <!-- create type name -->
        <xsl:choose>
            <xsl:when test="ext:get('has-key') = '1'">
                [link=<xsl:value-of select="ext:get('target-key')"/>]<xsl:value-of select="ext:get('name')"/>[/link]
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="ext:get('name')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
