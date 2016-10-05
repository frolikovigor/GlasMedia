<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xlink="http://www.w3.org/TR/xlink">
            
    <xsl:output encoding="utf-8" method="html" indent="yes" />

    <xsl:variable name="identifications" select="document('udata://users/identification/')" />
    <xsl:variable name="geo" select="document('udata://vote/geo/')" />
	<xsl:variable name="errors" select="document('udata://system/listErrorMessages')/udata"/>

	<xsl:variable name="lang-prefix" select="/result/@pre-lang"/>
	<xsl:variable name="lang" select="/result/@lang"/>
	<xsl:variable name="parents" select="/result/parents" />
    <xsl:variable name="document-page-id" select="/result/@pageId" />
    <xsl:variable name="document-page-type-id" select="/result/page/@type-id" />
    <xsl:variable name="document-page-object-id" select="/result/page/@object-id" />
    <xsl:variable name="document-page-alt-name" select="/result/page/@alt-name" />
    <xsl:variable name="document-link" select="document('udata://content/currentUrl/')/udata" />
    <xsl:variable name="parent-id" select="/result/page/@parentId" />
    <xsl:variable name="parent-root" select="/result/parents/page/@id" />
    <xsl:variable name="document-title" select="/result/@title" />
    <xsl:variable name="request-uri" select="/result/@request-uri" />
    <xsl:variable name="domain" select="/result/@domain" />
    <xsl:variable name="is-default" select="/result/page/@is-default" />
    <xsl:variable name="main-page-id" select="1" />
    <xsl:variable name="settings" select="document('uobject://3934')" />
    <!--<xsl:variable name="main-page" select="document(concat('upage://', document('udata://content/getDefaultPageId/')/udata))/udata" />-->
    
    <xsl:variable name="module" select="/result/@module" />
    <xsl:variable name="method" select="/result/@method" />
    
	<xsl:variable name="user-id" select="/result/user/@id" />
	<xsl:variable name="user-type" select="/result/user/@type" />
	<xsl:variable name="user-info" select="document(concat('uobject://', $user-id))" />
    <xsl:variable name="notifications" select="document('udata://users/getUserNotification/')" />
    <xsl:variable name="captcha" select="document('udata://system/captcha/')" />
    <xsl:variable name="counters" select="document(concat('udata://vote/viewsCounter/',$document-page-object-id))/udata" />
    <xsl:variable name="sort" select="document('udata://content/sort_cookie/')/udata" />
    <xsl:variable name="tooltips" select="document('udata://content/tooltips/')/udata" />

    <xsl:param name="p" />
    <xsl:param name="search_string" />
    <xsl:param name="template" />
    <xsl:param name="comment_posted" />
    <xsl:param name="goto" />
    <xsl:param name="preview" />

    <xsl:include href="redirect.xsl" />

	<xsl:include href="layouts/default.xsl" />
	<xsl:include href="library/common.xsl" />

    <xsl:include href="modules/usels.xsl" />
    <xsl:include href="modules/blocks.xsl" />
    <xsl:include href="modules/images.xsl" />

    <xsl:include href="modules/content/common.xsl" />
    <xsl:include href="modules/data/common.xsl" />
    <xsl:include href="modules/dispatches/common.xsl" />
    <xsl:include href="modules/news/common.xsl" />
    <xsl:include href="modules/search/common.xsl" />
    <xsl:include href="modules/users/common.xsl" />
    <xsl:include href="modules/vote/common.xsl" />
    <xsl:include href="modules/comments/common.xsl" />
	<xsl:include href="modules/feeds/common.xsl" />
    
</xsl:stylesheet>
