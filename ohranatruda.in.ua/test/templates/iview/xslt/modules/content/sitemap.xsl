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

	<xsl:template match="result[@module = 'content'][@method = 'sitemap']" priority="1">
		
		<xsl:apply-templates select="document('udata://content/sitemap/notemplate/')/udata" />
		
	</xsl:template>
	
	
	<xsl:template match="udata[@method = 'sitemap']">

		<h1>
			&site-map;
		</h1>

		<xsl:apply-templates mode="sitemap" />

	</xsl:template>
	
	
	<xsl:template match="items" mode="sitemap">
		
		<ul>
			
			<xsl:apply-templates mode="sitemap" />
			
		</ul>
		
	</xsl:template>
	
	
	<xsl:template match="item" mode="sitemap">
		
		<li>
			<a href="{@link}">
				<xsl:value-of select="@name" />
			</a>
			
			<xsl:apply-templates mode="sitemap" />
			
		</li>
		
	</xsl:template>

</xsl:stylesheet>