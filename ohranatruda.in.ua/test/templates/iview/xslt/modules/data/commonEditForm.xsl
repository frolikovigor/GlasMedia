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
	
	<xsl:template match="udata[@method = 'getCreateForm' or @method = 'getEditForm']">
		
		<xsl:apply-templates select="group" mode="form" />
		
	</xsl:template>
	
	
	<xsl:template match="group" mode="form">
		
		<h4>
			<xsl:value-of select="@title" />
		</h4>
		
		<xsl:apply-templates select="field" mode="form" />		
		
	</xsl:template>


	<xsl:template match="field" mode="form">
		
		<div>
			<label title="{@tip}">
				
				<xsl:apply-templates select="@required" mode="form" />
				
				<span>
					<xsl:value-of select="concat(@title, ':')" />
				</span>
				<input type="text" name="{@input_name}" value="{.}">
					
					<xsl:apply-templates select="@required" mode="form" />
					
					<xsl:if test="@name = 'email' and @required = 'required'">
						<xsl:attribute name="class">
							<xsl:text>required email</xsl:text>
						</xsl:attribute>								
					</xsl:if>					
					
				</input>
			</label>
		</div>
		
	</xsl:template>


	<xsl:template match="field[@type = 'relation']" mode="form">
		
		<div>
			<label title="{@tip}">
				
				<xsl:apply-templates select="@required" mode="form" />
				
				<span>
					<xsl:value-of select="concat(@title, ':')" />
				</span>
				<select type="text" name="{@input_name}">
					
					<xsl:apply-templates select="@required" mode="form" />
					
					<xsl:if test="@multiple = 'multiple'">
						<xsl:attribute name="multiple">multiple</xsl:attribute>
					</xsl:if>
					
					<xsl:apply-templates select="values/item" mode="form" />
					
				</select>
			</label>
		</div>
		
	</xsl:template>
	
	
	<xsl:template match="item" mode="form">
		
		<option value="{@id}">
			<xsl:copy-of select="@selected" />
			<xsl:value-of select="." />
		</option>
		
	</xsl:template>


	<xsl:template match="field[@type = 'boolean']" mode="form">
		
		<div>
			<label title="{@tip}">
				
				<xsl:apply-templates select="@required" mode="form" />
				
				<span>
					<xsl:value-of select="concat(@title, ':')" />
				</span>
				<input type="hidden" name="{@input_name}" value="0" />
				<input type="checkbox" name="{@input_name}" value="1">
					<xsl:copy-of select="@checked" />
				</input>
			</label>
		</div>
		
	</xsl:template>


	<xsl:template match="field[@type = 'text' or @type = 'wysiwyg']" mode="form">
		
		<div>
			<label title="{@tip}">
				
				<xsl:apply-templates select="@required" mode="form" />
				
				<span>
					<xsl:value-of select="concat(@title, ':')" />
				</span>
				<textarea name="{@input_name}">
					
					<xsl:apply-templates select="@required" mode="form" />
					
					<xsl:value-of select="." />
				</textarea>
			</label>
		</div>
		
	</xsl:template>


	<xsl:template match="field[@type = 'file' or @type = 'img_file']" mode="form">
		
		<div>
			<label title="{@tip}">
				
				<xsl:apply-templates select="@required" mode="form" />
				
				<span>
					<xsl:value-of select="concat(@title, ':')" />
				</span>
				
				<input type="file" name="{@input_name}">
					
					<xsl:apply-templates select="@required" mode="form" />
					
				</input>
			</label>
		</div>
		
	</xsl:template>
	
	<xsl:template match="@required" mode="form">
		
		<xsl:attribute name="class">
			<xsl:text>required</xsl:text>
		</xsl:attribute>
		
	</xsl:template>
	
</xsl:stylesheet>