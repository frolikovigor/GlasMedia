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

	<xsl:template match="result[@module = 'dispatches'][@method = 'subscribe_do']">
		
		<xsl:apply-templates select="document('udata://dispatches/subscribe_do/')/udata" />
		
	</xsl:template>


	<xsl:template match="udata[@module = 'dispatches'][@method = 'subscribe_do']">
		
		<xsl:apply-templates select="result" mode="subscribe_do" />
		
	</xsl:template>


	<xsl:template match="udata[@module = 'dispatches'][@method = 'subscribe_do'][unsubscribe_link]">
		
		<xsl:if test="$user-type = 'guest'">
			<p>
				<xsl:text>Вы подписались на рассылки.</xsl:text>
			</p>
			<p>
				<xsl:text>Если Вы не хотите получать нашу рассылку, Вы можете отказаться от подписки, перейдя по </xsl:text>
				<a href="{unsubscribe_link}"><xsl:text>ссылке</xsl:text></a>
				<xsl:text>.</xsl:text>
			</p>
		</xsl:if>
		
	</xsl:template>


	<xsl:template match="result" mode="subscribe_do">
		
		<xsl:choose>
			<xsl:when test="$user-type != 'guest'">
				<p>
					<xsl:text>Вы отписались от рассылок.</xsl:text>
				</p>
			</xsl:when>
			<xsl:otherwise>
				<p>
					<xsl:text>Вы подписались на рассылки.</xsl:text>
				</p>
				<p>
					<xsl:text>Если Вы не хотите получать нашу рассылку, Вы можете отказаться от подписки, перейдя по ссылке в письме.</xsl:text>
				</p>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>


	<xsl:template match="result[items]" mode="subscribe_do">
		
		<p>
			<xsl:text>Вы подписались на рассылки:</xsl:text>
		</p>
		<ul>
			<xsl:apply-templates select="items" mode="subscribe_do" />
		</ul>
		
	</xsl:template>


	<xsl:template match="items" mode="subscribe_do">
		
		<li>
			<xsl:value-of select="." disable-output-escaping="yes" />
		</li>
		
	</xsl:template>

</xsl:stylesheet>