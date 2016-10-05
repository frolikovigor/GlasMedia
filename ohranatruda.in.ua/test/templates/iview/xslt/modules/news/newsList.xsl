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

    <xsl:template match="result[@module = 'news'][@method = 'rubric']">
		
		<xsl:apply-templates select="document(concat('udata://news/lastlist/', page/@id))/udata" />

	</xsl:template>
    
    
	<xsl:template match="udata[@module = 'news'][@method = 'lastlist']">

		<h1>
			<xsl:value-of select="document(concat('upage://', $document-page-id, '.h1'))//value" />
		</h1>

		<xsl:apply-templates select="//item" />				
		<xsl:apply-templates select="total" mode="paginated" />

	</xsl:template>
    
    
	<xsl:template match="udata[@method = 'lastlist']//item">

		<a href="{@link}">
			<xsl:value-of select="." />
		</a>
		<xsl:value-of select="document(concat('udata://system/convertDate/', @publish_time, '/(d.m.Y)'))/udata" />
		<xsl:value-of select="$page//property[@name = 'anons']/value" disable-output-escaping="yes" />

	</xsl:template>
	
</xsl:stylesheet>