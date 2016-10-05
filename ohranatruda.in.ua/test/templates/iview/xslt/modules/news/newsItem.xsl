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
    
	<xsl:template match="result[@module = 'news'][@method = 'item']">

		<h1>
			<xsl:value-of select=".//property[@name = 'h1']/value" />
		</h1>
		<xsl:value-of select="document(concat('udata://system/convertDate/', .//@unix-timestamp, '/(d.m.Y)/'))/udata" />
		<xsl:value-of select=".//property[@name = 'content']/value" disable-output-escaping="yes" />

	</xsl:template>

</xsl:stylesheet>