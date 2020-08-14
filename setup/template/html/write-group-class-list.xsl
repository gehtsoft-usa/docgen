<?xml version="1.0" encoding="windows-1252"?>
<!-- writes body description
     param: ext:caller('curr-item') - a group to write classes
  -->
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" />
    <xsl:namespace-alias stylesheet-prefix="ext" result-prefix="#default"/>

    <xsl:template match="/" >
        <xsl:value-of select="ext:let('transform', ext:caller('transform'))" />
        <xsl:apply-templates select="ext:caller('curr-item')" />
    </xsl:template>

    <xsl:template match="group" >
        <!-- scan groups -->
        <xsl:value-of select="ext:let('curr-group', .)" />
        <xsl:for-each select="ext:get('g-classes-groups')/classes-groups/class-group" >
            <!-- build mask for all types of the current group -->
            <xsl:value-of select="ext:let('mask', '')" />
            <xsl:value-of select="ext:let('body-template', ./@template)" />
            <xsl:for-each select="./type">
                <xsl:value-of select="ext:let('mask', concat(ext:get('mask'), '{', ./@name, '}'))" />
            </xsl:for-each>
            <!-- choose classes which are in the current group and has the type which is in the mask -->
            <xsl:value-of select="ext:let('class-list', ext:get('g-root')/class[./@in-group=ext:caller('curr-item')/@key and contains(ext:get('mask'), concat('{', ./@type, '}'))])" />
            <!-- if at least one class is selected - write them -->
            <xsl:if test="count(ext:get('class-list'))>0">
                <!-- create content node and table header -->
                <xsl:value-of select="ext:let('content-node', ext:xmladdelement('help-content', ext:caller('content-node'), 'node'))" />
                <xsl:value-of select="ext:xmladdattribute('help-content', ext:get('content-node'), 'name', ./@title)" />
                <p/>
                <table class="tmain" width="100%">
                <tr><td colspan="2" class="thdr"><b><xsl:value-of select="./@title" /></b></td></tr>
                <!-- enumerate classes -->
                <xsl:choose>
                    <xsl:when test="ext:get('curr-group')/@sort-classes='yes'">
                        <xsl:apply-templates select="ext:get('class-list')" >
                            <xsl:sort select="./@name" />
                        </xsl:apply-templates>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="ext:get('class-list')" />
                    </xsl:otherwise>
                </xsl:choose>
                </table>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="class" >
       <!-- in case class is conditional process it only in case the if variable is defined -->
       <tr><td class="tmain_nw" width="31%" >
           <p><xsl:element name="a"><xsl:attribute name="href"><xsl:value-of select="./@key" />.html</xsl:attribute>
               <xsl:value-of select="./@name" disable-output-escaping="yes"  /></xsl:element></p></td>
           <td class="tmain" width="69%"><p><xsl:choose>
                    <xsl:when test="ext:get('transform')='yes'"><xsl:value-of select="ext:call('write-bbcode.xsl', ext:parsebbcode(./@brief))" disable-output-escaping="yes"  /></xsl:when>
                    <xsl:otherwise><xsl:value-of select="./@brief" /></xsl:otherwise>
                </xsl:choose></p></td>
       </tr>
       <xsl:value-of select="ext:let('curr-item', .)"/>
       <xsl:value-of select="ext:let('curr-item-type', ./@type)"/>
       <xsl:value-of select="ext:let('temp', ext:get('g-classes-groups')/classes-groups/class-group/type[./@name=ext:get('curr-item')/@type and count(./@display) > 0]) " />
       <xsl:if test="count(ext:get('temp'))>0">
        <xsl:value-of select="ext:let('curr-item-type', ext:get('temp')[1]/@display)"/>
       </xsl:if>
       <xsl:value-of select="ext:call('write-class-body.xsl', /, concat(./@key, '.html'), ext:get('codepage')) " />
    </xsl:template>
</xsl:stylesheet>


