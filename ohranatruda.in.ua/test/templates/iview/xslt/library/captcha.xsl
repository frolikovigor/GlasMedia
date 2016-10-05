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

	<xsl:template match="udata[@module = 'system' and @method = 'captcha']" />


	<xsl:template match="udata[@module = 'system' and @method = 'captcha' and count(url)]">

		<img src="{url}{url/@random-string}" id="captcha_img" align="absmiddle" />
        <span id="captcha_reset" class="glyphicon glyphicon-refresh" onclick="var $img = jQuery('#captcha_img'); $img.attr('src', $img.attr('src').split('?')[0] + '?' + Math.random()); return false;"></span>
        <input type="text" name="captcha" id="captcha" />

	</xsl:template>

</xsl:stylesheet>