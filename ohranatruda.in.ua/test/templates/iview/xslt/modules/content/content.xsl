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

    <xsl:template match="result[page/@alt-name='agreement']">
        <xsl:call-template name="header" />
        <xsl:call-template name="panel" />
        <xsl:call-template name="panel_info" />
        <div id="agreement" class="shift_right">
            <div class="shell">
                <div class="content">
                    <div class="theme">
                        <h1><xsl:value-of select="//property[@name='h1']/value" /></h1>
                    </div>
                    <xsl:value-of select="//property[@name='content']/value" disable-output-escaping="yes" />
                </div>
            </div>
        </div>
    </xsl:template>
	
</xsl:stylesheet>