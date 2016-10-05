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


<xsl:stylesheet	version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	
	<xsl:template match="property|fields/field//value">
		
		<xsl:value-of select="value" />
		
	</xsl:template>
	
	
	<xsl:template match="property[@type = 'boolean'][value]">
		
		<xsl:text>&no;</xsl:text>
		
	</xsl:template>


	<xsl:template match="property[@type = 'boolean'][value = 1]|fields/field[@type = 'boolean']//value[.]">
		
		<xsl:text>&yes;</xsl:text>
		
	</xsl:template>
	
	
	<xsl:template match="property[@type = 'relation']|fields/field[@type = 'relation']//value">
		
		<xsl:apply-templates select="value/item" />
		
	</xsl:template>
	
	
	<xsl:template match="property[@type = 'symlink']|fields/field[@type = 'symlink']//value">
		
		<xsl:apply-templates select="value/page" />
		
	</xsl:template>


	<xsl:template match="value/item">
		
		<xsl:value-of select="concat(@name, ', ')" />
		
	</xsl:template>
	
	
	<xsl:template match="value/item[position() = last()]">
		
		<xsl:value-of select="@name" />
		
	</xsl:template>


	<xsl:template match="value/page">
		
		<a href="{@link}">
			<xsl:value-of select="name" />
		</a>
		
	</xsl:template>

</xsl:stylesheet>