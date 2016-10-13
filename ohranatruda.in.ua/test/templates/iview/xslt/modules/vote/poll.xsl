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

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
                xmlns:xl="http://www.w3.org/1999/XSL/Transform">

    <xsl:include href="../images.xsl" />

    <xsl:template name="poll">
        <xsl:param name="id" />
        <xsl:param name="view_url">false</xsl:param>
        <xsl:param name="h">h2</xsl:param>
        <xsl:param name="type">standart</xsl:param>
        <xsl:param name="getPoll" select="document(concat('udata://vote/getPoll/',$id))" />

        <xsl:variable name="tooltips" select="document('udata://content/tooltips/')/udata" />

        <xsl:choose>
            <xsl:when test="$type='standart'">
                <xsl:variable name="width">588</xsl:variable>
                <div class="poll {$type} poll{$id}" data-id="{$id}" data-multiple="{$getPoll//multiple}">
                    <form>
                        <input type="hidden" name="data[params][type]" value="{$type}" />
                        <input type="hidden" name="data[params][view_url]" value="{$view_url}" />
                        <input type="hidden" name="data[id]" value="{$id}" />

                        <div class="theme" title="{$getPoll//h1}">
                            <xsl:if test="(($getPoll//user/@id  = '2') and ($getPoll//user/@auth = '1')) or (($getPoll//user/@auth = '1') and ($getPoll//user/@id = $getPoll//poll_user))">
                                <div class="dropdown settings_item">
                                    <button type="button" class="btn btn-default btn-white btn-xs dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                        <span class="glyphicon glyphicon-wrench"></span>&nbsp;&nbsp;<span class="caret"></span>
                                    </button>
                                    <ul class="dropdown-menu">
                                        <li><a href="/vote/editPoll/{$getPoll//id}/1/0">Изменить опрос</a></li>
                                        <li><a href="/vote/editPoll/{$getPoll//id}/1/1/">Создать похожий опрос</a></li>
                                        <xsl:if test="$getPoll//for_article">
                                            <li><a href="/vote/changeUserPolls/?data[{$getPoll//id}][base]=0&amp;data[{$getPoll//id}][article_id]={$getPoll//for_article/@id}">Убрать привязку к статье</a></li>
                                        </xsl:if>

                                        <li role="separator" class="divider"></li>
                                        <li>
                                            <xsl:choose>
                                                <xsl:when test="$getPoll//is_active = '1'">
                                                    <a href="/vote/changeUserPolls/?data[{$getPoll//id}][is_active]=0">Отключить опрос</a>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <a href="/vote/activate/{$getPoll//id}/">Активировать опрос</a>
                                                </xsl:otherwise>
                                            </xsl:choose>

                                        </li>
                                    </ul>
                                </div>
                            </xsl:if>

                            <xsl:choose>
                                <xsl:when test="$view_url = 'true'">
                                    <xsl:text disable-output-escaping="yes">&lt;</xsl:text><xsl:value-of select="$h"/><xsl:text disable-output-escaping="yes">&gt;</xsl:text>
                                    <a href="{$getPoll//link}"><xsl:value-of select="$getPoll//h1" /></a>
                                    <xsl:text> </xsl:text>
                                    <xsl:text disable-output-escaping="yes">&lt;/</xsl:text><xsl:value-of select="$h"/><xsl:text disable-output-escaping="yes">&gt;</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text disable-output-escaping="yes">&lt;</xsl:text><xsl:value-of select="$h"/><xsl:text disable-output-escaping="yes">&gt;</xsl:text>
                                    <xsl:value-of select="$getPoll//h1" /><xsl:text> </xsl:text>
                                    <xsl:text disable-output-escaping="yes">&lt;/</xsl:text><xsl:value-of select="$h"/><xsl:text disable-output-escaping="yes">&gt;</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                            <span class="label-poll">Опрос</span>
                        </div>

                        <xsl:if test="$getPoll//anons != ''">
                            <div class="anons">
                                <xsl:value-of select="$getPoll//anons" disable-output-escaping="yes" />
                            </div>
                        </xsl:if>

                        <div class="poll_navbar"><span>Раздел: </span>
                            <xsl:apply-templates select="$getPoll//categories//item" mode="poll_categories" />
                            <span class="date"><xsl:value-of select="$getPoll//date/@formatted-date" /></span>
                        </div>

                        <xsl:if test="$getPoll//images//td[@src]">
                            <div class="image">
                                <table width="100%">
                                    <colgroup>
                                        <col style="width: 25%" />
                                        <col style="width: 25%" />
                                        <col style="width: 25%" />
                                        <col style="width: 25%" />
                                    </colgroup>
                                    <xsl:apply-templates select="$getPoll//images//tr" mode="image_tr">
                                        <xsl:with-param name="poll_id" select="$id" />
                                        <xsl:with-param name="width" select="$width" />
                                        <xsl:with-param name="popup_img">1</xsl:with-param>
                                        <xsl:with-param name="link" select="$getPoll//link" />
                                        <xsl:with-param name="alt" select="$getPoll//h1" />
                                    </xsl:apply-templates>
                                </table>
                            </div>
                        </xsl:if>
                        <div class="variants" itemtype="http://schema.org/ItemList">
                            <xsl:apply-templates select="$getPoll//variants//item" mode="poll_variants">
                                <xsl:with-param name="pollId" select="$id" />
                                <xsl:with-param name="preview" select="$getPoll//preview" />
                                <xsl:with-param name="selected" select="$getPoll//variants//item[@selected = '1']" />
                                <xsl:with-param name="total_votes" select="$getPoll//variants/@total_votes" />
                                <xsl:with-param name="max_length" select="$getPoll//variants/@max_length" />
                                <xsl:with-param name="time_vote" select="$getPoll//time_vote" />
                                <xsl:with-param name="repeat_vote" select="$getPoll//repeat_vote" />
                                <xsl:with-param name="type" select="$type" />
                                <xsl:with-param name="schema_org">true</xsl:with-param>
                            </xsl:apply-templates>
                        </div>
                        <xsl:choose>
                            <xsl:when test="not($getPoll//variants//item[@selected])">
                                <xsl:if test="$getPoll//preview != '1'"><div class="warning"><span class="glyphicon glyphicon-info-sign"></span> Результат можно увидеть после голосования</div></xsl:if>
                                <xsl:call-template name="votePollButton">
                                    <xsl:with-param name="getPoll" select="$getPoll" />
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="($getPoll//time_vote != '') and ($getPoll//repeat_vote != '0')">
                                <div class="warning"><span class="glyphicon glyphicon-info-sign"></span> До следующего голосования - <xsl:value-of select="$getPoll//repeat_vote" /></div>
                            </xsl:when>
                            <xsl:when test="($getPoll//time_vote != '') and ($getPoll//repeat_vote = '0')">
                                <xsl:call-template name="votePollButton">
                                    <xsl:with-param name="getPoll" select="$getPoll" />
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="$view_url = 'true'">
                            <a class="detail" href="{$getPoll//link}" title="Подробнее: {$getPoll//h1}"><span class="detail"> Подробнее <span class="glyphicon glyphicon-share-alt"></span><span class="right">Результаты на карте</span></span></a>
                        </xsl:if>
                    </form>
                </div>
            </xsl:when>

            <xsl:when test="$type = 'medium'">
                <xsl:variable name="width">588</xsl:variable>
                <xsl:variable name="is_active">
                    <xsl:choose>
                        <xsl:when test="$getPoll//is_active = '1'">
                            <xsl:text></xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>disabled</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>

                <div class="poll {$type} poll{$id} shadow" data-id="{$id}" data-multiple="{$getPoll//multiple}" data-type="poll">

                    <xsl:variable name="link">
                        <xsl:choose>
                            <xsl:when test="$getPoll//is_active = '1'">
                                <xsl:value-of select="$getPoll//link" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>/vote/preview/</xsl:text><xsl:value-of select="$id" /><xsl:text></xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>

                    <xsl:if test="$is_active = 'disabled'">
                        <a href="{$link}"><div class="disabled"></div></a>
                    </xsl:if>
                    <form>
                        <input type="hidden" name="data[params][type]" value="{$type}" />
                        <input type="hidden" name="data[params][view_url]" value="{$view_url}" />
                        <input type="hidden" name="data[id]" value="{$id}" />

                        <xsl:if test="$getPoll//for_article">
                            <div class="for_article">
                                <xsl:text disable-output-escaping="yes">&lt;</xsl:text>!--noindex--<xsl:text disable-output-escaping="yes">&gt;</xsl:text>
                                    <!--<a class="article_title" href="{$getPoll//for_article//link}"><xsl:value-of select="$getPoll//for_article//title" /></a>-->
                                    <a class="article_title" href="{$link}"><xsl:value-of select="$getPoll//for_article//title" /></a>

                                    <span class="label label-{$getPoll//for_article/type/@class}"><xsl:value-of select="$getPoll//for_article/type/@name" /></span>
                                    <div class="cl"></div>

                                    <xsl:if test="$getPoll//for_article//source/name != ''">
                                        <div class="info">
                                            <span class="date"><xsl:value-of select="$getPoll//for_article//date/@formatted-date" /></span>
                                            <span class="source">Источник: <span><a href="{$getPoll//for_article//source/url}" target="_blank"><xsl:value-of select="$getPoll//for_article//source/name" /></a></span></span>
                                        </div>
                                    </xsl:if>

                                    <xsl:if test="$getPoll//for_article//img != ''">
                                        <a href="{$getPoll//for_article//link}">
                                            <xsl:apply-templates select="document(concat('udata://system/makeThumbnailFull/(.', $getPoll//for_article//img, ')/200/auto/void/0/1/5/0/80/'))/udata" mode="image">
                                                <xsl:with-param name="alt" select="$getPoll//for_article//title" />
                                            </xsl:apply-templates>
                                        </a>
                                    </xsl:if>
                                    <div class="anons content_cut" data-cut-id="article_{$getPoll//for_article/@id}" data-cut-height="90">
                                        <xsl:value-of select="$getPoll//for_article//content" disable-output-escaping="yes" />
                                    </div>
                                    <a href="#" class="open_cut hide" data-for-cut="article_{$getPoll//for_article/@id}">Читать дальше</a>
                                <xsl:text disable-output-escaping="yes">&lt;</xsl:text>!--/noindex--<xsl:text disable-output-escaping="yes">&gt;</xsl:text>
                            </div>
                        </xsl:if>

                        <div class="cl"></div>

                        <div class="dropdown settings_item">
                            <a href="#" class="dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false"><span class="glyphicon glyphicon-triangle-bottom"></span></a>
                            <ul class="dropdown-menu dropdown-menu-right"
                                data-tooltips-id="{$tooltips//item[@id='2']/@id}"
                                data-tooltips-content="{$tooltips//item[@id='2']/@content}"
                                data-tooltips-pos="{$tooltips//item[@id='2']/@pos}"
                            >
                                <li><a href="#" onclick="GM.Events.NewPoll.PollCreateFromTemplate({$getPoll//id})">Создать похожий опрос</a></li>
                            </ul>
                        </div>

                        <div class="theme" title="{$getPoll//h1}">
                            <xsl:choose>
                                <xsl:when test="$view_url = 'true'">
                                    <a href="{$link}">
                                        <xsl:text disable-output-escaping="yes">&lt;</xsl:text><xsl:value-of select="$h"/><xsl:text disable-output-escaping="yes">&gt;</xsl:text>
                                        <xsl:value-of select="$getPoll//h1" />
                                        <xsl:text disable-output-escaping="yes">&lt;/</xsl:text><xsl:value-of select="$h"/><xsl:text disable-output-escaping="yes">&gt;</xsl:text>
                                    </a>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text disable-output-escaping="yes">&lt;</xsl:text><xsl:value-of select="$h"/><xsl:text disable-output-escaping="yes">&gt;</xsl:text>
                                    <xsl:value-of select="$getPoll//h1" /><xsl:text> </xsl:text><span class="label-poll">Опрос</span>
                                    <xsl:text disable-output-escaping="yes">&lt;/</xsl:text><xsl:value-of select="$h"/><xsl:text disable-output-escaping="yes">&gt;</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </div>

                        <xsl:if test="$getPoll//anons != ''">
                            <div class="anons">
                                <xsl:value-of select="$getPoll//anons" disable-output-escaping="yes" />
                            </div>
                        </xsl:if>

                        <div class="poll_navbar"><span>Раздел: </span>
                            <xsl:apply-templates select="$getPoll//categories//item" mode="poll_categories" />
                            <span class="date"><xsl:value-of select="$getPoll//date/@formatted-date" /></span>
                        </div>
                        <xsl:if test="$getPoll//images//td[@src]">
                            <div class="image">
                                <table width="100%">
                                    <colgroup>
                                        <col style="width: 25%" />
                                        <col style="width: 25%" />
                                        <col style="width: 25%" />
                                        <col style="width: 25%" />
                                    </colgroup>
                                    <xsl:apply-templates select="$getPoll//images//tr" mode="image_tr">
                                        <xsl:with-param name="poll_id" select="$id" />
                                        <xsl:with-param name="width" select="$width" />
                                        <xsl:with-param name="popup_img">0</xsl:with-param>
                                        <xsl:with-param name="link" select="$link" />
                                        <xsl:with-param name="alt" select="$getPoll//h1" />
                                    </xsl:apply-templates>
                                </table>
                            </div>
                        </xsl:if>
                        <xsl:if test="count($getPoll//infoblocks//item)">
                            <xsl:apply-templates select="$getPoll//infoblocks//item[position() = 1]" mode="poll_infoblocks_preview">
                                <xsl:with-param name="url" select="$link" />
                            </xsl:apply-templates>
                        </xsl:if>
                        <div class="variants" itemtype="http://schema.org/ItemList">
                            <xsl:apply-templates select="$getPoll//variants//item" mode="poll_variants">
                                <xsl:with-param name="pollId" select="$id" />
                                <xsl:with-param name="preview" select="$getPoll//preview" />
                                <xsl:with-param name="selected" select="$getPoll//variants//item[@selected = '1']" />
                                <xsl:with-param name="total_votes" select="$getPoll//variants/@total_votes" />
                                <xsl:with-param name="max_length" select="$getPoll//variants/@max_length" />
                                <xsl:with-param name="time_vote" select="$getPoll//time_vote" />
                                <xsl:with-param name="repeat_vote" select="$getPoll//repeat_vote" />
                                <xsl:with-param name="type" select="$type" />
                                <xsl:with-param name="schema_org">false</xsl:with-param>
                            </xsl:apply-templates>
                        </div>

                        <xsl:choose>
                            <xsl:when test="not($getPoll//variants//item[@selected])">
                                <xsl:if test="$getPoll//preview != '1'"><div class="warning"><span class="glyphicon glyphicon-info-sign"></span> Результат можно увидеть после голосования</div></xsl:if>
                                <xsl:call-template name="votePollButton">
                                    <xsl:with-param name="getPoll" select="$getPoll" />
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="($getPoll//time_vote != '') and ($getPoll//repeat_vote != '0')">
                                <div class="warning"><span class="glyphicon glyphicon-info-sign"></span> До следующего голосования - <xsl:value-of select="$getPoll//repeat_vote" /></div>
                            </xsl:when>
                            <xsl:when test="($getPoll//time_vote != '') and ($getPoll//repeat_vote = '0')">
                                <xsl:call-template name="votePollButton">
                                    <xsl:with-param name="getPoll" select="$getPoll" />
                                </xsl:call-template>
                            </xsl:when>
                        </xsl:choose>

                        <!--<xsl:if test="$getPoll/udata/user/@id = '2'">-->
                        <!--<xsl:call-template name="likes_and_share">-->
                            <!--<xsl:with-param name="obj_id" select="$getPoll//obj_id" />-->
                        <!--</xsl:call-template>-->
                        <!--</xsl:if>-->

                        <xsl:call-template name="comments">
                            <xsl:with-param name="objId" select="$getPoll//obj_id" />
                            <xsl:with-param name="per_page">2</xsl:with-param>
                            <xsl:with-param name="cut-height">55</xsl:with-param>
                        </xsl:call-template>

                        <xsl:if test="$view_url = 'true'">
                            <a class="detail" href="{$link}" title="Подробнее: {$getPoll//h1}"><span class="detail"> Подробнее <span class="glyphicon glyphicon-share-alt"></span><span class="right">Результаты на карте</span></span></a>
                        </xsl:if>
                    </form>
                </div>
            </xsl:when>

            <xsl:when test="$type = 'short'">
                <xsl:variable name="width">263</xsl:variable>
                <div class="poll {$type} poll{$id}" data-id="{$id}" data-multiple="{$getPoll//multiple}">
                    <form>
                        <input type="hidden" name="data[params][type]" value="{$type}" />
                        <input type="hidden" name="data[params][view_url]" value="{$view_url}" />
                        <input type="hidden" name="data[id]" value="{$id}" />

                        <div class="theme" title="{$getPoll//h1}">
                            <xsl:choose>
                                <xsl:when test="$view_url = 'true'"><a href="{$getPoll//link}"><xsl:value-of select="$getPoll//h1" /></a></xsl:when>
                                <xsl:otherwise>
                                    <xsl:text disable-output-escaping="yes">&lt;</xsl:text><xsl:value-of select="$h"/><xsl:text disable-output-escaping="yes">&gt;</xsl:text>
                                    <xsl:value-of select="$getPoll//h1" />
                                    <xsl:text disable-output-escaping="yes">&lt;/</xsl:text><xsl:value-of select="$h"/><xsl:text disable-output-escaping="yes">&gt;</xsl:text>
                               </xsl:otherwise>
                            </xsl:choose>
                        </div>
                        <xsl:if test="$getPoll//images//td[@src]">
                            <div class="image">
                                <table width="100%">
                                    <colgroup>
                                        <col style="width: 25%" />
                                        <col style="width: 25%" />
                                        <col style="width: 25%" />
                                        <col style="width: 25%" />
                                    </colgroup>
                                    <xsl:apply-templates select="$getPoll//images//tr" mode="image_tr">
                                        <xsl:with-param name="poll_id" select="$id" />
                                        <xsl:with-param name="width" select="$width" />
                                        <xsl:with-param name="popup_img">0</xsl:with-param>
                                        <xsl:with-param name="link" select="$getPoll//link" />
                                        <xsl:with-param name="alt" select="$getPoll//h1" />
                                    </xsl:apply-templates>
                                </table>
                            </div>
                        </xsl:if>
                        <div class="variants" itemtype="http://schema.org/ItemList">
                            <xsl:apply-templates select="$getPoll//variants//item" mode="poll_variants">
                                <xsl:with-param name="pollId" select="$id" />
                                <xsl:with-param name="preview" select="$getPoll//preview" />
                                <xsl:with-param name="selected" select="$getPoll//variants//item[@selected = '1']" />
                                <xsl:with-param name="total_votes" select="$getPoll//variants/@total_votes" />
                                <xsl:with-param name="max_length" select="$getPoll//variants/@max_length" />
                                <xsl:with-param name="time_vote" select="$getPoll//time_vote" />
                                <xsl:with-param name="repeat_vote" select="$getPoll//repeat_vote" />
                                <xsl:with-param name="type" select="$type" />
                                <xsl:with-param name="schema_org">false</xsl:with-param>
                            </xsl:apply-templates>
                        </div>
                        <xsl:choose>
                            <xsl:when test="not($getPoll//variants//item[@selected])">
                                <xsl:if test="$getPoll//preview != '1'"><div class="warning"><span class="glyphicon glyphicon-info-sign"></span> Результат можно увидеть после голосования</div></xsl:if>
                                <xsl:call-template name="votePollButton">
                                    <xsl:with-param name="getPoll" select="$getPoll" />
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="($getPoll//time_vote != '') and ($getPoll//repeat_vote != '0')">
                                <div class="warning"><span class="glyphicon glyphicon-info-sign"></span> До следующего голосования - <xsl:value-of select="$getPoll//repeat_vote" /></div>
                            </xsl:when>
                            <xsl:when test="($getPoll//time_vote != '') and ($getPoll//repeat_vote = '0')">
                                <xsl:call-template name="votePollButton">
                                    <xsl:with-param name="getPoll" select="$getPoll" />
                                </xsl:call-template>
                            </xsl:when>
                        </xsl:choose>
                    </form>
                </div>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="item" mode="poll_variants">
        <xsl:param name="pollId" />
        <xsl:param name="preview" />
        <xsl:param name="selected" />
        <xsl:param name="total_votes" />
        <xsl:param name="max_length" />
        <xsl:param name="time_vote" />
        <xsl:param name="repeat_vote"  />
        <xsl:param name="type" />
        <xsl:param name="schema_org">true</xsl:param>
        <div class="item" onclick="GM.View.Poll.PollSelectVariant($(this));">
            <xsl:if test="$schema_org = 'true'">
                <xsl:attribute name="itemprop">itemListElement</xsl:attribute>
                <xsl:attribute name="itemscope">itemscope</xsl:attribute>
                <xsl:attribute name="itemtype">http://schema.org/ListItem</xsl:attribute>
            </xsl:if>
            <span class="layer"></span>
            <xsl:choose>
                <xsl:when test="($time_vote != '') and ($repeat_vote = '0')">
                    <input name="data[variant][{@id}]" type="checkbox" value="1" />
                </xsl:when>
                <xsl:when test="count($selected) &gt; 0">
                    <xsl:if test="@selected = '1'">
                        <!--<span class="glyphicon glyphicon-ok voted"></span>-->
                        <!--<span class="user_vote">(ваш голос)</span>-->
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <input name="data[variant][{@id}]" type="checkbox" value="1" />
                </xsl:otherwise>
            </xsl:choose>
            <label itemprop="description">
                <xsl:if test="$schema_org = 'true'">
                    <xsl:attribute name="itemprop">description</xsl:attribute>
                </xsl:if>
                <xsl:value-of select=".//variant" />
            </label>
            <xsl:if test="($total_votes != 0) and ((($preview = '1') and (count($selected) = 0)) or (count($selected) &gt; 0))">
                <table width="100%">
                    <tr>
                        <td>
                            <div class="percent_bar"><span class="percent_bar" style="width:{@perc_scale}%"></span></div>
                        </td>
                        <td class="width_voices width_voices_{$max_length}">
                            <div class="voices"><span class="perc_value"><xsl:value-of select="@perc_number"/>%</span>(<xsl:value-of select="@votes" />)</div>
                        </td>
                        <xsl:if test="$type = 'standart'">
                            <td width="20">
                                <span class="googleMapSelect active" data-for_map="googleMapPoll{$pollId}" data-variant_id="{@id}">
                                    <input type="hidden" name="data[google_select_map][]" value="{@id}" />
                                    <span class="glyphicon glyphicon-map-marker"></span>
                                </span>
                            </td>
                        </xsl:if>
                    </tr>
                </table>
            </xsl:if>
        </div>
    </xsl:template>
    <xsl:template match="tr" mode="image_tr">
        <xsl:param name="poll_id" />
        <xsl:param name="width" />
        <xsl:param name="popup_img" select="1" />
        <xsl:param name="link" />
        <xsl:param name="alt" />
        <tr>
            <xsl:apply-templates select=".//td" mode="image_td">
                <xsl:with-param name="poll_id" select="$poll_id" />
                <xsl:with-param name="width" select="$width" />
                <xsl:with-param name="popup_img" select="$popup_img" />
                <xsl:with-param name="link" select="$link" />
                <xsl:with-param name="alt" select="$alt" />
            </xsl:apply-templates>
        </tr>
    </xsl:template>
    <xsl:template match="td" mode="image_td">
        <xsl:param name="poll_id" />
        <xsl:param name="width" />
        <xsl:param name="popup_img" />
        <xsl:param name="link" />
        <xsl:param name="alt" />
        <td colspan="{@colspan}" rowspan="{@rowspan}" valign="top">
            <xsl:choose>
                <xsl:when test="$popup_img='1'">
                    <a href="{@src}" class="popup_img" rel="poll_img_{$poll_id}" data-id="{@id}" itemscope="itemscope" itemtype="http://schema.org/ImageObject">
                        <xsl:if test="@video_type">
                            <xsl:attribute name="class">popup_img video</xsl:attribute>
                            <xsl:choose>
                                <xsl:when test="@video_type = 'y'">
                                    <xsl:attribute name="href">http://www.youtube.com/embed/<xsl:value-of select="@video_id" />?rel=0&amp;wmode=transparent&amp;autoplay=1</xsl:attribute>
                                </xsl:when>
                            </xsl:choose>
                            <span class="play_ico"></span>
                        </xsl:if>
                        <xsl:apply-templates select="document(concat('udata://system/makeThumbnail/(.', @src, ')/',floor(@colspan * ($width div 4)),'/',floor(@rowspan * ($width div 5.8)),'/void/0/3/80/'))/udata" mode="image">
                            <xsl:with-param name="alt" select="$alt" />
                            <xsl:with-param name="schema_org">true</xsl:with-param>
                        </xsl:apply-templates>
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <a href="{$link}">
                        <xsl:apply-templates select="document(concat('udata://system/makeThumbnail/(.', @src, ')/',floor(@colspan * ($width div 4)),'/',floor(@rowspan * ($width div 5.8)),'/void/0/3/80/'))/udata" mode="image">
                            <xsl:with-param name="alt" select="$alt" />
                        </xsl:apply-templates>
                    </a>
                    <xsl:if test="@video_type">
                        <a href="{$link}?preview={@id}">
                            <span class="play_ico"></span>
                        </a>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </td>
    </xsl:template>
    <xsl:template match="item" mode="poll_categories">
        <xsl:if test="@type-id = 133">
            <xsl:if test="position() != 1"> / </xsl:if>
            <a href="{@link}">
                <xsl:if test="position() = last()"><xsl:attribute name="class">last</xsl:attribute></xsl:if>
                <xsl:value-of select=".//." disable-output-escaping="yes" />
            </a>
        </xsl:if>
    </xsl:template>

    <xsl:template match="result[@module='vote'][@method='poll']">
        <xsl:call-template name="header" />
        <xsl:call-template name="panel" />
        <xsl:call-template name="panel_info" />

        <xsl:call-template name="view_poll">
            <xsl:with-param name="id" select="$document-page-id" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="result[@module='vote'][@method='preview']">
        <xsl:call-template name="header" />
        <xsl:call-template name="panel" />
        <xsl:call-template name="panel_info" />

        <div class="set_info alert alert-warning hide shadow" role="alert">
            <xsl:if test=".//is_active = '0'">
                <form action="/vote/activate/{.//id}" method="get">
                    <p>Опрос неактивный. Для активации нажмите кнопку или перейдите в раздел кабинета <a href="/cabinet/polls/">Мои опросы</a>.</p>
                    <p><button type="submit" class="btn btn-success btn-sm">Активировать</button></p>
                </form>
            </xsl:if>
        </div>

        <xsl:call-template name="view_poll">
            <xsl:with-param name="id" select=".//id" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="view_poll">
        <xsl:param name="id" />
        <xsl:variable name="getPoll" select="document(concat('udata://vote/getPoll/',$id))" />

        <div id="view_poll" class="shift_right">
            <div class="shell">
                <div class="content shadow">
                    <xsl:if test="count($getPoll//feeds/item)">
                        <div class="breadcrumbs">
                            <a href="{$getPoll//feeds/item/@link}"><span class="glyphicon glyphicon-chevron-left"></span> Лента «<xsl:value-of select="$getPoll//feeds/item" />»</a>
                        </div>
                    </xsl:if>

                    <xsl:if test="$getPoll//for_article">
                        <div class="for_article">
                            <div class="theme">
                                <xsl:if test="(($getPoll//user/@id  = '2') and ($getPoll//user/@auth = '1')) or (($getPoll//user/@auth = '1') and ($getPoll//user/@id = $getPoll//for_article//article_user))">
                                    <div class="dropdown settings_item">
                                        <button type="button" class="btn btn-default btn-white btn-xs dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                            <span class="glyphicon glyphicon-wrench"></span>&nbsp;&nbsp;<span class="caret"></span>
                                        </button>
                                        <ul class="dropdown-menu">
                                            <li><a href="/content/edit_article/{$getPoll//for_article/@id}">Изменить статью</a></li>
                                            <li role="separator" class="divider"></li>
                                            <li>
                                                <xsl:choose>
                                                    <xsl:when test="$getPoll//is_active = '1'">
                                                        <a href="/content/changeUserArticles/?data[{$getPoll//for_article/@id}][is_active]=0">Отключить статью</a>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <a href="/content/activate/{$getPoll//for_article/@id}/">Активировать статью</a>
                                                    </xsl:otherwise>
                                                </xsl:choose>

                                            </li>
                                        </ul>
                                    </div>
                                </xsl:if>


                                <h2>
                                    <!--<a href="{$getPoll//for_article//link}">-->
                                    <xsl:value-of select="$getPoll//for_article//title" />
                                    <!--</a>-->
                                </h2>
                                <xsl:text> </xsl:text><span class="label-{$getPoll//for_article/type/@class}"><xsl:value-of select="$getPoll//for_article/type/@name" /></span>
                            </div>
                            <div class="info">
                                <span class="date"><xsl:value-of select="$getPoll//for_article//date/@formatted-date" /></span>
                                <xsl:if test="$getPoll//for_article//source/name != ''">
                                    <span class="source">Источник: <span><a href="{$getPoll//for_article//source/url}" target="_blank"><xsl:value-of select="$getPoll//for_article//source/name" /></a></span></span>
                                </xsl:if>
                            </div>
                            <div class="cl"></div>
                            <div class="for_article_content">
                                <!--<div class="content_cut" data-cut-id="1" data-cut-height="100" style="height:100px;">-->
                                <div class="">
                                    <xsl:if test="$getPoll//for_article//img != ''">
                                        <!--<xsl:attribute name="data-cut-height">285</xsl:attribute>-->
                                        <!--<xsl:attribute name="style">height:285px;</xsl:attribute>-->
                                        <a href="{$getPoll//for_article//img}" class="popup_img" rel="article_img_{$getPoll//for_article/@id}">
                                            <xsl:apply-templates select="document(concat('udata://system/makeThumbnailFull/(.', $getPoll//for_article//img, ')/300/200/void/0/1/5/0/80/'))/udata" mode="image">
                                                <xsl:with-param name="alt" select="$getPoll//for_article/title" />
                                            </xsl:apply-templates>
                                        </a>
                                    </xsl:if>
                                    <xsl:value-of select="$getPoll//for_article//content" disable-output-escaping="yes" />
                                </div>
                                <a href="#" class="open_cut hide" data-for-cut="1"><span class="glyphicon glyphicon-chevron-down"></span>См. полностью</a>
                            </div>
                            <a href="/vote/create_poll/?fn={$getPoll//for_article/@id}"><button type="button" class="btn btn-primary btn-sm">Создать опрос по теме</button></a>



                            <xsl:if test="$user-id != '337'">
                                <xsl:variable name="getListVotesOfUser" select="document('udata://vote/getListVotesOfUser/100000/name')" />
                                <xsl:if test="count($getListVotesOfUser//item)">
                                    <button type="button" class="btn btn-primary btn-sm poll_attach" data-toggle="modal" data-target="#poll_attach">Прикрепить опрос</button>
                                    <div class="modal fade" id="poll_attach" tabindex="-1" aria-hidden="true">
                                        <div class="modal-dialog">
                                            <form method="POST" action="/vote/attachPollToArticle/">
                                                <input type="hidden" name="article_id" value="{$getPoll//for_article/@id}" />
                                                <div class="modal-content">
                                                    <div class="modal-header bg">
                                                        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span class="glyphicon glyphicon-remove" aria-hidden="true"></span></button>
                                                        <h4 class="modal-title">Прикрепить опрос</h4>
                                                    </div>
                                                    <div class="modal-body">
                                                        <div class="form-group">
                                                            <xsl:apply-templates select="$getListVotesOfUser//item" mode="getListVotesRadio" />
                                                        </div>
                                                    </div>
                                                    <div class="modal-footer">
                                                        <button type="button" class="btn btn-default btn-sm" data-dismiss="modal">Закрыть</button>
                                                        <button type="submit" class="btn btn-primary btn-sm apply btn-preloader"><img src="/templates/iview/images/preloader.gif" /><span>Прикрепить</span></button>
                                                    </div>
                                                </div>
                                            </form>
                                        </div>
                                    </div>
                                </xsl:if>
                            </xsl:if>
                        </div>
                        <hr/>
                    </xsl:if>

                    <xsl:call-template name="poll">
                        <xsl:with-param name="id" select="$id" />
                        <xsl:with-param name="view_url">false</xsl:with-param>
                        <xsl:with-param name="type">standart</xsl:with-param>
                        <xsl:with-param name="getPoll" select="$getPoll" />
                        <xsl:with-param name="h">h1</xsl:with-param>
                    </xsl:call-template>
                    <xsl:if test="$getPoll//property[@name='content']/value">
                        <div class="content_poll">
                            <xsl:value-of select="$getPoll//property[@name='content']/value" disable-output-escaping="yes" />
                        </div>
                    </xsl:if>

                    <div class="cl"></div>

                    <div class="title_block">
                        <div>Результаты опроса на карте</div>
                        <span class="right_text">Карта переключается кнопками <span class="glyphicon glyphicon-map-marker"></span></span>
                    </div>
                    <div class="googleMap">
                        <div id="googleMapPoll{$id}" data-pollId="{$id}">
                        </div>
                        <span class="googleMapZoomOut hide glyphicon glyphicon-zoom-out" data-for_map="googleMapPoll{$id}"></span>
                    </div>

                    <div class="alert alert-default" role="alert">
                        <div class="slidedown_title" data-for-content="587"><img class="img_20" src="{$template-resources}images/poll/poll.png" /><xsl:text> </xsl:text><xsl:value-of select="$settings//property[@name='title_how_use_map']/value" disable-output-escaping="yes" /><span class="caret"></span></div>
                        <div class="slidedown_content hide" data-id="587"><xsl:value-of select="$settings//property[@name='how_use_map']/value" disable-output-escaping="yes" /></div>
                    </div>

                    <xsl:if test="count($getPoll//rating_pages//rating)">
                        <div class="title_block">
                            <div>Рейтинги</div>
                        </div>

                        <xsl:apply-templates select="$getPoll//rating_pages//rating" mode="poll_impact_rating" />

                        <div class="cl"></div>
                    </xsl:if>

                    <div class="cl"></div>
                    <!--<xsl:if test="$getPoll//for_article">-->
                        <!--<div class="title_block">-->
                            <!--<div>Опрос создан на основе <xsl:value-of select="$getPoll//for_article/type/@rp" /></div>-->
                        <!--</div>-->
                    <!--</xsl:if>-->
                    <hr/>

                    <xsl:if test="count($getPoll//infoblocks_colors//item)">
                        <style>
                            <xsl:apply-templates select="$getPoll//infoblocks_colors//item" mode="poll_infoblocks_colors" />
                        </style>
                    </xsl:if>
                    <xsl:if test="count($getPoll//infoblocks//item)">
                        <xsl:apply-templates select="$getPoll//infoblocks//item" mode="poll_infoblocks" />
                    </xsl:if>


                    <div class="title_block">
                        <div>Поделитесь опросом с друзьями в социальных сетях</div>
                    </div>
                    <div class="social-likes">
                        <div class="facebook" title="Поделиться ссылкой на Фейсбуке">Facebook</div>
                        <div class="twitter" title="Поделиться ссылкой в Твиттере">Twitter</div>
                        <div class="vkontakte" title="Поделиться ссылкой во Вконтакте">Вконтакте</div>
                        <div class="odnoklassniki" title="Поделиться ссылкой в Одноклассниках">Одноклассники</div>
                        <div class="plusone" title="Поделиться ссылкой в Гугл-плюсе">Google+</div>
                    </div>

                    <div class="cl"></div>

                    <div class="content_cut" data-cut-id="comments_cut" data-cut-height="600">
                        <xsl:call-template name="comments">
                            <xsl:with-param name="objId" select="$getPoll//obj_id" />
                            <xsl:with-param name="cut-height">145</xsl:with-param>
                        </xsl:call-template>
                    </div>
                    <a href="#" class="open_cut hide" data-for-cut="comments_cut">Читать дальше</a>


                    <!--<xsl:if test="count($getPoll//feeds//item)">
                        <div class="title_block">
                            <div>Ленты</div>
                        </div>
                    </xsl:if>

                    <xsl:apply-templates select="document(concat('udata://vote/getListFitFeeds/',$settings//property[@name='poll_page_num_feeds']/value))//feeds//feed[@id != $getPoll//feeds//item/@id]" mode="poll_list_feeds" />-->

                    <xsl:variable name="getListVotesOfCategory" select="document(concat('udata://vote/getListVotesOfCategory/',$parents//page[position() = last()]/@id,'/',$settings//property[@name='poll_page_num_poll_new']/value,'/popularity/1'))/udata/items//item" />
                    <!--<xsl:variable name="listPollsOfFeeds" select="document(concat('udata://vote/listPollsOfFeeds/',$getPoll//feeds/item/@id,'/',$settings//property[@name='poll_page_feed_polls_per_page']/value,'/popularity/',$getPoll//obj_id))" />-->

                    <!--<xsl:if test="(count($getListVotesOfCategory) &gt; 1) or (count($listPollsOfFeeds//item) &gt; 1)">-->
                    <xsl:if test="count($getListVotesOfCategory) &gt; 1">
                        <div class="title_block">
                            <div>Похожие опросы</div>
                        </div>

                        <div class="masonry hidden_block hidden_block_content" data-class-masonry="poll" data-masonry-gutter="2">
                            <!--<xsl:choose>-->
                                <!--<xsl:when test="count($listPollsOfFeeds//item) &gt; 1">-->
                                    <!--<xsl:apply-templates select="$listPollsOfFeeds//item" mode="getListVotesOnPollPage" />-->
                                <!--</xsl:when>-->
                                <!--<xsl:when test="count($getListVotesOfCategory) &gt; 1">-->
                                    <xsl:apply-templates select="$getListVotesOfCategory" mode="getListVotesOnPollPage" />
                                <!--</xsl:when>-->
                            <!--</xsl:choose>-->
                        </div>
                        <!--<xsl:if test="$listPollsOfFeeds//total &gt; $settings//property[@name='poll_page_feed_polls_per_page']/value">-->
                            <!--<div class="paginated">-->
                                <!--<a href="{$getPoll//feeds/item/@link}"><button class="btn btn-default btn-white btn-preloader"><img src="/templates/iview/images/preloader.gif" /><span>Еще</span></button></a>-->
                            <!--</div>-->
                        <!--</xsl:if>-->
                    </xsl:if>

                    <!--<div class="title_block">-->
                        <!--<div>Новые опросы</div>-->
                    <!--</div>-->
                    <!--<img class="preloader_list hidden_block" src="/templates/iview/images/preloader.gif" />-->
                    <!--<div class="masonry hidden_block hidden_block_content" data-class-masonry="poll" data-masonry-gutter="2">-->
                        <!--<xsl:apply-templates select="document(concat('udata://vote/getListVotesOfCategory/7/',$settings//property[@name='poll_page_num_poll_new']/value,'/auto/1'))/udata/items//item" mode="poll_listPollsOfFeeds" />-->
                    <!--</div>-->

                    <div class="title_block">
                        <div>Популярные рубрики</div>
                    </div>

                    <div class="row popular_categories">
                        <xsl:apply-templates select="document('udata://content/getListPopularCategories/')//catalog[position() &lt; 11]" mode="PopularCategoriesPollPage" />
                    </div>
                </div>

                <div class="sidebar shadow" itemscope="itemscope" itemtype="http://schema.org/WPSideBar">
                    <div class="sidebar_item">
                        <img class="preloader_list hidden_block" src="/templates/iview/images/preloader.gif" />
                        <div class="hidden_block hidden_block_content">
                            <xsl:text disable-output-escaping="yes">&lt;</xsl:text>!--noindex--<xsl:text disable-output-escaping="yes">&gt;</xsl:text>
                                <xsl:apply-templates select="document(concat('udata://news/getFitNews/',$getPoll//obj_id,'/',$settings//property[@name='poll_page_feed_polls_per_page']/value,'/',$settings//property[@name='poll_page_feed_per_page']/value))//part" mode="poll_fit_news" />
                            <xsl:text disable-output-escaping="yes">&lt;</xsl:text>!--/noindex--<xsl:text disable-output-escaping="yes">&gt;</xsl:text>
                        </div>
                    </div>
                </div>

                <div class="cl"></div>
                <!--<div class="info_block left">-->
                    <!--<xsl:call-template name="comments">-->
                        <!--<xsl:with-param name="objId" select="$getPoll//obj_id" />-->
                    <!--</xsl:call-template>-->
                <!--</div>-->
                <!--<div class="cl"></div>-->
            </div>

        </div>

        <!--<xsl:call-template name="home_page">
            <xsl:with-param name="enabled_popular_categories">false</xsl:with-param>
        </xsl:call-template>-->
    </xsl:template>

    <xsl:template match="rating" mode="poll_impact_rating">
        <xsl:call-template name="article">
            <xsl:with-param name="id" select="@id" />
            <xsl:with-param name="type">standart</xsl:with-param>
            <xsl:with-param name="comments">disabled</xsl:with-param>
            <xsl:with-param name="related_polls">disabled</xsl:with-param>
            <xsl:with-param name="h">h2</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="item|feed" mode="poll_list_feeds">
        <xsl:call-template name="feed_preview">
            <xsl:with-param name="id" select="@id" />
            <xsl:with-param name="per_page" select="$settings//property[@name='homepage_num_poll_in_feed']/value" />
            <xsl:with-param name="pagination">2</xsl:with-param>
            <xsl:with-param name="sort_polls">fit</xsl:with-param>
            <xsl:with-param name="desc">1</xsl:with-param>
            <xsl:with-param name="enable_link_feed">1</xsl:with-param>
            <xsl:with-param name="enable_link_create">0</xsl:with-param>
            <xsl:with-param name="h1">0</xsl:with-param>
        </xsl:call-template>




        <!--<xsl:param name="obj_id" select="0" />
        <xsl:variable name="listPollsOfFeeds" select="document(concat('udata://vote/listPollsOfFeeds/',@id,'/',$settings//property[@name='poll_page_feed_polls_per_page']/value,'/new/(',$obj_id,')'))" />
        <div class="poll_feed_item">
            <xsl:variable name="feed" select="document(concat('udata://vote/get/',@id,'/0'))" />
            <table>
                <tr>
                    <xsl:if test="$feed//photo_profile_active = '1'">
                        <td class="photo_profile">
                            <a href="{$feed//link}">
                                <xsl:apply-templates select="document(concat('udata://system/makeThumbnailFull/(.', $feed//photo_profile, ')/160/160/void/0/1/5/0/80/'))/udata" mode="feedPhotoProfile">
                                    <xsl:with-param name="width" select="160" />
                                    <xsl:with-param name="height" select="160" />
                                </xsl:apply-templates>
                            </a>
                        </td>
                    </xsl:if>
                    <td class="info">
                        <a href="{$feed//link}"><xsl:value-of select="$feed//name" /></a>
                        <hr/>
                        <div class="description"><xsl:value-of select="$feed//description" disable-output-escaping="yes" /></div>
                    </td>
                </tr>
            </table>
            <xsl:if test="count($listPollsOfFeeds//items//item)">
                <img class="preloader_list hidden_block" src="/templates/iview/images/preloader.gif" />
                <div class="poll_feeds_list masonry hidden_block hidden_block_content" data-class-masonry="poll" data-masonry-gutter="2">
                    <xsl:apply-templates select="$listPollsOfFeeds//items//item" mode="poll_listPollsOfFeeds" />
                </div>
                <div class="paginated">
                    <a href="{$feed//link}"><button class="btn btn-default btn-white btn-preloader"><img src="/templates/iview/images/preloader.gif" /><span>Еще</span></button></a>
                </div>
            </xsl:if>
        </div>-->
    </xsl:template>

    <xsl:template match="part" mode="poll_fit_news">
        <div class="title_block">
            <div><xsl:value-of select="@type" /></div>
            <span class="right_text"><xsl:value-of select="@title" /></span>
        </div>
        <xsl:apply-templates select="items//item" mode="poll_fit_new" />
    </xsl:template>

    <xsl:template match="item" mode="poll_fit_new">
        <div class="news short" data-id="{@id}" data-source="bd">
            <img src="{@image_120}" width="120" />
            <xsl:value-of select=".//title" disable-output-escaping="yes" />
        </div>
    </xsl:template>

    <xsl:template match="item" mode="poll_infoblocks">
        <div class="title_block">
            <div><xsl:value-of select=".//title" /></div>
        </div>
        <div class="infoblock">
            <div class="ib_description"><xsl:value-of select=".//description" disable-output-escaping="yes" /></div>
            <div class="image">
                <a href="{.//image}" class="popup_img">
                    <xsl:apply-templates select="document(concat('udata://system/makeThumbnailFull/(.', .//image, ')/293/auto/void/0/1/5/0/95/'))/udata" mode="image" />
                </a>
            </div>
            <div class="ib_content">
                <xsl:value-of select=".//content" disable-output-escaping="yes" />
            </div>
            <div class="cl"></div>
        </div>
    </xsl:template>
    <xsl:template match="item" mode="poll_infoblocks_colors">
        <xsl:text>.mark_color.mark_color_</xsl:text><xsl:value-of select="@id"/>
        <xsl:text>:before{background-color:#</xsl:text><xsl:value-of select="@color" /><xsl:text>;}</xsl:text>
    </xsl:template>

    <xsl:template match="item" mode="poll_infoblocks_preview">
        <xsl:param name="url" />
        <div class="title_block">
            <div><xsl:value-of select=".//title" /></div>
        </div>
        <div class="infoblock">
            <div class="image">
                <xsl:apply-templates select="document(concat('udata://system/makeThumbnailFull/(.', .//image, ')/293/auto/void/0/1/5/0/95/'))/udata" mode="image" />
            </div>
            <div class="ib_description">
                <xsl:value-of select=".//description_cut" disable-output-escaping="yes" />
                <a href="{$url}">Подробнее...</a>
            </div>
            <div class="cl"></div>

        </div>
    </xsl:template>

    <xsl:template name="votePollButton">
        <xsl:param name="getPoll" />
        <button type="button" class="btn btn-primary vote" disabled="disabled">
            <xsl:if test="($getPoll//user_reg = '1') and ($getPoll//user/@auth = '0')">
                <xsl:attribute name="data-needreg">1</xsl:attribute>
            </xsl:if>
            <span>
                Голосовать
                <xsl:if test="($getPoll//user_reg = '1') and ($getPoll//user/@auth = '0')">
                    <span class="glyphicon glyphicon-log-in"></span>
                </xsl:if>
            </span>
            <img class="preloader hide" src="/templates/iview/images/preloader.gif" />
        </button>
        <xsl:if test="$getPoll//multiple &gt; 1">
            <span class="multiple_ico">Вы можете выбрать <xsl:value-of select="$getPoll//multiple/@morph" disable-output-escaping="yes" /> ответа</span>
        </xsl:if>
    </xsl:template>

    <xsl:template match="item" mode="getListVotesOnPollPage">
        <xsl:if test="(@id != $document-page-id) or not($document-page-id)">
            <xsl:call-template name="poll">
                <xsl:with-param name="id" select="@id" />
                <xsl:with-param name="type">short</xsl:with-param>
                <xsl:with-param name="view_url">true</xsl:with-param>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xsl:template match="item" mode="getListVotesRadio">
        <div class="radio">
            <label>
                <input type="radio" name="vote_id" value="{@id}">
                    <xsl:if test="position() = 1">
                        <xsl:attribute name="checked">checked</xsl:attribute>
                    </xsl:if>
                </input>
                <xsl:value-of select=".//theme" disable-output-escaping="yes" />
            </label>
        </div>
    </xsl:template>

    <xsl:template match="catalog" mode="PopularCategoriesPollPage">
        <div class="col-lg-4 col-md-4 col-sm-6 col-xs-12">
            <a href="{@link}">
                <xsl:value-of select="@name" />
            </a>
        </div>
    </xsl:template>
</xsl:stylesheet>