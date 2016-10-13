export default function feedback(){
    var feedback_timer = false;

    return {
        Validate: function(){
            $("#feedback_form").cc_validate({
                settings: {required_class:'required', error_class:'error'},
                rules : [
                ],
                warning: function(elem, rule, result){
                    if (feedback_timer === false)
                        feedback_timer = setTimeout(function(){
                            $("#feedback .btn-preloader").removeClass("wait");
                            feedback_timer = false;
                        },300);
                },
                hide_warning: function(elem, rule, result){
                    if (feedback_timer === false)
                        feedback_timer = setTimeout(function(){
                            $("#feedback .btn-preloader").removeClass("wait");
                            feedback_timer = false;
                        },300);
                },
                success: function(form){
                    if (feedback_timer!== false) clearTimeout(feedback_timer);
                    $("#feedback .btn-preloader").addClass("wait");
                    $.ajax({
                        url : "/udata/feedback/send/.json",
                        type : "POST",
                        dataType : 'json',
                        data : $("#feedback_form").serialize(),
                        success : function(data) {
                            if (data.result!=undefined){
                                if (data.result == 'true'){
                                    $("#feedback").modal("hide");
                                    $("#feedback .btn-preloader").removeClass("wait");
                                    setTimeout(function(){
                                        $("#feedback input[type='text'], #feedback textarea").val("");
                                        $("#feedback_success").modal();
                                    }, 300);
                                    return false;
                                }
                            }
                            $("#feedback .alert").removeClass("hide");
                            $("#feedback .btn-preloader").removeClass("wait");
                        }
                    });
                    return false;
                }
            });
        },

        Open: function(elem){
            if (elem.attr("data-captcha") == undefined){
                $("#feedback").modal();
            } else {
                elem.attr("data-send","1");
            }
            return false;
        }
    };
};
