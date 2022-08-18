<?xml version="1.0" encoding="windows-1252"?>
<!-- writes one name
     param: ext:caller('curr-item') - a member to write
  -->
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" />
    <xsl:namespace-alias stylesheet-prefix="ext" result-prefix="#default"/>

<xsl:template match="/" >
    <xsl:value-of select="ext:let('transform', ext:caller('transform'))" />
    <xsl:value-of select="ext:let('write-signature', ext:caller('write-signature'))" />

   <xsl:variable name="declarations" select="ext:caller('curr-node')/declaration" />
   <xsl:variable name="newdeclarations" select="ext:caller('curr-node')//new-declaration" />
   <xsl:choose>
       <xsl:when test="ext:get('write-signature') and count($declarations)>0">
           <xsl:element name="a"><xsl:attribute name="href"><xsl:value-of select="concat(ext:caller('curr-node')/../@key, '.', ext:caller('curr-node')/@key)" />.html</xsl:attribute><xsl:value-of select="ext:caller('curr-node')/@name" disable-output-escaping="yes" />
           <xsl:value-of select="ext:let('params',  ext:call('strip-bbcode.xsl', ext:parsebbcode(ext:caller('curr-node')/declaration/@params)))" />
           (<xsl:value-of select="ext:get('params')"  disable-output-escaping="yes" />)
           </xsl:element>
       </xsl:when>
       <xsl:when test="ext:get('write-signature') and count($declarations)=0 and count($newdeclarations)>0">
           <xsl:element name="a"><xsl:attribute name="href"><xsl:value-of select="concat(ext:caller('curr-node')/../@key, '.', ext:caller('curr-node')/@key)" />.html</xsl:attribute><xsl:value-of select="ext:caller('curr-node')/@name" disable-output-escaping="yes" />
           <xsl:variable name="params" select="$newdeclarations[1]/example-tab[1]/body/p/text()" />
           <xsl:variable name="parsed" select="ext:parse('\((.*)\)', $params)" />
           <xsl:variable name="args">
               <xsl:choose>
                   <xsl:when test="$parsed/result/@count > 0"><xsl:value-of select="$parsed/result/match[1]/group[1]/text()"/></xsl:when>
                   <xsl:otherwise>???</xsl:otherwise>
               </xsl:choose>
           </xsl:variable>
           (<xsl:value-of select="$args"  disable-output-escaping="yes" />)
           </xsl:element>
       </xsl:when>
       <xsl:otherwise>
           <xsl:element name="a"><xsl:attribute name="href"><xsl:value-of select="concat(ext:caller('curr-node')/../@key, '.', ext:caller('curr-node')/@key)" />.html</xsl:attribute><xsl:value-of select="ext:caller('curr-node')/@name" disable-output-escaping="yes" /></xsl:element>
       </xsl:otherwise>
   </xsl:choose>
</xsl:template>
</xsl:stylesheet>