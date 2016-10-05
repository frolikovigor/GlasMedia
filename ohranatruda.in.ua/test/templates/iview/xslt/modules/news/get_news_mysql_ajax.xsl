<?xml version="1.0" encoding="UTF-8"?>

<!DOCTYPE xsl:stylesheet SYSTEM "ulang://i18n/constants.dtd:file"[
        <!ENTITY nbsp  "&#xA0;">
        <!ENTITY copy  "&#169;">
        <!ENTITY mdash "&#8212;">

        <!ENTITY laquo  "&#171;">
        <!ENTITY raquo  "&#187;">

        <!ENTITY rarr  "&#8594;">
        <!ENTITY larr  "&#8592;">
        ]>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:template match="udata[@method='getNewsMysql']">
        <input type="hidden" name="fnm" value="{//news/@id}" />
        <h2>
            <xsl:value-of select="//news//title" />
            <xsl:text> </xsl:text><span class="label-"><xsl:value-of select="//news/type/@name" /></span>
        </h2>
        <div class="info">
            <span class="date"><xsl:value-of select="//news/@date" /></span>
            <xsl:variable name="source" select="document(concat('uobject://',//news/@lent_id))" />
            <xsl:if test="$source//property[@name='source_url']/value">
                <span class="source">Источник: <span><a href="{$source//property[@name='source_url']/value}" target="_blank"><xsl:value-of select="$source//property[@name='title']/value" /></a></span></span>
            </xsl:if>
        </div>
        <div class="cl"></div>
        <div class="for_article_content">
            <xsl:if test="//news/@image">
                <img src="{//news/@image}" width="300" />
            </xsl:if>
            <xsl:value-of select="//news//content" disable-output-escaping="yes" />
        </div>
    </xsl:template>

</xsl:stylesheet>