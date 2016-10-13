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

    <xsl:include href="../images.xsl" />

    <xsl:template name="comments">
        <xsl:param name="objId" />
        <xsl:param name="per_page" />
        <xsl:param name="current_p">0</xsl:param>
        <xsl:param name="cut-height">56</xsl:param>

        <xsl:variable name="comments" select="document(concat('udata://content/getListComments/',$objId,'/',$per_page,'/',$current_p))" />
<!--

        <div class="comments">
            <div class="title"><div>Комментарии (<span>2</span>)</div></div>

            <div class="comment" data-page="18439" data-parent="" data-per_page="2">
                <img class="avatar" src="/images/cms/thumbs/146faa540e2a8f742fbd30325b9ed86c053c8d74/avatar_200_50_50_5_90.jpg" width="50" height="50" alt="" />
                <textarea class="form-control" placeholder="Введите текст комментария..." maxlength="10000"></textarea>
                <button type="button" class="btn btn-default btn-sm" onclick="sendComment($(this));">Комментировать</button>
                <label class="checkbox-inline anonymous"><input type="checkbox" name="anonymous" value="1" /> Анонимно</label>
                <img class="preloader hide" src="/templates/iview/images/preloader.gif" />
            </div>

            <div class="comment float" data-page="18439" data-parent="">
                <img class="avatar" src="/images/cms/thumbs/146faa540e2a8f742fbd30325b9ed86c053c8d74/avatar_200_50_50_5_90.jpg" width="50" height="50" alt="" />
                <textarea class="form-control" placeholder="Введите текст комментария..." maxlength="10000"></textarea>
                <button type="button" class="btn btn-default btn-sm" onclick="sendComment($(this));">Комментировать</button>
                <label class="checkbox-inline anonymous"><input type="checkbox" name="anonymous" value="1" /> Анонимно</label>
                <img class="preloader hide" src="/templates/iview/images/preloader.gif" />
            </div>

            <div class="comments_list">
                <div class="comment_item" itemprop="comment" itemscope="itemscope" itemtype="http://schema.org/UserComments">
                    <img class="avatar" src="/images/cms/thumbs/1f1204c38f5d7f50f0ab6bcf597ef97666ee60e8/avatar_200_50_50_5_80.jpg" width="50" height="50" alt="" />
                    <span class="name" itemprop="creator">Денис</span>
                    <span class="date">3 месяца назад</span>
                    <div class="comment_content" itemprop="commentText">
                        <div class="content_cut" data-cut-id="comment_1455" data-cut-height="55">Как по мне, так лучше собственный дом, который хорошо надо обустроить и не будет шумных соседей и всё будет тогда хорошо.</div>
                        <a href="#" class="open_cut hide" data-for-cut="comment_1455">Читать дальше</a>
                        <span class="comment_this" data-parent="1455" data-page="18439" data-per_page="2">
                            <span class="glyphicon glyphicon-pencil"></span>Ответить</span>
                        <span class="cancel_comment_this hide">
                            <span class="glyphicon glyphicon-share-alt"></span>Отменить ответ</span>
                        <div class="answer"></div>
                    </div>
                    <img class="comment_remove" src="/images/cms/admin/mac/tree/ico_del.png" onclick="comment_remove(1455);" />
                </div>

                <div class="comment_item" itemprop="comment" itemscope="itemscope" itemtype="http://schema.org/UserComments">
                    <img class="avatar" src="/images/cms/thumbs/1f1204c38f5d7f50f0ab6bcf597ef97666ee60e8/avatar_200_50_50_5_80.jpg" width="50" height="50" alt="" />
                    <span class="name" itemprop="creator">Денис</span>
                    <span class="date">3 месяца назад</span>
                    <div class="comment_content" itemprop="commentText">
                        <div class="content_cut" data-cut-id="comment_1455" data-cut-height="55">Как по мне, так лучше собственный дом, который хорошо надо обустроить и не будет шумных соседей и всё будет тогда хорошо.</div>
                        <a href="#" class="open_cut hide" data-for-cut="comment_1455">Читать дальше</a>
                        <span class="comment_this" data-parent="1455" data-page="18439" data-per_page="2">
                            <span class="glyphicon glyphicon-pencil"></span>Ответить</span>
                        <span class="cancel_comment_this hide">
                            <span class="glyphicon glyphicon-share-alt"></span>Отменить ответ</span>
                        <div class="answer"></div>
                    </div>
                    <img class="comment_remove" src="/images/cms/admin/mac/tree/ico_del.png" onclick="comment_remove(1455);" />
                </div>
            </div>
        </div>

-->


        <div class="comments">
            <div class="title">
                <div>Комментарии (<span><xsl:value-of select="$comments//total"/></span>)</div>
            </div>

            <div class="comment" data-page="{$objId}" data-parent="" data-per_page="{$comments//per_page}">
                <xsl:apply-templates select="document(concat('udata://system/makeThumbnailFull/(.', $comments//current_user/@user_photo_fragment, ')/50/50/void/0/1/5/0/80/'))/udata" mode="imageProfile">
                    <xsl:with-param name="width" select="50" />
                    <xsl:with-param name="height" select="50" />
                    <xsl:with-param name="class">avatar</xsl:with-param>
                </xsl:apply-templates>

                <xsl:if test="$comments//current_user/@id = 337">
                    <input type="text" name="name" class="form-control input-sm" placeholder="Ваше имя" maxlength="20" />
                </xsl:if>
                <textarea class="form-control" placeholder="Введите текст комментария..." maxlength="10000"></textarea>
                <button type="button" class="btn btn-default btn-sm" onclick="GM.View.Comments.SendComment($(this));">
                    <xsl:if test="$comments//current_user/@captcha">
                        <xsl:attribute name="data-captcha">1</xsl:attribute>
                    </xsl:if>
                    Комментировать
                </button>
                <xsl:if test="$comments//current_user/@id != 337">
                    <label class="checkbox-inline anonymous">
                        <input type="checkbox" name="anonymous" value="1" /> Анонимно
                    </label>
                </xsl:if>
                <img class="preloader hide" src="/templates/iview/images/preloader.gif" />
            </div>

            <div class="comment float" data-page="{$objId}" data-parent="">
                <xsl:apply-templates select="document(concat('udata://system/makeThumbnailFull/(.', $comments//current_user/@user_photo_fragment, ')/50/50/void/0/1/5/0/80/'))/udata" mode="imageProfile">
                    <xsl:with-param name="width" select="50" />
                    <xsl:with-param name="height" select="50" />
                    <xsl:with-param name="class">avatar</xsl:with-param>
                </xsl:apply-templates>
                <xsl:if test="$comments//current_user/@id = 337">
                    <input type="text" name="name" class="form-control input-sm" placeholder="Ваше имя" maxlength="20" />
                </xsl:if>
                <textarea class="form-control" placeholder="Введите текст комментария..." maxlength="10000"></textarea>
                <button type="button" class="btn btn-default btn-sm" onclick="GM.View.Comments.SendComment($(this));">
                    <xsl:if test="$comments//current_user/@captcha">
                        <xsl:attribute name="data-captcha">1</xsl:attribute>
                    </xsl:if>
                    Комментировать
                </button>
                <xsl:if test="$comments//current_user/@id != 337">
                    <label class="checkbox-inline anonymous">
                        <input type="checkbox" name="anonymous" value="1" /> Анонимно
                    </label>
                </xsl:if>
                <img class="preloader hide" src="/templates/iview/images/preloader.gif" />
            </div>

            <xsl:call-template name="comments_block">
                <xsl:with-param name="comments" select="$comments" />
                <xsl:with-param name="cut-height" select="$cut-height" />
            </xsl:call-template>
        </div>
    </xsl:template>
    <xsl:template name="comments_block">
        <xsl:param name="comments" />
        <xsl:param name="cut-height">56</xsl:param>
        <div class="comments_list">
            <xsl:apply-templates select="$comments/udata/items/item" mode="comment">
                <xsl:with-param name="comments" select="$comments" />
                <xsl:with-param name="objId" select="$comments//obj_id" />
                <xsl:with-param name="cut-height" select="$cut-height" />
            </xsl:apply-templates>
            <xsl:if test="$comments//total &gt; $comments//per_page">
                <a class="more" href="#" onclick="GM.View.Comments.GetListComments($(this),'{$comments//obj_id}','{$comments//per_page}');return false;"><span>Показать еще</span><img class="preloader hide" src="/templates/iview/images/preloader.gif" /></a>
            </xsl:if>
        </div>
    </xsl:template>

    <xsl:template match="item" mode="comment">
        <xsl:param name="comments" />
        <xsl:param name="objId" />
        <xsl:param name="cut-height">56</xsl:param>
        <xsl:param name="first_level">true</xsl:param>
        <xsl:variable name="parent" select="@parent" />
        <div class="comment_item">
            <xsl:if test="$first_level = 'true'">
                <xsl:attribute name="itemprop">comment</xsl:attribute>
                <xsl:attribute name="itemscope">itemscope</xsl:attribute>
                <xsl:attribute name="itemtype">http://schema.org/UserComments</xsl:attribute>
            </xsl:if>
            <xsl:if test="@highlight = '1'">
                <xsl:attribute name="class">comment_item highlight</xsl:attribute>
            </xsl:if>

            <xsl:variable name="photo">
                <xsl:choose>
                    <xsl:when test="@anonymous = '0'"><xsl:value-of select=".//photo" /></xsl:when>
                    <xsl:otherwise></xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

            <xsl:apply-templates select="document(concat('udata://system/makeThumbnailFull/(.', $photo, ')/50/50/void/0/1/5/0/80/'))/udata" mode="imageProfile">
                <xsl:with-param name="width" select="50" />
                <xsl:with-param name="height" select="50" />
                <xsl:with-param name="class">avatar</xsl:with-param>
            </xsl:apply-templates>

            <xsl:variable name="name">
                <xsl:choose>
                    <xsl:when test="@anonymous = '0'"><xsl:value-of select="./name" /></xsl:when>
                    <xsl:otherwise>Гость</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

            <xsl:if test="$name !=''">
                <span class="name" itemprop="creator">
                    <xsl:if test="$first_level = 'true'">
                        <xsl:attribute name="itemprop">creator</xsl:attribute>
                    </xsl:if>
                    <xsl:value-of select="$name" />
                </span>
            </xsl:if>
            <span class="date"><xsl:value-of select="@date_simple" /></span>
            <div class="comment_content">
                <xsl:if test="$first_level = 'true'">
                    <xsl:attribute name="itemprop">commentText</xsl:attribute>
                </xsl:if>
                <div class="content_cut" data-cut-id="comment_{@id}" data-cut-height="{$cut-height}">
                    <xsl:if test="@level"><span class="c_fu">+<xsl:value-of select="$comments//item[@id=$parent]/name" /></span></xsl:if>
                    <xsl:value-of select="./content" disable-output-escaping="yes" />
                </div>
                <a href="#" class="open_cut hide" data-for-cut="comment_{@id}">Читать дальше</a>

                <span class="comment_this" data-parent="{@id}" data-page="{$objId}" data-per_page="{$comments//per_page}"><span class="glyphicon glyphicon-pencil"></span>Ответить</span>
                <span class="cancel_comment_this hide"><span class="glyphicon glyphicon-share-alt"></span>Отменить ответ</span>
                <div class="answer"></div>
                <xsl:if test="count(./items/item)">
                    <!--<xsl:choose>
                        <xsl:when test="count(.//item) &gt; 10">
                            <a href="#" class="open_comments">Просмотреть все ответы (<xsl:value-of select="count(.//item)" />) <span class="glyphicon glyphicon-chevron-down"></span></a>
                            <xsl:for-each select=".//item">
                                <xsl:sort select="@date" order="ascending"/>
                                <xsl:if test="position() = last()">
                                    <xsl:apply-templates select="." mode="comment">
                                        <xsl:with-param name="comments" select=".//item" />
                                    </xsl:apply-templates>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select=".//item" mode="comment">
                                <xsl:with-param name="comments" select=".//item" />
                                <xsl:sort select="@date"/>
                            </xsl:apply-templates>
                        </xsl:otherwise>
                    </xsl:choose>-->
                    <xsl:apply-templates select="./items/item" mode="comment">
                        <xsl:with-param name="comments" select="$comments" />
                        <xsl:with-param name="objId" select="$objId" />
                        <xsl:with-param name="first_level">false</xsl:with-param>
                    </xsl:apply-templates>
                </xsl:if>
            </div>
            <xsl:if test="$comments//current_user/@id = '2'">
                <img class="comment_remove" src="/images/cms/admin/mac/tree/ico_del.png" onclick="GM.Events.Comments.CommentRemove({@id});" />
            </xsl:if>
        </div>
    </xsl:template>

    <xsl:template match="udata[@method='sendComment']">
        <div class="hide comments_amount"><xsl:value-of select="//total" /></div>
        <xsl:apply-templates select="/udata/items/item" mode="comment">
            <xsl:with-param name="objId" select="//obj_id" />
            <xsl:with-param name="comments" select="." />
        </xsl:apply-templates>
        <xsl:if test=".//total &gt; .//per_page">
            <a class="more" href="#" onclick="GM.View.Comments.GetListComments($(this),'{.//obj_id}','{.//per_page}');return false;"><span>Показать еще</span><img class="preloader hide" src="/templates/iview/images/preloader.gif" /></a>
        </xsl:if>
    </xsl:template>

    <xsl:template match="udata[@method='getListComments']">
        <div class="hide comments_amount"><xsl:value-of select="//total" /></div>
        <xsl:apply-templates select="/udata/items/item" mode="comment">
            <xsl:with-param name="objId" select="//obj_id" />
            <xsl:with-param name="comments" select="." />
        </xsl:apply-templates>
        <xsl:if test=".//total &gt; .//per_page">
            <a class="more" href="#" onclick="GM.View.Comments.GetListComments($(this),'{.//obj_id}','{.//per_page}');return false;"><span>Показать еще</span><img class="preloader hide" src="/templates/iview/images/preloader.gif" /></a>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>