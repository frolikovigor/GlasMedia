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

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

    <xsl:include href="../vote/poll.xsl" />
    <xsl:include href="../comments/comments.xsl" />

    <xsl:template match="udata[@method='votePoll']">
        <xsl:call-template name="poll">
            <xsl:with-param name="id" select="//id" />
            <xsl:with-param name="type" select="//params/type" />
            <xsl:with-param name="view_url" select="//params/view_url" />
        </xsl:call-template>
    </xsl:template>

    <!-- test --> <!-- test -->


</xsl:stylesheet>