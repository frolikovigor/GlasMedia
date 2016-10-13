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

	<xsl:template name="header">
        <header itemscope="itemscope" itemtype="http://schema.org/WPHeader">
            <div class="content">
                <div class="logo"><a href="/">Glas<span>Media</span></a></div>

                <nav id="navigation">
                    <xsl:if test="$user-type != 'guest'">
                        <xsl:attribute name="class">margin</xsl:attribute>
                    </xsl:if>

                    <div class="content">
                        <span id="open_sidebar" class="glyphicon glyphicon-th-list"></span>
                        <ul>
                            <li class="first">
                                <xsl:if test="$document-page-id = $main-page-id">
                                    <xsl:attribute name="class">first active</xsl:attribute>
                                </xsl:if>
                                <a href="/">Главная</a>
                            </li>
                            <xsl:apply-templates select="document('udata://vote/xsltCache/31536000/(udata://menu/draw/3807/)')//item" mode="navigation_item" />
                            <li class="search">
                                <form id="search-results-form" method="get" action="/search/s/">
                                    <div class="input-group">
                                        <input type="text" class="form-control input-sm" name="search_string" placeholder="Поиск..." value="{//last_search_string}" />
                                        <span class="input-group-btn">
                                            <button class="btn btn-default btn-sm" type="submit"><span class="glyphicon glyphicon-search"></span></button>
                                        </span>
                                    </div>
                                    <input id="search-results-type" type="hidden" name="search_types" value="{sections//section[@selected='1']/@type-id}" />
                                </form>
                            </li>
                            <li class="all_categories" data-open="0">
                                <a href="#">Все разделы <span class="caret"></span></a>
                            </li>
                        </ul>
                        <div class="cl">&nbsp;</div>
                        <div id="all_catagories">
                            <div class="masonry js-masonry" data-class-masonry="grid-item" data-masonry-gutter="0">
                                <xsl:apply-templates select="document('udata://vote/xsltCache/31536000/(usel://uniq/1/7/133/)')//page" mode="all_catagories" />
                            </div>
                        </div>
                    </div>
                </nav>
                <xsl:choose>
                    <xsl:when test="$user-type = 'guest'">
                        <button class="btn btn-default btn-sm" id="authorization_btn" data-toggle="modal" data-target="#authorization"><span class="glyphicon glyphicon-log-in"></span><xsl:text> </xsl:text>Войти</button>
                    </xsl:when>
                    <xsl:otherwise>
                        <a class="logout" href="/users/logout/"><button class="btn btn-default btn-sm" id="authorization_btn" data-toggle="modal" data-target="#authorization"><span class="glyphicon glyphicon-log-out"></span></button></a>
                    </xsl:otherwise>
                </xsl:choose>
            </div>
        </header>
        <!-- end of header -->
	</xsl:template>

    <!-- Левая панель -->
    <xsl:template name="panel">
        <div id="left_panel" class="shadow" itemscope="itemscope" itemtype="http://schema.org/WPSideBar">
            <xsl:if test="$user-type != 'guest'">
                <ul>
                    <li><a href="/cabinet/feeds/"><span class="icon glyphicon glyphicon-th-large"></span>Мои ленты</a></li>
                    <li><a href="/cabinet/polls/"><span class="icon glyphicon glyphicon-bullhorn"></span>Мои опросы</a></li>
                    <li><a href="/cabinet/articles/"><span class="icon glyphicon glyphicon-file"></span>Мои статьи</a></li>
                    <li><a href="/cabinet/subscribe/"><span class="icon glyphicon glyphicon-bookmark"></span>Подписки</a></li>
                    <li>
                        <a href="/cabinet/profile/">
                        <span class="icon glyphicon glyphicon-user"></span>
                        <xsl:text>Мои настройки</xsl:text>
                            <xsl:variable name="badge_3259" select="$notifications//item[@menu_id='3259']" />
                            <xsl:if test="count($badge_3259)">
                                <span class="badge"><xsl:value-of select="count($badge_3259)" /></span>
                            </xsl:if>
                        </a>
                    </li>
                </ul>
                <hr/>
            </xsl:if>

            <ul>
                <li><a href="/vote/create_poll/"><span class="icon glyphicon glyphicon-edit"></span>Новый опрос</a></li>
                <li><a href="/content/create_article/"><span class="icon glyphicon glyphicon-pencil"></span>Новая статья</a></li>
                <li>
                    <a href="#" data-toggle="modal" data-target="#authorization">
                        <xsl:if test="$user-type != 'guest'">
                            <xsl:attribute name="data-target">#new_feed_modal</xsl:attribute>
                        </xsl:if>
                        <span class="icon glyphicon glyphicon-th-large"></span>Новая лента
                    </a>
                </li>
                <xsl:if test="$user-id = '2'">
                    <li>
                        <a href="#" data-toggle="modal" data-target="#authorization">
                            <xsl:if test="$user-type != 'guest'">
                                <xsl:attribute name="data-target">#new_test_modal</xsl:attribute>
                            </xsl:if>
                            <span class="icon glyphicon glyphicon-th-large"></span>Новый тест
                        </a>
                    </li>

                </xsl:if>
            </ul>
            <hr/>
            <ul>
                <li><a href="/vote/getlist/"><span class="icon glyphicon glyphicon-th"></span>Все ленты</a></li>
            </ul>
            <hr/>
            <form method="get" action="/search/s/">
                <div class="input-group">
                    <input type="text" class="form-control input-sm" name="search_string" placeholder="Поиск..." />
                    <span class="input-group-btn">
                        <button class="btn btn-default btn-sm" type="submit"><span class="glyphicon glyphicon-search"></span></button>
                    </span>
                </div>
            </form>
            <hr/>
            <ul>
                <li>
                    <a href="#"  onclick="GM.View.Feedback.Open($(this));">
                        <xsl:if test="count($captcha//url)">
                            <xsl:attribute name="data-captcha">1</xsl:attribute>
                        </xsl:if>
                        <span class="icon glyphicon glyphicon-refresh"></span>Обратная связь
                    </a>
                </li>
            </ul>

            <div class="swipe-area"></div>
        </div>
    </xsl:template>

    <xsl:template name="panel_info">
        <div id="panel_info">
            <div class="content">
            </div>
        </div>
    </xsl:template>

    <xsl:template name="likes_and_share">
        <xsl:param name="obj_id" />
        <div class="likes_and_share">
            <span class="likes"><span class="glyphicon glyphicon-thumbs-up"></span>Нравится<span class="value">12</span></span>
            <span class="dislikes"><span class="glyphicon glyphicon-thumbs-down"></span>Не нравится<span class="value">4</span></span>
            <span class="share"><span class="glyphicon glyphicon-share-alt"></span>Поделиться</span>
        </div>
    </xsl:template>

    <xsl:template match="item" mode="getListVotes">
        <xsl:param name="type">medium</xsl:param>
        <xsl:param name="view_url">true</xsl:param>
        <xsl:param name="advert">false</xsl:param>
        <xsl:param name="h">h1</xsl:param>
        <xsl:call-template name="poll">
            <xsl:with-param name="id" select="@id" />
            <xsl:with-param name="view_url" select="$view_url" />
            <xsl:with-param name="type" select="$type" />
            <xsl:with-param name="h" select="$h" />
        </xsl:call-template>
        <xsl:if test="($advert != 'false') and ($user-id != '2')">
            <xsl:if test="(position() mod $advert) = 0">
                <xsl:variable name="pos" select="position() div $advert" />
                <xsl:variable name="advert_value" select="$settings//property[@name=concat('advert_',$pos)]/value" />
                <xsl:if test="$advert_value != ''">
                    <div class="poll medium advert">
                        <xsl:value-of select="$advert_value" disable-output-escaping="yes" />
                    </div>
                </xsl:if>
            </xsl:if>
        </xsl:if>
    </xsl:template>

    <xsl:template match="article" mode="getListArticles">
        <xsl:param name="type">medium</xsl:param>
        <xsl:param name="view_url">true</xsl:param>
        <xsl:call-template name="article">
            <xsl:with-param name="id" select="@id" />
            <xsl:with-param name="view_url" select="$view_url" />
            <xsl:with-param name="type" select="$type" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="item" mode="navigation_item">
        <li>
            <xsl:choose>
                <xsl:when test="position() = last()">
                    <xsl:choose>
                        <xsl:when test="($parent-root = @id) or ($document-page-id = @id)">
                            <xsl:attribute name="class">last active</xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="class">last</xsl:attribute>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="($parent-root = @id) or ($document-page-id = @id)">
                        <xsl:attribute name="class">active</xsl:attribute>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
            <a href="{@link}"><xsl:value-of select="." /></a>
        </li>
    </xsl:template>

    <xsl:template match="item" mode="options_of_select">
        <xsl:param name="selected" />
        <option value="{@id}">
            <xsl:if test="not($selected) and (position() = 1)"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
            <xsl:if test="$selected and ($selected = @id)"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
            <xsl:value-of select="@name" disable-output-escaping="yes" />
        </option>
    </xsl:template>

    <xsl:template match="page" mode="all_catagories">
        <xsl:variable name="subcat" select="document(concat('udata://vote/xsltCache/31536000/(usel://uniq/1/',@id,'/133/)'))" />

        <div class="grid-item">
            <a href="{@link}"><h2><xsl:value-of select=".//name" /></h2></a>
            <xsl:if test="count($subcat//page)">
                <ul>
                    <xsl:apply-templates select="$subcat//page" mode="subcat" />
                </ul>
            </xsl:if>
        </div>
    </xsl:template>

    <xsl:template match="page" mode="subcat">
        <li><a href="{@link}"><h3><xsl:value-of select=".//name" /></h3></a></li>
    </xsl:template>

    <xsl:template name="filters">
        <xsl:param name="type">link</xsl:param>
        <xsl:param name="link_new" select="0" />
        <xsl:param name="link_old" select="0" />
        <xsl:param name="popularity" select="0" />
        <xsl:param name="fit" select="0" />
        <xsl:param name="unactive" select="0" />
        <xsl:choose>
            <xsl:when test="$type = 'link'">
                <div class="filters {$type}">
                    <span class="glyphicon glyphicon-sort"></span>
                    <xsl:if test="$link_new = '1'">
                        <form action="{$document-link}" onclick="$(this).submit();" method="POST">
                            <xsl:if test="($sort = 'new') or not($sort) or ($sort and ($sort!='new') and ($sort!='old') and ($sort!='popularity') and ($sort!='fit'))">
                                <xsl:attribute name="class">active</xsl:attribute>
                            </xsl:if>
                            <xsl:text>Сначала новые</xsl:text>
                            <input type="hidden" name="sort" value="new" />
                        </form>
                    </xsl:if>
                    <xsl:if test="$link_old = '1'">
                        <form action="{$document-link}" onclick="$(this).submit();" method="POST">
                            <xsl:if test="$sort = 'old'">
                                <xsl:attribute name="class">active</xsl:attribute>
                            </xsl:if>
                            <xsl:text>Сначала старые</xsl:text>
                            <input type="hidden" name="sort" value="old" />
                        </form>
                    </xsl:if>
                    <xsl:if test="$popularity = '1'">
                        <form action="{$document-link}" onclick="$(this).submit();" method="POST">
                            <xsl:if test="$sort = 'popularity'">
                                <xsl:attribute name="class">active</xsl:attribute>
                            </xsl:if>
                            <xsl:text>Популярные</xsl:text>
                            <input type="hidden" name="sort" value="popularity" />
                        </form>
                    </xsl:if>
                    <xsl:if test="$fit">
                        <form action="{$document-link}" onclick="$(this).submit();" method="POST">
                            <xsl:if test="$sort = 'fit'">
                                <xsl:attribute name="class">active</xsl:attribute>
                            </xsl:if>
                            <xsl:text>Подобранные</xsl:text>
                            <input type="hidden" name="sort" value="fit" />
                        </form>
                    </xsl:if>
                </div>
            </xsl:when>
            <xsl:when test="$type = 'relation'">
                <div class="filters {$type}">
                    <label>Сортировка:</label>
                    <div class="dropdown">
                        <button class="btn btn-default btn-white btn-xs dropdown-toggle" type="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="true">
                            <xsl:choose>
                                <xsl:when test="($sort = 'new') or not($sort) or ($sort and ($sort!='new') and ($sort!='old') and ($sort!='popularity') and ($sort!='fit') and ($sort!='unactive'))">
                                    <xsl:text>Сначала новые</xsl:text>
                                </xsl:when>
                                <xsl:when test="$sort = 'old'">
                                    <xsl:text>Сначала старые</xsl:text>
                                </xsl:when>
                                <xsl:when test="$sort = 'popularity'">
                                    <xsl:text>Популярные</xsl:text>
                                </xsl:when>
                                <xsl:when test="$sort = 'fit'">
                                    <xsl:text>Подобранные</xsl:text>
                                </xsl:when>
                            </xsl:choose>
                            <xsl:text> </xsl:text>
                            <span class="caret"></span>
                        </button>
                        <ul class="dropdown-menu">
                            <xsl:if test="$link_new = '1'">
                                <li>
                                    <xsl:if test="($sort = 'new') or not($sort) or ($sort and ($sort!='new') and ($sort!='old') and ($sort!='popularity') and ($sort!='fit') and ($sort!='unactive'))">
                                        <xsl:attribute name="class">active</xsl:attribute>
                                    </xsl:if>
                                    <form action="{$document-link}" onclick="$(this).submit();" method="POST">
                                        <xsl:text>Сначала новые</xsl:text>
                                        <input type="hidden" name="sort" value="new" />
                                    </form>
                                </li>
                            </xsl:if>
                            <xsl:if test="$link_old = '1'">
                                <li>
                                    <xsl:if test="$sort = 'old'">
                                        <xsl:attribute name="class">active</xsl:attribute>
                                    </xsl:if>
                                    <form action="{$document-link}" onclick="$(this).submit();" method="POST">
                                        <xsl:text>Сначала старые</xsl:text>
                                        <input type="hidden" name="sort" value="old" />
                                    </form>
                                </li>
                            </xsl:if>
                            <xsl:if test="$popularity = '1'">
                                <li>
                                    <xsl:if test="$sort = 'popularity'">
                                        <xsl:attribute name="class">active</xsl:attribute>
                                    </xsl:if>
                                    <form action="{$document-link}" onclick="$(this).submit();" method="POST">
                                        <xsl:text>Популярные</xsl:text>
                                        <input type="hidden" name="sort" value="popularity" />
                                    </form>
                                </li>
                            </xsl:if>
                            <xsl:if test="$fit">
                                <li>
                                    <xsl:if test="$sort = 'fit'">
                                        <xsl:attribute name="class">active</xsl:attribute>
                                    </xsl:if>
                                    <form action="{$document-link}" onclick="$(this).submit();" method="POST">
                                        <xsl:text>Подобранные</xsl:text>
                                        <input type="hidden" name="sort" value="fit" />
                                    </form>
                                </li>
                            </xsl:if>
                        </ul>
                    </div>
                </div>
            </xsl:when>
        </xsl:choose>

    </xsl:template>

    <xsl:template name="filters_section">
        <xsl:param name="link_new" select="1" />
        <xsl:param name="link_old" select="1" />
        <xsl:param name="popularity" select="1" />
        <xsl:param name="fit" select="1" />

        <div class="section_title">
            <div class="title">
                <xsl:choose>
                    <xsl:when test="($sort = 'new') or not($sort) or ($sort and ($sort!='new') and ($sort!='old') and ($sort!='popularity') and ($sort!='fit'))">
                        Новые опросы
                    </xsl:when>
                    <xsl:when test="$sort = 'old'">
                        Сначала старые
                    </xsl:when>
                    <xsl:when test="$sort = 'popularity'">
                        Популярные опросы
                    </xsl:when>
                    <xsl:when test="$sort = 'fit'">
                        Подобранные
                    </xsl:when>
                </xsl:choose>


                <xsl:text> </xsl:text><span class="glyphicon glyphicon-forward"></span>
            </div>
            <div class="sort_list">
                <xsl:if test="$link_new = '1'">
                    <a href="{$document-link}?sort=new">
                        <xsl:if test="($sort = 'new') or not($sort) or ($sort and ($sort!='new') and ($sort!='old') and ($sort!='popularity') and ($sort!='fit'))">
                            <xsl:attribute name="class">active</xsl:attribute>
                        </xsl:if>
                        <xsl:text>Новые опросы</xsl:text>
                    </a>
                </xsl:if>
                <xsl:if test="$link_old = '1'">
                    <a href="{$document-link}?sort=old">
                        <xsl:if test="$sort = 'old'">
                            <xsl:attribute name="class">active</xsl:attribute>
                        </xsl:if>
                        <xsl:text>Сначала старые</xsl:text>
                    </a>
                </xsl:if>
                <xsl:if test="$popularity = '1'">
                    <a href="{$document-link}?sort=popularity">
                        <xsl:if test="$sort = 'popularity'">
                            <xsl:attribute name="class">active</xsl:attribute>
                        </xsl:if>
                        <xsl:text>Популярные опросы</xsl:text>
                    </a>
                </xsl:if>
                <xsl:if test="$fit">
                    <a href="{$document-link}?sort=fit">
                        <xsl:if test="$sort = 'fit'">
                            <xsl:attribute name="class">active</xsl:attribute>
                        </xsl:if>
                        <xsl:text>Подобранные</xsl:text>
                    </a>
                </xsl:if>
            </div>
        </div>
    </xsl:template>

    <xsl:template match="item" mode="notifications">
        <xsl:choose>
            <xsl:when test="@notification = 'user_not_activated'">
                <div class="set_info alert alert-danger hide" role="alert">
                    Указанный Вами электронный адрес <strong><xsl:value-of select="$notifications//notifications//item[@notification='user_not_activated']/@email" disable-output-escaping="yes"/></strong> не подтвержден. На этот  адрес было отправлено сообщение со ссылкой для активации аккаунта.  Проверьте, пожалуйста, свою почту и перейдите по указанной в письме ссылке.
                    Если Вы не получили письмо, сообщите нам при помощи формы обратной связи.
                </div>
            </xsl:when>
            <xsl:when test="@notification = 'user_recommend_change_password'">
                <div class="set_info alert alert-danger hide" role="alert">
                    Вы сделали запрос на восстановление пароля. Изменить пароль Вы сможете в разделе «Мои настройки». <a href="/cabinet/profile/common/">Перейти</a>
                </div>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>