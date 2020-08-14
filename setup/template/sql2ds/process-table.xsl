<?xml version="1.0" encoding="windows-1252"?>
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" />
    <!-- eliminate ext declaration -->
    <xsl:namespace-alias stylesheet-prefix="ext" result-prefix="#default"/>
    <xsl:template match="TABLE" >
@class
    @name=<xsl:value-of select="./TABLE_NAME/text()" />
    @brief=
    @type=sql
    @ingroup=<xsl:value-of select="ext:get('group')" />
    @sort=no
    @transform=yes

    <xsl:apply-templates select="./COLUMNS/COLUMN" />
    <xsl:apply-templates select="./PKEY[count(./PKEY_NAME)>0]" />
    <xsl:apply-templates select="./FKEYS/FKEY">
        <xsl:sort select="./FKEY_NAME/text()" />
    </xsl:apply-templates>
    <xsl:apply-templates select="./INDEXES/INDEX">
        <xsl:sort select="./IND_NAME/text()" />
    </xsl:apply-templates>
    <xsl:apply-templates select="./TRIGGERS/TRIGGER">
        <xsl:sort select="./TRI_NAME/text()" />
    </xsl:apply-templates>

@end
    </xsl:template>
    <xsl:template match="COLUMN" >
    @member
        @name=<xsl:value-of select="./COLUMN_NAME/text()" />
        @brief=
        @type=field
        @custom=sql-column
        @declaration
            @language=sql
            @custom=
            @return=<xsl:value-of select="./DATA_TYPE/text()" />
            @prefix=
            @suffix=<xsl:if test="./NULLABLE/text()!='Y'"> NOT NULL</xsl:if><xsl:if test="string-length(./DATA_DEFAULT/text()) > 0"> DEFAULT <xsl:value-of select="./DATA_DEFAULT/text()" /></xsl:if>
        @end
    @end
    </xsl:template>
    <xsl:template match="PKEY" >
    @member
        @name=<xsl:value-of select="./PKEY_NAME/text()" />
        @key=<xsl:value-of select="./PKEY_NAME/text()" />.PKey
        @brief=Primary key
        @type=property
        @custom=sql-key
        @declaration
            @language=sql
            @prefix=PRIMARY KEY
            @custom=
            @return=
            @suffix=(<xsl:for-each select="./PKEY_COL_LIST/PKEY_COLUMN[string-length(./text())!=0]"><xsl:if test="position()>1">, </xsl:if>[link=<xsl:value-of select="../../../TABLE_NAME/text()"/>.<xsl:value-of select="./text()"/>]<xsl:value-of select="./text()"/>[/link]</xsl:for-each>)
        @end
    @end
    </xsl:template>
    <xsl:template match="FKEY" >
    @member
        @name=<xsl:value-of select="./FKEY_NAME/text()" />
        @key=<xsl:value-of select="./FKEY_NAME/text()" />.FKey
        @brief=Foreign key
        @type=property
        @custom=sql-key
        @declaration
            @language=sql
            @prefix=FOREIGN KEY
            @custom=
            @return=
            @suffix=(<xsl:for-each select="./FKEY_COL_ITEM"><xsl:if test="position()>1">, </xsl:if>[link=<xsl:value-of select="../../../TABLE_NAME/text()"/>.<xsl:value-of select="./THIS_NAME/text()"/>]<xsl:value-of select="./THIS_NAME/text()"/>[/link]</xsl:for-each>) REFERENCES [link=<xsl:value-of select="./REF_TABLE/text()" />]<xsl:value-of select="./REF_TABLE/text()" />[/link] (<xsl:for-each select="./FKEY_COL_ITEM"><xsl:if test="position()>1">, </xsl:if>[link=<xsl:value-of select="../REF_TABLE/text()"/>.<xsl:value-of select="./REF_NAME/text()"/>]<xsl:value-of select="./REF_NAME/text()"/>[/link]</xsl:for-each>)
        @end
    @end
    </xsl:template>
    <xsl:template match="INDEX" >
    @member
        @name=<xsl:value-of select="./IND_NAME/text()" />
        @key=<xsl:value-of select="./IND_NAME/text()" />.Index
        @brief=Index
        @type=property
        @custom=sql-index
        @declaration
            @language=sql
            @prefix=<xsl:value-of select="./IND_TYPE/text()" /> INDEX
            @custom=
            @return=
            @suffix=ON [link=<xsl:value-of select="../../TABLE_NAME/text()"/>]<xsl:value-of select="../../TABLE_NAME/text()"/>[/link] (<xsl:for-each select="./IND_COLUMNS/COL_NAME"><xsl:if test="position()>1">, </xsl:if>[link=<xsl:value-of select="../../../../TABLE_NAME/text()"/>.<xsl:value-of select="./text()"/>]<xsl:value-of select="./text()"/>[/link]</xsl:for-each>)
        @end
    @end
    </xsl:template>
    <xsl:template match="TRIGGER" >
    @member
        @name=<xsl:value-of select="./TRI_NAME/text()" />
        @key=<xsl:value-of select="./TRI_NAME/text()" />.Trigger
        @brief=Index
        @type=property
        @custom=sql-trigger
        @declaration
            @language=sql
            @prefix=TRIGGER
            @custom=
            @return=
            @suffix=<xsl:value-of select="./TRI_TYPE/text()" /><xsl:text> </xsl:text><xsl:value-of select="./TRI_EVENT/text()" /> <xsl:if test="count(./TRI_COLUMNS/COL_NAME)>0"> ON <xsl:for-each select="./TRI_COLUMNS/COL_NAME"><xsl:if test="position()>1">, </xsl:if>[link=<xsl:value-of select="../../../../TABLE_NAME/text()"/>.<xsl:value-of select="./text()"/>]<xsl:value-of select="./text()"/>[/link]</xsl:for-each></xsl:if>
        @end
    @end
    </xsl:template>
</xsl:stylesheet>


