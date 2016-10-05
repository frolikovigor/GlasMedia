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
                xmlns:Xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:template match="result[page/@type-id='153']
                        |result[page/@type-id='154']
                        |result[page/@type-id='157']">
        <xsl:call-template name="header" />
        <xsl:call-template name="panel" />
        <xsl:call-template name="panel_info" />

        <xsl:variable name="getArticle" select="document(concat('udata://content/getArticle/',$document-page-id))" />

        <div id="view_article" class="shift_right article_{$getArticle//field[@name='_type']/value/@class}">
            <div class="shell">
                <div class="content">
                    <xsl:call-template name="article">
                        <xsl:with-param name="id" select="$document-page-id" />
                        <xsl:with-param name="type">standart</xsl:with-param>
                    </xsl:call-template>
                </div>

                <div class="sidebar">
                    <div class="sidebar_item">
                        <img class="preloader_list hidden_block" src="/templates/iview/images/preloader.gif" />
                        <div class="hidden_block hidden_block_content">
                            <xsl:apply-templates select="document(concat('udata://news/getFitNews/',$getArticle//obj_id,'/',$settings//property[@name='poll_page_feed_polls_per_page']/value,'/',$settings//property[@name='poll_page_feed_per_page']/value))//part" mode="article_fit_news" />
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </xsl:template>

    <xsl:template match="result[@module='content'][@method='preview']">
        <!--<xsl:if test="not(//field[@name='_id']/value)">-->
            <!--<xsl:value-of select="document('udata://content/articleError/')" />-->
        <!--</xsl:if>-->
        <xsl:call-template name="header" />
        <xsl:call-template name="panel" />
        <xsl:call-template name="panel_info" />

        <xsl:if test="//_is_active = '0'">
            <div class="set_info alert alert-warning hide" role="alert">

                <form action="/content/activate/{//_id}" method="get">
                    <p>Статья неактивна. Для активации нажмите кнопку или перейдите в раздел кабинета <a href="/cabinet/articles/">Мои статьи</a>.</p>
                    <p><button type="submit" class="btn btn-success btn-sm">Активировать</button></p>
                </form>
            </div>
        </xsl:if>

        <div id="view_article" class="shift_right article_{//_type/value/@class}">
            <div class="shell">
                <div class="content">
                    <xsl:call-template name="article">
                        <xsl:with-param name="id" select="//_id" />
                        <xsl:with-param name="type">standart</xsl:with-param>
                    </xsl:call-template>
                </div>

                <div class="sidebar">
                </div>
            </div>
        </div>

    </xsl:template>

    <xsl:template name="article">
        <xsl:param name="id" />
        <xsl:param name="type">standart</xsl:param>
        <xsl:param name="comments">enabled</xsl:param>
        <xsl:param name="related_polls">enabled</xsl:param>
        <xsl:param name="h">h1</xsl:param>

        <xsl:variable name="getArticle" select="document(concat('udata://content/getArticle/',$id))" />

        <xsl:variable name="is_active">
            <xsl:choose>
                <xsl:when test="$getArticle//field[@name='_is_active']/value = '1'">
                    <xsl:text></xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>disabled</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="link">
            <xsl:choose>
                <xsl:when test="$getArticle//field[@name='_is_active']/value = '1'">
                    <xsl:value-of select="$getArticle//field[@name='_link']/value" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>/content/preview/</xsl:text><xsl:value-of select="$id" /><xsl:text>/</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="$type = 'standart'">
                <xsl:choose>
                    <!-- Статья standart -->
                    <xsl:when test="$getArticle//field[@name='_type']/value/@id = '153'">
                        <div class="article {$type} article{$id} {$is_active}" data-id="{$id}">
                            <div class="theme">
                                <xsl:if test="(($getArticle//field[@name='_current_user']/@id  = '2') and ($getArticle//field[@name='_current_user']/@auth = '1')) or (($getArticle//field[@name='_current_user']/@auth = '1') and ($getArticle//field[@name='_current_user']/@id = $getArticle//field[@name='_article_user']/value))">
                                    <div class="dropdown settings_item">
                                        <button type="button" class="btn btn-default btn-white btn-xs dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                            <span class="glyphicon glyphicon-wrench"></span>&nbsp;&nbsp;<span class="caret"></span>
                                        </button>
                                        <ul class="dropdown-menu">
                                            <li><a href="/content/edit_article/{$id}">Изменить статью</a></li>
                                            <li role="separator" class="divider"></li>
                                            <li>
                                                <xsl:choose>
                                                    <xsl:when test="$getArticle//field[@name='_is_active']/value = '1'">
                                                        <a href="/content/changeUserArticles/?data[{$id}][is_active]=0">Отключить статью</a>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <a href="/content/activate/{$id}/">Активировать статью</a>
                                                    </xsl:otherwise>
                                                </xsl:choose>

                                            </li>
                                        </ul>
                                    </div>
                                </xsl:if>

                                <xsl:text disable-output-escaping="yes">&lt;</xsl:text><xsl:value-of select="$h" /><xsl:text disable-output-escaping="yes">&gt;</xsl:text>
                                    <xsl:value-of select="$getArticle//field[@name='h1']/value" disable-output-escaping="yes" />
                                    <xsl:text> </xsl:text><span class="label-{$getArticle//field[@name='_type']/value/@class}"><xsl:value-of select="$getArticle//field[@name='_type']/value/@name" /></span>
                                <xsl:text disable-output-escaping="yes">&lt;/</xsl:text><xsl:value-of select="$h" /><xsl:text disable-output-escaping="yes">&gt;</xsl:text>
                            </div>

                            <div class="article_navbar"><span>Раздел: </span>
                                <xsl:apply-templates select="$getArticle//field[@name='_categories']//item" mode="article_categories" />
                                <xsl:if test="$getArticle//field[@name='source_url']/value != ''">
                                    <span class="source">Источник:
                                        <span><a href="{$getArticle//field[@name='source_url']/value}" target="_blank">
                                            <xsl:value-of select="$getArticle//field[@name='source_title']/value" /></a>
                                        </span>
                                    </span>
                                </xsl:if>
                                <span class="date"><xsl:value-of select="$getArticle//field[@name='date']/value/@formatted-date" /></span>
                            </div>
                            <div class="article_content">
                                <xsl:if test="$getArticle//field[@name='img']/value != ''">
                                    <a href="{$getArticle//field[@name='img']/value}" class="popup_img" rel="article_img_{$id}">
                                        <xsl:apply-templates select="document(concat('udata://system/makeThumbnailFull/(.', $getArticle//field[@name='img']/value, ')/300/auto/void/0/1/5/0/80/'))/udata" mode="image" />
                                    </a>
                                </xsl:if>
                                <xsl:value-of select="$getArticle//field[@name='content']/value" disable-output-escaping="yes" />
                                <xsl:value-of select="$getArticle//field[@name='article']/value" disable-output-escaping="yes" />
                            </div>
                            <div class="cl"></div>

                            <xsl:if test="$related_polls = 'enabled'">
                                <div class="title_block">
                                    <div>Опросы по теме</div>
                                </div>
                                <xsl:if test="count($getArticle//field[@name='_polls']/value//item)">
                                    <div class="article_polls">
                                        <xsl:apply-templates select="$getArticle//field[@name='_polls']/value//item" mode="article_polls" />
                                    </div>
                                </xsl:if>
                                <a href="/vote/create_poll/?fn={$id}"><button type="button" class="btn btn-primary btn-sm">Создать опрос по теме</button></a>
                            </xsl:if>

                            <!--<xsl:if test="count($getArticle//field[@name='ratings']/value//item)">
                                <div class="title_block">
                                    <div>Рейтинг</div>
                                </div>
                                <div style="font-size:14px;"></div>
                            </xsl:if>-->
                            <xsl:if test="$comments = 'enabled'">
                                <xsl:call-template name="comments">
                                    <xsl:with-param name="objId" select="$getArticle//field[@name='_obj_id']/value" />
                                </xsl:call-template>
                            </xsl:if>
                        </div>
                    </xsl:when>

                    <!-- Новость standart -->
                    <xsl:when test="$getArticle//field[@name='_type']/value/@id = '154'">
                        <div class="article {$type} article{$id} {$is_active}" data-id="{$id}">
                            <div class="theme">
                                <xsl:if test="(($getArticle//field[@name='_current_user']/@id  = '2') and ($getArticle//field[@name='_current_user']/@auth = '1')) or (($getArticle//field[@name='_current_user']/@auth = '1') and ($getArticle//field[@name='_current_user']/@id = $getArticle//field[@name='_article_user']/value))">
                                    <div class="dropdown settings_item">
                                        <button type="button" class="btn btn-default btn-white btn-xs dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                            <span class="glyphicon glyphicon-wrench"></span>&nbsp;&nbsp;<span class="caret"></span>
                                        </button>
                                        <ul class="dropdown-menu">
                                            <li><a href="/content/edit_article/{$id}">Изменить статью</a></li>
                                            <li role="separator" class="divider"></li>
                                            <li>
                                                <xsl:choose>
                                                    <xsl:when test="$getArticle//field[@name='_is_active']/value = '1'">
                                                        <a href="/content/changeUserArticles/?data[{$id}][is_active]=0">Отключить статью</a>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <a href="/content/activate/{$id}/">Активировать статью</a>
                                                    </xsl:otherwise>
                                                </xsl:choose>

                                            </li>
                                        </ul>
                                    </div>
                                </xsl:if>

                                <xsl:text disable-output-escaping="yes">&lt;</xsl:text><xsl:value-of select="$h" /><xsl:text disable-output-escaping="yes">&gt;</xsl:text>
                                    <xsl:value-of select="$getArticle//field[@name='h1']/value" disable-output-escaping="yes" />
                                    <xsl:text> </xsl:text><span class="label-{$getArticle//field[@name='_type']/value/@class}"><xsl:value-of select="$getArticle//field[@name='_type']/value/@name" /></span>
                                <xsl:text disable-output-escaping="yes">&lt;/</xsl:text><xsl:value-of select="$h" /><xsl:text disable-output-escaping="yes">&gt;</xsl:text>
                            </div>

                            <div class="article_navbar"><span>Раздел: </span>
                                <xsl:apply-templates select="$getArticle//field[@name='_categories']//item" mode="article_categories" />
                                <xsl:if test="$getArticle//field[@name='source_url']/value != ''">
                                    <span class="source">Источник:
                                        <span><a href="{$getArticle//field[@name='source_url']/value}" target="_blank">
                                            <xsl:value-of select="$getArticle//field[@name='source_title']/value" /></a>
                                        </span>
                                    </span>
                                </xsl:if>
                                <span class="date"><xsl:value-of select="$getArticle//field[@name='date']/value/@formatted-date" /></span>
                            </div>
                            <div class="article_content">
                                <xsl:if test="$getArticle//field[@name='img']/value != ''">
                                    <a href="{$getArticle//field[@name='img']/value}" class="popup_img" rel="article_img_{$id}">
                                        <xsl:apply-templates select="document(concat('udata://system/makeThumbnailFull/(.', $getArticle//field[@name='img']/value, ')/300/auto/void/0/1/5/0/80/'))/udata" mode="image" />
                                    </a>
                                </xsl:if>
                                <xsl:value-of select="$getArticle//field[@name='content']/value" disable-output-escaping="yes" />
                                <xsl:value-of select="$getArticle//field[@name='article']/value" disable-output-escaping="yes" />
                            </div>
                            <div class="cl"></div>

                            <xsl:if test="$related_polls = 'enabled'">
                                <div class="title_block">
                                    <div>Опросы по теме</div>
                                </div>
                                <xsl:if test="count($getArticle//field[@name='_polls']/value//item)">
                                    <div class="article_polls">
                                        <xsl:apply-templates select="$getArticle//field[@name='_polls']/value//item" mode="article_polls" />
                                    </div>
                                </xsl:if>
                                <a href="/vote/create_poll/?fn={$id}"><button type="button" class="btn btn-primary btn-sm">Создать опрос по теме</button></a>
                            </xsl:if>

                            <!--<xsl:if test="count($getArticle//field[@name='ratings']/value//item)">
                                <div class="title_block">
                                    <div>Рейтинг</div>
                                </div>
                                <div style="font-size:14px;"></div>
                            </xsl:if>-->
                            <xsl:if test="$comments = 'enabled'">
                                <xsl:call-template name="comments">
                                    <xsl:with-param name="objId" select="$getArticle//field[@name='_obj_id']/value" />
                                </xsl:call-template>
                            </xsl:if>
                        </div>
                    </xsl:when>

                    <!-- Фильм standart -->
                    <xsl:when test="$getArticle//field[@name='_type']/value/@id = '157'">
                        <div class="article {$type} article{$id} {$is_active}" data-id="{$id}">
                            <div class="theme">
                                <xsl:if test="(($getArticle//field[@name='_current_user']/@id  = '2') and ($getArticle//field[@name='_current_user']/@auth = '1')) or (($getArticle//field[@name='_current_user']/@auth = '1') and ($getArticle//field[@name='_current_user']/@id = $getArticle//field[@name='_article_user']/value))">
                                    <div class="dropdown settings_item">
                                        <button type="button" class="btn btn-default btn-white btn-xs dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                            <span class="glyphicon glyphicon-wrench"></span>&nbsp;&nbsp;<span class="caret"></span>
                                        </button>
                                        <ul class="dropdown-menu">
                                            <li><a href="/content/edit_article/{$id}">Изменить статью</a></li>
                                            <li role="separator" class="divider"></li>
                                            <li>
                                                <xsl:choose>
                                                    <xsl:when test="$getArticle//field[@name='_is_active']/value = '1'">
                                                        <a href="/content/changeUserArticles/?data[{$id}][is_active]=0">Отключить статью</a>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <a href="/content/activate/{$id}/">Активировать статью</a>
                                                    </xsl:otherwise>
                                                </xsl:choose>

                                            </li>
                                        </ul>
                                    </div>
                                </xsl:if>

                                <xsl:text disable-output-escaping="yes">&lt;</xsl:text><xsl:value-of select="$h" /><xsl:text disable-output-escaping="yes">&gt;</xsl:text>
                                    <xsl:value-of select="$getArticle//field[@name='h1']/value" disable-output-escaping="yes" />
                                    <xsl:text> </xsl:text><span class="label-{$getArticle//field[@name='_type']/value/@class}"><xsl:value-of select="$getArticle//field[@name='_type']/value/@name" /></span>
                                <xsl:text disable-output-escaping="yes">&lt;/</xsl:text><xsl:value-of select="$h" /><xsl:text disable-output-escaping="yes">&gt;</xsl:text>
                            </div>

                            <div class="article_navbar"><span>Раздел: </span>
                                <xsl:apply-templates select="$getArticle//field[@name='_categories']//item" mode="article_categories" />
                                <xsl:if test="$getArticle//field[@name='source_url']/value != ''">
                                    <span class="source">Источник:
                                        <span><a href="{$getArticle//field[@name='source_url']/value}" target="_blank">
                                            <xsl:value-of select="$getArticle//field[@name='source_title']/value" /></a>
                                        </span>
                                    </span>
                                </xsl:if>
                                <span class="date"><xsl:value-of select="$getArticle//field[@name='date']/value/@formatted-date" /></span>
                            </div>
                            <div class="article_content">
                                <xsl:if test="$getArticle//field[@name='poster']/value != ''">
                                    <a href="{$getArticle//field[@name='poster']/value}" class="popup_img" rel="article_img_{$id}">
                                        <xsl:apply-templates select="document(concat('udata://system/makeThumbnailFull/(.', $getArticle//field[@name='poster']/value, ')/300/auto/void/0/1/5/0/80/'))/udata" mode="image" />
                                    </a>
                                </xsl:if>
                                <div class="film_info">
                                    <ul>
                                        <xsl:if test="$getArticle//field[@name='year']/value != ''">
                                            <li><span>Год:</span><xsl:value-of select="$getArticle//field[@name='year']/value" /></li>
                                        </xsl:if>
                                        <xsl:if test="$getArticle//field[@name='country']/value != ''">
                                            <li><span>Страна:</span><xsl:value-of select="$getArticle//field[@name='country']/value" /></li>
                                        </xsl:if>
                                        <xsl:if test="$getArticle//field[@name='genre']/value != ''">
                                            <li><span>Жанр:</span><xsl:value-of select="$getArticle//field[@name='genre']/value" /></li>
                                        </xsl:if>
                                        <xsl:if test="$getArticle//field[@name='duration']/value != ''">
                                            <li><span>Время:</span><xsl:value-of select="$getArticle//field[@name='duration']/value" /></li>
                                        </xsl:if>
                                    </ul>
                                </div>
                                <xsl:value-of select="$getArticle//field[@name='content']/value" disable-output-escaping="yes" />
                                <xsl:value-of select="$getArticle//field[@name='article']/value" disable-output-escaping="yes" />
                            </div>
                            <div class="cl"></div>

                            <xsl:if test="$related_polls = 'enabled'">
                                <div class="title_block">
                                    <div>Опросы по теме</div>
                                </div>
                                <xsl:if test="count($getArticle//field[@name='_polls']/value//item)">
                                    <div class="article_polls">
                                        <xsl:apply-templates select="$getArticle//field[@name='_polls']/value//item" mode="article_polls" />
                                    </div>
                                </xsl:if>
                                <a href="/vote/create_poll/?fn={$id}"><button type="button" class="btn btn-primary btn-sm">Создать опрос по теме</button></a>
                            </xsl:if>

                            <!--<xsl:if test="count($getArticle//field[@name='ratings']/value//item)">
                                <div class="title_block">
                                    <div>Рейтинг</div>
                                </div>
                                <div style="font-size:14px;"></div>
                            </xsl:if>-->

                            <xsl:if test="$getArticle//field[@name='_trailer']/value != ''">
                                <xsl:value-of select="$getArticle//field[@name='_trailer']/value" disable-output-escaping="yes" />
                            </xsl:if>

                            <xsl:if test="$comments = 'enabled'">
                                <xsl:call-template name="comments">
                                    <xsl:with-param name="objId" select="$getArticle//field[@name='_obj_id']/value" />
                                </xsl:call-template>
                            </xsl:if>
                        </div>
                    </xsl:when>
                </xsl:choose>

                <div class="cl"></div>

            </xsl:when>

            <xsl:when test="$type = 'medium'">
                <xsl:choose>
                    <!-- Статья medium -->
                    <xsl:when test="$getArticle//field[@name='_type']/value/@id = '153'">
                        <div class="article {$type} article{$id} {$is_active} shadow" data-id="{$id}">

                            <div class="theme" title="{$getArticle//field[@name='h1']/value}">
                                <a href="{$link}"><xsl:value-of select="$getArticle//field[@name='h1']/value" /></a>
                            </div>

                            <div class="article_navbar"><span>Раздел: </span>
                                <xsl:apply-templates select="$getArticle//field[@name='_categories']//item" mode="poll_categories" />
                                <span class="date"><xsl:value-of select="$getArticle//field[@name='date']/value/@formatted-date" /></span>
                            </div>

                            <div class="article_content">
                                <xsl:if test="$getArticle//field[@name='img']/value != ''">
                                    <a href="{$link}">
                                        <xsl:apply-templates select="document(concat('udata://system/makeThumbnailFull/(.', $getArticle//field[@name='img']/value, ')/590/auto/void/0/1/5/0/80/'))/udata" mode="image" />
                                    </a>
                                </xsl:if>
                                <div class="content_cut" data-cut-id="article_{$id}" data-cut-height="90">
                                    <xsl:value-of select="$getArticle//field[@name='content']/value" disable-output-escaping="yes" />
                                    <xsl:value-of select="$getArticle//field[@name='article']/value" disable-output-escaping="yes" />
                                </div>
                                <a href="#" class="open_cut hide" data-for-cut="article_{$id}">Читать дальше</a>
                            </div>
                        </div>
                    </xsl:when>

                    <!-- Новость medium -->
                    <xsl:when test="$getArticle//field[@name='_type']/value/@id = '154'">
                        <div class="article {$type} article{$id} {$is_active} shadow" data-id="{$id}">

                            <div class="theme" title="{$getArticle//field[@name='h1']/value}">
                                <a href="{$link}"><xsl:value-of select="$getArticle//field[@name='h1']/value" /></a>
                            </div>

                            <div class="article_navbar"><span>Раздел: </span>
                                <xsl:apply-templates select="$getArticle//field[@name='_categories']//item" mode="poll_categories" />
                                <span class="date"><xsl:value-of select="$getArticle//field[@name='date']/value/@formatted-date" /></span>
                            </div>

                            <div class="article_content">
                                <xsl:if test="$getArticle//field[@name='img']/value != ''">
                                    <a href="{$link}">
                                        <xsl:apply-templates select="document(concat('udata://system/makeThumbnailFull/(.', $getArticle//field[@name='img']/value, ')/590/auto/void/0/1/5/0/80/'))/udata" mode="image" />
                                    </a>
                                </xsl:if>
                                <div class="content_cut" data-cut-id="article_{$id}" data-cut-height="90">
                                    <xsl:value-of select="$getArticle//field[@name='content']/value" disable-output-escaping="yes" />
                                    <xsl:value-of select="$getArticle//field[@name='article']/value" disable-output-escaping="yes" />
                                </div>
                                <a href="#" class="open_cut hide" data-for-cut="article_{$id}">Читать дальше</a>
                            </div>
                        </div>
                    </xsl:when>

                    <!-- Фильм medium -->
                    <xsl:when test="$getArticle//field[@name='_type']/value/@id = '157'">
                        <div class="article {$type} article{$id} {$is_active} shadow" data-id="{$id}">

                            <div class="theme" title="{$getArticle//field[@name='h1']/value}">
                                <a href="{$link}"><xsl:value-of select="$getArticle//field[@name='h1']/value" /></a>
                            </div>

                            <div class="article_navbar"><span>Раздел: </span>
                                <xsl:apply-templates select="$getArticle//field[@name='_categories']//item" mode="poll_categories" />
                                <span class="date"><xsl:value-of select="$getArticle//field[@name='date']/value/@formatted-date" /></span>
                            </div>

                            <div class="article_content">
                                <xsl:if test="$getArticle//field[@name='poster']/value != ''">
                                    <a href="{$link}">
                                        <xsl:apply-templates select="document(concat('udata://system/makeThumbnailFull/(.', $getArticle//field[@name='poster']/value, ')/590/auto/void/0/1/5/0/80/'))/udata" mode="image" />
                                    </a>
                                </xsl:if>
                                <div class="content_cut" data-cut-id="article_{$id}" data-cut-height="90">
                                    <xsl:value-of select="$getArticle//field[@name='content']/value" disable-output-escaping="yes" />
                                    <xsl:value-of select="$getArticle//field[@name='article']/value" disable-output-escaping="yes" />
                                </div>
                                <a href="#" class="open_cut hide" data-for-cut="article_{$id}">Читать дальше</a>
                            </div>
                        </div>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>


    </xsl:template>


    <xsl:template match="item" mode="article_polls">
        <a href="{@link}">
            <h2><xsl:value-of select=".//name" /></h2>
        </a>
        <xsl:text> </xsl:text>
        <span class="label-poll">Опрос</span>
    </xsl:template>

    <xsl:template match="item" mode="article_categories">
        <xsl:if test="@type-id = 133">
            <xsl:if test="position() != 1"> / </xsl:if>
            <a href="{@link}">
                <xsl:if test="position() = last()"><xsl:attribute name="class">last</xsl:attribute></xsl:if>
                <xsl:value-of select=".//." disable-output-escaping="yes" />
            </a>
        </xsl:if>
    </xsl:template>

    <xsl:template match="part" mode="article_fit_news">
        <div class="title_block">
            <div><xsl:value-of select="@type" /></div>
            <span class="right_text"><xsl:value-of select="@title" /></span>
        </div>
        <xsl:apply-templates select="items//item" mode="article_fit_new" />
    </xsl:template>

    <xsl:template match="item" mode="article_fit_new">
        <div class="news short" data-id="{@id}" data-source="bd">
            <img src="{@image_120}" width="120" />
            <xsl:value-of select=".//title" disable-output-escaping="yes" />
        </div>
    </xsl:template>

</xsl:stylesheet>