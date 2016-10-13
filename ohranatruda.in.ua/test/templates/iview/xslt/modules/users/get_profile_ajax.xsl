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

    <xsl:include href="../images.xsl" />

    <xsl:template match="udata[@method='getProfile']">
        <form id="profile" class="profile" method="POST" action="/users/saveSettings/">
            <table width="100%">
                <tr>
                    <td valign="top" width="190">
                        <div class="avatar">
                            <xsl:apply-templates select="document(concat('udata://system/makeThumbnailFull/(.', //photo_fragment, ')/160/160/void/0/1/5/0/80/'))/udata" mode="imageProfile">
                                <xsl:with-param name="width" select="160" />
                                <xsl:with-param name="height" select="160" />
                                <xsl:with-param name="url" select="//photo" />
                            </xsl:apply-templates>
                            <xsl:if test="//photo_fragment != ''">
                                <span class="glyphicon glyphicon-remove remove" aria-hidden="true"></span>
                            </xsl:if>
                        </div>
                        <button class="btn btn-default" type="button" data-fragment="1" data-url="/users/upload_image_profile/" data-parameters="" onclick="GM.View.Images.UploadImage('upload_image_profile', $(this));"><xsl:choose>
                            <xsl:when test="//photo != ''">Изменить</xsl:when>
                            <xsl:otherwise>Добавить </xsl:otherwise>
                        </xsl:choose> фото</button>
                    </td>
                    <td valign="top">
                        <div class="form-group">
                            <label>Имя</label>
                            <input type="text" name="data[fname]" class="form-control input-sm required" value="{//fname}" maxlength="100" />
                            <span class="hide label label-warning" data-warning='min_length'>Укажите Ваше имя</span>
                        </div>
                        <div class="form-group">
                            <label>Фамилия</label>
                            <input type="text" name="data[lname]" class="form-control input-sm" value="{//lname}" maxlength="100" />
                        </div>
                        <div class="form-group birthday">
                            <label>День рождения</label>
                            <select class="form-control input-sm required" name="data[day]" data-select="{//birthday/day}" data-error="1">
                                <option value="{//birthday/day}" selected="selected" data-remove="1"><xsl:value-of select="//birthday/day" /></option>
                                <option value="">День</option>
                                <option data-counter_from="1" data-counter_to="31"></option>
                            </select>
                            <select class="form-control input-sm required" name="data[month]" data-error="2">
                                <option value="">Месяц</option>
                                <xsl:apply-templates select="document('udata://content/counter/1/12/1/months/1')//item" mode="options_of_select">
                                    <xsl:with-param name="selected" select="//birthday/month" />
                                </xsl:apply-templates>
                            </select>
                            <select class="form-control input-sm required" name="data[year]" data-select="{//birthday/year}" data-error="3">
                                <option value="{//birthday/year}" selected="selected" data-remove="1"><xsl:value-of select="//birthday/year" /></option>
                                <option value="">Год</option>
                                <option data-counter_from="1935" data-counter_to="{document('udata://system/convertDate/now/(Y)')/udata}"></option>
                            </select>
                            <span class="hide1 hide2 hide3 label label-warning label-warning" data-warning='min_length' data-error="1">Дата рождения указана неверно</span>
                        </div>
                    </td>
                </tr>
            </table>

            <div class="form-group birthday">
                <label>Адрес Вашей электронной почты</label>
                <input type="text" name="email" class="form-control input-sm required email" value="{//new_email}" maxlength="100" />
                <span class="hide label label-warning label-warning-email label-warning-required">Некорректный e-mail</span>
                <span class="hide label label-warning label-warning-check">Пользователь с таким e-mail уже зарегистрирован</span>
            </div>


            <div class="title_block">
                <div>Изменить пароль</div>
            </div>

            <xsl:if test="//recommend_change_password = '0'">
                <div class="form-group birthday">
                    <label>Старый пароль</label>
                    <input type="password" name="old_password" class="form-control input-sm" value="" maxlength="100" />
                    <span class="hide label label-warning label-warning-check">Пароль указан неверно</span>
                </div>
            </xsl:if>

            <div class="form-group birthday">
                <label>Новый пароль</label>
                <input type="password" name="password" class="form-control input-sm" value="" maxlength="100" />
                <span class="hide label label-warning label-warning-min_length">Пароль должен быть не короче 6 символов</span>
            </div>

            <div class="form-group birthday">
                <label>Повторите пароль</label>
                <input type="password" name="password_confirm" class="form-control input-sm" value="" maxlength="100" />
                <span class="hide label label-warning label-warning-compare">Введенные пароли не совпадают</span>
            </div>


            <div class="interests">
                <ul class="hide categories">
                    <xsl:apply-templates select="document('udata://content/menu///7')//item" mode="listCategories">
                        <xsl:with-param name="level">1</xsl:with-param>
                    </xsl:apply-templates>
                </ul>
                <div class="title_block">
                    <div>Мои интересы</div> <img class="preloader hide" src="/templates/iview/images/preloader.gif" />
                    <span class="right_text">Для подбора публикаций</span>
                </div>
                <!--<label>Мои интересы </label>-->
                <ul class="list">
                    <xsl:apply-templates select="document('udata://users/getInterestsOfUser')//item" mode="interests" />
                </ul>
                <span class="glyphicon glyphicon-plus"></span>
                <select class="form-control input-sm" data-cat="1"></select>
                <span class="glyphicon glyphicon-chevron-right hide" data-cat="2"></span>
                <select class="form-control input-sm hide" data-cat="2"></select>
                <span class="glyphicon glyphicon-chevron-right hide" data-cat="3"></span>
                <select class="form-control input-sm hide" data-cat="3"></select>
                <button class="btn btn-default btn-sm add" type="button">Добавить</button>
            </div>
            <input class="btn btn-primary btn-sm save" type="submit" value="Сохранить" />
        </form>

    </xsl:template>

    <xsl:template match="item" mode="options_of_select">
        <xsl:param name="selected" />
        <option value="{@id}">
            <xsl:if test="not($selected) and (position() = 1)"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
            <xsl:if test="$selected and ($selected = @id)"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
            <xsl:value-of select="@name" disable-output-escaping="yes" />
        </option>
    </xsl:template>

    <xsl:template match="item" mode="listCategories">
        <xsl:param name="level" />
        <xsl:variable name="subcategories" select="document(concat('udata://content/menu///',@id))//item" />
        <li data-id="{@id}" data-name="{@name}" data-cat="{$level}">
            <xsl:if test="count($subcategories) &gt; 0">
                <ul>
                    <xsl:apply-templates select="$subcategories" mode="listCategories">
                        <xsl:with-param name="level" select="$level + 1" />
                    </xsl:apply-templates>
                </ul>
            </xsl:if>
        </li>
    </xsl:template>

    <xsl:template match="item" mode="interests">
        <li class="interest-item">
            <xsl:apply-templates select=".//parents//parent" mode="interestsItem" />
            <span class="glyphicon glyphicon-remove remove" data-id="{@id}"></span>
        </li>
    </xsl:template>

    <xsl:template match="parent" mode="interestsItem">
        <xsl:value-of select=".//." disable-output-escaping="yes" />
        <xsl:if test="position() != last()"> <span class="glyphicon glyphicon-menu-right divider"></span> </xsl:if>
    </xsl:template>

    <xsl:template match="udata[@method='getInterestsOfUser']">
        <xsl:apply-templates select="//item" mode="interests" />
    </xsl:template>
</xsl:stylesheet>