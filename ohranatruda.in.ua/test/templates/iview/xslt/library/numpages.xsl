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

	<xsl:template match="total" mode="paginated" />
		
		
	<xsl:template match="total[. &gt; ../per_page]" mode="paginated" >

		<xsl:apply-templates select="document(concat('udata://system/numpages/', ., '/', ../per_page))" mode="paginated" />

	</xsl:template>
	
	
	<xsl:template match="udata[@method = 'numpages'][count(items)]" mode="paginated" />
		
		
	<xsl:template match="udata[@method = 'numpages']" mode="paginated" >
        <nav>
            <ul class="pagination">
                <xsl:apply-templates select="toprev_link" />
                <xsl:apply-templates select="items/item" mode="numpages" />
                <xsl:apply-templates select="tonext_link" />
            </ul>
        </nav>
	</xsl:template>
		
	
	<xsl:template match="item" mode="numpages">

        <!--<li class="disabled"><a href="#" aria-label="Previous"><span aria-hidden="true">&laquo;</span></a></li>-->
        <!--<li class="active"><a href="#">1 <span class="sr-only">(current)</span></a></li>-->

        <li>
			
			<xsl:choose>
				<xsl:when test="@is-active">
					<xsl:attribute name="class">
						<xsl:text>active</xsl:text>
					</xsl:attribute>
                    <a href="#">
                        <xsl:value-of select="." />
                    </a>
				</xsl:when>
				<xsl:otherwise>
					<a href="{@link}">
						<xsl:value-of select="." />
					</a>
				</xsl:otherwise>
			</xsl:choose>
			
		</li>
			
	</xsl:template>
	
	
	<xsl:template match="toprev_link">
		<li>
			<a href="{.}"><span aria-hidden="true">&laquo;</span></a>
		</li>
	</xsl:template>
		
		
	<xsl:template match="tonext_link">
		<li>
			<a href="{.}"><span aria-hidden="true">&raquo;</span></a>
		</li>
	</xsl:template>

</xsl:stylesheet>