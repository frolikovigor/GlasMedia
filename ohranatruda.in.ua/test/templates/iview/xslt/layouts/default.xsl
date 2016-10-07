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
                xmlns:xsk="http://www.w3.org/1999/XSL/Transform">

    <xsl:output encoding="utf-8" method="html" indent="yes"/>

    <xsl:template match="/">
        <xsl:value-of select="document('udata://content/doAction/')" />


        <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE HTML&gt;</xsl:text>
        <html>
            <head>
                <title>
                    <xsl:variable name="title_sort_label">
                        <xsl:if test="$sort = 'old'"><xsl:text>Первые опросы</xsl:text></xsl:if>
                        <xsl:if test="$sort = 'popularity'"><xsl:text>Популярные опросы</xsl:text></xsl:if>
                        <xsl:if test="$sort = 'fit'"><xsl:text>Подобранные опросы</xsl:text></xsl:if>
                    </xsl:variable>

                    <xsl:choose>
                        <xsl:when test="$module = 'vote' and $method='get'">
                            <xsl:value-of select="//udata/name" />
                            <xsl:if test="$search_string != ''">
                                <xsl:text> :: </xsl:text>
                                <xsl:value-of select="$search_string" />
                            </xsl:if>
                            <xsl:text> :: Glas.Media </xsl:text>
                            <xsl:value-of select="$title_sort_label" />
                        </xsl:when>

                        <xsl:when test="$document-page-type-id = '133'">
                            <xsl:value-of select="$document-title" /> :: Glas.Media <xsl:value-of select="$title_sort_label" />
                        </xsl:when>

                        <xsl:when test="$module = 'vote' and $method='getlist'">
                            <xsl:value-of select="$settings//property[@name='title_feed_all']/value" />
                        </xsl:when>
                        <xsl:when test="$document-page-type-id = 71">
                            <xsl:value-of select="$document-title" />
                            <!--<xsl:text> | Опрос</xsl:text>-->
                        </xsl:when>
                        <xsl:when test="$module = 'search' and $method='s'">
                            <xsl:text>Поиск</xsl:text>
                        </xsl:when>
                        <xsl:when test="$module = 'vote' and $method='preview'">
                            <xsl:text>Предварительный просмотр</xsl:text>
                        </xsl:when>
                        <xsl:when test="$module = 'content' and $method='preview'">
                            <xsl:text>Предварительный просмотр</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$document-title" />
                            <xsl:if test="$p"><xsl:text> Страница </xsl:text><xsl:value-of select="$p+1" /></xsl:if>
                        </xsl:otherwise>
                    </xsl:choose>
                </title>
                <meta name="viewport" content="width=device-width" />
                <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
                <!--<meta name="keywords" content="{//meta/keywords}" />-->

                <xsl:variable name="description">
                    <xsl:choose>
                        <xsl:when test="$document-page-type-id = 71">
                            <xsl:text>Опрос | </xsl:text>
                            <xsl:choose>
                                <xsl:when test="//property[@name='anons']/value != ''">
                                    <xsl:value-of select="//property[@name='anons']/value" disable-output-escaping="yes" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="//property[@name='h1']/value" disable-output-escaping="yes" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                    </xsl:choose>
                </xsl:variable>

                <meta name="description" content="{$description}" />

                <!-- Оптимизация под социальные сети -->
                <xsl:if test="$module='vote' and $method='poll'">
                    <meta property="og:url"                content="http://{$domain}{/result/page/@link}" />
                    <meta property="og:type"               content="article" />
                    <meta property="og:title"              content="{//property[@name='h1']/value}" />
                    <meta property="og:description"        content="{$description}" />
                    <meta property="og:image"              content="http://glas.media/templates/iview/images/poster.jpg">
                        <xsl:if test="//property[@name='img_0']/value">
                            <xsl:attribute name="content">http://<xsl:value-of select="$domain" /><xsl:value-of select="//property[@name='img_0']/value" /></xsl:attribute>
                        </xsl:if>
                    </meta>
                    <link rel="image_src" href="http://glas.media/templates/iview/images/poster.jpg">
                        <xsl:if test="//property[@name='img_0']/value">
                            <xsl:attribute name="href">http://<xsl:value-of select="$domain" /><xsl:value-of select="//property[@name='img_0']/value" /></xsl:attribute>
                        </xsl:if>
                    </link>
                    <meta property="fb:app_id"             content="168290833526698" />

                    <meta name="twitter:card" content="summary" />
                    <meta name="twitter:site" content="http://{$domain}{/result/page/@link}" />
                    <meta name="twitter:title" content="{//property[@name='h1']/value}" />
                    <meta name="twitter:description" content="{$description}" />
                    <!--<meta name="twitter:creator" content="автор" />-->
                    <meta property="twitter:image:src" content="http://glas.media/templates/iview/images/poster.jpg">
                        <xsl:if test="//property[@name='img_0']/value">
                            <xsl:attribute name="content">http://<xsl:value-of select="$domain" /><xsl:value-of select="//property[@name='img_0']/value" /></xsl:attribute>
                        </xsl:if>
                    </meta>
                    <meta name="twitter:domain" content="glas.media" />

                </xsl:if>

                <link rel="shortcut icon" type="image/x-icon" href="/favicon.ico" />
                <!--<link rel="stylesheet" href="{$template-resources}css/bootstrap.min.css" />-->
                <!--<link rel="stylesheet" href="{$template-resources}css/bootstrap-theme.min.css" />-->
                <!--<link rel="stylesheet" href="{$template-resources}css/colorbox.css" />-->
                <!--<link rel="stylesheet" href="{$template-resources}css/cropper.min.css" />-->
                <!--<link rel="stylesheet" href="{$template-resources}css/style.css" type="text/css" media="all" />-->
                <link type="text/css" rel="stylesheet" href="/min/b=templates/iview/css&amp;f=bootstrap.min.css,bootstrap-theme.min.css,colorbox.css,cropper.min.css,social-likes_classic.css,introJs/introjs.css,style.css?{/result/@system-build}" />

                <!-- Если выключен javascript -->
                <xsl:if test="not($document-page-id) or ($document-page-id and ($document-page-id != 3311))">
                    <noscript>
                        <!--<meta http-equiv="refresh" content="0;URL=/service/noscript/" />-->
                        <link type="text/css" rel="stylesheet" href="{$template-resources}css/noscript.css" />
                    </noscript>
                </xsl:if>
            </head>

            <body>
                <input type="hidden" id="reloadValue" value="" />
                <script>
                    //При нажатии на back в браузере, выполняется перезагрузка
                    var reloadValue = new Date();
                    reloadValue = reloadValue.getTime();
                    if (document.getElementById('reloadValue').value == ""){
                    document.getElementById('reloadValue').value = reloadValue;
                    } else{
                    document.getElementById('reloadValue').value = '';
                    location.reload();
                    }
                </script>

                <input type="hidden" id="service-information"
                       data-lang="{$lang}"
                       data-page-id="{$document-page-id}"
                       data-page-type-id="{$document-page-type-id}"
                       data-user-id="{$user-id}"
                       data-user-type="{$user-type}"
                       data-goto="{$goto}"
                       data-preview="{$preview}"
                       data-sort="{$sort}"
                />

                <xsl:apply-templates select="result" />

                <div id="disabled_screen" class="hide"></div>

                <xsl:if test="$user-type = 'guest'">
                    <div class="modal fade" id="authorization" tabindex="-1" role="dialog" aria-hidden="true">
                        <form>
                            <div class="modal-dialog">
                                <div class="modal-content">
                                    <div class="inset" inset="1">
                                        <div class="modal-header bg">
                                            <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span class="glyphicon glyphicon-remove" aria-hidden="true"></span></button>
                                            <h4 class="modal-title">Авторизация <img class="preloader hide" src="/templates/iview/images/preloader.gif" /></h4>
                                        </div>
                                        <div class="modal-body">
                                            <div class="alert alert-warning hide" role="alert" warning="error">
                                                Произошла ошибка!
                                            </div>
                                            <div class="alert alert-warning hide" role="alert" warning="incorrect_password">
                                                Ошибка авторизации. Убедитесь в том, что включена английская раскладка клавиатуры и на клавиатуре отключен «Caps Lock». Затем повторите попытку ввода email и пароля.
                                            </div>
                                            <div class="alert alert-warning hide" role="alert" warning="incorrect_email">
                                                Некорректный e-mail
                                            </div>
                                            <div class="alert alert-warning hide" role="alert" warning="empty_email">
                                                Укажите свой Email
                                            </div>
                                            <div class="alert alert-warning hide" role="alert" warning="user_not_exist">
                                                Пользователь с таким e-mail не зарегистрирован или не подтвердил свою учетную запись переходом по ссылке в письме
                                            </div>
                                            <div class="form-group">
                                                <label>Email</label>
                                                <input type="text" name="email" class="form-control input-sm" />
                                            </div>
                                            <div class="form-group">
                                                <label>Пароль</label>
                                                <input type="password" name="password" class="form-control input-sm" />
                                            </div>
                                            <a class="remind_password" href="#">Забыл(а) пароль?</a>
                                        </div>
                                        <div class="modal-footer">
                                            <div class="row">
                                                <div class="col-md-6 col-xs-6 text-left">
                                                    <button type="button" class="btn btn-default btn next_p">Вход</button>
                                                </div>
                                                <div class="col-md-6 col-xs-6">
                                                    <button type="button" class="btn btn-primary btn set_inset" inset="2">Регистрация</button>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="inset hide" inset="2">
                                        <div class="modal-header bg">
                                            <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span class="glyphicon glyphicon-remove" aria-hidden="true"></span></button>
                                            <h4 class="modal-title">Регистрация нового пользователя <img class="preloader hide" src="/templates/iview/images/preloader.gif" /></h4>
                                        </div>
                                        <div class="modal-body">
                                            <div class="alert alert-warning hide" role="alert" warning="error">
                                                Произошла ошибка!
                                            </div>
                                            <div class="alert alert-warning hide" role="alert" warning="incorrect_new_password">
                                                Пароль должен быть не короче 6 символов
                                            </div>
                                            <div class="alert alert-warning hide" role="alert" warning="user_exist">
                                                Пользователь с таким e-mail уже зарегистрирован
                                            </div>
                                            <div class="alert alert-warning hide" role="alert" warning="incorrect_email">
                                                Некорректный e-mail
                                            </div>
                                            <div class="alert alert-warning hide" role="alert" warning="empty_email">
                                                Укажите свой Email
                                            </div>
                                            <div class="alert alert-warning hide" role="alert" warning="incorrect_name">
                                                Поле "Имя" должно быть заполнено
                                            </div>
                                            <div class="row">
                                                <div class="col-md-6 col-xs-6">
                                                    <div class="form-group">
                                                        <label class="required">Email</label>
                                                        <input type="text" class="form-control input-sm avatar_mail" name="email_reg" />
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="required">Пароль</label>
                                                        <input type="password" name="password_reg" class="form-control input-sm" />
                                                    </div>
                                                </div>
                                                <div class="col-md-6 col-xs-6">
                                                    <div class="form-group">
                                                        <label class="required">Имя</label>
                                                        <input type="text" class="form-control input-sm avatar_mail" name="name" />
                                                    </div>
                                                    <div class="form-group">
                                                        <label>День рождения</label>
                                                        <div class="row">
                                                            <div class="col-md-3 col-xs-3">
                                                                <select class="form-control input-sm" name="day">
                                                                    <option value="">День</option>
                                                                    <option data-counter_from="1" data-counter_to="31"></option>
                                                                </select>
                                                            </div>
                                                            <div class="col-md-4 col-xs-4">
                                                                <select class="form-control input-sm" name="month">
                                                                    <option value="">Месяц</option>
                                                                    <xsl:apply-templates select="document('udata://vote/xsltCache/31536000/(udata://content/counter/1/12/1/months/1/)')//item" mode="options_of_select" />
                                                                </select>
                                                            </div>
                                                            <div class="col-md-3 col-xs-3">
                                                                <select class="form-control input-sm" name="year">
                                                                    <option value="">Год</option>
                                                                    <option data-counter_from="1925" data-counter_to="{document('udata://vote/xsltCache/31536000/(udata://system/convertDate/now/(Y))/')/udata}"></option>
                                                                </select>
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <div class="form-group">
                                                        <label>Пол</label>
                                                        <div>
                                                            <label class="radio-inline">
                                                                <input type="radio" name="sex" value="male" checked="checked" /> Мужской
                                                            </label>
                                                            <label class="radio-inline">
                                                                <input type="radio" name="sex" value="female" /> Женский
                                                            </label>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                            <!--<div class="read_required">Нажимая кнопку «Зарегистрироваться», вы соглашаетесь с <a href="/cabinet/agreement/">Пользовательским соглашением</a>.</div>-->
                                        </div>
                                        <div class="modal-footer">
                                            <div class="row">
                                                <div class="col-md-6 col-xs-6 text-left">
                                                    <button type="button" class="btn btn-default btn set_inset" inset="1"><span class="glyphicon glyphicon-arrow-left"></span> Авторизация</button>
                                                </div>
                                                <div class="col-md-6 col-xs-6">
                                                    <button type="button" class="btn btn-primary btn next_p">Зарегистрироваться</button>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="inset hide" inset="3">
                                        <div class="modal-header bg">
                                            <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span class="glyphicon glyphicon-remove" aria-hidden="true"></span></button>
                                            <h4 class="modal-title">Авторизация <img class="preloader hide" src="/templates/iview/images/preloader.gif" /></h4>
                                        </div>
                                        <div class="modal-body">
                                            <div class="alert alert-warning hide" role="alert" warning="error">
                                                Произошла ошибка!
                                            </div>
                                            <h4>Восстановление пароля</h4>
                                            На указанный Вами адрес электронной почты отправлено письмо с новым паролем.
                                        </div>
                                        <div class="modal-footer">
                                            <div class="row">
                                                <div class="col-md-6 col-xs-6 text-left">
                                                    <button type="button" class="btn btn-default btn-sm" data-dismiss="modal">Закрыть</button>
                                                </div>
                                                <div class="col-md-6 col-xs-6">
                                                    <button type="button" class="btn btn-primary btn-sm next_p">Зарегистрироваться</button>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </form>
                    </div>
                </xsl:if>

                <xsl:if test="$user-type != 'guest'">
                    <div class="modal fade" id="new_feed_modal" tabindex="-1" aria-hidden="true">
                        <div class="modal-dialog">
                            <form method="POST" action="/vote/new_feed/">
                                <div class="modal-content">
                                    <div class="modal-header bg">
                                        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span class="glyphicon glyphicon-remove" aria-hidden="true"></span></button>
                                        <h4 class="modal-title">Новая лента</h4>
                                    </div>
                                    <div class="modal-body">
                                        <div class="form-group">
                                            <label>Введите название ленты</label>
                                            <input type="text" name="feed_name" class="form-control" onkeyup="if (!$(this).val()) $('#new_feed_modal .apply').prop('disabled', true); else $('#new_feed_modal .apply').prop('disabled', false);" maxlength="255" />
                                        </div>
                                    </div>
                                    <div class="modal-footer">
                                        <button type="button" class="btn btn-default btn-sm" data-dismiss="modal">Закрыть</button>
                                        <button type="submit" class="btn btn-primary btn-sm apply btn-preloader" disabled="disabled"><img src="/templates/iview/images/preloader.gif" /><span>Создать</span></button>
                                    </div>
                                </div>
                            </form>
                        </div>
                    </div>
                    <div class="modal fade" id="new_test_modal" tabindex="-1" aria-hidden="true">
                        <div class="modal-dialog">
                            <form method="POST" action="/vote/new_feed/1/">
                                <div class="modal-content">
                                    <div class="modal-header bg">
                                        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span class="glyphicon glyphicon-remove" aria-hidden="true"></span></button>
                                        <h4 class="modal-title">Новый тест</h4>
                                    </div>
                                    <div class="modal-body">
                                        <div class="form-group">
                                            <label>Введите название теста</label>
                                            <input type="text" name="feed_name" class="form-control" onkeyup="if (!$(this).val()) $('#new_test_modal .apply').prop('disabled', true); else $('#new_test_modal .apply').prop('disabled', false);" maxlength="255" />
                                        </div>
                                    </div>
                                    <div class="modal-footer">
                                        <button type="button" class="btn btn-default btn-sm" data-dismiss="modal">Закрыть</button>
                                        <button type="submit" class="btn btn-primary btn-sm apply btn-preloader" disabled="disabled"><img src="/templates/iview/images/preloader.gif" /><span>Создать</span></button>
                                    </div>
                                </div>
                            </form>
                        </div>
                    </div>
                </xsl:if>

                <div class="modal fade bs-example-modal-sm" id="captcha_enter" tabindex="-1" aria-hidden="true">
                    <div class="modal-dialog modal-sm">
                        <div class="modal-content">
                            <div class="modal-header bg">
                                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span class="glyphicon glyphicon-remove" aria-hidden="true"></span></button>
                                <h4 class="modal-title">Введите код с картинки</h4>
                            </div>
                            <div class="modal-body">
                                <xsl:apply-templates select="document('udata://system/captcha')/udata[url]" />
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-default btn-sm" data-dismiss="modal">Закрыть</button>
                                <button type="button" class="btn btn-primary btn-sm apply btn-preloader"><img src="/templates/iview/images/preloader.gif" /><span>Отправить</span></button>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Форма загрузки изображения -->
                <div class="modal fade" id="upload_image" tabindex="-1" role="dialog" aria-hidden="true" data-fragment="" >
                    <div class="modal-dialog">
                        <div class="modal-content">
                            <div class="modal-header bg">
                                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span class="glyphicon glyphicon-remove" aria-hidden="true"></span></button>
                                <h4 class="modal-title">Прикрепление фотографии <img class="preloader hide" src="/templates/iview/images/preloader.gif" /><span class="progress_bar hide"></span></h4>
                            </div>
                            <div class="modal-body">
                                <div class="form-group">
                                    <label>Загрузить с компьютера</label>
                                    <form action="" enctype="multipart/form-data" method="post">
                                        <input type="file" name="filename" style="position:absolute;" />
                                        <input type="hidden" name="crop" value="" />
                                        <input type="hidden" name="parameters" value="" />
                                    </form>
                                    <div class="input-group" onclick="$('#upload_image form input').click();">
                                        <input type="text" class="form-control input-sm" placeholder="Выберите файл" />
                                        <span class="input-group-btn">
                                            <button class="btn btn-default btn-sm" type="button">Обзор</button>
                                        </span>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label>Загрузить с Интернета</label>
                                    <input type="text" class="form-control" placeholder="Укажите URL" />
                                </div>
                                <div class="cropper" data-fragment=""></div>
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-default btn-sm close_abort" data-dismiss="modal">Закрыть</button>
                                <button type="button" class="btn btn-primary btn-sm apply" disabled="disabled">Прикрепить</button>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="modal fade" id="feedback" tabindex="-1" aria-hidden="true">
                    <div class="modal-dialog">
                        <div class="modal-content">
                            <div class="modal-header bg">
                                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span class="glyphicon glyphicon-remove" aria-hidden="true"></span></button>
                                <h4 class="modal-title">Обратная связь</h4>
                            </div>
                            <form id="feedback_form" method="post">
                                <div class="modal-body">
                                    <input type="hidden" name="system_email_to" value="3947" />
                                    <div class="alert alert-warning hide">Произошла непредвиденная ошибка. Попробуйте перезагрузить страницу и отправить сообщение повторно. Извините за неудобства.</div>

                                    <div class="form-group">
                                        <label>Пожалуйста, выберите тему сообщения</label>
                                        <select class="form-control input-sm" name="system_form_id">
                                            <option value="148" selected="selected">Проблема с регистрацией / авторизацией</option>
                                            <option value="149">Вопросы по работе сервиса</option>
                                        </select>
                                    </div>
                                    <div class="row">
                                    <div class="col-md-6 col-xs-6">
                                    <div class="form-group">
                                        <label>Ваше имя</label>
                                        <input type="text" name="data[new][name]" class="form-control input-sm required" value="" maxlength="100" />
                                    </div>
                                        </div>
                                        <div class="col-md-6 col-xs-6">
                                    <div class="form-group">
                                        <label>Email</label>
                                        <input type="text" name="data[new][email]" class="form-control input-sm required email" value="" maxlength="100" />
                                    </div>
                                        </div>
                                        </div>
                                    <div class="form-group">
                                        <label>Сообщение</label>
                                        <textarea name="data[new][comment]" class="form-control input-sm required"></textarea>
                                    </div>
                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-default btn-sm" data-dismiss="modal">Закрыть</button>
                                    <button type="submit" class="btn btn-primary btn-sm apply btn-preloader"><img src="/templates/iview/images/preloader.gif" /><span>Отправить</span></button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>

                <div class="modal fade" id="feedback_success" tabindex="-1" aria-hidden="true">
                    <div class="modal-dialog">
                        <div class="modal-content">
                            <div class="modal-header bg">
                                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span class="glyphicon glyphicon-remove" aria-hidden="true"></span></button>
                                <h4 class="modal-title">Обратная связь</h4>
                            </div>
                            <div class="modal-body">
                                Ваше сообщение успешно отправлено.  Мы постараемся Вам ответить в самое ближайшее время.
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-default btn-sm" data-dismiss="modal">Закрыть</button>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="modal fade" id="unexpected_error" tabindex="-1" aria-hidden="true">
                    <div class="modal-dialog">
                        <div class="modal-content">
                            <div class="modal-header bg">
                                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span class="glyphicon glyphicon-remove" aria-hidden="true"></span></button>
                                <h4 class="modal-title">Ошибка</h4>
                            </div>
                            <div class="modal-body">
                                Произошла непредвиденная ошибка. Перезагрузите, пожалуйста, страницу и выполните действие повторно. Извините за неудобства.
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-default btn-sm" data-dismiss="modal">Закрыть</button>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="modal fade" id="fast_poll_complete" tabindex="-1" aria-hidden="true">
                    <div class="modal-dialog">
                        <div class="modal-content">
                            <div class="modal-header bg">
                                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span class="glyphicon glyphicon-remove" aria-hidden="true"></span></button>
                                <h4 class="modal-title">Быстрый опрос</h4>
                            </div>
                            <div class="modal-body">
                                Опрос успешно создан. В самое ближайшее время, после проверки администратором, опрос появиться на сайте.<br/>
                                Спасибо за участие в нашем проекте.
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-default btn-sm" data-dismiss="modal">Закрыть</button>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="modal modal-wide fade" id="news_view_from_bd" tabindex="-1" aria-hidden="true">
                    <div class="modal-dialog">
                        <div class="modal-content">
                            <div class="modal-header bg">
                                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span class="glyphicon glyphicon-remove" aria-hidden="true"></span></button>
                                <h4 class="modal-title">Новость</h4>
                            </div>
                            <form action="/vote/create_poll/" method="get">
                                <div class="modal-body"></div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-default btn-sm" data-dismiss="modal">Закрыть</button>
                                    <button type="submit" class="btn btn-primary btn-sm apply btn-preloader"><img src="/templates/iview/images/preloader.gif" /><span>Создать опрос на основе новости</span></button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>

                <div class="modal fade" id="not_enough_data_poll" tabindex="-1" role="dialog" aria-hidden="true">
                    <div class="modal-dialog">
                        <div class="modal-content">
                            <div class="modal-header bg">
                                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span class="glyphicon glyphicon-remove" aria-hidden="true"></span></button>
                                <h4 class="modal-title">Сохранение нового опроса</h4>
                            </div>
                            <div class="modal-body">
                                <img src="/templates/iview/images/warning.png" />
                                Недостаточно данных для сохранения опроса.<br/>Должны быть заполнены тема опроса и минимум два варианта ответа.
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

                <div class="modal fade" id="images_incorrect" tabindex="-1" role="dialog" aria-hidden="true">
                    <div class="modal-dialog">
                        <div class="modal-content">
                            <div class="modal-header bg">
                                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span class="glyphicon glyphicon-remove" aria-hidden="true"></span></button>
                                <h4 class="modal-title">Сохранение нового опроса</h4>
                            </div>
                            <div class="modal-body">
                                <img src="/templates/iview/images/warning.png" />
                                Нужно расположить изображение(я) более компактно по высоте
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

                <footer id="footer" class="shift_right">
                    <xsl:if test="$user-id != '2'">
                        <div class="item">
                            <xsl:value-of select="$settings//property[@name='liveinternet']/value" disable-output-escaping="yes" />
                        </div>
                        <div class="item">
                            <div id='Rambler-counter'>
                                <noscript>
                                    <a href="http://top100.rambler.ru/navi/4418888/">
                                        <img src="http://counter.rambler.ru/top100.cnt?4418888" alt="Rambler's Top100" border="0" />
                                    </a>
                                </noscript>
                            </div>
                            <script type="text/javascript">
                                var _top100q = _top100q || [];
                                _top100q.push(['setAccount', '4418888']);
                                _top100q.push(['trackPageviewByLogo', document.getElementById('Rambler-counter')]);

                                (function(){
                                var pa = document.createElement("script");
                                pa.type = "text/javascript";
                                pa.async = true;
                                pa.src = ("https:" == document.location.protocol ? "https:" : "http:") + "//st.top100.ru/top100/top100.js";
                                var s = document.getElementsByTagName("script")[0];
                                s.parentNode.insertBefore(pa, s);
                                })();
                            </script>
                        </div>
                        <div class="item">
                            <!-- Rating@Mail.ru counter -->
                            <script type="text/javascript">
                                var _tmr = window._tmr || (window._tmr = []);
                                _tmr.push({id: "2768540", type: "pageView", start: (new Date()).getTime()});
                                (function (d, w, id) {
                                if (d.getElementById(id)) return;
                                var ts = d.createElement("script"); ts.type = "text/javascript"; ts.async = true; ts.id = id;
                                ts.src = (d.location.protocol == "https:" ? "https:" : "http:") + "//top-fwz1.mail.ru/js/code.js";
                                var f = function () {var s = d.getElementsByTagName("script")[0]; s.parentNode.insertBefore(ts, s);};
                                if (w.opera == "[object Opera]") { d.addEventListener("DOMContentLoaded", f, false); } else { f(); }
                                })(document, window, "topmailru-code");
                            </script>
                            <noscript>
                                <div style="position:absolute;left:-10000px;">
                                    <img src="//top-fwz1.mail.ru/counter?id=2768540;js=na" style="border:0;" height="1" width="1" alt="Рейтинг@Mail.ru" />
                                </div>
                            </noscript>
                            <!-- //Rating@Mail.ru counter -->
                            <!-- Rating@Mail.ru logo -->
                            <a href="http://top.mail.ru/jump?from=2768540">
                                <img src="//top-fwz1.mail.ru/counter?id=2768540;t=418;l=1"
                                     style="border:0;" height="31" width="88" alt="Рейтинг@Mail.ru" /></a>
                            <!-- //Rating@Mail.ru logo -->
                        </div>
                    </xsl:if>
                    <div class="item last">
                        <a href="mailto:support@glas.media">support@glas.media</a> GlasMedia © <xsl:value-of select="document('udata://system/convertDate/now/(Y)')/udata" />
                    </div>
                    <div class="cl"></div>
                </footer>
                <!--<script type="text/javascript" src="https://www.google.com/jsapi"></script>-->
                <!--<script src="//ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min.js"></script>-->
                <!--<script type="text/javascript" src="{$template-resources}js/query.cookie.js"></script>-->
                <!--<script type="text/javascript" src="{$template-resources}js/bootstrap.min.js"></script>-->
                <!--<script type="text/javascript" src="{$template-resources}js/masonry.pkgd.min.js"></script>-->
                <!--<script type="text/javascript" src="{$template-resources}js/cropper.min.js"></script>-->
                <!--<script type="text/javascript" src="{$template-resources}js/cc_validate.js"></script>-->
                <!--<script type="text/javascript" src="{$template-resources}js/jquery.colorbox-min.js" />-->
                <!--<script type="text/javascript" src="{$template-resources}js/scripts.js" />-->

                <xsl:if test="($document-page-id = '3245') or (/result/udata[@module='vote'][@method='get']/user = $user-id)">
                    <script type="text/javascript" src="/templates/iview/js/ckeditor/ckeditor.js" />
                </xsl:if>

                <!--<script async="async" type="text/javascript" src="/min/b=templates/iview/js&amp;f=jquery.min.js,google_jsapi.js,jquery.cookie.js,bootstrap.min.js,masonry.pkgd.min.js,cropper.min.js,cc_validate.js,jquery.colorbox-min.js,social-likes.min.js,jquery.form.js,jquery.gridster.min.js,introJs/intro.js,mousewhell.js,wait_for_images.js,ddd.js,touch_smartphoenes.js,scripts.js?{/result/@system-build}"></script>-->
                <script type="text/javascript" src="/templates/iview/js/scripts.js" />

                <!--<script type="text/javascript">socializ(encodeURIComponent('<xsl:value-of select="concat('http://',$domain,$document-link)" />'),encodeURIComponent('<xsl:value-of select="//property[@name='h1']/value" />'))</script>-->


            </body>

            <xsl:if test="$user-id != '2'">
                <!-- Yandex.Metrika counter -->
                <script type="text/javascript">
                    (function (d, w, c) {
                    (w[c] = w[c] || []).push(function() {
                    try {
                    w.yaCounter33985785 = new Ya.Metrika({id:33985785,clickmap:true});
                    } catch(e) { }
                    });

                    var n = d.getElementsByTagName("script")[0],
                    s = d.createElement("script"),
                    f = function () { n.parentNode.insertBefore(s, n); };
                    s.type = "text/javascript";
                    s.async = true;
                    s.src = (d.location.protocol == "https:" ? "https:" : "http:") + "//mc.yandex.ru/metrika/watch.js";

                    if (w.opera == "[object Opera]") {
                    d.addEventListener("DOMContentLoaded", f, false);
                    } else { f(); }
                    })(document, window, "yandex_metrika_callbacks");
                </script>
                <noscript><div><img src="//mc.yandex.ru/watch/33985785" style="position:absolute; left:-9999px;" alt="" /></div></noscript>
                <!-- /Yandex.Metrika counter -->
            </xsl:if>

        </html>

    </xsl:template>

</xsl:stylesheet>