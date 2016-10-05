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

    <xsl:template match="result[page/@alt-name='homepage']">
        <xsl:call-template name="header" />

        <!--<xsl:variable name="banner_4167" select="document('udata://content/banner/4167')/udata" />-->
        <!--<xsl:if test="$banner_4167 != ''">-->
            <!--<div class="shift_right">-->
                <!--<xsl:value-of select="$banner_4167" disable-output-escaping="yes" />-->
            <!--</div>-->
        <!--</xsl:if>-->

        <xsl:call-template name="panel" />
        <xsl:call-template name="panel_info" />

        <xsl:call-template name="home_page" />
    </xsl:template>

    <xsl:template match="feed" mode="getListFitFeedsPreview">
        <div class="poll medium feed_medium">
            <xsl:call-template name="feed_preview">
                <xsl:with-param name="id" select="@id" />
                <xsl:with-param name="per_page" select="$settings//property[@name='homepage_num_poll_in_feed']/value" />
                <xsl:with-param name="pagination">2</xsl:with-param>
                <xsl:with-param name="sort_polls">fit</xsl:with-param>
                <xsl:with-param name="enable_link_feed">1</xsl:with-param>
                <xsl:with-param name="enable_link_create">0</xsl:with-param>
                <xsl:with-param name="h1">0</xsl:with-param>
            </xsl:call-template>
        </div>
    </xsl:template>



    <xsl:template match="feed" mode="getListFitFeeds">
        <xsl:call-template name="feed">
            <xsl:with-param name="id" select="@id" />
            <xsl:with-param name="per_page" select="$settings//property[@name='homepage_num_poll_in_feed']/value" />
            <xsl:with-param name="pagination">2</xsl:with-param>
            <xsl:with-param name="sort_polls">fit</xsl:with-param>
            <xsl:with-param name="desc">1</xsl:with-param>
            <xsl:with-param name="enable_link_feed">1</xsl:with-param>
            <xsl:with-param name="enable_link_create">0</xsl:with-param>
            <xsl:with-param name="h1">0</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="catalog" mode="PopularCategoriesHomePage">
        <xsl:if test="./img != ''">
            <a href="{@link}">
                <div>
                    <img src="{./img}" width="{./img/@width}" height="{./img/@height}" alt="{@name}" />
                    <span><xsl:value-of select="@name" /></span>
                </div>
            </a>
        </xsl:if>
        <xsl:text> </xsl:text>
    </xsl:template>

    <xsl:template name="home_page">
        <xsl:param name="enabled_popular_categories">true</xsl:param>
        <xsl:param name="enabled_list_fit_feeds">true</xsl:param>

        <div id="homepage" class="shift_right">
            <xsl:if test="$enabled_popular_categories = 'true'">
                <div class="shell">
                    <div class="popular_categories">
                        <xsl:apply-templates select="document('udata://content/getListPopularCategories/')//catalog[position() &lt; 6]" mode="PopularCategoriesHomePage" />
                    </div>
                    <div class="cl"></div>
                </div>
            </xsl:if>
            <xsl:variable name="getListVotesOfCategory" select="document(concat('udata://vote/getListVotesOfCategory/7/',$settings//property[@name='homepage_num_poll_new']/value,'/auto/1/609/1/int_val/1'))" />
            <div class="shell">
                <div class="title_block light">
                    <xsl:choose>
                        <xsl:when test="$sort = 'popularity'">
                            <div>Популярные опросы</div>
                            <form class="right_text" action="/" onclick="$(this).submit();" method="POST">
                                <xsl:text>Показать новые</xsl:text>
                                <input type="hidden" name="sort" value="new" />
                            </form>
                        </xsl:when>
                        <xsl:otherwise>
                            <div>Новые опросы</div>
                            <form class="right_text" action="{$document-link}" onclick="$(this).submit();" method="POST">
                                <xsl:text>Показать популярные</xsl:text>
                                <input type="hidden" name="sort" value="popularity" />
                            </form>
                        </xsl:otherwise>
                    </xsl:choose>
                </div>


                <img class="preloader_list hidden_block" src="/templates/iview/images/preloader.gif" />

                <div class="content masonry hidden_block hidden_block_content" data-class-masonry="poll" data-masonry-gutter="20" data-block="1">

                    <div class="poll medium shadow new_poll_block" data-type="fast" data-for=""
                         data-tooltips-id="{$tooltips//item[@id='1']/@id}"
                         data-tooltips-content="{$tooltips//item[@id='1']/@content}"
                         data-tooltips-pos="{$tooltips//item[@id='1']/@pos}"
                    ></div>

                    <xsl:if test="$enabled_list_fit_feeds = 'true'">
                        <xsl:apply-templates select="document(concat('udata://vote/getListFitFeeds/',$settings//property[@name='homepage_num_feeds']/value))//feeds//feed" mode="getListFitFeedsPreview" />
                    </xsl:if>

                    <xsl:apply-templates select="$getListVotesOfCategory/udata/items//item" mode="getListVotes">
                        <xsl:with-param name="type">medium</xsl:with-param>
                        <xsl:with-param name="view_url">true</xsl:with-param>
                        <xsl:with-param name="h">h2</xsl:with-param>
                    </xsl:apply-templates>
                </div>

                <xsl:if test="$getListVotesOfCategory//last_page = '0'">
                    <button class="btn btn-default btn-white btn-preloader paginated_ajax"
                            for-data-block="1"
                            data-udata="/udata/vote/getListVotesOfCategory/7/{$settings//property[@name='homepage_num_poll_new']/value}/auto/1/609/1/int_val/1/"
                            data-transform="modules/content/ajax_getListVotesOfCategory.xsl"
                    >
                        <img src="/templates/iview/images/preloader.gif" />
                        <span>Еще</span>
                    </button>
                </xsl:if>

                <div class="cl"></div>
            </div>
        </div>
    </xsl:template>

</xsl:stylesheet>