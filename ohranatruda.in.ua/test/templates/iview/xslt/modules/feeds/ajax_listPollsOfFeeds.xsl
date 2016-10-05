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

    <xsl:include href="../blocks.xsl" />
    <xsl:include href="../vote/poll.xsl" />
    <xsl:include href="../feeds/feeds.xsl" />
    <xsl:include href="../comments/comments.xsl" />



    <xsl:template match="udata[@method='listPollsOfFeeds']">
        <xsl:apply-templates select="//items//item" mode="getListVotes">
            <xsl:with-param name="h">h2</xsl:with-param>
        </xsl:apply-templates>
        <xsl:if test="//last_page = '1'">
            <div class="last_page"></div>
        </xsl:if>
    </xsl:template>


</xsl:stylesheet>