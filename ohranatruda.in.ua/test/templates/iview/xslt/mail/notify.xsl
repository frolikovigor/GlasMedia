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

	<xsl:output method="html" />

	<xsl:template match="body">
		
		<xsl:text>У страницы </xsl:text>
		<a href="{page_link}">
			<xsl:value-of select="page_header" />
		</a>
		<br />
		<xsl:text>приближается время потери актуальности</xsl:text><br />
		<xsl:text>Комментарии к публикации:</xsl:text><br />
		<p>
			<xsl:value-of select="publish_comments" />
		</p>
		
	</xsl:template>

</xsl:stylesheet>