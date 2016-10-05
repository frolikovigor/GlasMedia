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

    <xsl:template match="udata[@method='getListVotesOfUser']">
        <xsl:choose>
            <xsl:when test="count(//vote)">
                <form class="my_polls">
                    <table width="100%" border="1">
                        <thead>
                            <th>Опрос</th>
                            <th class="chanels">Лента</th>
                            <th>Ред.</th>
                            <th>Активность</th>
                        </thead>
                        <tbody>
                            <xsl:variable name="getCurrentUserId" select="document('udata://users/getCurrentUserId/')/udata" />
                            <xsl:apply-templates select="//vote" mode="getListVotesOfUser">
                                <xsl:with-param name="getCurrentUserId" select="$getCurrentUserId" />
                            </xsl:apply-templates>
                        </tbody>
                    </table>
                </form>
                <div class="paginated">
                    <xsl:apply-templates select="document(concat('udata://system/numpages/',//total,'/',//per_page,'/'))"  mode="paginated" />
                </div>
            </xsl:when>
            <xsl:otherwise>
                <div class="alert alert-warning" role="alert">У Вас пока нет опросов.</div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="vote" mode="getListVotesOfUser">
        <xsl:param name="getCurrentUserId" />
        <tr>
            <xsl:if test="@is-active = '0'"><xsl:attribute name="class">unactive</xsl:attribute></xsl:if>
            <td>
                <div class="title_link">
                    <xsl:choose>
                        <xsl:when test="@is-active = '0'">
                            <a href="{@link_preview}"><xsl:apply-templates select=".//theme" mode="getListVotesOfUser" /></a>
                        </xsl:when>
                        <xsl:otherwise>
                            <a href="{@link}"><xsl:apply-templates select=".//theme" mode="getListVotesOfUser" /></a>
                        </xsl:otherwise>
                    </xsl:choose>
                </div>
                <div><xsl:apply-templates select=".//item" mode="getListVotesOfUser" /></div>
                <div><xsl:value-of select="@date" /></div>
                <div>Голосов <xsl:value-of select="@votes" /></div>
            </td>
            <td class="chanels">
                <div class="chanels">
                    <xsl:apply-templates select="document(concat('usel://uniq_objects/146/user/',$getCurrentUserId,'/not/?ext_groups=additional'))/udata/item" mode="getListFeeds">
                        <xsl:with-param name="poll_id" select="@id" />
                        <xsl:with-param name="selected" select=".//feeds" />
                    </xsl:apply-templates>
                </div>
            </td>
            <td width="50" align="center">
                <xsl:choose>
                    <xsl:when test="@votes = 0">
                        <a href="/vote/editPoll/{@id}"><span class="glyphicon glyphicon-pencil edit_poll"></span></a>
                    </xsl:when>
                    <xsl:otherwise>
                        <span class="glyphicon glyphicon-pencil" data-toggle="tooltip" data-placement="top" title="Редактирование запрещено, когда есть хоть один голос" ></span>
                    </xsl:otherwise>
                </xsl:choose>
            </td>
            <td width="75" align="center">
                <input type="hidden" name="data[{@id}][is_active]" value="0" />
                <input type="checkbox" name="data[{@id}][is_active]" value="1">
                    <xsl:if test="@is-active = '1'"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
                </input>
            </td>
        </tr>
    </xsl:template>

    <xsl:template match="item" mode="getListVotesOfUser">
        <xsl:if test="position() != 1"> / </xsl:if>
        <a href="{@link}">
            <xsl:value-of select=".//." disable-output-escaping="yes" />
        </a>
    </xsl:template>

    <xsl:template match="item" mode="getListFeeds">
        <xsl:param name="poll_id" />
        <xsl:param name="selected" />

        <div class="checkbox">
            <label>
                <input type="checkbox" name="data[{$poll_id}][feed][]" value="{@id}">
                    <xsl:if test="@id = $selected//feed"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
                </input>
                <xsl:value-of select="@name" />
            </label>
        </div>
    </xsl:template>

</xsl:stylesheet>