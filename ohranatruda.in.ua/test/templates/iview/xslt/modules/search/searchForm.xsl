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
	
	<xsl:template match="udata[@method = 'insert_form']">
		
		<form action="/search/search_do/" method="get" class="search">
			<input type="text" name="search_string" placeholder="&search-default-text;">
				
				<xsl:if test="$search_string != ''">
					<xsl:attribute name = "placeholder">
						<xsl:value-of select="$search_string" />
					</xsl:attribute>					
				</xsl:if>				
				
			</input>
		</form>
		
	</xsl:template>
	
</xsl:stylesheet>