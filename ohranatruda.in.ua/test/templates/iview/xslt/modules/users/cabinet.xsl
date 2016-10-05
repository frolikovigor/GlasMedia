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

    <xsl:param name="p" />

    <!-- Общее -->
    <xsl:template match="result[page/@id='3333']">
        <xsl:call-template name="header" />
        <xsl:call-template name="panel" />
        <xsl:call-template name="panel_info" />

        <xsl:apply-templates select="$notifications//notifications//item[@menu_id = '3259']" mode="notifications" />

        <div id="cabinet" class="shift_right">
            <xsl:choose>
                <xsl:when test="$user-type = 'guest'">
                    <div class="set_info alert alert-danger hide" role="alert">
                        <span class="glyphicon glyphicon-exclamation-sign" aria-hidden="true"></span>
                        <span class="sr-only">Error:</span>
                        Кабинет доступен только для авторизованных пользователей.<br/>
                        <a href="#" class="alert-link" onclick="$('#authorization_btn').click(); return false;">Авторизация</a>
                    </div>
                </xsl:when>
                <xsl:otherwise>
                    <div class="content">
                        <div class="shell">
                            <div class="header shadow">
                                <div class="title">
                                    <span class="glyphicon glyphicon-user"></span>
                                    <h1>
                                        Мои настройки
                                        <span></span>
                                    </h1>
                                </div>
                                <xsl:variable name="category_subcat" select="document(concat('udata://content/menu///',3259))//item" />

                                <xsl:if test="count($category_subcat)">
                                    <ul class="subcategories">
                                        <li><span class="glyphicon glyphicon-folder-open"></span></li>
                                        <xsl:apply-templates select="$category_subcat" mode="category_subcat" />
                                    </ul>
                                </xsl:if>
                            </div>

                            <div id="cabinet_profile" class="shadow"><font size="3">Идет загрузка...</font></div>
                        </div>
                    </div>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>

    <!-- Мои опросы -->
    <xsl:template match="result[page/@id='3260']">
        <xsl:call-template name="header" />
        <xsl:call-template name="panel" />
        <xsl:call-template name="panel_info" />

        <div id="cabinet" class="shift_right">
            <div class="content">
                <xsl:choose>
                    <xsl:when test="$user-type = 'guest'">
                        <div class="shell">
                            <div class="set_info alert alert-danger hide" role="alert">
                                <span class="glyphicon glyphicon-exclamation-sign" aria-hidden="true"></span>
                                <span class="sr-only">Error:</span>
                                Кабинет доступен только для авторизованных пользователей.<br/>
                                <a href="#" class="alert-link" onclick="$('#authorization_btn').click(); return false;">Авторизация</a>
                            </div>
                        </div>
                    </xsl:when>
                    <xsl:otherwise>
                        <div class="shell">
                            <div class="header shadow">
                                <div class="title">
                                    <h1>
                                        <xsl:value-of select="//property[@name='h1']/value" />
                                        <span></span>
                                    </h1>
                                </div>
                                <xsl:call-template name="filters">
                                    <xsl:with-param name="type">link</xsl:with-param>
                                    <xsl:with-param name="link_new" select="1" />
                                    <xsl:with-param name="link_old" select="1" />
                                    <xsl:with-param name="popularity" select="1" />
                                    <xsl:with-param name="fit" select="0" />
                                </xsl:call-template>
                            </div>

                            <xsl:variable name="getListVotesOfUser" select="document('udata://vote/getListVotesOfUser/')" />
                            <div class="content masonry hidden_block hidden_block_content" data-class-masonry="poll" data-masonry-gutter="20" data-block="1">
                                <xsl:apply-templates select="$getListVotesOfUser//item" mode="getListVotes">
                                    <xsl:with-param name="type">medium</xsl:with-param>
                                    <xsl:with-param name="view_url">true</xsl:with-param>
                                    <xsl:with-param name="h">h2</xsl:with-param>
                                </xsl:apply-templates>
                            </div>
                            <xsl:if test="not(count($getListVotesOfUser//item))">
                                <div class="alert alert-warning" role="alert">У Вас пока нет опросов.</div>
                            </xsl:if>

                            <div class="cl"></div>

                            <div class="paginated">
                                <xsl:apply-templates select="document(concat('udata://system/numpages/',$getListVotesOfUser//total,'/',$getListVotesOfUser//per_page,'///10'))"  mode="paginated" />
                            </div>

                        </div>
                    </xsl:otherwise>
                </xsl:choose>
            </div>
        </div>
    </xsl:template>

    <!-- Мои ленты -->
    <xsl:template match="result[page/@id='3264']">
        <xsl:call-template name="header" />
        <xsl:call-template name="panel" />
        <xsl:call-template name="panel_info" />

        <div id="cabinet" class="shift_right">
            <xsl:choose>
                <xsl:when test="$user-type = 'guest'">
                    <div class="set_info alert alert-danger hide" role="alert">
                        <span class="glyphicon glyphicon-exclamation-sign" aria-hidden="true"></span>
                        <span class="sr-only">Error:</span>
                        Кабинет доступен только для авторизованных пользователей.<br/>
                        <a href="#" class="alert-link" onclick="$('#authorization_btn').click(); return false;">Авторизация</a>
                    </div>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="getListFeeds" select="document('udata://vote/getListFeeds/user/')" />
                    <div class="content">
                        <div id="cabinet_my_feeds">
                            <div class="shell">
                                <div class="header shadow">
                                    <div class="title">
                                        <h1>
                                            <xsl:value-of select="//property[@name='h1']/value" />
                                            <span></span>
                                        </h1>
                                    </div>
                                    <xsl:call-template name="filters">
                                        <xsl:with-param name="type">link</xsl:with-param>
                                        <xsl:with-param name="link_new" select="1" />
                                        <xsl:with-param name="link_old" select="1" />
                                        <xsl:with-param name="popularity" select="1" />
                                        <xsl:with-param name="fit" select="0" />
                                    </xsl:call-template>
                                </div>

                                <xsl:choose>
                                    <xsl:when test="count($getListFeeds//feed)">
                                        <form class="my_feeds">
                                            <xsl:apply-templates select="$getListFeeds//feed" mode="OfListFeeds">
                                                <xsl:with-param name="label_enabled">1</xsl:with-param>
                                            </xsl:apply-templates>
                                        </form>
                                        <div class="paginated">
                                            <xsl:apply-templates select="document(concat('udata://system/numpages/',$getListFeeds//total,'/',$getListFeeds//per_page,'/'))"  mode="paginated" />
                                        </div>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <div class="alert alert-warning" role="alert">У Вас пока нет лент.</div>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </div>
                        </div>
                    </div>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>

    <!-- Мои статьи -->
    <xsl:template match="result[page/@id='3261']">
        <xsl:call-template name="header" />
        <xsl:call-template name="panel" />
        <xsl:call-template name="panel_info" />

        <div id="cabinet" class="shift_right">
            <div class="content">
                <xsl:choose>
                    <xsl:when test="$user-type = 'guest'">
                        <div class="shell">
                            <div class="set_info alert alert-danger hide" role="alert">
                                <span class="glyphicon glyphicon-exclamation-sign" aria-hidden="true"></span>
                                <span class="sr-only">Error:</span>
                                Кабинет доступен только для авторизованных пользователей.<br/>
                                <a href="#" class="alert-link" onclick="$('#authorization_btn').click(); return false;">Авторизация</a>
                            </div>
                        </div>
                    </xsl:when>
                    <xsl:otherwise>
                        <div class="shell">
                            <div class="header shadow">
                                <div class="title">
                                    <h1>
                                        <xsl:value-of select="//property[@name='h1']/value" />
                                        <span></span>
                                    </h1>
                                </div>
                                <xsl:call-template name="filters">
                                    <xsl:with-param name="type">link</xsl:with-param>
                                    <xsl:with-param name="link_new" select="1" />
                                    <xsl:with-param name="link_old" select="1" />
                                    <xsl:with-param name="popularity" select="0" />
                                    <xsl:with-param name="fit" select="0" />
                                </xsl:call-template>
                            </div>

                            <xsl:variable name="getListArticlesOfUser" select="document('udata://content/getListArticlesOfUser/')" />
                            <div class="content masonry hidden_block hidden_block_content" data-class-masonry="article" data-masonry-gutter="20" data-block="1">
                                <xsl:apply-templates select="$getListArticlesOfUser//article" mode="getListArticles">
                                    <xsl:with-param name="type">medium</xsl:with-param>
                                    <xsl:with-param name="view_url">true</xsl:with-param>
                                </xsl:apply-templates>
                            </div>
                            <xsl:if test="not(count($getListArticlesOfUser//article))">
                                <div class="alert alert-warning" role="alert">У Вас пока нет статей.</div>
                            </xsl:if>

                            <div class="cl"></div>

                            <div class="paginated">
                                <xsl:apply-templates select="document(concat('udata://system/numpages/',$getListArticlesOfUser//total,'/',$getListArticlesOfUser//per_page,'///10'))"  mode="paginated" />
                            </div>
                        </div>
                    </xsl:otherwise>
                </xsl:choose>
            </div>
        </div>
    </xsl:template>

    <!-- Подписки -->
    <xsl:template match="result[page/@id='3262']">
        <xsl:call-template name="header" />
        <xsl:call-template name="panel" />
        <xsl:call-template name="panel_info" />

        <div id="cabinet" class="shift_right">
            <xsl:choose>
                <xsl:when test="$user-type = 'guest'">
                    <div class="set_info alert alert-danger hide" role="alert">
                        <span class="glyphicon glyphicon-exclamation-sign" aria-hidden="true"></span>
                        <span class="sr-only">Error:</span>
                        Кабинет доступен только для авторизованных пользователей.<br/>
                        <a href="#" class="alert-link" onclick="$('#authorization_btn').click(); return false;">Авторизация</a>
                    </div>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="getListFeeds" select="document('udata://vote/getListFeeds/subscribe/')" />
                    <div class="content">
                        <div id="cabinet_my_subscribe">
                            <div class="shell">
                                <div class="header shadow">
                                    <div class="title">
                                        <h1>
                                            <xsl:value-of select="//property[@name='h1']/value" />
                                            <span></span>
                                        </h1>
                                    </div>
                                    <xsl:call-template name="filters">
                                        <xsl:with-param name="type">link</xsl:with-param>
                                        <xsl:with-param name="link_new" select="1" />
                                        <xsl:with-param name="link_old" select="1" />
                                        <xsl:with-param name="popularity" select="1" />
                                        <xsl:with-param name="fit" select="0" />
                                    </xsl:call-template>
                                </div>

                                <xsl:choose>
                                    <xsl:when test="count($getListFeeds//feed)">
                                        <form class="my_feeds">
                                            <xsl:apply-templates select="$getListFeeds//feed" mode="OfListFeeds" />
                                        </form>
                                        <div class="paginated">
                                            <xsl:apply-templates select="document(concat('udata://system/numpages/',$getListFeeds//total,'/',$getListFeeds//per_page,'/'))"  mode="paginated" />
                                        </div>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <div class="alert alert-warning" role="alert">У Вас пока нет подписок.</div>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </div>
                        </div>
                    </div>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>

</xsl:stylesheet>