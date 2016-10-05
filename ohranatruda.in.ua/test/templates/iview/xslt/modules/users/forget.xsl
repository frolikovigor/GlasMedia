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

	<xsl:template match="result[@method = 'forget']">

		<form id="forget" method="post" action="/users/forget_do/">
			<input type="radio" id="forget_login" name="choose_forget" checked="checked" />
			<xsl:text>&login;</xsl:text>
			<input type="radio" id="forget_email" name="choose_forget" />
			<xsl:text>&e-mail;</xsl:text>
			<input type="text" name="forget_login" />
			<input type="submit" class="button" value="&forget-button;" />
		</form>

	</xsl:template>

	<xsl:template match="result[@method = 'forget_do']">

		<p>
			<xsl:text>&registration-activation-note;</xsl:text>
		</p>

	</xsl:template>
	
</xsl:stylesheet>