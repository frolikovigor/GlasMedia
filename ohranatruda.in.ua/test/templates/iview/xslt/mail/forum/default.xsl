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

	<xsl:output encoding="utf-8" method="html" indent="yes" />

	<xsl:template match="mail_subject">
		
		<xsl:text>New reply</xsl:text>
		
	</xsl:template>


	<xsl:template match="mail_message">
		
		<h1>
			<xsl:value-of select="h1" />
		</h1>
		
		<xsl:value-of select="message" />
		
	</xsl:template>

</xsl:stylesheet>