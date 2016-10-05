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

	<xsl:template match="result[@module = 'users'][@method = 'restore']">
		
		<xsl:apply-templates select="document(concat('udata://users/restore/', $param0 ,'/'))/udata" />
		
	</xsl:template>


	<xsl:template match="udata[@module = 'users'][@method = 'restore'][@status = 'success']">
		
		<xsl:text>&forget-message;</xsl:text>
		
	</xsl:template>


	<xsl:template match="udata[@module = 'users'][@method = 'restore'][@status = 'fail']">
		
		<xsl:text>&activation-error;</xsl:text>
		
	</xsl:template>

</xsl:stylesheet>
