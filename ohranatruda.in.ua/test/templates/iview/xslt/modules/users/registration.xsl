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

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">	

	<xsl:template match="result[@method = 'registrate']">
		
		<xsl:apply-templates select="document('udata://users/registrate')/udata" />
		
	</xsl:template>
	
	
	<xsl:template match="udata[@method = 'registrate']">
		
		<xsl:if test="$errors">
			<xsl:value-of select="$errors" />
		</xsl:if>		
		
		<form id="registrate" method="post" action="{$lang-prefix}/users/registrate_do/">
			<xsl:text>&login;:</xsl:text>
			<input type="text" name="login" />
			<xsl:text>&password;:</xsl:text>
			<input type="password" name="password" />
			<xsl:text>&password-confirm;:</xsl:text>
			<input type="password" name="password_confirm" />
			<xsl:text>&e-mail;:</xsl:text>
			<input type="text" name="email" />
			
			<xsl:apply-templates select="document('udata://system/captcha')/udata" />
			
			<input type="submit" class="button" value="&registration-do;" />
		</form>
		
	</xsl:template>
	

	<xsl:template match="result[@method = 'registrate_done']">	
			
		<xsl:apply-templates select="document('udata://users/registrate_done')/udata"/>
		
	</xsl:template>
	
	
	<xsl:template match="udata[@method = 'registrate_done']">
		
		<xsl:choose>
			<xsl:when test="result = 'without_activation'">
				<xsl:text>&registration-done;</xsl:text>
			</xsl:when>
			<xsl:when test="result = 'error'">
				<xsl:text>&registration-error;</xsl:text>
			</xsl:when>
			<xsl:when test="result = 'error_user_exists'">
				<xsl:text>&registration-error-user-exists;</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>&registration-done;</xsl:text>
				<xsl:text>&registration-activation-note;</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>
	
	
	<xsl:template match="result[@method = 'activate']">
		
		<xsl:variable name="activation-errors" select="document('udata://users/activate')/udata/error" />
		
		<xsl:choose>
			<xsl:when test="count($activation-errors)">
				
				<xsl:apply-templates select="$activation-errors" />
				
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>&account-activated;</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>
	
	
	<xsl:template match="result[@method = 'settings']">
		
		<xsl:apply-templates select="document('udata://users/settings/')/udata" />
		
	</xsl:template>
	
	
	<xsl:template match="udata[@method = 'settings']">
		
		<form method="post" action="{$lang-prefix}/users/settings_do/">
			<xsl:text>&login;:</xsl:text>
			<input type="text" name="login" disabled="disabled" value="{$user-info//property[@name = 'login']/value}" />
			<xsl:text>&password;:</xsl:text>
			<input type="password" name="password" />
			<xsl:text>&password-confirm;:</xsl:text>
			<input type="password" name="password_confirm" />
			<xsl:text>&e-mail;:</xsl:text>
			<input type="text" name="email" value="{$user-info//property[@name = 'e-mail']/value}" />

			<xsl:apply-templates select="document(concat('udata://data/getEditForm/', $user-id))/udata" />

			<input type="submit" class="button" value="&save-changes;" />
		</form>
		
	</xsl:template>
	
</xsl:stylesheet>