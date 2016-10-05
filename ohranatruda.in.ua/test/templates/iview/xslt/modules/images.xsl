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

    <xsl:template match="udata[@module = 'system' and (@method = 'makeThumbnail' or @method = 'makeThumbnailFull')]" mode="image">
        <xsl:param name="alt"></xsl:param>
        <xsl:param name="schema_org">false</xsl:param>
        <img src="{src}" alt="{$alt}">
            <xsl:if test="$schema_org = 'true'">
                <xsl:attribute name="itemprop">contentUrl</xsl:attribute>
            </xsl:if>
        </img>
    </xsl:template>

    <xsl:template match="udata[@module = 'system' and (@method = 'makeThumbnail' or @method = 'makeThumbnailFull')]" mode="imageProfile">
        <xsl:param name="width" />
        <xsl:param name="height" />
        <xsl:param name="url" />
        <xsl:param name="class" />
        <xsl:param name="alt"></xsl:param>
        <xsl:choose>
            <xsl:when test="src">
                <xsl:choose>
                    <xsl:when test="$url">
                        <a href="{$url}" class="popup_img" rel="photo">
                            <img src="{src}" width="{width}" height="{height}" alt="{$alt}" />
                        </a>
                    </xsl:when>
                    <xsl:otherwise>
                        <img class="{$class}" src="{src}" width="{width}" height="{height}" alt="{$alt}" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="document(concat('udata://system/makeThumbnailFull/(./templates/iview/images/avatar_200.jpg)/',$width,'/',$height,'/void/0/1/5/0/90/'))/udata" mode="imageProfile">
                    <xsl:with-param name="class" select="$class" />
                    <xsl:with-param name="alt" select="$alt" />
                </xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="udata[@module = 'system' and (@method = 'makeThumbnail' or @method = 'makeThumbnailFull')]" mode="feedPhotoProfile">
        <xsl:param name="width" />
        <xsl:param name="height" />
        <xsl:param name="url" />
        <xsl:param name="alt"></xsl:param>
        <xsl:choose>
            <xsl:when test="src">
                <xsl:choose>
                    <xsl:when test="$url">
                        <a href="{$url}" class="popup_img" rel="photo">
                            <img src="{src}" width="{width}" height="{height}" alt="{$alt}" />
                        </a>
                    </xsl:when>
                    <xsl:otherwise>
                        <img src="{src}" width="{width}" height="{height}" alt="{$alt}" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <!--<xsl:apply-templates select="document(concat('udata://system/makeThumbnailFull/(./templates/iview/images/feed_ico.jpg)/',$width,'/',$height,'/void/0/1/5/0/90/'))/udata" mode="imageProfile">-->
                    <!--<xsl:with-param name="alt" select="$alt" />-->
                <!--</xsl:apply-templates>-->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="udata[@module = 'system' and (@method = 'makeThumbnail' or @method = 'makeThumbnailFull')]" mode="feedPhotoCover">
        <xsl:param name="alt"></xsl:param>
        <img class="adaptive_image" data-src="{src}" data-width="{width}" alt="{$alt}" />
    </xsl:template>

</xsl:stylesheet>