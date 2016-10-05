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

<xsl:stylesheet	version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:umi="http://www.umi-cms.ru/TR/umi">

    <xsl:template name="smart-resize">
    	
        <xsl:param name="element-id" />
        <xsl:param name="field-name" />
        <xsl:param name="empty" />
        <xsl:param name="class" />
        <xsl:param name="width">
            <xsl:text>auto</xsl:text>
        </xsl:param>
        <xsl:param name="height">
            <xsl:text>auto</xsl:text>
        </xsl:param>
        <xsl:param name="src-only">0</xsl:param>


        <xsl:variable name="img-analyser" select="document(concat('udata://content/getOptimalImageParams/',$element-id,'/',$field-name,'/',$width,'/',$height,'/'))/udata" />
	   
        <xsl:variable name="width-result">
        	
            <xsl:choose>
                <xsl:when test="$img-analyser/type = 'width'">
                    <xsl:value-of select="$img-analyser/size" />
                </xsl:when>
                <xsl:when test="$img-analyser/type = 'height'">
                    <xsl:text>auto</xsl:text>
                </xsl:when>
            </xsl:choose>
            
        </xsl:variable>

        <xsl:variable name="height-result">
        	
            <xsl:choose>
                <xsl:when test="$img-analyser/type = 'height'">
                    <xsl:value-of select="$img-analyser/size" />
                </xsl:when>
                <xsl:when test="$img-analyser/type = 'width'">
                    <xsl:text>auto</xsl:text>
                </xsl:when>
            </xsl:choose>
            
        </xsl:variable>
	   
        <xsl:choose>
            <xsl:when test="$height-result = '' and $width-result = ''">
                <xsl:call-template name="catalog-thumbnail">
                    <xsl:with-param name="element-id" select="$element-id" />
                    <xsl:with-param name="field-name" select="$field-name" />
                    <xsl:with-param name="width" select="$width" />
                    <xsl:with-param name="height" select="$height" />
                    <xsl:with-param name="empty" select="$empty" />
                    <xsl:with-param name="class" select="$class" />
                    <xsl:with-param name="src-only" select="$src-only" />
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="catalog-thumbnail">
                    <xsl:with-param name="element-id" select="$element-id" />
                    <xsl:with-param name="field-name" select="$field-name" />
                    <xsl:with-param name="width" select="$width-result" />
                    <xsl:with-param name="height" select="$height-result" />
                    <xsl:with-param name="empty" select="$empty" />
                    <xsl:with-param name="class" select="$class" />
                    <xsl:with-param name="src-only" select="$src-only" />
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
	   
    </xsl:template>
	
</xsl:stylesheet>