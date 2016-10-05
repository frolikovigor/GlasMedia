function clearplaceholderValues(target_form)
{
    $('#'+target_form + ' input:text,' + '#'+target_form + ' textarea').each(function() {
        var placeholder = $(this).attr('placeholder');
        if(placeholder == $(this).val()){
            $(this).val('');
        }
    });
}

function returnplaceholderValues(target_form)
{
    $(target_form + ' input:text,' + target_form + ' textarea').each(function() {
        if($(this).val() == '') {
            $(this).val($(this).val());
        }
    });
}

$(document).ready(function()
{
    $("form").submit(function(){
        form_id = $(this).attr('id');
        if(form_id.length == 0) {
            
        } else {
            clearplaceholderValues($(this).attr('id'));
        }
    });
    $("form input:text, form textarea").each(function (index) {
		
        if($(this).is('[placeholder]'))
		
        {
            var val = $(this).val();
            $(this).val($(this).attr('placeholder'));
			
            if (val.length > 0) {
                $(this).val(val);
            }
        }
    });

    $("form input:text, form textarea").blur(function () {
        if ($(this).val().length == 0) {
            $(this).val($(this).attr('placeholder'));
        }
    });
    
    $("form input:text, form textarea").focus(function () {
        if ($(this).val() == $(this).attr("placeholder")) {
            $(this).val('');
        }
    });
});
