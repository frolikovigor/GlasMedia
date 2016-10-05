<?xml version="1.0" encoding="utf-8"?>
<!--DOCTYPE xsl:stylesheet SYSTEM "ulang://i18n/constants.dtd:file"-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output method="html" />

	<xsl:template match="body">
		<xsl:variable name="domain" select="document('udata://content/getDomainName/')/udata" />
		<xsl:variable name="main_page" select="document(concat('upage://',document('udata://content/getMainPageId/')/udata))" />
		<html>
			<head>
				<style type="text/css">
					
				</style>
			</head>
			<body>
				<xsl:if test="$main_page//property[@name='mail_logo']//value != ''">
					<a href="http://{$domain}/" style="border: 0 !important; text-decoration: none !important;"><img src="http://{$domain}/{$main_page//property[@name='mail_logo']//value}" alt="" style="margin-bottom: 10px" /></a> 
				</xsl:if>
                <h2><xsl:value-of select="header" /></h2>
				<xsl:value-of select="content" disable-output-escaping="yes" />
				<xsl:if test="$main_page//property[@name='mail_footer']//value != ''">
					<xsl:value-of select="$main_page//property[@name='mail_footer']//value" disable-output-escaping="yes" />
				</xsl:if>
			</body>
		</html>
	</xsl:template>

</xsl:stylesheet>