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

    <xsl:template match="udata[@method='getNewArticleForm']">
        <xsl:variable name="lang" select="document('udata://content/getLang/')/udata" />
        <xsl:variable name="settings" select="document('uobject://3934')" />

        <form id="new_article_form">
            <div class="shell shadow">
                <div class="content">
                    <xsl:if test="//field[@name='_current_user']/value/@guid = 'system-guest'">
                        <div class="set_info alert alert-warning hide shadow" role="alert">Для создания статьи потребуется <a href="#" class="alert-link" onclick="$('#authorization_btn').click(); return false;">авторизация</a>.</div>
                    </xsl:if>
                    <div class="set_info alert alert-default hide wide shadow" role="alert">
                        <div class="slidedown_title" data-for-content="571">
                            <img src="/templates/iview/images/poll/poll.png" />
                            <xsl:value-of select="$settings//property[@name='title_why_article']/value" disable-output-escaping="yes" />
                            <span class="caret"></span>
                        </div>
                        <div class="slidedown_content hide" data-id="571">
                            <xsl:value-of select="$settings//property[@name='why_article']/value" disable-output-escaping="yes" />
                        </div>
                    </div>

                    <xsl:choose>
                        <xsl:when test="//field[@name='_edit_mode']/value != ''">
                            <h1>Редактирование статьи</h1>
                            <input type="hidden" name="data[edit]" value="{//field[@name='_edit_mode']/value}" />
                        </xsl:when>
                        <xsl:otherwise>
                            <h1>Новая статья</h1>
                        </xsl:otherwise>
                    </xsl:choose>

                    <div class="setting_chapter">
                        <div class="title">Тип статьи<span class="glyphicon glyphicon-question-sign" data-toggle="tooltip" data-placement="top" title="Определяет формат статьи" ></span></div>
                        <div class="content_setting">
                            <div class="form-group">
                                <select class="form-control" name="data[_type]" reload_form="1">
                                    <xsl:if test="//field[@name='_edit_mode']/value != ''">
                                        <xsl:attribute name="disabled">disabled</xsl:attribute>
                                    </xsl:if>
                                    <option value="">Не выбрано</option>
                                    <xsl:apply-templates select="document('usel://uniq_objects/145/is_active/1/?ext_props=type_id&amp;sort=sort')//item" mode="all_article_types">
                                        <xsl:with-param name="selected" select="//field[@name='_type']/value" />
                                    </xsl:apply-templates>
                                </select>
                                <xsl:if test="//field[@name='_edit_mode']/value != ''">
                                    <input type="hidden" name="data[_type]" value="{//field[@name='_type']/value}" />
                                </xsl:if>
                            </div>
                        </div>
                    </div>
                    <div class="cl"></div>

                    <xsl:if test="//field[@name='_type']/value != ''">
                        <div class="setting_chapter">
                            <div class="title">Категория<span class="glyphicon glyphicon-question-sign" data-toggle="tooltip" data-placement="top" title="Определяет тематику статьи" ></span></div>
                            <xsl:if test="not(//for_article)">
                                <div class="content_setting">
                                    <div class="form-group">
                                        <select class="form-control" name="data[_category]" reload_form="1" onchange="$('#data_subcategory').val('');">
                                            <xsl:apply-templates select="document('udata://content/menu///7')//item" mode="options_of_select">
                                                <xsl:with-param name="selected" select="//field[@name='_category']/value" />
                                            </xsl:apply-templates>
                                        </select>
                                    </div>
                                    <xsl:variable name="_category">
                                        <xsl:choose>
                                            <xsl:when test="//field[@name='_category']/value != ''"><xsl:value-of select="//field[@name='_category']/value" /></xsl:when>
                                            <xsl:otherwise>8</xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:variable>
                                    <xsl:variable name="subcategory" select="document(concat('udata://content/menu///',$_category))//item" />
                                    <xsl:if test="count($subcategory)">
                                        <div class="form-group">
                                            <div class="setting_chapter">
                                                <div class="title">Подкатегория<span class="glyphicon glyphicon-question-sign" data-toggle="tooltip" data-placement="top" title="Определяет тематику статьи" ></span></div>
                                            </div>
                                            <select id="data_subcategory" class="form-control" name="data[_subcategory]">
                                                <option value="">Не выбрано</option>
                                                <xsl:apply-templates select="$subcategory" mode="options_of_select">
                                                    <xsl:with-param name="selected" select="//field[@name='_subcategory']/value" />
                                                </xsl:apply-templates>
                                            </select>
                                        </div>
                                    </xsl:if>
                                </div>
                            </xsl:if>
                            <!--<div class="checkbox">
                                <label>
                                    <input type="checkbox" name="data[eighteen_plus]" value="on">
                                        <xsl:if test="(//eighteen_plus = 'on')"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
                                    </input>
                                    18+
                                </label>
                            </div>-->
                        </div>
                        <div class="cl"></div>

                        <xsl:apply-templates select="document(concat('utype://',//field[@name='_type']/value))//group[not(@locked)][@visible='visible']" mode="new_article_group">
                            <xsl:with-param name="fields" select="//field" />
                        </xsl:apply-templates>

                        <div class="cl"></div>

                    </xsl:if>
                </div>

                <div class="sidebar">
                    <xsl:value-of select="$settings//property[@name='article_new_info']/value" disable-output-escaping="yes" />
                </div>
                <button type="button" class="btn btn-primary save_article">Сохранить статью</button>
                <xsl:if test="//field[@name='_edit_mode']/value != ''">
                    <a href="{//field[@name='_edit_mode_cancel']/value}"><button type="button" class="btn btn-default btn cancel">Отменить</button></a>
                </xsl:if>


                <div class="cl"></div>
            </div>
        </form>

        <div class="modal fade" id="not_enough_data" tabindex="-1" role="dialog" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header bg">
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span class="glyphicon glyphicon-remove" aria-hidden="true"></span></button>
                        <h4 class="modal-title">Сохранение новой статьи</h4>
                    </div>
                    <div class="modal-body">
                        <img src="/templates/iview/images/warning.png" />
                        Недостаточно данных для сохранения статьи.<br/>Должны быть заполнены поля отмеченные звездочкой (*).
                    </div>
                    <div class="modal-footer">
                        <div class="row">
                            <div class="col-md-5 text-left">
                                <button type="button" class="btn btn-default btn-sm" data-dismiss="modal">Закрыть</button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
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

    <xsl:template match="item" mode="options_of_select">
        <xsl:param name="selected" />
        <option value="{@id}">
            <xsl:if test="$selected and ($selected = @id)"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
            <xsl:value-of select="@name" disable-output-escaping="yes" />
        </option>
    </xsl:template>

    <xsl:template match="item" mode="all_article_types">
        <xsl:param name="selected" />
        <option value="{.//property[@name='type_id']/value}">
            <xsl:if test=".//property[@name='type_id']/value = $selected"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
            <xsl:value-of select="@name" />
        </option>
    </xsl:template>

    <xsl:template match="group" mode="new_article_group">
        <xsl:param name="fields" />
        <div class="title_block">
            <div><xsl:value-of select="@title" /></div>
        </div>
        <xsl:apply-templates select=".//field[@visible='visible']" mode="new_article_field">
            <xsl:with-param name="fields" select="$fields" />
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="field" mode="new_article_field">
        <xsl:param name="fields" />
        <xsl:variable name="name" select="@name" />
        
        <xsl:variable name="title">
            <xsl:choose>
                <xsl:when test="@name = 'h1'">Заголовок</xsl:when>
                <xsl:when test="@name = 'content'">Содержание</xsl:when>
                <xsl:otherwise><xsl:value-of select="@title" /></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="required">
            <xsl:choose>
                <xsl:when test="@name = 'h1'">required</xsl:when>
                <xsl:when test="@name = 'content'">required</xsl:when>
                <xsl:otherwise>
                    <xsl:if test="@required='required'">required</xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test=".//type/@data-type = 'string'">
                <div class="setting_chapter {$required}">
                    <div class="title"><xsl:value-of select="$title" />
                        <xsl:if test=".//tip">
                            <span class="glyphicon glyphicon-question-sign" data-toggle="tooltip" data-placement="top" title="{.//tip}"></span>
                        </xsl:if>
                    </div>
                    <div class="content_setting">
                        <div class="form-group">
                            <input type="text" name="data[{$name}]" class="form-control" value="{$fields[@name = $name]/value}" maxlength="255">
                                <xsl:if test="@name='h1'">
                                    <xsl:attribute name="reload_form">1</xsl:attribute>
                                </xsl:if>
                            </input>
                        </div>
                    </div>
                </div>
            </xsl:when>
            <xsl:when test="(.//type/@data-type = 'wysiwyg') or (.//type/@data-type = 'text')">
                <div class="setting_chapter {$required}">
                    <div class="title"><xsl:value-of select="$title" />
                        <xsl:if test=".//tip">
                            <span class="glyphicon glyphicon-question-sign" data-toggle="tooltip" data-placement="top" title="{.//tip}"></span>
                        </xsl:if>
                    </div>
                    <div class="content_setting">
                        <div class="form-group">
                            <textarea class="wysiwyg" id="wysiwyg_{@id}"><xsl:value-of select="$fields[@name = $name]/value" disable-output-escaping="yes" /></textarea>
                            <input type="hidden" data-for="wysiwyg_{@id}" name="data[{$name}]" value="" />
                        </div>
                    </div>
                </div>
            </xsl:when>
            <xsl:when test=".//type/@data-type = 'img_file'">
                <div class="setting_chapter {$required}">
                    <div class="title"><xsl:value-of select="$title" />
                        <xsl:if test=".//tip">
                            <span class="glyphicon glyphicon-question-sign" data-toggle="tooltip" data-placement="top" title="{.//tip}"></span>
                        </xsl:if>
                    </div>
                    <div class="content_setting photo">
                        <xsl:choose>
                            <xsl:when test="$fields[@name = $name]/value != ''">
                                <a href="{$fields[@name = $name]/value}" class="thumbnail popup_img" rel="article_img">
                                    <img src="{$fields[@name = $name]/value}" />
                                </a>
                                <span class="glyphicon glyphicon-remove remove" aria-hidden="true" onclick="$(this).parent().find('input').val(''); $(this).parent().find('input').change();"></span>
                                <input type="hidden" name="data[{$name}]" value="{$fields[@name = $name]/value}" reload_form="1" />
                            </xsl:when>
                            <xsl:otherwise>
                                <a href="#" class="thumbnail empty" data-fragment="" data-url="/content/upload_image_article/" data-parameters="field_name={$name}" onclick="GM.View.Images.UploadImage('upload_image_article', $(this));">+</a>
                            </xsl:otherwise>
                        </xsl:choose>
                    </div>
                </div>
            </xsl:when>
            <xsl:when test=".//type/@data-type = 'boolean'">
                <div class="setting_chapter {$required}">
                    <div class="content_setting">
                        <div class="checkbox">
                            <label>
                                <input type="checkbox" name="data[{$name}]" value="on">
                                    <xsl:if test="($fields[@name = $name]/value = 'on')"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
                                </input>
                                <xsl:value-of select="$title" />
                            </label>
                            <xsl:if test=".//tip">
                                <span class="glyphicon glyphicon-question-sign" data-toggle="tooltip" data-placement="top" title="{.//tip}"></span>
                            </xsl:if>
                        </div>
                    </div>
                </div>
            </xsl:when>
        </xsl:choose>

    </xsl:template>

</xsl:stylesheet>