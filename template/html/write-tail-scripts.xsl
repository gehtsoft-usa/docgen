<?xml version="1.0" encoding="windows-1252"?>
<!-- writes scripts to the page header -->
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" />
    <xsl:namespace-alias stylesheet-prefix="ext" result-prefix="#default"/>
    <xsl:template match="/" >
<xsl:choose>
<xsl:when test="ext:exist('external-resources') and ext:get('external-resources') = 'yes'">
<script language="javascript" type="text/javascript">syncList();</script>
</xsl:when>
<xsl:otherwise>
<script language="javascript" type="text/javascript">if(window.parent.frames[0]) window.parent.frames[0].selectItem(window.location.href);</script>
</xsl:otherwise>
</xsl:choose>
    </xsl:template>
</xsl:stylesheet>

