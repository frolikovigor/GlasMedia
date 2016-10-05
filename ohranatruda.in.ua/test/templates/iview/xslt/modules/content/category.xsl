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

    <xsl:template match="result[page/@type-id='133']">
        <xsl:call-template name="header" />
        <xsl:call-template name="panel" />
        <xsl:call-template name="panel_info" />

        <xsl:variable name="getListVotesOfCategory" select="document(concat('udata://vote/getListVotesOfCategory/',$document-page-id,'//auto/1'))" />

        <div id="view_category" class="shift_right">
            <div class="shell">
                <div class="header shadow">
                    <div class="title">
                        <span class="glyphicon {//property[@name='glyphicon_icon']/value}"></span>
                        <h1>
                            <xsl:value-of select="//property[@name='h1']/value" />
                            <span></span>
                        </h1>
                    </div>

                    <xsl:variable name="category_subcat_id">
                        <xsl:choose>
                            <xsl:when test="(count($parents//page[@type-id='133']) = 1) and (count($parents//page) = 1) and ($parents//page[@type-id='133']/@id = 7)">
                                <xsl:value-of select="$document-page-id" />
                            </xsl:when>
                            <xsl:when test="(count($parents//page[@type-id='133']) = 2) and (count($parents//page) = 2)">
                                <xsl:value-of select="$parents//page[position()=last()]/@id" />
                            </xsl:when>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="category_subcat" select="document(concat('udata://vote/xsltCache/31536000/(udata://content/menu///',$category_subcat_id,'/)'))//item" />

                    <xsl:if test="count($category_subcat)">
                        <ul class="subcategories">
                            <li><span class="glyphicon glyphicon-folder-open"></span></li>
                            <xsl:apply-templates select="$category_subcat" mode="category_subcat" />
                        </ul>
                    </xsl:if>

                    <xsl:call-template name="filters">
                        <xsl:with-param name="type">link</xsl:with-param>
                        <xsl:with-param name="link_new" select="1" />
                        <xsl:with-param name="link_old" select="1" />
                        <xsl:with-param name="popularity" select="1" />
                        <xsl:with-param name="fit" select="0" />
                    </xsl:call-template>
                </div>

                <xsl:choose>
                    <xsl:when test="count($getListVotesOfCategory/udata/items//item)">
                        <img class="preloader_list hidden_block" src="/templates/iview/images/preloader.gif" />
                        <div class="content masonry hidden_block hidden_block_content" data-class-masonry="poll" data-masonry-gutter="20">
                            <xsl:apply-templates select="$getListVotesOfCategory/udata/items//item" mode="getListVotes">
                                <xsl:with-param name="type">medium</xsl:with-param>
                                <xsl:with-param name="view_url">true</xsl:with-param>
                                <xsl:with-param name="h">h2</xsl:with-param>
                            </xsl:apply-templates>
                        </div>
                        <div class="cl"></div>

                        <div class="paginated">
                            <xsl:apply-templates select="document(concat('udata://system/numpages/',$getListVotesOfCategory//total,'/',$getListVotesOfCategory//per_page,'/'))"  mode="paginated" />
                        </div>
                    </xsl:when>
                    <xsl:otherwise>
                        <div class="list_empty">
                            Нет публикаций для отображения
                        </div>
                        <div class="category_empty">
                            <a href="/content/create_article/">
                                <button type="button" class="btn btn-default">Новая статья</button>
                            </a>
                            <a href="/vote/create_poll/">
                                <button type="button" class="btn btn-default">Новый опрос</button>
                            </a>
                        </div>
                    </xsl:otherwise>
                </xsl:choose>
            </div>
        </div>
    </xsl:template>

    <xsl:template match="item" mode="category_subcat">
        <li>
            <a href="{@link}">
                <xsl:if test="@id = $document-page-id">
                    <xsl:attribute name="class">active</xsl:attribute>
                </xsl:if>
                <xsl:value-of select="." />
            </a>
        </li>
    </xsl:template>

</xsl:stylesheet>