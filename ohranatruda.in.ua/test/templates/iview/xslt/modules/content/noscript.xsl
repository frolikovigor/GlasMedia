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
    
    <xsl:template match="result[page/@id='3311']" priority="1">
        <xsl:call-template name="header" />
        <xsl:call-template name="panel" />
        <xsl:call-template name="panel_info" />

        <xsl:variable name="noscript-page" select="document('upage://3311')/udata/page" />

        <div id="noscript" class="shift_right">
            <div class="shell">
                <div class="content">
                    <xsl:value-of select="$noscript-page//property[@name = 'content']/value" disable-output-escaping="yes" />
                </div>
            </div>
        </div>
    </xsl:template>

</xsl:stylesheet>