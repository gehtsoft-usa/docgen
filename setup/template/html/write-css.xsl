<?xml version="1.0" encoding="windows-1252"?>
<!-- writes scripts to the page header -->
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" />
    <xsl:namespace-alias stylesheet-prefix="ext" result-prefix="#default"/>
    <xsl:template match="/" >
    <xsl:if test="ext:exist('enable-highlighter') and ext:get('enable-highlighter') = 'yes'">
    <link rel="stylesheet" href="highlighter/default.css"></link>
    </xsl:if>
<xsl:choose>
<xsl:when test="ext:exist('external-resources') and ext:get('external-resources') = 'yes'">
    <link rel="stylesheet" href="res/styles.css"></link>
</xsl:when>
<xsl:otherwise>
<style type="text/css">
    <!-- default p-style -->
    body
    {
        color:#444444;
        background-color:white;
        font-family:Trebuchet MS, Arial;
        font-size:10pt;
    }
    A:link
    {
        color:#0068be;
        font-family:Trebuchet MS, Arial;
        font-size:10pt;
        cursor:pointer;
    }
    A:visited
    {
        color:#039CCF;
        font-family:Trebuchet MS, Arial;
        font-size:10pt;
        cursor:pointer;
    }
    p, h1, h2, h3, h4, h5, h6
    {
        font-family : Trebuchet MS, Arial;
    }

    pre.example
    {
        background-color : #f1f1f1;
    }

    ul, ul.main
    {
        list-style-type : disc;
        margin-left: 18pt;
    }
    ol, ol.main
    {
        list-style-type: decimal;
        margin-left: 18pt;
    }
    li
    {
        font-family : Trebuchet MS, Arial;
    }
    ul.hhc
    {
        list-style-type : none;
        margin-left : 1em;
        padding : 0;
        padding-left : 0;
        text-indent : 0;
    }
    li.hhc
    {
        font-family : Trebuchet MS, Arial;
        margin-left : 0;
        padding : 0;
        padding-left : 0;
        text-indent : 0;
    }
    <!-- table styles -->
    table, table.tmain
    {
        font-size:10pt;
        border-collapse : collapse;
        border : 1px solid;
        border-color : #dfe3e7;
    }
    td.tmain, td.tmain_nw, td.thdr
    {
        border : 1px solid;
        border-color : #dfe3e7;
        background-color : rgb(255, 255, 255);
        vertical-align : top;
        padding : 3px;
        font-family : Trebuchet MS, Arial;
    }
    td.tmain p, td.tmain_nw p, td.thdr p
    {
        margin-bottom : 6pt;
    }
    td.tmain_nw
    {
        white-space : nowrap;
    }
    td.thdr
    {
        font-size:10pt;
        background-color : #f1f1f1;
    }
    table.decl
    {
        border : 0px none;
        background-color : rgb(192, 192, 192);
        vertical-align : top;
        padding : 3px;
        font-family : Trebuchet MS, Arial;
        width : 100%;
    }
</style>
</xsl:otherwise>
</xsl:choose>
    </xsl:template>
</xsl:stylesheet>

