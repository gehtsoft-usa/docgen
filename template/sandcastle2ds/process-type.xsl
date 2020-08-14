<?xml version="1.0" encoding="windows-1252"?>
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" />
    <!-- eliminate ext declaration -->
    <xsl:namespace-alias stylesheet-prefix="ext" result-prefix="#default"/>
    <xsl:template match="/" >
    <!-- the type node is in the ascentors or in the parameters -->
    <xsl:value-of select="ext:let('curr-type', ext:caller('type'))" />
    <!-- the currently processed namespace -->
    <xsl:value-of select="ext:let('p-ns-id', ext:caller('p-ns-id')) " />
    <!-- check whether the class is in the ref. list -->
    <xsl:value-of select="ext:let('def', ext:get('g-data')/reflection/apis/api[./@id=ext:get('curr-type')/@api]) "/>
    <xsl:value-of select="ext:let('link', '')" />
    <xsl:choose>
        <xsl:when test="count(ext:get('def'))>0">
            <!-- the class is in the list. check whether namespace is the same -->
            <xsl:choose>
                <xsl:when test="ext:get('def')/containers/namespace/@api=ext:get('p-ns-id')" >
                    <!-- the class is in the same name space. eliminate the namespace name name -->
                    <xsl:value-of select="ext:let('name', substring(ext:get('curr-type')/@api, string-length(ext:get('p-ns-id')) + 2)) "/>
                </xsl:when>
                <xsl:otherwise>
                    <!-- the class is not in the same name space. leave the full name -->
                    <xsl:value-of select="ext:let('name', substring(ext:get('curr-type')/@api, 3)) "/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="ext:let('p-class-id', ext:get('curr-type')/@api)" />
            <xsl:value-of select="ext:let('link', ext:call('get-class-key.xsl', /))" />
        </xsl:when>
        <xsl:otherwise>
            <!-- the class is not in the ref list. leave the full name. -->
            <xsl:value-of select="ext:let('name', substring(ext:get('curr-type')/@api, 3)) "/>
        </xsl:otherwise>
    </xsl:choose>
    <!-- process the generic type -->
    <xsl:value-of select="ext:let('name1', '')" />
    <xsl:if test="contains(ext:get('name'), '`')">
        <!-- eliminate `N fromt the name -->
        <xsl:value-of select="ext:let('name', substring(ext:get('name'), 1, string-length(ext:get('name')) - 2))" />
        <xsl:value-of select="ext:let('name1', '&lt;') " />
        <xsl:value-of select="ext:let('i', 0)" />
        <xsl:for-each select="ext:get('curr-type')/specialization/*">
            <xsl:if test="ext:get('i')!=0">
                <xsl:value-of select="ext:let('name1', concat(ext:get('name1'), ','))" />
            </xsl:if>
            <xsl:choose>
                <xsl:when test="name(.)='type'">
                    <xsl:value-of select="ext:let('type', .)" />
                    <xsl:value-of select="ext:let('name1', concat(ext:get('name1'), ext:call('process-type.xsl', /)))" />
                </xsl:when>
                <xsl:when test="name(.)='template'">
                    <xsl:value-of select="ext:let('name1', concat(ext:get('name1'), ./@name))" />
                </xsl:when>
            </xsl:choose>
            <xsl:value-of select="ext:let('i', ext:get('i') + 1)" />
        </xsl:for-each>
        <xsl:value-of select="ext:let('name1', concat(ext:get('name1'), '&gt;')) " />
    </xsl:if>
    <!-- decode the standard classes -->
    <xsl:choose>
        <xsl:when test="ext:get('name')='System.Object'"><xsl:value-of select="ext:let('name', 'object')" /></xsl:when>
        <xsl:when test="ext:get('name')='System.String'"><xsl:value-of select="ext:let('name', 'string')" /></xsl:when>
        <xsl:when test="ext:get('name')='System.Int32'"><xsl:value-of select="ext:let('name', 'int')" /></xsl:when>
        <xsl:when test="ext:get('name')='System.Boolean'"><xsl:value-of select="ext:let('name', 'bool')" /></xsl:when>
        <xsl:when test="ext:get('name')='System.DateTime'"><xsl:value-of select="ext:let('name', 'DateTime')" /></xsl:when>
        <xsl:when test="ext:get('name')='System.Double'"><xsl:value-of select="ext:let('name', 'double')" /></xsl:when>
        <xsl:when test="ext:get('name')='System.IntPtr'"><xsl:value-of select="ext:let('name', 'IntPtr')" /></xsl:when>
        <xsl:when test="ext:get('name')='System.Byte'"><xsl:value-of select="ext:let('name', 'byte')" /></xsl:when>
        <xsl:when test="ext:get('name')='System.SByte'"><xsl:value-of select="ext:let('name', 'sbyte')" /></xsl:when>
        <xsl:when test="ext:get('name')='System.Char'"><xsl:value-of select="ext:let('name', 'char')" /></xsl:when>
        <xsl:when test="ext:get('name')='System.Decimal'"><xsl:value-of select="ext:let('name', 'decimal')" /></xsl:when>
        <xsl:when test="ext:get('name')='System.Signle'"><xsl:value-of select="ext:let('name', 'float')" /></xsl:when>
        <xsl:when test="ext:get('name')='System.UInt32'"><xsl:value-of select="ext:let('name', 'uint')" /></xsl:when>
        <xsl:when test="ext:get('name')='System.UInt64'"><xsl:value-of select="ext:let('name', 'ulong')" /></xsl:when>
        <xsl:when test="ext:get('name')='System.Int64'"><xsl:value-of select="ext:let('name', 'long')" /></xsl:when>
        <xsl:when test="ext:get('name')='System.UInt16'"><xsl:value-of select="ext:let('name', 'ushort')" /></xsl:when>
        <xsl:when test="ext:get('name')='System.Int16'"><xsl:value-of select="ext:let('name', 'short')" /></xsl:when>
    </xsl:choose>
    <xsl:if test="ext:get('link')!=''">[clink=<xsl:value-of select="ext:get('link')" />]</xsl:if><xsl:value-of select="ext:get('name')" /><xsl:if test="ext:get('link')!=''">[/clink]</xsl:if><xsl:value-of select="ext:get('name1')" />
    </xsl:template>
</xsl:stylesheet>

