<?xml version="1.0" encoding="windows-1252"?>
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" />
    <xsl:template match="/" >&lt;html&gt;
<!--Sitemap 1.0-->
&lt;OBJECT type="text/site properties"&gt;&lt;/OBJECT&gt;
&lt;UL&gt;
    <xsl:apply-templates select="/root/node" />
&lt;/UL&gt;
&lt;/html&gt;
    </xsl:template>
    <xsl:template match="node">
    <xsl:choose><xsl:when test="count(./@local)>0">&lt;li&gt;&lt;object type="text/sitemap"&gt;&lt;param name="Name" value="<xsl:value-of select="./@name" />"&gt;&lt;param name="Local" value="<xsl:value-of select="./@local" />"&gt;&lt;/object&gt;&lt;a href="<xsl:value-of select="./@local" />"&gt;<xsl:value-of select="./@name" />&lt;/a&gt;
    </xsl:when><xsl:otherwise>&lt;li&gt;&lt;object type="text/sitemap"&gt;&lt;param name="Name" value="<xsl:value-of select="./@name" />"&gt;&lt;/object&gt;<xsl:value-of select="./@name" />
    </xsl:otherwise></xsl:choose>
    <xsl:if test="count(./node)>0">
        &lt;UL&gt;
            <xsl:apply-templates select="./node" />
        &lt;/UL&gt;
    </xsl:if>
    </xsl:template>
</xsl:stylesheet>

