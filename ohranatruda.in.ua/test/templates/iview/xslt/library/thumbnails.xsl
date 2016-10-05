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
	
    <xsl:template name="catalog-thumbnail">
        <xsl:param name="object-id" />
        <xsl:param name="element-id" />
        <xsl:param name="field-name" />
        <xsl:param name="empty" select="'/images/cms/nofoto.jpg'" />
        <xsl:param name="width">auto</xsl:param>
        <xsl:param name="height">auto</xsl:param>
        <xsl:param name="style"/>
        <xsl:param name="src-only">0</xsl:param>                
		
        <xsl:choose>
            <xsl:when test="$element-id != ''">
                <xsl:variable name="property" select="document(concat('upage://', $element-id, '.', $field-name))/udata/property" />
		
                <xsl:call-template name="thumbnail">
                    <xsl:with-param name="width" select="$width" />
                    <xsl:with-param name="height" select="$height" />

                    <xsl:with-param name="element-id" select="$element-id" />
                    <xsl:with-param name="field-name" select="$field-name" />
                    <xsl:with-param name="empty" select="$empty" />
                    <xsl:with-param name="style" select="$style" />
                    <xsl:with-param name="src">
                    	
                        <xsl:choose>
                            <xsl:when test="$property/value">
                                <xsl:value-of select="$property/value" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$empty" />
                            </xsl:otherwise>
                        </xsl:choose>
                        
                    </xsl:with-param>
                    <xsl:with-param name="src-only" select="$src-only" />
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="property" select="document(concat('uobject://', $object-id, '.', $field-name))/udata/property" />
                        
                <xsl:call-template name="thumbnail">
                    <xsl:with-param name="width" select="$width" />
                    <xsl:with-param name="height" select="$height" />

                    <xsl:with-param name="element-id" select="$element-id" />
                    <xsl:with-param name="field-name" select="$field-name" />
                    <xsl:with-param name="empty" select="$empty" />
                    <xsl:with-param name="style" select="$style" />
                    <xsl:with-param name="src">
                    	
                        <xsl:choose>
                            <xsl:when test="$property/value">
                                <xsl:value-of select="$property/value" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$empty" />
                            </xsl:otherwise>
                        </xsl:choose>
                        
                    </xsl:with-param>
                    <xsl:with-param name="src-only" select="$src-only" />
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>

    <xsl:template name="thumbnail">
    	
        <xsl:param name="src" />
        <xsl:param name="width">auto</xsl:param>
        <xsl:param name="height">auto</xsl:param>
        <xsl:param name="empty" />
        <xsl:param name="style"/>
		
        <xsl:param name="element-id" />
        <xsl:param name="field-name" />
        <xsl:param name="src-only" />
		
        <xsl:apply-templates select="document(concat('udata://system/makeThumbnailFull/(.', $src, ')/', $width, '/', $height, '/void/0/1/5/0/100/'))/udata">
            <xsl:with-param name="element-id" select="$element-id" />
            <xsl:with-param name="field-name" select="$field-name" />
            <xsl:with-param name="empty" select="$empty" />
            <xsl:with-param name="style" select="$style" />
            <xsl:with-param name="src-only" select="$src-only" />
        </xsl:apply-templates>
        
    </xsl:template>
	
    <xsl:template match="udata[@module = 'system' and (@method = 'makeThumbnail' or @method = 'makeThumbnailFull')]">
    	
        <xsl:param name="element-id" />
        <xsl:param name="field-name" />
        <xsl:param name="empty" />
        <xsl:param name="style"/>
        <xsl:param name="src-only" />
        
        <xsl:choose>
            <xsl:when test="$src-only = '1'">
                <xsl:value-of select="src" />
            </xsl:when>
            <xsl:otherwise>
                <img src="{src}" width="{width}" height="{height}">
                	
                    <xsl:if test="$element-id and $field-name">
                        <xsl:attribute name="umi:element-id">
                            <xsl:value-of select="$element-id" />
                        </xsl:attribute>
				
                        <xsl:attribute name="umi:field-name">
                            <xsl:value-of select="$field-name" />
                        </xsl:attribute>
                    </xsl:if>
			
                    <xsl:if test="$empty">
                        <xsl:attribute name="umi:empty">
                            <xsl:value-of select="$empty" />
                        </xsl:attribute>
                    </xsl:if>
                    
                    <xsl:if test="$style">
                        <xsl:attribute name="style">
                            <xsl:value-of select="$style" />
                        </xsl:attribute>
                    </xsl:if>
                    
                </img>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
</xsl:stylesheet>