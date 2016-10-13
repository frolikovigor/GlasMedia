export default function poll(){
    return (function(){

        //Форма авторизации / регистрации =============================================================
        if ($("#authorization").length){
            $("#authorization").on("click", ".next_p", function(){
                $("#authorization .preloader").removeClass("hide");
                var inset=$("#authorization .inset:not(.hide)").attr("inset");
                if (inset == undefined) return false;
                var func = "";

                switch (inset){
                    case "1": func="authorization"; break;
                    case "2": func="registration"; break;
                }
                if (func != ""){
                    $.ajax({
                        url : "/udata/users/"+func+"/.json",
                        type : "POST",
                        dataType : 'json',
                        data : $("#authorization form").serialize(),
                        success : function(data) {
                            $("#authorization .preloader").addClass("hide");
                            var result = data.result;
                            var set_inset = data.set_inset;
                            var loc = data.location;
                            $("#authorization .alert-warning").addClass("hide");
                            if ((result != undefined) && (result != "success")){
                                $("#authorization .alert-warning[warning='"+result+"']").removeClass("hide")
                            } else {
                                $("#authorization .avatar_mail").html($("#authorization input[name='email']").val());
                                $("#authorization .avatar_mail").val($("#authorization input[name='email']").val());
                                if (set_inset != undefined){
                                    if (set_inset == "location") {
                                        if (loc != undefined) {
                                            if (loc == "reload") location.reload(); else location.href = loc;
                                        }
                                    }
                                    else {
                                        $("#authorization .alert-warning").addClass("hide")
                                        $("#authorization .inset").addClass("hide");
                                        $("#authorization .inset[inset='"+set_inset+"']").removeClass("hide");
                                    }
                                }
                            }
                        }
                    });
                }
            });

            $("#authorization").on("click", ".set_inset", function(e){
                e.preventDefault();
                var set_inset = $(this).attr("inset");
                if (set_inset!=undefined) {
                    $("#authorization .inset").addClass("hide");
                    $("#authorization .inset[inset='"+set_inset+"']").removeClass("hide");
                    $("#authorization .alert-warning").addClass("hide")
                }
            });

            $("#authorization").on("keyup", "input", function(i){
                if (i.keyCode != undefined) if (i.keyCode == 13) $("#authorization .next_p").click();
            });

            $("#authorization").on("click", ".remind_password", function(){
                $("#authorization .preloader").removeClass("hide");
                $.ajax({
                    url : "/udata/users/remindPassword/.json",
                    type : "POST",
                    dataType : 'json',
                    data : $("#authorization form").serialize(),
                    success : function(data) {
                        $("#authorization .preloader").addClass("hide");
                        var result = data.result;
                        $("#authorization .alert-warning").addClass("hide");
                        if ((result != undefined) && (result != "success")){
                            $("#authorization .alert-warning[warning='"+result+"']").removeClass("hide");
                        } else {
                            $("#authorization .inset").addClass("hide");
                            $("#authorization .inset[inset='3']").removeClass("hide");
                            $("#authorization .next_p").addClass("hide");
                        }
                    }
                });
            });

            $("#authorization").on('hide.bs.modal', function (e) {
                setTimeout(function(){
                    $("#authorization .inset").addClass("hide");
                    $("#authorization .inset[inset='1']").removeClass("hide");
                    $("#authorization .next_p").removeClass("hide");
                    $("#authorization .alert-warning").addClass("hide");
                    $(".save_poll").prop("disabled", false);
                },300);
            });
            //=============================================================================================
        };
        
        
        
    })();
}
