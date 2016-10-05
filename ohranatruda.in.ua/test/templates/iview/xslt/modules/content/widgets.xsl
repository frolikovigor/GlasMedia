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

    <xsl:template match="result[@pageId=33]">
        <div id="body">
            <div id="content">
                <div id="head_widget_polls">
                    <div alt_name="info">
                        <xsl:variable name="getPage" select="document('upage://34')" />
                        <h2><xsl:value-of select="$getPage//property[@name='h1']//value" disable-output-escaping="yes" /></h2>
                        <xsl:value-of select="$getPage//property[@name='content']//value" disable-output-escaping="yes" />
                    </div>
                    <div class="hide" alt_name="settings">
                        <xsl:variable name="getPage" select="document('upage://35')" />
                        <h2><xsl:value-of select="$getPage//property[@name='h1']//value" disable-output-escaping="yes" /></h2>
                        <xsl:value-of select="$getPage//property[@name='content']//value" disable-output-escaping="yes" />
                    </div>
                    <div class="hide" alt_name="position">
                        <xsl:variable name="getPage" select="document('upage://36')" />
                        <h2><xsl:value-of select="$getPage//property[@name='h1']//value" disable-output-escaping="yes" /></h2>
                        <xsl:value-of select="$getPage//property[@name='content']//value" disable-output-escaping="yes" />
                    </div>
                    <div class="hide" alt_name="settings_item">
                        <xsl:variable name="getPage" select="document('upage://37')" />
                        <h2><xsl:value-of select="$getPage//property[@name='h1']//value" disable-output-escaping="yes" /></h2>
                        <xsl:value-of select="$getPage//property[@name='content']//value" disable-output-escaping="yes" />
                    </div>
                    <div class="hide" alt_name="result">
                        <xsl:variable name="getPage" select="document('upage://38')" />
                        <h2><xsl:value-of select="$getPage//property[@name='h1']//value" disable-output-escaping="yes" /></h2>
                        <xsl:value-of select="$getPage//property[@name='content']//value" disable-output-escaping="yes" />
                    </div>
                    <div class="hide" alt_name="get_code">
                        <xsl:variable name="getPage" select="document('upage://39')" />
                        <h2><xsl:value-of select="$getPage//property[@name='h1']//value" disable-output-escaping="yes" /></h2>
                        <xsl:value-of select="$getPage//property[@name='content']//value" disable-output-escaping="yes" />
                    </div>
                </div>


                <div id="widget_preview_template" class="hide">
                    <ul item="0">
                        <li class="item" item="1" name="widget_polls[title]"><span></span></li>
                        <li class="item" item="2" name="widget_polls[interview]"><span></span></li>
                        <li class="item" item="3" name="widget_polls[image]"><span></span></li>
                        <li class="item" item="4">
                            <ul style="list-style:none;margin:0px;padding:0px;">
                                <li name="widget_polls[answer][]"><input name="widget_polls[answer][]" type="radio" style="vertical-align:middle;margin:-2px 5px 0px 0px;" /><span></span></li>
                                <li name="widget_polls[answer][]"><input name="widget_polls[answer][]" type="radio" style="vertical-align:middle;margin:-2px 5px 0px 0px;" /><span></span></li>
                                <li name="widget_polls[answer][]"><input name="widget_polls[answer][]" type="radio" style="vertical-align:middle;margin:-2px 5px 0px 0px;" /><span></span></li>
                                <li name="widget_polls[answer][]"><input name="widget_polls[answer][]" type="radio" style="vertical-align:middle;margin:-2px 5px 0px 0px;" /><span></span></li>
                                <li name="widget_polls[answer][]"><input name="widget_polls[answer][]" type="radio" style="vertical-align:middle;margin:-2px 5px 0px 0px;" /><span></span></li>
                                <li name="widget_polls[answer][]"><input name="widget_polls[answer][]" type="radio" style="vertical-align:middle;margin:-2px 5px 0px 0px;" /><span></span></li>
                                <li name="widget_polls[answer][]"><input name="widget_polls[answer][]" type="radio" style="vertical-align:middle;margin:-2px 5px 0px 0px;" /><span></span></li>
                                <li name="widget_polls[answer][]"><input name="widget_polls[answer][]" type="radio" style="vertical-align:middle;margin:-2px 5px 0px 0px;" /><span></span></li>
                                <li name="widget_polls[answer][]"><input name="widget_polls[answer][]" type="radio" style="vertical-align:middle;margin:-2px 5px 0px 0px;" /><span></span></li>
                                <li name="widget_polls[answer][]"><input name="widget_polls[answer][]" type="radio" style="vertical-align:middle;margin:-2px 5px 0px 0px;" /><span></span></li>
                                <li name="widget_polls[answer][]"><input name="widget_polls[answer][]" type="radio" style="vertical-align:middle;margin:-2px 5px 0px 0px;" /><span></span></li>
                                <li name="widget_polls[answer][]"><input name="widget_polls[answer][]" type="radio" style="vertical-align:middle;margin:-2px 5px 0px 0px;" /><span></span></li>
                                <li name="widget_polls[answer][]"><input name="widget_polls[answer][]" type="radio" style="vertical-align:middle;margin:-2px 5px 0px 0px;" /><span></span></li>
                                <li name="widget_polls[answer][]"><input name="widget_polls[answer][]" type="radio" style="vertical-align:middle;margin:-2px 5px 0px 0px;" /><span></span></li>
                                <li name="widget_polls[answer][]"><input name="widget_polls[answer][]" type="radio" style="vertical-align:middle;margin:-2px 5px 0px 0px;" /><span></span></li>
                                <li name="widget_polls[answer][]"><input name="widget_polls[answer][]" type="radio" style="vertical-align:middle;margin:-2px 5px 0px 0px;" /><span></span></li>
                                <li name="widget_polls[answer][]"><input name="widget_polls[answer][]" type="radio" style="vertical-align:middle;margin:-2px 5px 0px 0px;" /><span></span></li>
                                <li name="widget_polls[answer][]"><input name="widget_polls[answer][]" type="radio" style="vertical-align:middle;margin:-2px 5px 0px 0px;" /><span></span></li>
                                <li name="widget_polls[answer][]"><input name="widget_polls[answer][]" type="radio" style="vertical-align:middle;margin:-2px 5px 0px 0px;" /><span></span></li>
                                <li name="widget_polls[answer][]"><input name="widget_polls[answer][]" type="radio" style="vertical-align:middle;margin:-2px 5px 0px 0px;" /><span></span></li>
                            </ul>
                        </li>
                    </ul>
                </div>
                <div id="widget_preview" class="clear"><ul item="0"></ul></div>

                <form id="new_widget_polls" class="form-horizontal" action="/content/save_widget_polls/" method="post" enctype="multipart/form-data">
                    <div alt_name="info">
                        <div class="jumbotron">
                            <div class="container">
                                <div class="form-group">
                                    <label class="col-sm-4 control-label">Название сайта: *</label>
                                    <div class="col-sm-6">
                                        <input type="text" class="form-control input-sm required" name="widget_polls[site_name][]" value="Мой сайт" />
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="col-sm-4 control-label">Адрес сайта: *</label>
                                    <div class="col-sm-6">
                                        <input type="text" class="form-control input-sm required url" name="widget_polls[site_address][]" value="http://yoursite.ru" />
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="col-sm-4 control-label">Тематика сайта:</label>
                                    <div class="col-sm-6">
                                        <select class="form-control input-sm" name="widget_polls[theme]">
                                            <xsl:apply-templates select="document('udata://content/menu///7')//item" mode="options_of_select_1" />
                                        </select>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <button type="button" class="btn btn-default btn-primary next" alt_name="settings">Далее</button>
                    </div>


                    <div class="hide" alt_name="settings">
                        <input type="text" class="hide" item="0" set_style="list-style:none;margin:0px auto;padding:0px;overflow:hidden;font-family:Arial;" value="" />
                        <div class="jumbotron">
                            <div class="container">
                                <div class="form-group">
                                    <label class="col-sm-4 control-label">Ширина, px:</label>
                                    <div class="col-sm-6">
                                        <input type="number" class="form-control input-sm" value="300" min="50" max="2000" placeholder="100%" item="0" set_style="width:" suffix="px;" />
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="col-sm-4 control-label">Высота, px:</label>
                                    <div class="col-sm-6">
                                        <input type="number" class="form-control input-sm" value="" min="50" max="2000" placeholder="auto" item="0" set_style="height:" suffix="px;" />
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="col-sm-4 control-label">Толщина границы, px:</label>
                                    <div class="col-sm-6">
                                        <input type="number" class="form-control input-sm" value="1" min="0" item="0" set_style="border:" suffix="px solid;" />
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="col-sm-4 control-label">Цвет границы:</label>
                                    <div class="col-sm-6">
                                        <input type="text" class="form-control input-sm color_select" value="#dddddd" item="0" set_style="border-color:" suffix=";" />
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="col-sm-4 control-label">Радиус скругления, px:</label>
                                    <div class="col-sm-6">
                                        <input type="number" class="form-control input-sm" value="5" min="0" item="0" set_style="border-radius:" suffix="px;" />
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="col-sm-4 control-label">Тень:</label>
                                    <div class="col-sm-6">
                                        <div class="checkbox">
                                            <label>
                                                <input type="checkbox" checked="checked" for_item="0" for_set_style="box-shadow: 2px 2px 10px " />
                                            </label>
                                        </div>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="col-sm-4 control-label">Цвет тени:</label>
                                    <div class="col-sm-6">
                                        <input type="text" class="form-control input-sm color_select" value="#ededed" item="0" set_style="box-shadow: 2px 2px 10px " suffix=";" />
                                    </div>
                                </div>
                            </div>
                        </div>
                        <button type="button" class="btn btn-default btn-primary prev" alt_name="info">Назад</button>
                        <button type="button" class="btn btn-default btn-primary next" alt_name="position">Далее</button>
                    </div>


                    <div class="hide" alt_name="position">
                        <button type="button" class="btn btn-default btn-primary prev" alt_name="settings">Назад</button>
                        <button type="button" class="btn btn-default btn-primary next" alt_name="settings_item">Далее</button>
                    </div>


                    <div class="hide" alt_name="settings_item">
                        <ul class="nav nav-tabs">
                            <li class="active" item="1"><a href="#">Заголовок</a></li>
                            <li item="2"><a href="#">Тема опроса</a></li>
                            <li item="3"><a href="#">Изображение</a></li>
                            <li item="4"><a href="#">Ответы</a></li>
                        </ul>

                        <div class="jumbotron">
                            <div class="container">
                                <div item="1">
                                    <div class="form-group">
                                        <label class="col-sm-4 control-label">Показать заголовок:</label>
                                        <div class="col-sm-6">
                                            <div class="checkbox">
                                                <label>
                                                    <input type="checkbox" checked="checked" set_visible_item="1" />
                                                </label>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-4 control-label">Заголовок опроса:</label>
                                        <div class="col-sm-6">
                                            <input type="text" class="form-control input-sm" name="widget_polls[title]" value="Нам важно ваше мнение!" />
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-4 control-label">Цвет фона:</label>
                                        <div class="col-sm-6">
                                            <input type="text" class="form-control input-sm color_select" value="#ebebeb" item="1" set_style="background-color:" suffix=";" />
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-4 control-label">Отступ, px:</label>
                                        <div class="col-sm-6">
                                            <input type="number" class="form-control input-sm" value="5" min="0" max="50" placeholder="0px" item="1" set_style="padding:" suffix="px;" />
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-4 control-label">Размер шрифта, px:</label>
                                        <div class="col-sm-6">
                                            <input type="number" class="form-control input-sm" min="6" max="36" placeholder="auto" item="1" set_style="font-size:" suffix="px;" />
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-4 control-label">Выравнивание:</label>
                                        <div class="col-sm-6">
                                            <label class="radio-inline">
                                                <input type="radio" checked="checked" name="align_1" for_item="1" for_set_style="text-align:left" /> Слева
                                            </label>
                                            <label class="radio-inline">
                                                <input type="radio" name="align_1" for_item="1" for_set_style="text-align:center" /> По центру
                                            </label>
                                            <label class="radio-inline">
                                                <input type="radio" name="align_1" for_item="1" for_set_style="text-align:right" /> Справа
                                            </label>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-4 control-label">Полужирное начертание:</label>
                                        <div class="col-sm-6">
                                            <div class="checkbox">
                                                <label>
                                                    <input type="checkbox" for_item="1" for_set_style="font-weight:bold" />
                                                </label>
                                            </div>
                                        </div>
                                    </div>
                                    <input type="text" class="hide" item="1" set_style="text-align:left" value="" suffix=";" />
                                    <input type="text" class="hide" item="1" set_style="text-align:center" value="" suffix=";" />
                                    <input type="text" class="hide" item="1" set_style="text-align:right" value="" suffix=";" />
                                    <input type="text" class="hide" item="1" set_style="font-weight:bold" value="" suffix=";" />
                                </div>

                                <div item="2" class="hide">
                                    <div class="form-group">
                                        <label class="col-sm-4 control-label">Тема опроса: *</label>
                                        <div class="col-sm-6">
                                            <input type="text" class="form-control input-sm required" name="widget_polls[interview]" value="Каким браузером Вы пользуетесь?" />
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-4 control-label">Цвет фона:</label>
                                        <div class="col-sm-6">
                                            <input type="text" class="form-control input-sm color_select" value="#fafafa" item="2" set_style="background-color:" suffix=";" />
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-4 control-label">Отступ, px:</label>
                                        <div class="col-sm-6">
                                            <input type="number" class="form-control input-sm" value="7" min="0" max="50" placeholder="0px" item="2" set_style="padding:" suffix="px;" />
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-4 control-label">Размер шрифта, px:</label>
                                        <div class="col-sm-6">
                                            <input type="number" class="form-control input-sm" min="6" max="36" placeholder="auto" item="2" set_style="font-size:" suffix="px;" />
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-4 control-label">Выравнивание:</label>
                                        <div class="col-sm-6">
                                            <label class="radio-inline">
                                                <input type="radio" checked="checked" name="align_2" for_item="2" for_set_style="text-align:left" /> Слева
                                            </label>
                                            <label class="radio-inline">
                                                <input type="radio" name="align_2" for_item="2" for_set_style="text-align:center" /> По центру
                                            </label>
                                            <label class="radio-inline">
                                                <input type="radio" name="align_2" for_item="2" for_set_style="text-align:right" /> Справа
                                            </label>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-4 control-label">Полужирное начертание:</label>
                                        <div class="col-sm-6">
                                            <div class="checkbox">
                                                <label>
                                                    <input type="checkbox" for_item="2" for_set_style="font-weight:bold" />
                                                </label>
                                            </div>
                                        </div>
                                    </div>
                                    <input type="text" class="hide" item="2" set_style="text-align:left" value="" suffix=";" />
                                    <input type="text" class="hide" item="2" set_style="text-align:center" value="" suffix=";" />
                                    <input type="text" class="hide" item="2" set_style="text-align:right" value="" suffix=";" />
                                    <input type="text" class="hide" item="2" set_style="font-weight:bold" value="" suffix=";" />
                                </div>

                                <div item="3" class="hide">
                                    <div class="form-group">
                                        <label class="col-sm-4 control-label">Показать изображение:</label>
                                        <div class="col-sm-6">
                                            <div class="checkbox">
                                                <label>
                                                    <input type="checkbox" checked="checked" set_visible_item="3" />
                                                </label>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-4 control-label">URL изображения:</label>
                                        <div class="col-sm-6">
                                            <input id="url_image" type="text" class="form-control input-sm" name="widget_polls[image_url]" value="/templates/iview/images/test.png" item="3" set_style="background: url(" suffix=");" />
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-4 control-label">Загрузить с компьютера:</label>
                                        <div class="col-sm-2">
                                            <input id="select_file" type="button" class="btn btn-sm btn-primary" value="Обзор" onclick="$('#selected_file input').val(''); $('#selected_file input').click();" />
                                            <div id="selected_file" style="height:0px; width:0px; overflow:hidden">
                                                <input type="file" name="filename" onchange="$('#new_widget_polls').submit()" />
                                            </div>
                                        </div>
                                        <div class="col-sm-4">
                                            <div class="progress hide">
                                                <div class="progress-bar" role="progressbar" style="width: 0%;">0%</div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-4 control-label">Цвет фона:</label>
                                        <div class="col-sm-6">
                                            <input type="text" class="form-control input-sm color_select" value="#fafafa" item="3" set_style="background-color:" suffix=";" />
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-4 control-label">Высота, px:</label>
                                        <div class="col-sm-6">
                                            <input type="number" class="form-control input-sm" value="120" min="10" max="1000" placeholder="0px" item="3" set_style="height:" suffix="px;" />
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-4 control-label">Выравнивание:</label>
                                        <div class="col-sm-6">
                                            <label class="radio-inline">
                                                <input type="radio" name="align_3" for_item="3" for_set_style="background-position:left" /> Слева
                                            </label>
                                            <label class="radio-inline">
                                                <input type="radio" checked="checked" name="align_3" for_item="3" for_set_style="background-position:center" /> По центру
                                            </label>
                                            <label class="radio-inline">
                                                <input type="radio" name="align_3" for_item="3" for_set_style="background-position:right" /> Справа
                                            </label>
                                        </div>
                                    </div>
                                    <input type="text" class="hide" item="3" set_style="background-repeat:no-repeat;background-size:auto 100%;" value="" />
                                    <input type="text" class="hide" item="3" set_style="background-position:left" value="" suffix=";" />
                                    <input type="text" class="hide" item="3" set_style="background-position:center" value="" suffix=";" />
                                    <input type="text" class="hide" item="3" set_style="background-position:right" value="" suffix=";" />
                                </div>

                                <div item="4" class="hide">
                                    <div class="form-group">
                                        <label class="col-sm-4 control-label">Варианты ответов: *
                                            <span class="add_del"><a href="#" class="add">Добавить</a> / <a href="#" class="del">удалить</a></span>
                                        </label>
                                        <div class="col-sm-6 variant">
                                            <input type="text" class="form-control input-sm required" name="widget_polls[answer][]" value="Google Chrome" />
                                            <input type="text" class="form-control input-sm required" name="widget_polls[answer][]" value="Opera" />
                                            <input type="text" class="form-control input-sm required" name="widget_polls[answer][]" value="Mozilla Firefox" />
                                            <input type="text" class="form-control input-sm required" name="widget_polls[answer][]" value="Yandex Browser" />
                                            <input type="text" class="form-control input-sm required" name="widget_polls[answer][]" value="Internet Explorer" />
                                            <input type="text" class="form-control input-sm required" name="widget_polls[answer][]" value="Safari" />
                                            <input type="text" class="form-control input-sm required" name="widget_polls[answer][]" value="Другой" />
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-4 control-label">Цвет фона:</label>
                                        <div class="col-sm-6">
                                            <input type="text" class="form-control input-sm color_select" value="#fafafa" item="4" set_style="background-color:" suffix=";" />
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-4 control-label">Отступ, px:</label>
                                        <div class="col-sm-6">
                                            <input type="number" class="form-control input-sm" value="10" min="0" max="50" placeholder="0px" item="4" set_style="padding:" suffix="px;" />
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-4 control-label">Размер шрифта, px:</label>
                                        <div class="col-sm-6">
                                            <input type="number" class="form-control input-sm" min="6" max="36" placeholder="auto" item="4" set_style="font-size:" suffix="px;" />
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-4 control-label">Выравнивание:</label>
                                        <div class="col-sm-6">
                                            <label class="radio-inline">
                                                <input type="radio" checked="checked" name="align_4" for_item="4" for_set_style="text-align:left" /> Слева
                                            </label>
                                            <label class="radio-inline">
                                                <input type="radio" name="align_4" for_item="4" for_set_style="text-align:center" /> По центру
                                            </label>
                                            <label class="radio-inline">
                                                <input type="radio" name="align_4" for_item="4" for_set_style="text-align:right" /> Справа
                                            </label>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-4 control-label">Полужирное начертание:</label>
                                        <div class="col-sm-6">
                                            <div class="checkbox">
                                                <label>
                                                    <input type="checkbox" for_item="4" for_set_style="font-weight:bold" />
                                                </label>
                                            </div>
                                        </div>
                                    </div>
                                    <input type="text" class="hide" item="4" set_style="text-align:left" value="" suffix=";" />
                                    <input type="text" class="hide" item="4" set_style="text-align:center" value="" suffix=";" />
                                    <input type="text" class="hide" item="4" set_style="text-align:right" value="" suffix=";" />
                                    <input type="text" class="hide" item="4" set_style="font-weight:bold" value="" suffix=";" />
                                </div>
                            </div>
                        </div>
                        <button type="button" class="btn btn-default btn-primary prev" alt_name="position">Назад</button>
                        <button type="button" class="btn btn-default btn-primary next" alt_name="result">Далее</button>
                    </div>


                    <div class="hide" alt_name="result">
                        <div class="jumbotron">
                            <div class="container">
                                <select class="form-control input-sm" id="type_diagram">
                                    <option value="PieChart" selected="selected">Круговая</option>
                                    <option value="ColumnChart">Линейная</option>
                                </select>
                            </div>
                        </div>
                        <button type="button" class="btn btn-default btn-primary prev" alt_name="settings_item">Назад</button>
                        <button type="button" class="btn btn-default btn-primary next" alt_name="get_code">Далее</button>
                    </div>


                    <div class="hide" alt_name="get_code">
                        <div class="jumbotron">
                            <div class="container">
                                <textarea>asdasd</textarea>
                            </div>
                        </div>
                        <button type="button" class="btn btn-default btn-primary prev" alt_name="result" style="float:left">Назад</button>
                    </div>
                </form>
            </div>

            <div class="sidebar">
                <ul>
                    <li>
                        <div class="side-menu">
                            <nav class="navbar navbar-default">
                                <div class="side-menu-container">
                                    <ul class="nav navbar-nav nav-new_widget_polls">
                                        <xsl:apply-templates select="document('udata://content/menu///33')//item" mode="widget_menu" />
                                    </ul>
                                </div>
                            </nav>
                        </div>
                    </li>
                </ul>
            </div>
            <div class="clear"></div>
        </div>
    </xsl:template>

    <xsl:template match="item" mode="options_of_select_1">
        <option value="{@id}">
            <xsl:if test="position() = 1"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
            <xsl:value-of select="@name" disable-output-escaping="yes" />
        </option>
    </xsl:template>

    <xsl:template match="item" mode="widget_menu">
        <li class="disabled">
            <xsl:if test="position() = 1">
                <xsl:attribute name="class">active</xsl:attribute>
            </xsl:if>
            <a href="#" alt_name="{@alt-name}"><xsl:value-of select="@name" disable-output-escaping="yes" /></a>
        </li>
    </xsl:template>

</xsl:stylesheet>