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

	<xsl:template match="result[@module = 'dispatches'][@method = 'unsubscribe']">
		
		<xsl:apply-templates select="document('udata://dispatches/unsubscribe/')/udata" />
		
	</xsl:template>


	<xsl:template match="udata[@module = 'dispatches'][@method = 'unsubscribe']">
		
		<p>
			<xsl:value-of select="." />
		</p>
		
	</xsl:template>

</xsl:stylesheet>