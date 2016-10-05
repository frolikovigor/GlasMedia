site.captcha = {};

site.captcha.init = function() {
	var captcha_reset = jQuery('#captcha_reset');
	captcha_reset.click(function(){
		var d = new Date();
		jQuery('#captcha_img').attr('src', '/captcha.php?reset&' + d.getTime());
	});
};

jQuery(document).ready(function(){site.captcha.init()});