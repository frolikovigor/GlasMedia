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

    <xsl:include href="../blocks.xsl" />
    <xsl:include href="../../library/common.xsl" />

    <xsl:template match="udata[@method='getListFeedsOfUser']">
        <xsl:choose>
            <xsl:when test="count(//feed)">
                <form class="my_feeds">
                    <xsl:apply-templates select="//feed" mode="getListFeedsOfUser" />
                </form>
                <div class="paginated">
                    <xsl:apply-templates select="document(concat('udata://system/numpages/',//total,'/',//per_page,'/'))"  mode="paginated" />
                </div>
            </xsl:when>
            <xsl:otherwise>
                <div class="alert alert-warning" role="alert">У Вас пока нет лент.</div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="feed" mode="getListFeedsOfUser">
        <div class="feed_item">
            <table>
                <tr>
                    <td class="photo_profile">
                        <a href="/vote/get/{@id}/">
                            <xsl:apply-templates select="document(concat('udata://system/makeThumbnailFull/(.', .//photo_profile, ')/160/160/void/0/1/5/0/80/'))/udata" mode="feedPhotoProfile">
                                <xsl:with-param name="width" select="160" />
                                <xsl:with-param name="height" select="160" />
                            </xsl:apply-templates>
                        </a>
                    </td>
                    <td class="info">
                        <a href="/vote/get/{@id}/"><xsl:value-of select="@name" /></a>
                        <span class="date"><xsl:value-of select="@date" /></span>
                        <span class="num_subscribe">Подписчиков: <xsl:value-of select="@polls_num" /></span>
                        <hr/>
                        <div class="description"><xsl:value-of select=".//description" /></div>
                    </td>
                    <td class="labels">
                        <xsl:choose>
                            <xsl:when test="@is-active = '1'">
                                <span class="label label-success">Лента активна</span>
                            </xsl:when>
                            <xsl:otherwise>
                                <span class="label label-warning">Лента отключена</span>
                            </xsl:otherwise>
                        </xsl:choose>
                    </td>
                </tr>
            </table>
        </div>
    </xsl:template>

</xsl:stylesheet>