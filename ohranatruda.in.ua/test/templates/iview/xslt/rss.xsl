<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/TR/xlink">
    <xsl:output encoding="utf-8" method="xml" indent="yes"/>

    <xsl:param name="c">7</xsl:param>

    <xsl:template match="/">
        <rss version="2.0">
            <channel>
                <title>Glas.Media RSS polls</title>
                <link>http://glas.media/</link>
                <description>glas.media rss</description>
                <pubDate></pubDate>
                <xsl:choose>
                    <xsl:when test="$c = '7'">
                        <xsl:apply-templates select="document(concat('udata://vote/getListVotesOfCategory/',$c,'/50/auto/1/609/1/int_val/1'))/udata/items//item" mode="votes" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="document(concat('udata://vote/getListVotesOfCategory/',$c,'/50/auto/1/'))/udata/items//item" mode="votes" />
                    </xsl:otherwise>
                </xsl:choose>
            </channel>
        </rss>
    </xsl:template>

    <xsl:template match="item" mode="votes">
        <xsl:variable name="page" select="document(concat('udata://vote/getPoll/',@id))" />
        <xsl:if test="$page//images != ''">
            <item>
                <title><xsl:value-of select="$page//h1" /></title>
                <link>http://glas.media<xsl:value-of select="$page//link" /></link>
                <description>
                    <!--СЕРВИС ОНЛАЙН ОПРОСОВ. Примите участие в голосовании или создайте свой опрос на сайте.-->
                    <!--<xsl:if test="$page//for_article">-->
                    <!--Опрос создан но основе <xsl:value-of select="$page//for_article/type/@rp" />: <xsl:value-of select="$page//title" />-->
                    <!--</xsl:if>-->
                    <xsl:text disable-output-escaping="yes">&lt;![CDATA[</xsl:text><br/><xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>
                    <xsl:value-of select="$page//anons" disable-output-escaping="yes" />
                    <xsl:text disable-output-escaping="yes">&lt;![CDATA[</xsl:text><br/><xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>
                    <xsl:apply-templates select="$page//variants//item" mode="variant" />
                    <xsl:text disable-output-escaping="yes">&lt;![CDATA[</xsl:text><br/><xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>
                    Подробнее: http://glas.media<xsl:value-of select="$page//link" />
                    <xsl:text disable-output-escaping="yes">&lt;![CDATA[</xsl:text><br/><xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>
                </description>
                <guid><xsl:value-of select="@id" /></guid>
                <xsl:apply-templates select="$page//images//td" mode="image" />
            </item>
        </xsl:if>
    </xsl:template>

    <xsl:template match="td" mode="image">
        <image>http://glas.media<xsl:value-of select="@src" /></image>
    </xsl:template>

    <xsl:template match="item" mode="variant">
        <xsl:value-of select="position()" />) <xsl:text disable-output-escaping="yes">&lt;![CDATA[</xsl:text><xsl:value-of select=".//variant" /><br/><xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>
    </xsl:template>

</xsl:stylesheet>