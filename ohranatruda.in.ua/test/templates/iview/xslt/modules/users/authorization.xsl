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

	<xsl:template match="user">
		
		<!--<xsl:apply-templates select="$user-info//property[@name = 'lname']" />
		<xsl:apply-templates select="$user-info//property[@name = 'fname']" />
		<xsl:apply-templates select="$user-info//property[@name = 'father_name']" />

		<a href="{$lang-prefix}/emarket/personal/" class="office">
			<xsl:text>&private-office;</xsl:text>
		</a>
		<a href="{$lang-prefix}/users/logout/" class="exit">
			<xsl:text>&log-out;</xsl:text>
		</a>-->
				
	</xsl:template>
	

	<xsl:template match="property[@name = 'fname' or @name = 'lname' or @name = 'father_name']">
		
		<!--<xsl:value-of select="value" />
		<xsl:text> </xsl:text>-->
		
	</xsl:template>
	

	<xsl:template match="user[@type = 'guest']">
		
		<!--<form class="login" action="{$lang-prefix}/users/login_do/" method="post">
			
			<input type="text" value="&login;" name="login" />
			<input type="password" value="&password;" name="password" />
			
			<input type="submit" class="button" value="&log-in;" />
			<a href="{$lang-prefix}/users/registrate/">
				<xsl:text>&registration;</xsl:text>
			</a>
			<a href="/users/forget/">
				<xsl:text>&forget-password;</xsl:text>
			</a>
		</form>-->
		
	</xsl:template>
	

	<xsl:template match="result[@method = 'login' or @method = 'login_do' or @method = 'loginza' or @method = 'auth']">
		
		<!--<xsl:if test="@not-permitted = 1">
			<p>
				<xsl:text>&user-not-permitted;</xsl:text>
			</p>
		</xsl:if>
		
		<xsl:if test="user[@type = 'guest'] and (@method = 'login_do' or @method = 'loginza')">
			<p>
				<xsl:text>&user-reauth;</xsl:text>
			</p>
		</xsl:if>
		
		<xsl:apply-templates select="document('udata://users/auth/')/udata" />-->
		
	</xsl:template>
	

	<xsl:template match="udata[@module = 'users'][@method = 'auth']">
		
		<!--<form method="post" action="/users/login_do/">
			<input type="hidden" name="from_page" value="{from_page}" />
			<xsl:text>&login;:</xsl:text>
			<input type="text" name="login" />
			<xsl:text>&password;:</xsl:text>
			<input type="password" name="password" />
			<a href="{$lang-prefix}/users/registrate/">
				<xsl:text>&registration;</xsl:text>
			</a>
			<a href="/users/forget/">
				<xsl:text>&forget-password;</xsl:text>
			</a>
			<input type="submit" class="button" value="&log-in;" />
		</form>-->
		
	</xsl:template>
	

	<xsl:template match="udata[@module = 'users'][@method = 'auth'][user_id]">

		<!--<xsl:text>&welcome; </xsl:text>
		
		<xsl:choose>
			<xsl:when test="translate(user_name, ' ', '') = ''">
				<xsl:value-of select="user_login" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="user_name" /> (<xsl:value-of select="user_login" />)
			</xsl:otherwise>
		</xsl:choose>

		<a href="{$lang-prefix}/users/logout/">
			<xsl:text>&log-out;</xsl:text>
		</a>
		<xsl:text> | </xsl:text>
		<a href="{$lang-prefix}/emarket/personal/">
			<xsl:text>&private-office;</xsl:text>
		</a>-->

	</xsl:template>

</xsl:stylesheet>