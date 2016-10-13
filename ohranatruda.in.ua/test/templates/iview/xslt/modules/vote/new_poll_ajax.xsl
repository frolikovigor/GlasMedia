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

    <xsl:template match="udata[@method='getNewPollForm']">
        <xsl:choose>
            <xsl:when test="//fast_poll = '1'">
                <form id="new_poll_form">
                    <div class="theme">Предложите свой опрос</div>
                    <xsl:if test="//feeds/item != ''">
                        <input type="hidden" name="data[feeds][]" value="{//feeds/item}" />
                        <input type="hidden" name="data[for_lent]" value="on" />
                    </xsl:if>

                    <xsl:if test="//category != ''">
                        <input type="hidden" name="data[category]" value="{//category}" />
                    </xsl:if>
                    <xsl:if test="//subcategory != ''">
                        <input type="hidden" name="data[subcategory]" value="{//subcategory}" />
                    </xsl:if>

                    <div class="setting_chapter">
                        <div class="title">Заголовок</div>
                    </div>
                    <div class="form-group">
                        <input type="text" name="data[theme]" class="form-control" value="{//theme}" maxlength="255" placeholder="" />
                    </div>

                    <xsl:if test="count(//images//item) &gt; 0">
                        <div class="image">
                            <img src="{//images/item/@link}" />
                            <span class="glyphicon glyphicon-remove remove" data-id="{@id}" onclick="
                            $(this).find('input').prop('checked',$(this).find('input').prop('checked') ? false : true);
                            $(this).find('input').change();">
                                <span class="not_visible"><input type="checkbox" name="data[images][{@id}][delete]" value="on" reload_form="1" /></span>
                            </span>
                        </div>
                    </xsl:if>

                    <xsl:if test="count(//images//item) &lt; 1">
                        <div class="form-group attach_photo">
                            <button class="btn btn-default btn upload_image" type="button" data-fragment="0" data-url="/vote/upload_image_poll/" data-parameters="" onclick="GM.View.Images.UploadImage('poll_new_image', $(this));">
                                <span class="glyphicon glyphicon-paperclip"></span>
                                Прикрепить фото
                            </button>
                        </div>
                    </xsl:if>

                    <div class="setting_chapter">
                        <div class="title">Анонс (выводится под темой опроса)</div>
                    </div>
                    <div class="form-group">
                        <textarea name="data[anons]" class="form-control" rows="3" maxlength="4096" placeholder=""> 
                            <xsl:if test="//limited_access = '1'">
                                <xsl:attribute name="disabled">disabled</xsl:attribute>
                            </xsl:if>
                            <xsl:value-of select="//anons" />
                        </textarea>
                        <xsl:if test="//limited_access = '1'">
                            <input type="hidden" name="data[anons]" value="{//anons}" />
                        </xsl:if>
                    </div>


                    <div class="setting_chapter">
                        <div class="title">
                            Варианты ответов
                            <xsl:if test="//variants_autocomplete_exists = '1'">
                                <span class="right">
                                    <span class="glyphicon glyphicon-refresh"></span><xsl:text> </xsl:text>
                                    <a href="#" onclick="
                            $(this).find('input').prop('checked',$(this).find('input').prop('checked') ? false : true);
                            $(this).find('input').change();">Подобрать варианты ответов
                                        <span class="not_visible"><input type="checkbox" name="data[auto_complete]" value="{//feeds/item}" reload_form="1" /></span>
                                    </a>
                                </span>
                            </xsl:if>
                        </div>
                    </div>
                    <xsl:variable name="num_variants" select="count(//variants//item)" />
                    <xsl:apply-templates select="//variants//item" mode="variants">
                        <xsl:with-param name="nums" select="$num_variants" />
                    </xsl:apply-templates>

                    <div class="setting_chapter">
                        <div class="title">
                            <div class="checkbox">
                                <label>
                                    <input type="checkbox" name="data[multiple]" value="on" reload_form="1">
                                        <xsl:if test="(//multiple != '')"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
                                    </input>
                                    Разрешить выбирать несколько вариантов ответов
                                </label>
                            </div>
                        </div>
                        <xsl:if test="(//multiple != '')">
                            <div class="content_setting">
                                <div class="form-group">
                                    <select name="data[multiple_max]" class="form-control">
                                        <option value="2"><xsl:if test="(//multiple = '2')"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>2</option>

                                        <xsl:if test="$num_variants &gt; 2">
                                            <xsl:call-template name="multiple_max">
                                                <xsl:with-param name="i" select="3" />
                                                <xsl:with-param name="count" select="$num_variants" />
                                                <xsl:with-param name="multiple" select="//multiple" />
                                            </xsl:call-template>
                                        </xsl:if>

                                        <!--<xsl:if test="$num_variants &gt; 2"><option value="3"><xsl:if test="(//multiple = '3')"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>3</option></xsl:if>-->
                                        <!--<xsl:if test="$num_variants &gt; 3"><option value="4"><xsl:if test="(//multiple = '4')"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>4</option></xsl:if>-->
                                        <!--<xsl:if test="$num_variants &gt; 4"><option value="5"><xsl:if test="(//multiple = '5')"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>5</option></xsl:if>-->
                                        <!--<xsl:if test="$num_variants &gt; 5"><option value="6"><xsl:if test="(//multiple = '6')"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>6</option></xsl:if>-->
                                        <!--<xsl:if test="$num_variants &gt; 6"><option value="7"><xsl:if test="(//multiple = '7')"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>7</option></xsl:if>-->
                                        <!--<xsl:if test="$num_variants &gt; 7"><option value="8"><xsl:if test="(//multiple = '8')"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>8</option></xsl:if>-->
                                        <!--<xsl:if test="$num_variants &gt; 8"><option value="9"><xsl:if test="(//multiple = '9')"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>9</option></xsl:if>-->
                                        <!--<xsl:if test="$num_variants &gt; 9"><option value="10"><xsl:if test="(//multiple = '10')"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>10</option></xsl:if>-->
                                    </select>
                                </div>
                            </div>
                        </xsl:if>
                    </div>
                    <button type="button" class="btn btn-primary btn save_poll">Сохранить опрос</button>
                </form>
            </xsl:when>

            <xsl:otherwise>
                <xsl:variable name="lang" select="document('udata://content/getLang/')/udata" />
                <xsl:variable name="settings" select="document('uobject://3934')" />

                <div class="shell">
                    <form id="new_poll_form">
                        <div class="content">
                            <xsl:choose>
                                <xsl:when test="//edit_mode != ''">
                                    <h1>Редактирование опроса</h1>
                                    <xsl:if test="//limited_access = '1'">
                                        <div class="alert alert-danger">Редактирование некоторых полей запрещено, т. к. пользователи уже проголосовали в этом опросе.</div>
                                    </xsl:if>

                                    <input type="hidden" name="data[edit]" value="{//edit_mode}" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <h1>Новый опрос
                                        <xsl:if test="//for_article">
                                            на основе <xsl:value-of select="//for_article/type/@rp" />
                                        </xsl:if>
                                    </h1>
                                </xsl:otherwise>
                            </xsl:choose>

                            <xsl:if test="//current_user/@guid = 'system-guest'">
                                <div class="set_info alert alert-warning hide shadow" role="alert">Для создания опроса потребуется <a href="#" class="alert-link" onclick="$('#authorization_btn').click(); return false;">авторизация</a>.</div>
                            </xsl:if>

                            <xsl:if test="not(//for_article) or (//for_article = '')">
                                <div class="set_info alert alert-success hide shadow" role="alert">Придайте вашему опросу больше информативности. Для этого перед созданием нового опроса Вы можете <a href="/content/create_article/" class="alert-link">создать статью</a>.</div>
                                <div class="set_info alert alert-default hide wide shadow" role="alert">
                                    <div class="slidedown_title" data-for-content="571"><img src="/templates/iview/images/poll/poll.png" /><xsl:value-of select="$settings//property[@name='title_why_article']/value" disable-output-escaping="yes" /><span class="caret"></span></div>
                                    <div class="slidedown_content hide" data-id="571"><xsl:value-of select="$settings//property[@name='why_article']/value" disable-output-escaping="yes" /></div>
                                </div>
                            </xsl:if>

                            <xsl:if test="//for_article">
                                <input type="hidden" name="data[for_article]" value="{//for_article/@id}" />
                                <input type="hidden" name="data[get]" value="{//get}" />
                                <div class="for_article">
                                    <h2>
                                        <xsl:value-of select="//for_article//title" />
                                        <xsl:text> </xsl:text><span class="label-{//for_article/type/@class}"><xsl:value-of select="//for_article/type/@name" /></span>
                                    </h2>
                                    <div class="info">
                                        <span class="date"><xsl:value-of select="//for_article//date" /></span>
                                        <xsl:if test="//for_article//source/name != ''">
                                            <span class="source">Источник: <span><a href="{//for_article//source/url}" target="_blank"><xsl:value-of select="//for_article//source/name" /></a></span></span>
                                        </xsl:if>
                                    </div>
                                    <div class="cl"></div>
                                    <div class="for_article_content">
                                        <div class="content_cut" data-cut-id="1" data-cut-height="275" style="height:275px;">
                                            <xsl:if test="//for_article//img != ''">
                                                <a href="{//for_article//img}" class="popup_img" rel="article_img_{//for_article/@id}">
                                                    <img src="{//for_article//img}" width="300" />
                                                </a>
                                            </xsl:if>
                                            <xsl:value-of select="//for_article//content" disable-output-escaping="yes" />
                                        </div>
                                        <a href="#" class="open_cut hide" data-for-cut="1"><span class="glyphicon glyphicon-chevron-down"></span>См. полностью</a>
                                    </div>
                                </div>
                            </xsl:if>

                            <div class="setting_chapter">
                                <div class="title">Заголовок</div>
                            </div>
                            <div class="form-group">
                                <input type="text" name="data[theme]" class="form-control" value="{//theme}" maxlength="255">
                                    <xsl:if test="//limited_access = '1'">
                                        <xsl:attribute name="disabled">disabled</xsl:attribute>
                                    </xsl:if>
                                </input>
                                <xsl:if test="//limited_access = '1'">
                                    <input type="hidden" name="data[theme]" value="{//theme}" />
                                </xsl:if>
                            </div>

                            <xsl:if test="count(//images//item) &gt; 0">
                                <div class="images">
                                    <div class="gridster">
                                        <xsl:if test="//limited_access = '1'">
                                            <xsl:attribute name="class"></xsl:attribute>
                                        </xsl:if>
                                        <ul>
                                            <xsl:choose>
                                                <xsl:when test="//limited_access = '1'">
                                                    <xsl:apply-templates select="//images//item" mode="images_in_preview">
                                                        <xsl:with-param name="disabled">true</xsl:with-param>
                                                    </xsl:apply-templates>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:apply-templates select="//images//item" mode="images_in_preview" />
                                                </xsl:otherwise>
                                            </xsl:choose>

                                        </ul>
                                    </div>
                                </div>
                            </xsl:if>

                            <xsl:if test="count(//images//item) &lt; 4">
                                <div class="form-group attach_photo">
                                    <button class="btn btn-default btn upload_image" type="button" data-fragment="" data-url="/vote/upload_image_poll/" data-parameters="" onclick="GM.View.Images.UploadImage('poll_new_image', $(this));">
                                        <span class="glyphicon glyphicon-paperclip"></span>
                                        Прикрепить фото
                                    </button>
                                </div>
                            </xsl:if>

                            <div class="setting_chapter">
                                <div class="title">Анонс (выводится под темой опроса)</div>
                            </div>
                            <div class="form-group">
                                <textarea name="data[anons]" class="form-control" rows="3" maxlength="4096">
                                    <xsl:if test="//limited_access = '1'">
                                        <xsl:attribute name="disabled">disabled</xsl:attribute>
                                    </xsl:if>
                                    <xsl:value-of select="//anons" />
                                </textarea>
                                <xsl:if test="//limited_access = '1'">
                                    <input type="hidden" name="data[anons]" value="{//anons}" />
                                </xsl:if>
                            </div>


                            <xsl:variable name="getListFeeds" select="document(concat('usel://uniq_objects/146/user/',//current_user/@id,'/not/?ext_groups=additional'))/udata/item" />
                            <xsl:if test="count($getListFeeds)">
                                <div class="setting_chapter">
                                    <div class="title">Принадлежность к ленте</div>
                                    <div class="content_setting chanels">
                                        <div class="form-group">
                                            <xsl:apply-templates select="$getListFeeds" mode="getListFeeds">
                                                <xsl:with-param name="selected" select=".//feeds" />
                                            </xsl:apply-templates>
                                        </div>
                                    </div>
                                </div>
                                <div class="setting_chapter">
                                    <div class="title">
                                        <div class="checkbox">
                                            <label>
                                                <input type="checkbox" name="data[for_lent]" value="on">
                                                    <xsl:if test="(//for_lent = 'on')"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
                                                </input>
                                                Отображать только в ленте
                                            </label>
                                            <span class="glyphicon glyphicon-question-sign" data-toggle="tooltip" data-placement="top" title="Опрос не будет отображаться в тематических разделах. Пользователи смогут увидеть этот опрос только в ленте." ></span>
                                        </div>
                                    </div>
                                </div>
                            </xsl:if>


                            <div class="setting_chapter">
                                <div class="title">
                                    Варианты ответов
                                    <xsl:if test="//variants_autocomplete_exists = '1'">
                                        <span class="right">
                                            <span class="glyphicon glyphicon-refresh"></span><xsl:text> </xsl:text>
                                            <a href="#" onclick="
                            $(this).find('input').prop('checked',$(this).find('input').prop('checked') ? false : true);
                            $(this).find('input').change();">Подобрать варианты ответов<span class="glyphicon glyphicon-question-sign" data-toggle="tooltip" data-placement="top" title="Доступно, когда выбрана принадлежность к ленте. Полезно, когда лента содержит много однотипных опросов с одинаковыми вариантами ответов." ></span>
                                                <span class="not_visible"><input type="checkbox" name="data[auto_complete]" value="{//feeds/item}" reload_form="1" /></span>
                                            </a>
                                        </span>
                                    </xsl:if>
                                </div>
                            </div>
                            <xsl:variable name="num_variants" select="count(//variants//item)" />
                            <xsl:choose>
                                <xsl:when test="//limited_access = '1'">
                                    <xsl:apply-templates select="//variants//item" mode="variants">
                                        <xsl:with-param name="nums" select="$num_variants" />
                                        <xsl:with-param name="disabled">true</xsl:with-param>
                                    </xsl:apply-templates>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:apply-templates select="//variants//item" mode="variants">
                                        <xsl:with-param name="nums" select="$num_variants" />
                                    </xsl:apply-templates>
                                </xsl:otherwise>
                            </xsl:choose>



                            <div class="setting_chapter">
                                <div class="title">Категория опроса<span class="glyphicon glyphicon-question-sign" data-toggle="tooltip" data-placement="top" title="Определяет тематику опроса" ></span></div>

                                <div class="content_setting">
                                    <div class="form-group">
                                        <select class="form-control" name="data[category]" reload_form="1" onchange="$('#data_subcategory').val('');">
                                            <xsl:apply-templates select="document('udata://content/menu///7')//item" mode="options_of_select">
                                                <xsl:with-param name="selected" select="//category" />
                                            </xsl:apply-templates>
                                        </select>
                                    </div>

                                    <xsl:variable name="category">
                                        <xsl:choose>
                                            <xsl:when test="//category != ''"><xsl:value-of select="//category" /></xsl:when>
                                            <xsl:otherwise>8</xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:variable>

                                    <xsl:variable name="subcategory" select="document(concat('udata://content/menu///',$category))//item" />
                                    <xsl:if test="count($subcategory)">
                                        <div class="form-group">
                                            <div class="setting_chapter">
                                                <div class="title">Подкатегория<span class="glyphicon glyphicon-question-sign" data-toggle="tooltip" data-placement="top" title="Определяет тематику опроса" ></span></div>
                                            </div>
                                            <select id="data_subcategory" class="form-control" name="data[subcategory]">
                                                <option value="">Не выбрано</option>
                                                <xsl:apply-templates select="$subcategory" mode="options_of_select">
                                                    <xsl:with-param name="selected" select="//subcategory" />
                                                </xsl:apply-templates>
                                            </select>
                                        </div>
                                    </xsl:if>
                                </div>
                            </div>
                            <div class="setting_chapter">
                                <div class="title">
                                    <div class="checkbox">
                                        <label>
                                            <input type="checkbox" name="data[eighteen_plus]" value="on">
                                                <xsl:if test="(//eighteen_plus = 'on')"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
                                            </input>
                                            18+
                                        </label>
                                        <span class="glyphicon glyphicon-question-sign" data-toggle="tooltip" data-placement="top" title="Содержимое опроса предназначено только для совершеннолетних. Опрос с такой пометкой будет виден только зарегистрированным пользователям, которые указали дату своего рождения при регистрации или в профиле пользователя." ></span>
                                    </div>
                                </div>
                            </div>
                            <div class="setting_chapter">
                                <div class="title">Кто может голосовать<span class="glyphicon glyphicon-question-sign" data-toggle="tooltip" data-placement="top" title="«Все пользователи» - предоставляется возможность голосования как авторизованному так и неавторизованному пользователю. Такой вариант дает менее объективную информацию о результатах голосования, чем вариант «Только зарегистрированные», но в то же время именно неавторизованные пользователи составляют основную аудиторию сайта." ></span></div>
                                <div class="content_setting">
                                    <div class="form-group">
                                        <select class="form-control" name="data[user_reg]">
                                            <option value="0">
                                                <xsl:if test="(//user_reg = '0') or not(//user_reg)"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
                                                Все пользователи
                                            </option>
                                            <option value="1">
                                                <xsl:if test="//user_reg = '1'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
                                                Только зарегистрированные
                                            </option>
                                        </select>
                                    </div>
                                </div>
                            </div>
                            <div class="setting_chapter">
                                <div class="title">
                                    <div class="checkbox">
                                        <label>
                                            <input type="checkbox" name="data[preview]" value="on">
                                                <xsl:if test="(//preview = 'on')"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
                                            </input>
                                            Показывать результат до голосования
                                        </label>
                                    </div>
                                </div>
                            </div>
                            <div class="setting_chapter">
                                <div class="title">
                                    <div class="checkbox">
                                        <label>
                                            <input type="checkbox" name="data[targeting_regional][enabled]" value="on" reload_form="1">
                                                <xsl:if test="(//targeting_regional/enabled = 'on')"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
                                            </input>
                                            Региональный таргетинг
                                        </label>
                                        <span class="glyphicon glyphicon-question-sign" data-toggle="tooltip" data-placement="top" title="Можно указать для пользователей какой территории предназначен опрос. Пользователям, находящимся за пределами этой территории опрос не будет виден."></span>
                                    </div>
                                </div>
                                <xsl:if test="(//targeting_regional/enabled = 'on')">
                                    <div class="content_setting">
                                        <div class="form-group">
                                            <label>Страна</label>
                                            <select name="data[targeting_regional][country]" class="form-control" reload_form="1">
                                                <option value="">
                                                    <xsl:if test="not(//country) or (//country = '')">
                                                        <xsl:attribute name="selected">selected</xsl:attribute>
                                                    </xsl:if>
                                                    Все
                                                </option>
                                                <xsl:apply-templates select="document('udata://content/getListCountries/')//item" mode="options_of_select_countries">
                                                    <xsl:with-param name="lang" select="$lang" />
                                                    <xsl:with-param name="selected" select="//country" />
                                                </xsl:apply-templates>
                                            </select>
                                        </div>
                                        <div class="form-group">
                                            <xsl:variable name="getListRegions" select="document(concat('udata://content/getListRegions/',//country))//item" />
                                            <label>Регион / область</label>
                                            <select name="data[targeting_regional][region]" class="form-control" reload_form="1">
                                                <xsl:if test="count($getListRegions) = 0"><xsl:attribute name="disabled">disabled</xsl:attribute></xsl:if>
                                                <option value="">
                                                    <xsl:if test="not(//region) or (//region = '')">
                                                        <xsl:attribute name="selected">selected</xsl:attribute>
                                                    </xsl:if>
                                                    Все
                                                </option>
                                                <xsl:apply-templates select="$getListRegions" mode="options_of_select_regions">
                                                    <xsl:with-param name="lang" select="$lang" />
                                                    <xsl:with-param name="selected" select="//region" />
                                                </xsl:apply-templates>
                                            </select>
                                        </div>
                                        <!--<div class="form-group">
                                            <xsl:variable name="getListCities" select="document(concat('udata://content/getListCities/',//region))//item" />
                                            <label>Город</label>
                                            <select name="data[targeting_regional][city]" class="form-control input-sm" reload_form="1">
                                                <xsl:if test="count($getListCities) = 0"><xsl:attribute name="disabled">disabled</xsl:attribute></xsl:if>
                                                <option value="">
                                                    <xsl:if test="not(//city) or (//city = '')">
                                                        <xsl:attribute name="selected">selected</xsl:attribute>
                                                    </xsl:if>
                                                    Все
                                                </option>
                                                <xsl:apply-templates select="$getListCities" mode="options_of_select_cities">
                                                    <xsl:with-param name="lang" select="$lang" />
                                                    <xsl:with-param name="selected" select="//city" />
                                                </xsl:apply-templates>
                                            </select>
                                        </div>-->
                                    </div>
                                </xsl:if>
                            </div>
                            <div class="setting_chapter">
                                <div class="title">
                                    <div class="checkbox">
                                        <label>
                                            <input type="checkbox" name="data[multiple]" value="on" reload_form="1">
                                                <xsl:if test="(//multiple != '')"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
                                            </input>
                                            Разрешить выбирать несколько вариантов ответов
                                        </label>
                                    </div>
                                </div>
                                <xsl:if test="(//multiple != '')">
                                    <div class="content_setting">
                                        <div class="form-group">
                                            <select name="data[multiple_max]" class="form-control">
                                                <option value="2"><xsl:if test="(//multiple = '2')"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>2</option>

                                                <xsl:call-template name="multiple_max">
                                                    <xsl:with-param name="i" select="3" />
                                                    <xsl:with-param name="count" select="$num_variants" />
                                                    <xsl:with-param name="multiple" select="//multiple" />
                                                </xsl:call-template>

                                                <!--<xsl:if test="$num_variants &gt; 2"><option value="3"><xsl:if test="(//multiple = '3')"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>3</option></xsl:if>-->
                                                <!--<xsl:if test="$num_variants &gt; 3"><option value="4"><xsl:if test="(//multiple = '4')"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>4</option></xsl:if>-->
                                                <!--<xsl:if test="$num_variants &gt; 4"><option value="5"><xsl:if test="(//multiple = '5')"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>5</option></xsl:if>-->
                                                <!--<xsl:if test="$num_variants &gt; 5"><option value="6"><xsl:if test="(//multiple = '6')"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>6</option></xsl:if>-->
                                                <!--<xsl:if test="$num_variants &gt; 6"><option value="7"><xsl:if test="(//multiple = '7')"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>7</option></xsl:if>-->
                                                <!--<xsl:if test="$num_variants &gt; 7"><option value="8"><xsl:if test="(//multiple = '8')"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>8</option></xsl:if>-->
                                                <!--<xsl:if test="$num_variants &gt; 8"><option value="9"><xsl:if test="(//multiple = '9')"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>9</option></xsl:if>-->
                                                <!--<xsl:if test="$num_variants &gt; 9"><option value="10"><xsl:if test="(//multiple = '10')"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>10</option></xsl:if>-->
                                            </select>
                                        </div>
                                    </div>
                                </xsl:if>
                            </div>

                            <div class="setting_chapter">
                                <div class="title">Повторное голосование через, часов<span class="glyphicon glyphicon-question-sign" data-toggle="tooltip" data-placement="top" title="Указывается период времени в часах, по истечению которого пользователь может повторно отдать свой голос. Если поле оставить пустым или указать «0» - ноль, то пользователь может проголосовать только один раз."></span></div>
                                <div class="content_setting">
                                    <div class="form-group">
                                        <input type="number" name="data[time_vote]" class="form-control" value="{//time_vote}" min="0" max="99999" />
                                    </div>
                                </div>
                            </div>

                            <xsl:if test="count(//images//item) &gt; 0">
                                <!--<div class="poll_tooltip">
                                    <span class="glyphicon glyphicon-question-sign"></span>
                                    <p>
                                        Размер изображения меняется потянув за правый нижний угол<br/>
                                        <b style="color:red;">*</b> - не во всех браузерах
                                    </p>
                                    <img src="/templates/iview/images/poll/poll_mouse.jpg" />
                                    <div class="tooltip_1">Изменить положение</div>
                                    <div class="tooltip_2">Изменить масштаб</div>
                                    <div class="tooltip_3"><b style="color:red;">*</b> Выбрать фрагмент</div>
                                </div>-->
                            </xsl:if>
                        </div>
                        <div class="sidebar">
                            <xsl:value-of select="$settings//property[@name='poll_new_info']/value" disable-output-escaping="yes" />
                        </div>
                        <button type="button" class="btn btn-primary btn save_poll">Сохранить опрос</button>
                        <xsl:if test="//edit_mode">
                            <a href="{//edit_mode_cancel}"><button type="button" class="btn btn-default btn cancel">Отменить</button></a>
                        </xsl:if>

                        <div class="cl"></div>
                    </form>
                </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="item" mode="variants">
        <xsl:param name="nums" />
        <xsl:param name="disabled">false</xsl:param>
        <div class="form-group">
            <div class="input-group">
                <span class="input-group-btn">
                    <button class="btn btn-default" type="button" onclick="
                            $(this).find('input').prop('checked',$(this).find('input').prop('checked') ? false : true);
                            $(this).find('input').change();">
                        <xsl:if test="position() = 1"><xsl:attribute name="class">btn btn-default disabled</xsl:attribute></xsl:if>
                        <xsl:if test="$disabled = 'true'">
                            <xsl:attribute name="disabled">disabled</xsl:attribute>
                        </xsl:if>
                        <span class="not_visible"><input type="checkbox" name="data[shift_up]" value="{@id}" reload_form="1" /></span>
                        <span class="glyphicon glyphicon-menu-up"></span>
                    </button>
                    <button class="btn btn-default" type="button" onclick="
                            $(this).find('input').prop('checked',$(this).find('input').prop('checked') ? false : true);
                            $(this).find('input').change();">
                        <xsl:if test="position() = last()"><xsl:attribute name="class">btn btn-default disabled</xsl:attribute></xsl:if>
                        <xsl:if test="$disabled = 'true'">
                            <xsl:attribute name="disabled">disabled</xsl:attribute>
                        </xsl:if>
                        <span class="not_visible"><input type="checkbox" name="data[shift_down]" value="{@id}" reload_form="1" /></span>
                        <span class="glyphicon glyphicon-menu-down"></span>
                    </button>
                </span>
                <input type="text" class="form-control" name="data[variants][{@id}]" placeholder="" value="{.//.}" maxlength="255">
                    <xsl:if test="$disabled = 'true'">
                        <xsl:attribute name="disabled">disabled</xsl:attribute>
                    </xsl:if>
                </input>
                <xsl:if test="$disabled = 'true'">
                    <input type="hidden" name="data[variants][{@id}]" value="{.//.}" />
                </xsl:if>
                <xsl:if test="$nums &gt; 2">
                    <span class="input-group-btn">
                        <button class="btn btn-default btn-danger" type="button" onclick="
                            $(this).find('input').prop('checked',$(this).find('input').prop('checked') ? false : true);
                            $(this).find('input').change();">
                            <xsl:if test="$disabled = 'true'">
                                <xsl:attribute name="disabled">disabled</xsl:attribute>
                            </xsl:if>
                            <span class="not_visible"><input type="checkbox" name="data[delete]" value="{@id}" reload_form="1" /></span>
                            <span class="glyphicon glyphicon-remove"></span>
                        </button>
                    </span>
                </xsl:if>
            </div>
        </div>
        <xsl:if test="$disabled = 'false'">
            <div class="add_answer">
                <span class="glyphicon glyphicon-plus" onclick="
                    $(this).find('input').prop('checked',$(this).find('input').prop('checked') ? false : true);
                    $(this).find('input').change()">
                    <span class="not_visible"><input type="checkbox" name="data[add_answer]" value="{@id}" reload_form="1" /></span>
                </span>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template match="item" mode="options_of_select_countries">
        <xsl:param name="lang" />
        <xsl:param name="selected" />
        <option value="{@iso}">
            <xsl:if test="$selected and ($selected = @iso)"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
            <xsl:choose>
                <xsl:when test="$lang = 'ru'">
                    <xsl:value-of select="@name_ru" disable-output-escaping="yes" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@name_en" disable-output-escaping="yes" />
                </xsl:otherwise>
            </xsl:choose>
        </option>
    </xsl:template>

    <xsl:template match="item" mode="options_of_select_regions">
        <xsl:param name="lang" />
        <xsl:param name="selected" />
        <option value="{@id}">
            <xsl:if test="$selected and ($selected = @id)"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
            <xsl:choose>
                <xsl:when test="$lang = 'ru'">
                    <xsl:value-of select="@name_ru" disable-output-escaping="yes" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@name_en" disable-output-escaping="yes" />
                </xsl:otherwise>
            </xsl:choose>
        </option>
    </xsl:template>

    <xsl:template match="item" mode="options_of_select_cities">
        <xsl:param name="lang" />
        <xsl:param name="selected" />
        <option value="{@id}">
            <xsl:if test="$selected and ($selected = @id)"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
            <xsl:choose>
                <xsl:when test="$lang = 'ru'">
                    <xsl:value-of select="@name_ru" disable-output-escaping="yes" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@name_en" disable-output-escaping="yes" />
                </xsl:otherwise>
            </xsl:choose>
        </option>
    </xsl:template>

    <xsl:template match="item" mode="poll_style">
        <xsl:param name="current_style" />
        <option value="{.//property[@name='code']/value}">
            <xsl:if test="$current_style = .//property[@name='code']/value"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
            <xsl:value-of select="@name" />
        </option>
    </xsl:template>

    <xsl:template match="item" mode="images_in_preview">
        <xsl:param name="disabled">false</xsl:param>
        <li id="gridster_{@id}" data-id="{@id}" data-width="{@width}" data-top="{@top}" data-left="{@left}" data-row="{@row}" data-col="{@col}" data-sizex="{@sizex}" data-sizey="{@sizey}">
            <input type="hidden" name="data[images][{@id}][top]" data-name="top" value="{@top}" />
            <input type="hidden" name="data[images][{@id}][left]" data-name="left" value="{@left}" />
            <input type="hidden" name="data[images][{@id}][width]" data-name="width" value="{@width}" />
            <input type="hidden" name="data[images][{@id}][row]" data-name="row" value="{@row}" />
            <input type="hidden" name="data[images][{@id}][col]" data-name="col" value="{@col}" />
            <input type="hidden" name="data[images][{@id}][sizex]" data-name="sizex" value="{@sizex}" />
            <input type="hidden" name="data[images][{@id}][sizey]" data-name="sizey" value="{@sizey}" />
            <img src="{@link}" style="width:{@width}%; margin-top:{@top}px; margin-left:{@left}px" />
            <xsl:if test="@video_type">
                <span class="play_ico"></span>
            </xsl:if>
            <span class="glyphicon glyphicon-remove remove" data-id="{@id}" onclick="
                            $(this).find('input').prop('checked',$(this).find('input').prop('checked') ? false : true);
                            $(this).find('input').change();">
                <span class="not_visible"><input type="checkbox" name="data[images][{@id}][delete]" value="on" reload_form="1" /></span>
            </span>
            <xsl:if test="$disabled = 'false'">
                <span class="glyphicon glyphicon-chevron-left move to_left"></span>
                <span class="glyphicon glyphicon-chevron-right move to_right"></span>
                <span class="glyphicon glyphicon-chevron-up move to_top"></span>
                <span class="glyphicon glyphicon-chevron-down move to_down"></span>
            </xsl:if>
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

    <!--<xsl:template match="udata[@module = 'system' and (@method = 'makeThumbnail' or @method = 'makeThumbnailFull')]" mode="image">
        <img src="{src}" width="{width}" height="{height}" />
    </xsl:template>-->

    <xsl:template match="item" mode="getListFeeds">
        <xsl:param name="selected" />

        <div class="checkbox">
            <label>
                <input type="checkbox" name="data[feeds][]" value="{@id}" reload_form="1">
                    <xsl:if test="@id = $selected//item"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
                </input>
                <xsl:value-of select="@name" />
            </label>
        </div>
    </xsl:template>

    <xsl:template name="multiple_max">
        <xsl:param name="i" select="1" />
        <xsl:param name="count" />
        <xsl:param name="multiple" />

        <option value="{$i}">
            <xsl:if test="($multiple = $i)">
                <xsl:attribute name="selected">selected</xsl:attribute>
            </xsl:if>
            <xsl:value-of select="$i" />
        </option>
        <xsl:if test="$i &lt; $count">
            <xsl:call-template name="multiple_max">
                <xsl:with-param name="i" select="$i + 1"/>
                <xsl:with-param name="count" select="$count"/>
                <xsl:with-param name="multiple" select="$multiple" />
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>