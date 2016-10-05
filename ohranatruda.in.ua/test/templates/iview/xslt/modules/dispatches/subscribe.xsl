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

	<xsl:template match="result[@module = 'dispatches'][@method = 'subscribe']">
		
		<form action="/dispatches/subscribe_do/" enctype="multipart/form-data" name="sbs_frm" method="post">
			
			<xsl:apply-templates select="document('udata://dispatches/subscribe/')/udata" />
			
			<input type="submit" class="button" value="&subscribe;" />
		</form>
		
	</xsl:template>


	<xsl:template match="udata[@module = 'dispatches'][@method = 'subscribe']">
		
		<div>
			<input	type="text"
					onblur="javascript: if(this.value == '') this.value = '&e-mail;';"
					onfocus="javascript: if(this.value == '&e-mail;') this.value = '';"
					value="&e-mail;"
					class="input"
					id="subscribe"
					name="sbs_mail" />
		</div>
		
	</xsl:template>


	<xsl:template match="udata[@module = 'dispatches'][@method = 'subscribe'][subscriber_dispatches]">
		
		<xsl:apply-templates select="subscriber_dispatches" />
		
	</xsl:template>


	<xsl:template match="subscriber_dispatches" />
	

	<xsl:template match="subscriber_dispatches[items]">
		
		<ul>
			<xsl:apply-templates select="items" mode="dispatches" />
			
		</ul>
		
	</xsl:template>


	<xsl:template match="items" mode="dispatches">
		
		<li>
			<label>
				<input type="checkbox" name="subscriber_dispatches[{@id}]" value="{@id}">
					<xsl:if test="@is_checked = '1'">
						<xsl:attribute name="checked">
							<xsl:text>checked</xsl:text>
						</xsl:attribute>
					</xsl:if>
				</input>
				<xsl:value-of select="." />
			</label>
		</li>
		
	</xsl:template>

</xsl:stylesheet>