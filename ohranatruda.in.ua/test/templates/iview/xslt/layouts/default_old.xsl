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

        <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE HTML&gt;</xsl:text>
        <html>
            <head>

                <title>
                    <xsl:value-of select="$document-title" /> 
                </title>

                <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
                <meta name="keywords" content="{//meta/keywords}" />
                <meta name="description" content="{//meta/description}" />

                <link rel="icon" type="image/x-icon" href="/favicon.ico" />
                <link rel="shortcut icon" type="image/x-icon" href="/favicon.ico" />
                <link rel="stylesheet" href="{$template-resources}css/bootstrap.min.css" />
                <link rel="stylesheet" href="{$template-resources}css/bootstrap-theme.min.css" />
                <link rel="stylesheet" href="{$template-resources}css/colorpicker.css" type="text/css" />
                <link rel="stylesheet" type="text/css" href="{$template-resources}css/custom.css?{/result/@system-build}" />
                <script type="text/javascript" src="/js/jquery/jquery-2.1.3.min.js?{/result/@system-build}"></script>
                <script type="text/javascript" src="{$template-resources}js/jquery-ui-1.10.4.custom.min.js?{/result/@system-build}"></script>
                <script type="text/javascript" src="{$template-resources}js/bootstrap.min.js"></script>


                <!-- Страница создания виджета опросов -->
                <xsl:if test="$document-page-id = 33">
                    <script type="text/javascript" src="https://www.google.com/jsapi"></script>
                    <script type="text/javascript">google.load("visualization", "1", {packages:["corechart"]});</script>
                    <script type="text/javascript" src="{$template-resources}js/widget_polls.js?{/result/@system-build}"></script>
                </xsl:if>

                <script type="text/javascript" src="{$template-resources}js/custom.js?{/result/@system-build}"></script>
            </head>

            <body>
                <div id="nav">
                    <table>
                        <tr>
                            <xsl:apply-templates select="document('udata://content/menu')//item" mode="top_menu" />
                        </tr>
                    </table>
                </div>
                <div id="container">
                    <div id="header">
                        <span class="head_title"><a href="/">Inter<strong>View</strong></a></span>
                        <h1>общественное мнение</h1>
                        <form class="navbar-form searchform" role="search">
                            <div class="input-group add-on input-group-sm">
                                <input type="text" class="form-control" placeholder="Поиск" name="srch-term" id="srch-term" />
                                <div class="input-group-btn">
                                    <button class="btn btn-default" type="submit"><i class="glyphicon glyphicon-search"></i></button>
                                </div>
                            </div>
                        </form>
                        <div class="clear"></div>
                    </div>
                    <xsl:apply-templates select="result" />



                </div>
                <div id="footer">
                    <div class="footer-content">
                        <p>&copy; InterView 2015</p>
                    </div>
                </div>




            </body>
        </html>

    </xsl:template>

</xsl:stylesheet>