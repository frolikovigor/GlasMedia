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

	<xsl:template name="breadcrumbs">
	
		<ul class="breadcrumbs">
			
			<xsl:apply-templates select="document('udata://core/navibar')/udata" />
		
		</ul>
	
	</xsl:template>
	
	
	<!-- A template for data processing macro -->	
	
	<xsl:template match="udata[@method = 'navibar']">
		
		<li>
			<a href="/">Главная</a>
			&#160;<span class="divider">&#187;</span>
		</li>
		
		<xsl:apply-templates select="items/item" mode="navibar" />
	
	</xsl:template>	
	
	<!-- /A template for data processing macro -->
	
	
	<!-- Template for elements with links -->	
	
	<xsl:template match="item" mode="navibar">
		
		<li>
			<a href="{@link}">
				<xsl:value-of select="." />
			</a>
			&#160;<span class="divider">&#187;</span>
		</li>
		
	</xsl:template>	
	
	<!-- /Template for elements with links -->
	
	
	<!-- Template for the last element -->	
	
	<xsl:template match="item[position() = last()]" mode="navibar">
	
		<li class="active">
			<xsl:value-of select="."/>
		</li>
	
	</xsl:template>
	
	<!-- /Template for the last element -->

</xsl:stylesheet>
