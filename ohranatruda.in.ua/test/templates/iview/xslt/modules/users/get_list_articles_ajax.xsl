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

    <xsl:include href="../../library/common.xsl" />

    <xsl:template match="udata[@method='getListArticlesOfUser']">
        <xsl:choose>
            <xsl:when test="count(//article)">
                <form class="my_articles">
                    <table width="100%" border="1">
                        <thead>
                            <th>Наименование</th>
                            <th>Категория</th>
                            <th>Дата</th>
                            <th>Ред.</th>
                            <th>Активность</th>
                        </thead>
                        <tbody>
                            <xsl:apply-templates select="//article" mode="getListArticlesOfUser" />
                        </tbody>
                    </table>
                </form>
                <div class="paginated">
                    <xsl:apply-templates select="document(concat('udata://system/numpages/',//total,'/',//per_page,'/'))"  mode="paginated" />
                </div>
            </xsl:when>
            <xsl:otherwise>
                <div class="alert alert-warning" role="alert">У Вас пока нет статей.</div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="article" mode="getListArticlesOfUser">
        <tr>
            <xsl:if test="@is-active = '0'"><xsl:attribute name="class">unactive</xsl:attribute></xsl:if>
            <td>
                <div class="title_link">
                    <xsl:choose>
                        <xsl:when test="@is-active = '0'">
                            <a href="{@link_preview}"><xsl:apply-templates select=".//name" mode="getListArticlesOfUser" /></a>
                        </xsl:when>
                        <xsl:otherwise>
                            <a href="{@link}"><xsl:apply-templates select=".//name" mode="getListArticlesOfUser" /></a>
                        </xsl:otherwise>
                    </xsl:choose>
                </div>
            </td>
            <td><xsl:apply-templates select=".//item" mode="getListArticlesOfUser" /></td>
            <td><xsl:value-of select="@date" /></td>
            <td width="50" align="center">
                <a href="/content/edit_article/{@id}"><span class="glyphicon glyphicon-pencil edit_poll"></span></a>
            </td>
            <td width="75" align="center">
                <input type="hidden" name="data[{@id}][is_active]" value="0" />
                <input type="checkbox" name="data[{@id}][is_active]" value="1">
                    <xsl:if test="@is-active = '1'"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
                </input>
            </td>
        </tr>
    </xsl:template>

    <xsl:template match="item" mode="getListArticlesOfUser">
        <xsl:if test="position() != 1"> / </xsl:if>
        <a href="{@link}">
            <xsl:value-of select=".//." disable-output-escaping="yes" />
        </a>
    </xsl:template>

</xsl:stylesheet>