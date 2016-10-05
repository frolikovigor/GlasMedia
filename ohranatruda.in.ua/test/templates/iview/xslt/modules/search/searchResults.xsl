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

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:umi="http://www.umi-cms.ru/TR/umi"
                xmlns:Xsl="http://www.w3.org/1999/XSL/Transform">
	
	<xsl:template match="/result[@method = 's']">
        <xsl:call-template name="header" />
        <xsl:call-template name="panel" />
        <xsl:call-template name="panel_info" />

        <div id="search-results" class="shift_right">
            <div class="shell">
                <div class="content">
                    <xsl:apply-templates select="document('udata://search/s/')/udata" />
                </div>
                <div class="cl"></div>
            </div>
        </div>
	</xsl:template>
	
	
	<!--<xsl:template match="udata[@method = 'search_do']">
        <xsl:call-template name="search-header" />
			<xsl:text>&search-founded-left; "</xsl:text>
			<xsl:value-of select="$search_string" />
			<xsl:text>" &search-founded-nothing;.</xsl:text>

	</xsl:template>-->
	
	
	<xsl:template match="udata[@method = 's']">
        <!--and count(items/item)]-->
        <div class="header shadow">
            <form id="search-results-form" method="get" action="/search/s/">
                <div class="input-group">
                    <input type="text" class="form-control input-sm" name="search_string" placeholder="Поиск..." value="{//last_search_string}" />
                    <span class="input-group-btn">
                        <button class="btn btn-default btn-sm" type="submit"><span class="glyphicon glyphicon-search"></span></button>
                        <input id="search-results-type" type="hidden" name="search_types" value="{sections//section[@selected='1']/@type-id}" />
                    </span>
                </div>
            </form>

            <ul class="nav nav-pills">
                <xsl:apply-templates select="//sections/section" mode="search_sections" />
            </ul>
        </div>
        <xsl:variable name="type-id" select="//sections/section[@selected='1']/@type-id" />

        <xsl:text>&search-founded-left; "</xsl:text>
        <xsl:value-of select="$search_string" />
        <xsl:text>" </xsl:text>
        <xsl:value-of select="document(concat('udata://search/morphWords/', total, '/found/true/'))/udata" />
        <xsl:text> </xsl:text>
        <xsl:value-of select="total" />
        <xsl:text> </xsl:text>
        <xsl:value-of select="document(concat('udata://search/morphWords/', total, '/pages/true/'))/udata" />
        <xsl:text>.</xsl:text>

        <xsl:choose>
            <xsl:when test="count(items/item)">
                <xsl:choose>
                    <xsl:when test="$type-id = 71">
                        <img class="preloader_list hidden_block" src="/templates/iview/images/preloader.gif" />
                        <div class="content masonry hidden_block hidden_block_content" data-class-masonry="poll" data-masonry-gutter="20">
                            <xsl:apply-templates select="items/item" mode="getListVotes">
                                <xsl:with-param name="h">h2</xsl:with-param>
                            </xsl:apply-templates>
                        </div>
                        <div class="cl"></div>

                        <div class="paginated">
                            <xsl:apply-templates select="document(concat('udata://system/numpages/',//total,'/',//per_page,'/'))"  mode="paginated" />
                        </div>
                    </xsl:when>

                    <xsl:when test="$type-id = 146">
                        <img class="preloader_list hidden_block" src="/templates/iview/images/preloader.gif" />
                        <div class="content hidden_block hidden_block_content">
                            <xsl:apply-templates select="items/item" mode="OfListFeeds">
                                <xsl:with-param name="label_enabled">0</xsl:with-param>
                            </xsl:apply-templates>
                        </div>
                        <div class="cl"></div>

                        <div class="paginated">
                            <xsl:apply-templates select="document(concat('udata://system/numpages/',//total,'/',//per_page,'/'))"  mode="paginated" />
                        </div>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <div class="list_empty">
                    <p>По запросу "<b><xsl:value-of select="$search_string" /></b>" ничего не найдено.</p>
                    <p>Убедитесь, что все слова написаны без ошибок или попробуйте использовать другие ключевые слова.</p>
                </div>
            </xsl:otherwise>
        </xsl:choose>

        
        
        <!--<xsl:apply-templates select="items/item" mode="search-result" />-->
		<!--<xsl:apply-templates select="total" mode="paginated"/>-->
		
	</xsl:template>
	
	
	<xsl:template match="item" mode="search-result">

		<xsl:choose>
			<xsl:when test="$p">
				<xsl:value-of select="concat($p * ../../per_page + position(), '. ')" />		
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat(position(), '. ')" />		
			</xsl:otherwise>
		</xsl:choose>

		<a href="{@link}" umi:element-id="{@id}" umi:field-name="name">
			<xsl:value-of select="@name" />
		</a>
		<xsl:value-of select="." disable-output-escaping="yes" />
		
	</xsl:template>

    <xsl:template match="section" mode="search_sections">
        <li>
            <xsl:if test="@selected = '1'">
                <xsl:attribute name="class">active</xsl:attribute>
            </xsl:if>
            <a href="#" onclick="$('#search-results-type').val('{@type-id}'); $('#search-results-form').submit(); return false;"><xsl:value-of select=".//name" /> (<xsl:value-of select="@num" />)</a>
        </li>
    </xsl:template>
	
</xsl:stylesheet>