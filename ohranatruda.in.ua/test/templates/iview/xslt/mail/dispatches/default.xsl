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

	<xsl:template match="subscribe_confirm_subject">
		
		<xsl:text>Подписка на рассылку</xsl:text>
		
	</xsl:template>


	<xsl:template match="subscribe_confirm">
		
		<p>
			<xsl:text>Доброго времени суток!</xsl:text>
		</p>
		<p>
			<xsl:text>Вы подписались на рассылку.</xsl:text>
		</p>
		<p>
			<xsl:text>Если вы не хотите ее получать, перейдите по этой ссылке: </xsl:text>
			<a href="{unsubscribe_link}">
				<xsl:value-of select="unsubscribe_link" />
			</a>
		</p>
		<p>
			<xsl:text>UMI.CMS</xsl:text><br />
			<a href="mailto:help@umi-cms.ru">help@umi-cms.ru</a>
		</p>
		
	</xsl:template>

</xsl:stylesheet>