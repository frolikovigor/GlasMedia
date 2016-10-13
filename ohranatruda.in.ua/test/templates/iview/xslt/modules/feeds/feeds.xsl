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
    
	<xsl:template match="result[@module = 'vote'][@method = 'get']">
        <xsl:call-template name="header" />
        <xsl:call-template name="panel" />
        <xsl:call-template name="panel_info" />

        <xsl:variable name="clearSession" select="document('udata://vote/create_poll/1')" />

        <xsl:variable name="id" select="//udata/id" />

        <!-- счетчик посещений -->
        <xsl:variable name="counters" select="document(concat('udata://vote/viewsCounter/',$id))/udata" />

        <xsl:if test="/result/udata[@module='vote'][@method='get']/user = $user-id">
            <!--<xsl:call-template name="feed_settings">-->
                <!--<xsl:with-param name="id" select="$id" />-->
            <!--</xsl:call-template>-->
        </xsl:if>

        <xsl:variable name="enable_edit">
            <xsl:choose>
                <xsl:when test="/result/udata[@module='vote'][@method='get']/user = $user-id">true</xsl:when>
                <xsl:otherwise>false</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <div class="shift_right">
            <xsl:call-template name="feed">
                <xsl:with-param name="id" select="$id" />
                <xsl:with-param name="per_page" select="$settings//property[@name='feed_per_page']/value" />
                <xsl:with-param name="pagination">1</xsl:with-param>
                <xsl:with-param name="sort_polls">
                    <xsl:choose>
                        <xsl:when test="$sort"><xsl:value-of select="$sort" /></xsl:when>
                        <xsl:otherwise>auto</xsl:otherwise>
                    </xsl:choose>
                </xsl:with-param>
                <xsl:with-param name="enable_sort">1</xsl:with-param>
                <xsl:with-param name="enable_link_create">1</xsl:with-param>
                <xsl:with-param name="enable_edit" select="$enable_edit" />
            </xsl:call-template>
        </div>
    </xsl:template>

    <xsl:template match="result[@module = 'vote'][@method = 'getlist']">
        <xsl:call-template name="header" />
        <xsl:call-template name="panel" />
        <xsl:call-template name="panel_info" />
        <div id="all_feed_list" class="shift_right">
            <xsl:variable name="getListFeeds" select="document('udata://vote/getListFeeds/')" />

            <div class="shell">
                <div class="content">
                    <div class="header">
                        <div class="title">
                            <h1>
                                <xsl:value-of select="$settings//property[@name='h1_feed_all']/value" />
                                <span></span>
                            </h1>
                        </div>
                        <xsl:call-template name="filters">
                            <xsl:with-param name="type">link</xsl:with-param>
                            <xsl:with-param name="link_new" select="1" />
                            <xsl:with-param name="link_old" select="1" />
                            <xsl:with-param name="popularity" select="1" />
                            <xsl:with-param name="fit" select="1" />
                        </xsl:call-template>
                    </div>

                    <xsl:apply-templates select="$getListFeeds//feed" mode="OfListFeeds">
                        <xsl:with-param name="label_enabled">0</xsl:with-param>
                    </xsl:apply-templates>

                    <div class="paginated">
                        <xsl:apply-templates select="document(concat('udata://system/numpages/',$getListFeeds//total,'/',$getListFeeds//per_page,'/'))"  mode="paginated" />
                    </div>
                </div>
            </div>
        </div>
    </xsl:template>

    <xsl:template match="udata[@method='subscribe']">
        <xsl:choose>
            <xsl:when test="//subscribe = '1'">
                <button type="button" class="btn btn-default" data-feed-id="{//id}"><span class="glyphicon glyphicon-log-out"></span> Отписаться</button>
            </xsl:when>
            <xsl:otherwise>
                <button type="button" class="btn btn-danger" data-feed-id="{//id}">
                    <xsl:if test="//user-id = 337">
                        <xsl:attribute name="data-toggle">modal</xsl:attribute>
                        <xsl:attribute name="data-target">#authorization</xsl:attribute>
                        <xsl:attribute name="class">btn btn-danger no-auth</xsl:attribute>
                    </xsl:if>
                    <span class="glyphicon glyphicon-log-in"></span> Подписаться
                </button>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:variable name="num_subscribers">
            <xsl:choose>
                <xsl:when test="//num_subscribers != ''"><xsl:value-of select="//num_subscribers" /></xsl:when>
                <xsl:otherwise>0</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <button type="button" class="btn btn-default disabled"><xsl:value-of select="$num_subscribers" /></button>
    </xsl:template>


    <!-- Лента опросов -->
    <xsl:template name="feed">
        <xsl:param name="id" />
        <xsl:param name="per_page" />
        <xsl:param name="pagination">1</xsl:param>
        <xsl:param name="sort_polls">auto</xsl:param>
        <xsl:param name="enable_link_feed">0</xsl:param>
        <xsl:param name="enable_sort">0</xsl:param>
        <xsl:param name="enable_link_create">0</xsl:param>
        <xsl:param name="h1">1</xsl:param>
        <xsl:param name="enable_edit">false</xsl:param>
        <xsl:variable name="listPollsOfFeeds" select="document(concat('udata://vote/listPollsOfFeeds/',$id,'/',$per_page,'/',$sort_polls))" />
        <xsl:variable name="feed" select="document(concat('udata://vote/get/',$id,'/0'))" />
        <div class="feed">
            <div class="shell">
                <div class="head shadow">
                    <div class="image">
                        <xsl:if test="($feed//photo_profile != '') or ($enable_edit = 'true')">
                            <xsl:attribute name="class">image f_h</xsl:attribute>
                        </xsl:if>

                        <xsl:apply-templates select="document(concat('udata://system/makeThumbnailFull/(.', $feed//photo_cover, ')/940/320/void/0/1/5/0/80/'))/udata" mode="feedPhotoCover">
                            <xsl:with-param name="alt" select="$feed//name" />
                        </xsl:apply-templates>
                        <xsl:apply-templates select="document(concat('udata://system/makeThumbnailFull/(.', $feed//photo_cover, ')/630/210/void/0/1/5/0/80/'))/udata" mode="feedPhotoCover">
                            <xsl:with-param name="alt" select="$feed//name" />
                        </xsl:apply-templates>

                        <xsl:if test="$enable_edit = 'true'">
                            <div class="feed_img_cover_ch" data-fragment="3" data-url="/vote/upload_photo_cover_feed/" data-parameters="id={$id}" onclick="GM.View.Images.UploadImage('upload_image_feed', $(this));">
                                <span class="glyphicon glyphicon-camera"></span>
                                <xsl:choose>
                                    <xsl:when test="$feed//photo_cover != ''">
                                        <div>Изменить фото обложки</div>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <div>Добавить фото обложки</div>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </div>
                        </xsl:if>
                    </div>

                    <xsl:if test="($enable_edit = 'true') or ($feed//photo_profile != '')">
                        <div class="photo_profile empty">
                            <xsl:choose>
                                <xsl:when test="$feed//photo_profile != ''">
                                    <xsl:attribute name="class">photo_profile</xsl:attribute>
                                    <xsl:apply-templates select="document(concat('udata://system/makeThumbnailFull/(.', $feed//photo_profile, ')/160/160/void/0/1/5/0/80/'))/udata" mode="feedPhotoProfile">
                                        <xsl:with-param name="width" select="160" />
                                        <xsl:with-param name="height" select="160" />
                                    </xsl:apply-templates>
                                    <xsl:if test="$enable_edit = 'true'">
                                        <div class="edit">
                                            <span></span>
                                            <div>
                                                <a href="#" data-fragment="1" data-url="/vote/upload_photo_profile_feed/" data-parameters="id={$id}" onclick="GM.View.Images.UploadImage('upload_image_feed', $(this));">Изменить фото профиля</a>
                                                <a href="/vote/remove_photo_profile_feed/{$id}/">Удалить фото профиля</a>
                                            </div>
                                        </div>
                                    </xsl:if>
                                </xsl:when>
                                <xsl:otherwise>
                                    <div data-fragment="1" data-url="/vote/upload_photo_profile_feed/" data-parameters="id={$id}" onclick="GM.View.Images.UploadImage('upload_image_feed', $(this));">
                                        <span class="glyphicon glyphicon-camera"></span>
                                        <div>Добавить фото профиля</div>
                                    </div>
                                </xsl:otherwise>
                            </xsl:choose>
                        </div>
                    </xsl:if>
                </div>
                <div class="feed-info shadow">
                    <xsl:choose>
                        <xsl:when test="$h1 = '1'">
                            <h1>
                                <xsl:choose>
                                    <xsl:when test="$enable_link_feed = '1'">
                                        <a href="{$feed//link}"><xsl:value-of select="$feed//name" disable-output-escaping="yes" /><span class="glyphicon glyphicon-link"></span></a>
                                    </xsl:when>
                                    <xsl:otherwise><xsl:value-of select="$feed//name" disable-output-escaping="yes" /></xsl:otherwise>
                                </xsl:choose>
                            </h1>
                        </xsl:when>
                        <xsl:otherwise>
                            <div class="h1">
                                <xsl:choose>
                                    <xsl:when test="$enable_link_feed = '1'">
                                        <a href="{$feed//link}"><xsl:value-of select="$feed//name" disable-output-escaping="yes" /><span class="glyphicon glyphicon-link"></span></a>
                                    </xsl:when>
                                    <xsl:otherwise><xsl:value-of select="$feed//name" disable-output-escaping="yes" /></xsl:otherwise>
                                </xsl:choose>
                            </div>
                        </xsl:otherwise>
                    </xsl:choose>

                    <xsl:choose>
                        <xsl:when test="$feed//description != ''">
                            <div class="description">
                                <xsl:value-of select="$feed//description" disable-output-escaping="yes" />
                            </div>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:if test="$enable_edit = 'true'">
                                <div class="description empty" onclick="$('#feeds_setting_form').slideToggle();">Добавить описание</div>
                            </xsl:if>
                        </xsl:otherwise>
                    </xsl:choose>

                    <xsl:if test="$feed//test = '0'">
                        <div class="btn-group btn-group-xs subsribe" role="group">
                            <xsl:choose>
                                <xsl:when test="$user-info//property[@name='subscribe']//item/@id = $id">
                                    <button type="button" class="btn btn-default" data-feed-id="{$id}"><span class="glyphicon glyphicon-log-out"></span> Отписаться</button>
                                </xsl:when>
                                <xsl:otherwise>
                                    <button type="button" class="btn btn-danger" data-feed-id="{$id}">
                                        <xsl:if test="$user-id = 337">
                                            <xsl:attribute name="data-toggle">modal</xsl:attribute>
                                            <xsl:attribute name="data-target">#authorization</xsl:attribute>
                                            <xsl:attribute name="class">btn btn-danger no-auth</xsl:attribute>
                                        </xsl:if>
                                        <span class="glyphicon glyphicon-log-in"></span> Подписаться
                                    </button>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:variable name="num_subscribers">
                                <xsl:choose>
                                    <xsl:when test="$feed//num_subscribers != ''"><xsl:value-of select="$feed//num_subscribers" /></xsl:when>
                                    <xsl:otherwise>0</xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <button type="button" class="btn btn-default disabled"><xsl:value-of select="$num_subscribers" /></button>
                        </div>
                    </xsl:if>

                    <div class="settings">
                        <xsl:if test="$enable_sort = '1'">
                            <xsl:call-template name="filters">
                                <xsl:with-param name="type">relation</xsl:with-param>
                                <xsl:with-param name="link_new" select="1" />
                                <xsl:with-param name="link_old" select="1" />
                                <xsl:with-param name="popularity" select="1" />
                                <xsl:with-param name="fit" select="1" />
                                <xsl:with-param name="unactive">
                                    <xsl:choose>
                                        <xsl:when test="$enable_edit = 'true'">1</xsl:when>
                                        <xsl:otherwise>0</xsl:otherwise>
                                    </xsl:choose>
                                </xsl:with-param>
                            </xsl:call-template>
                        </xsl:if>

                        <xsl:if test="$enable_edit = 'true'">
                            <xsl:if test="$listPollsOfFeeds//unactive = '1'">
                                <a class="item back" href="{$feed//link}">Вернуться к ленте</a>
                            </xsl:if>

                            <a class="item" href="#" onclick="$('#feeds_setting_form').slideToggle();">Редактировать <span class="caret"></span></a>
                            <a class="item" href="/vote/create_poll/?feed={$id}"><span class="glyphicon glyphicon-tasks"></span>Новый опрос</a>
                            <a class="item" href="/content/create_article/"><span class="glyphicon glyphicon-pencil"></span>Новая статья</a>

                            <xsl:variable name="getUnactive" select="document(concat('udata://vote/listPollsOfFeeds/',$id,'/?unactive'))" />
                            <!--<xsl:if test="$getOffers//total != '0'">-->
                                <!--<a class="create" href="#" onclick="$('#feeds_setting_form').slideToggle();">Предложения <span class="badge danger"><xsl:value-of select="$getOffers//total" /></span></a>-->
                            <!--</xsl:if>-->

                            <xsl:if test="($getUnactive//total != '0') and ($listPollsOfFeeds//unactive = '0')">
                                <a class="item" href="{$feed//link}?unactive">Неактивные <span class="badge danger"><xsl:value-of select="$getUnactive//total" /></span></a>
                            </xsl:if>

                            <form id="feeds_setting_form" class="form-horizontal" action="/vote/settings/" method="post" data-feed-id="{$id}">
                                <div class="h1">Редактирование ленты</div>
                                <hr/>

                                <input type="hidden" name="id" value="{$id}" />

                                <div class="form-group">
                                    <label class="col-sm-3 control-label">Название ленты</label>
                                    <div class="col-sm-9">
                                        <input type="text" name="name" class="form-control required" value="{$feed//name}" maxlength="255" />
                                        <span class="hide label label-warning" data-warning='min_length'>Слишком короткое название</span>
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label class="col-sm-3 control-label">Описание</label>
                                    <div class="col-sm-9">
                                        <textarea class="wysiwyg" id="feed_description">
                                            <xsl:value-of select="$feed//description" disable-output-escaping="yes" />
                                        </textarea>
                                        <input id="feed_description_hidden" type="hidden" name="description" value="" />
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label class="col-sm-3 control-label">Короткий адрес Вашей ленты</label>
                                    <div class="col-sm-9">
                                        <span class="label_1">http://<xsl:value-of select="$domain" />/</span><input type="text" name="url" class="form-control" value="{$feed//url}" maxlength="32" data-toggle="tooltip" data-placement="top" title="Адрес должен состоять из латинских букв, цифр или знаков «_». Адрес не должен содержать только цифры." />
                                        <span class="hide label label-warning" data-warning='check'></span>
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label class="col-sm-3 control-label">Сортировка тегов</label>
                                    <div class="col-sm-9">
                                        <select name="sort_tags" class="form-control">
                                            <xsl:apply-templates select="document('usel://uniq_objects/158/')/udata/item" mode="sort_tags">
                                                <xsl:with-param name="selected" select="$feed//sort_tags" />
                                            </xsl:apply-templates>
                                        </select>
                                    </div>
                                </div>

                                <div class="form-group">
                                    <div class="col-sm-offset-3 col-sm-9">
                                        <div class="checkbox">
                                            <label>
                                                <input type="checkbox" name="is_active" value="on">
                                                    <xsl:if test="($feed//is_active = '1')"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
                                                </input> Активность ленты <span class="glyphicon glyphicon-question-sign" data-toggle="tooltip" data-placement="top" title="Включение/отключение ленты. Пользователи не будут видеть ленту, если она неактивна." ></span>
                                            </label>
                                        </div>
                                    </div>
                                </div>

                                <button type="submit" class="btn btn-default btn-preloader"><img src="/templates/iview/images/preloader.gif" /><span>Сохранить</span></button>
                            </form>
                        </xsl:if>
                    </div>

                    <form id="feed_search" method="get" action="">
                        <div class="input-group">
                            <input type="text" class="form-control input-sm" name="search_string" placeholder="Поиск в ленте..." value="{$feed//last_search_string}" />
                            <span class="input-group-btn">
                                <button class="btn btn-default btn-sm" type="submit"><span class="glyphicon glyphicon-search"></span></button>
                            </span>
                        </div>
                    </form>

                    <xsl:variable name="search_list" select="$feed//search_list//search" />

                    <xsl:if test="($feed//last_search_string != '') or (count($feed//search_list//search))">
                        <div id="feed_tags">
                            <xsl:if test="($feed//last_search_string != '') and ($enable_edit = 'true') and not($feed//search_list//search[@selected='1'])">
                                <form class="feed_add_tag" action="/vote/feed_add_tag/" method="POST">
                                    <input type="hidden" name="feed_id" value="{$id}" />
                                    <input type="hidden" name="last_search_string" value="{$feed//last_search_string}" />
                                    <a href="#" onclick="$('#feed_tags .feed_add_tag').submit();">Добавить</a> запрос "<xsl:value-of select="$feed//last_search_string" />" в теги.
                                </form>
                            </xsl:if>

                            <div class="h2">Теги</div>
                            <xsl:choose>
                                <xsl:when test="count($feed//search_list//search)">
                                    <ul>
                                        <xsl:apply-templates select="$search_list" mode="feed_search_list">
                                            <xsl:with-param name="enable_edit" select="$enable_edit" />
                                            <xsl:with-param name="feed_id" select="$id" />
                                        </xsl:apply-templates>
                                    </ul>
                                </xsl:when>
                                <xsl:otherwise>Список тегов пуст</xsl:otherwise>
                            </xsl:choose>
                        </div>
                    </xsl:if>


                </div>

                <xsl:if test="$feed//last_search_string != ''">
                    <div class="list_empty">
                        <xsl:choose>
                            <xsl:when test="$listPollsOfFeeds//total = '0'">
                                <p>По запросу "<b><xsl:value-of select="$search_string" /></b>" ничего не найдено.</p>
                                <p>Убедитесь, что все слова написаны без ошибок или попробуйте использовать другие ключевые слова.</p>
                                <a href="{$feed//link}">Вернуться к ленте</a>
                            </xsl:when>
                            <xsl:otherwise>
                                <p>Результаты поиска по запросу "<b><xsl:value-of select="$search_string" /></b>".</p>
                                <a href="{$feed//link}">Вернуться к ленте</a>
                            </xsl:otherwise>
                        </xsl:choose>
                    </div>
                </xsl:if>

                <img class="preloader_list hidden_block" src="/templates/iview/images/preloader.gif" />
                <div class="content hidden_block hidden_block_content">
                    <xsl:choose>
                        <xsl:when test="($feed//is_active = '1') or ($user-id = $feed//user/id)">

                            <xsl:if test="$listPollsOfFeeds//unactive = '1'">
                                <div class="title_block">
                                    <div>Неактивные опросы</div>
                                </div>
                            </xsl:if>

                            <div class="list_articles masonry" data-class-masonry="poll" data-masonry-gutter="20" data-block="1">

                                <xsl:if test="$listPollsOfFeeds//unactive = '0'">
                                    <div class="poll medium shadow new_poll_block" data-type="fast" data-for="feed" data-id="{$id}"
                                         data-tooltips-id="{$tooltips//item[@id='1']/@id}"
                                         data-tooltips-content="{$tooltips//item[@id='1']/@content}"
                                         data-tooltips-pos="{$tooltips//item[@id='1']/@pos}"
                                    >
                                    </div>
                                </xsl:if>

                                <xsl:choose>
                                    <xsl:when test="count($listPollsOfFeeds//items//item)">
                                        <xsl:apply-templates select="$listPollsOfFeeds//items//item" mode="getListVotes">
                                            <xsl:with-param name="type">medium</xsl:with-param>
                                            <xsl:with-param name="view_url">true</xsl:with-param>
                                            <xsl:with-param name="advert">5</xsl:with-param>
                                            <xsl:with-param name="h">h2</xsl:with-param>
                                        </xsl:apply-templates>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <!--<div class="list_empty">
                                            Нет публикаций для отображения
                                        </div>-->
                                    </xsl:otherwise>
                                </xsl:choose>
                            </div>
                            <xsl:if test="$pagination = '1'">
                                <div class="paginated">
                                    <xsl:apply-templates select="document(concat('udata://system/numpages/',$listPollsOfFeeds//total,'/',$listPollsOfFeeds//per_page,'/'))"  mode="paginated" />
                                </div>
                                <xsl:if test="$listPollsOfFeeds//last_page = '0'">
                                    <button class="btn btn-default btn-white btn-preloader paginated_ajax"
                                            for-data-block="1"
                                            data-udata="/udata/vote/listPollsOfFeeds/{$id}/{$per_page}/{$sort_polls}"
                                            data-transform="modules/feeds/ajax_listPollsOfFeeds.xsl"
                                            data-search_string="{$search_string}"
                                    >
                                        <img src="/templates/iview/images/preloader.gif" />
                                        <span>Еще</span>
                                    </button>
                                </xsl:if>
                            </xsl:if>
                            <xsl:if test="$pagination = '2'">
                                <xsl:if test="$listPollsOfFeeds//total &gt; $listPollsOfFeeds//per_page">
                                    <div class="paginated">
                                        <form action="{$feed//link}" method="POST">
                                            <input type="hidden" name="sort" value="fit" />
                                            <input type="hidden" name="goto" value="poll{$listPollsOfFeeds//items//item[position()=last()]/@id}" />
                                            <button class="btn btn-default btn-white btn-preloader">
                                                <img src="/templates/iview/images/preloader.gif" />
                                                <span>Еще</span>
                                            </button>
                                        </form>
                                    </div>
                                </xsl:if>
                            </xsl:if>
                        </xsl:when>
                        <xsl:otherwise>
                            <div class="alert alert-warning" role="alert">Лента отключена</div>
                        </xsl:otherwise>
                    </xsl:choose>
                </div>
            </div>
        </div>
    </xsl:template>

    <!-- Лента опросов (предпросмотр) -->
    <xsl:template name="feed_preview">
        <xsl:param name="id" />
        <xsl:param name="per_page" />
        <xsl:param name="pagination">1</xsl:param>
        <xsl:param name="sort_polls">auto</xsl:param>
        <xsl:param name="enable_link_feed">0</xsl:param>
        <xsl:param name="enable_sort">0</xsl:param>
        <xsl:param name="enable_link_create">0</xsl:param>
        <xsl:param name="h1">1</xsl:param>
        <xsl:variable name="listPollsOfFeeds" select="document(concat('udata://vote/listPollsOfFeeds/',$id,'/',$per_page,'/',$sort_polls))" />
        <xsl:variable name="feed" select="document(concat('udata://vote/get/',$id,'/0'))" />
        <div class="feed shadow">
            <div class="head">
                <div class="image">
                    <xsl:if test="$feed//photo_profile != ''">
                        <xsl:attribute name="class">image f_h</xsl:attribute>
                    </xsl:if>
                    <xsl:if test="$feed//photo_cover != ''">
                        <xsl:apply-templates select="document(concat('udata://system/makeThumbnailFull/(.', $feed//photo_cover, ')/940/320/void/0/1/5/0/80/'))/udata" mode="feedPhotoCover">
                            <xsl:with-param name="alt" select="$feed//name" />
                        </xsl:apply-templates>
                        <xsl:apply-templates select="document(concat('udata://system/makeThumbnailFull/(.', $feed//photo_cover, ')/630/210/void/0/1/5/0/80/'))/udata" mode="feedPhotoCover">
                            <xsl:with-param name="alt" select="$feed//name" />
                        </xsl:apply-templates>
                    </xsl:if>

                    <div class="list_polls_preview">
                        <div></div>
                        <ul class="dot">
                            <xsl:apply-templates select="$listPollsOfFeeds//items//item" mode="listPollsOfFeedsPreview" />
                        </ul>
                    </div>
                </div>

                <xsl:if test="$feed//photo_profile != ''">
                    <div class="photo_profile">
                        <xsl:apply-templates select="document(concat('udata://system/makeThumbnailFull/(.', $feed//photo_profile, ')/160/160/void/0/1/5/0/80/'))/udata" mode="feedPhotoProfile">
                            <xsl:with-param name="width" select="160" />
                            <xsl:with-param name="height" select="160" />
                            <xsl:with-param name="alt" select="$feed//name" />
                        </xsl:apply-templates>
                    </div>
                </xsl:if>
            </div>
            <div class="feed-info">
                <xsl:choose>
                    <xsl:when test="$h1 = '1'">
                        <h1>
                            <xsl:choose>
                                <xsl:when test="$enable_link_feed = '1'">
                                    <a href="{$feed//link}"><xsl:value-of select="$feed//name" disable-output-escaping="yes" /><span class="glyphicon glyphicon-link"></span></a>
                                </xsl:when>
                                <xsl:otherwise><xsl:value-of select="$feed//name" disable-output-escaping="yes" /></xsl:otherwise>
                            </xsl:choose>
                        </h1>
                    </xsl:when>
                    <xsl:otherwise>
                        <div class="h1">
                            <xsl:choose>
                                <xsl:when test="$enable_link_feed = '1'">
                                    <a href="{$feed//link}"><xsl:value-of select="$feed//name" disable-output-escaping="yes" /><span class="glyphicon glyphicon-chevron-right"></span></a>
                                </xsl:when>
                                <xsl:otherwise><xsl:value-of select="$feed//name" disable-output-escaping="yes" /></xsl:otherwise>
                            </xsl:choose>
                        </div>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:if test="$feed//description != ''">
                    <div class="description">
                        <xsl:value-of select="$feed//description" disable-output-escaping="yes" />
                    </div>
                </xsl:if>
                <xsl:if test="$feed//test = '0'">
                    <div class="btn-group btn-group-xs subsribe" role="group">
                        <xsl:choose>
                            <xsl:when test="$user-info//property[@name='subscribe']//item/@id = $id">
                                <button type="button" class="btn btn-default" data-feed-id="{$id}"><span class="glyphicon glyphicon-log-out"></span> Отписаться</button>
                            </xsl:when>
                            <xsl:otherwise>
                                <button type="button" class="btn btn-danger" data-feed-id="{$id}">
                                    <xsl:if test="$user-id = 337">
                                        <xsl:attribute name="data-toggle">modal</xsl:attribute>
                                        <xsl:attribute name="data-target">#authorization</xsl:attribute>
                                        <xsl:attribute name="class">btn btn-danger no-auth</xsl:attribute>
                                    </xsl:if>
                                    <span class="glyphicon glyphicon-log-in"></span> Подписаться
                                </button>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:variable name="num_subscribers">
                            <xsl:choose>
                                <xsl:when test="$feed//num_subscribers != ''"><xsl:value-of select="$feed//num_subscribers" /></xsl:when>
                                <xsl:otherwise>0</xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <button type="button" class="btn btn-default disabled"><xsl:value-of select="$num_subscribers" /></button>
                    </div>
                </xsl:if>

                <xsl:if test="$enable_sort = '1'">
                    <hr/>
                    <!--<xsl:call-template name="filters">
                        <xsl:with-param name="type">relation</xsl:with-param>
                        <xsl:with-param name="link_new" select="1" />
                        <xsl:with-param name="link_old" select="1" />
                        <xsl:with-param name="popularity" select="1" />
                        <xsl:with-param name="fit" select="1" />
                    </xsl:call-template>-->
                </xsl:if>

                <xsl:if test="$user-id = $feed//user/id and $enable_link_create = '1'">
                    <a class="item" href="/vote/create_poll/?feed={$id}"><span class="glyphicon glyphicon-tasks"></span>Новый опрос</a>
                    <a class="item" href="/content/create_article/"><span class="glyphicon glyphicon-pencil"></span>Новая статья</a>
                </xsl:if>
            </div>
            <!--<img class="preloader_list hidden_block" src="/templates/iview/images/preloader.gif" />
            <div class="content hidden_block hidden_block_content">
                <xsl:choose>
                    <xsl:when test="($feed//is_active = '1') or ($user-id = $feed//user/id)">
                        <div class="list_articles masonry" data-class-masonry="poll" data-masonry-gutter="20">
                            <xsl:choose>
                                <xsl:when test="count($listPollsOfFeeds//items//item)">
                                    <xsl:apply-templates select="$listPollsOfFeeds//items//item" mode="listPollsOfFeeds" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <div class="list_empty">
                                        Нет публикаций для отображения
                                    </div>
                                </xsl:otherwise>
                            </xsl:choose>
                        </div>
                        <xsl:if test="$pagination = '1'">
                            <div class="paginated">
                                <xsl:apply-templates select="document(concat('udata://system/numpages/',$listPollsOfFeeds//total,'/',$listPollsOfFeeds//per_page,'/'))"  mode="paginated" />
                            </div>
                        </xsl:if>
                        <xsl:if test="$pagination = '2'">
                            <xsl:if test="$listPollsOfFeeds//total &gt; $listPollsOfFeeds//per_page">
                                <div class="paginated">
                                    <form action="{$feed//link}" method="POST">
                                        <input type="hidden" name="sort" value="fit" />
                                        <input type="hidden" name="goto" value="poll{$listPollsOfFeeds//items//item[position()=last()]/@id}" />
                                        <button class="btn btn-default btn-white btn-preloader">
                                            <img src="/templates/iview/images/preloader.gif" />
                                            <span>Еще</span>
                                        </button>
                                    </form>
                                </div>
                            </xsl:if>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <div class="alert alert-warning" role="alert">Лента отключена</div>
                    </xsl:otherwise>
                </xsl:choose>
            </div>-->
        </div>
    </xsl:template>

    <xsl:template match="item" mode="listPollsOfFeedsPreview">
        <li>
            <a href="{@link}">
                <div>
                    <xsl:value-of select="./name" />
                </div>
            </a>
        </li>
    </xsl:template>


    <xsl:template match="feed|item" mode="OfListFeeds">
        <xsl:param name="label_enabled">0</xsl:param>
        <xsl:call-template name="feed_item">
            <xsl:with-param name="id" select="@id" />
            <xsl:with-param name="label_enabled" select="$label_enabled" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="feed_item">
        <xsl:param name="id" />
        <xsl:param name="label_enabled">0</xsl:param>


        <xsl:call-template name="feed_preview">
            <xsl:with-param name="id" select="$id" />
            <xsl:with-param name="per_page" select="$settings//property[@name='homepage_num_poll_in_feed']/value" />
            <xsl:with-param name="pagination">2</xsl:with-param>
            <xsl:with-param name="sort_polls">fit</xsl:with-param>
            <xsl:with-param name="enable_link_feed">1</xsl:with-param>
            <xsl:with-param name="enable_link_create">0</xsl:with-param>
            <xsl:with-param name="h1">0</xsl:with-param>
        </xsl:call-template>


        <!--<xsl:variable name="feed" select="document(concat('udata://vote/get/',$id,'/0'))" />
        <div class="feed_item">
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
                        <span class="date"><xsl:value-of select="$feed//date" /></span>
                        <span class="info_item">Подписчиков: <xsl:value-of select="$feed//num_subscribers" /></span>
                        <hr/>
                        <div class="description"><xsl:value-of select="$feed//description" disable-output-escaping="yes" /></div>
                    </td>
                    <xsl:if test="$label_enabled = '1'">
                        <td class="labels">
                            <xsl:choose>
                                <xsl:when test="$feed//is_active = '1'">
                                    <span class="label label-success">Лента активна</span>
                                </xsl:when>
                                <xsl:otherwise>
                                    <span class="label label-warning">Лента отключена</span>
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                    </xsl:if>
                </tr>
            </table>
        </div>-->
    </xsl:template>

    <xsl:template match="page" mode="feed_list_category">
        <xsl:param name="selected" />
        <xsl:param name="sub">false</xsl:param>
        <xsl:variable name="subcat" select="document(concat('udata://vote/xsltCache/31536000/(usel://uniq/1/',@id,'/133/)'))" />
        <option value="{@id}">
            <xsl:if test="$selected and ($selected = @id)"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>

            <xsl:if test="$sub = 'true'">&nbsp;&nbsp;&nbsp;&nbsp;</xsl:if>
            <xsl:value-of select=".//name" /></option>
            <xsl:if test="count($subcat//page)">
                <xsl:apply-templates select="$subcat//page" mode="feed_list_category">
                    <xsl:with-param name="sub">true</xsl:with-param>
                    <xsl:with-param name="selected" select="$selected" />
                </xsl:apply-templates>
            </xsl:if>

    </xsl:template>

    <xsl:template match="search" mode="feed_search_list">
        <xsl:param name="enable_edit" />
        <xsl:param name="feed_id" />

        <li class="feed_search_item">
            <xsl:if test="@selected = '1'">
                <xsl:attribute name="class">feed_search_item select</xsl:attribute>
            </xsl:if>
            <a href="?search_string={@uri}"><xsl:value-of select="@search" /></a>
            <xsl:if test="$enable_edit = 'true'">
                <a href="/vote/feed_del_tag/{$feed_id}/{@id}"><img class="delete" src="/images/cms/admin/mac/tree/ico_del.png" /></a>
            </xsl:if>
        </li>
    </xsl:template>

    <xsl:template match="item" mode="sort_tags">
        <xsl:param name="selected" />
        <option value="{@id}">
            <xsl:if test="@id = $selected">
                <xsl:attribute name="selected">selected</xsl:attribute>
            </xsl:if>
            <xsl:value-of select="@name" />
        </option>
    </xsl:template>

</xsl:stylesheet>