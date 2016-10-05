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

    <xsl:include href="index.xsl" />
    <!--<xsl:include href="widgets.xsl" />-->
    <xsl:include href="content.xsl" />
    <xsl:include href="articles.xsl" />
    <xsl:include href="new_article.xsl" />
    <xsl:include href="category.xsl" />
    <xsl:include href="menu.xsl" />
    
    <xsl:include href="sitemap.xsl" />
    <xsl:include href="404.xsl" />
    <xsl:include href="noscript.xsl" />
	


<!--    <table width="100%" height="100">
        <colgroup>
            <col style="width: 25%" />
            <col style="width: 25%" />
            <col style="width: 25%" />
            <col />
        </colgroup>
        <tr>
            <td colspan="3" rowspan="2">1</td>
            <td colspan="1" rowspan="3">1</td>
        </tr>
        <tr></tr>
        <tr>
            <td colspan="1" rowspan="1">3</td>
            <td colspan="2" rowspan="1">3</td>
        </tr>
    </table>-->



</xsl:stylesheet>