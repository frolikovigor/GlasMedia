export default function cabinet(){

    return {
        GetInterestsList(){
            $("#cabinet .interests .preloader").removeClass("hide");
            GM.Model.Cabinet.GetInterestsOfUser().then(
                (data) => {
                    $(".interests ul.list").html(data);
                    $(".interests .preloader").addClass("hide");

                    $("#cabinet .interests .remove").unbind();
                    $("#cabinet .interests .remove").click(function(){
                        $("#cabinet .interests .preloader").removeClass("hide");
                        var id = $(this).data('id');
                        GM.Model.Cabinet.RemoveInterestsOfUser(id).then(
                            () => GM.View.Cabinet.GetInterestsList(),
                            () => {}
                        );
                    });

                    $("#cabinet .interests .add").unbind();
                    $("#cabinet .interests .add").click(function(){
                        var id = false;
                        if ($("#cabinet .interests select[data-cat='3']").val()) id = $("#cabinet .interests select[data-cat='3']").val();
                        else
                        if ($("#cabinet .interests select[data-cat='2']").val()) id = $("#cabinet .interests select[data-cat='2']").val();
                        else
                        if ($("#cabinet .interests select[data-cat='1']").val()) id = $("#cabinet .interests select[data-cat='1']").val();

                        if (id !== false) {
                            $("#cabinet .interests .preloader").removeClass("hide");
                            GM.Model.Cabinet.AddInterestsOfUser(id).then(
                                () => GM.View.Cabinet.GetInterestsList(),
                                () => {}
                            );
                        }
                        return false;
                    });

                    $("#cabinet .interests .categories>li").each(function(){
                        var id = $(this).data("id");
                        var name = $(this).data("name");
                        $("#cabinet .interests select[data-cat='1']").append("<option value='"+id+"'>"+name+"</option>");
                    });

                    $("#cabinet .interests select").unbind();
                    $("#cabinet .interests select").change(function(){
                        var cat = $(this).val();
                        var level = parseInt($(this).data("cat"));
                        var id = $(this).val();
                        $("#cabinet .interests select[data-cat='"+(level+1)+"']").text('');
                        if($("#cabinet .interests .categories li[data-id='"+id+"']>ul>li").length){
                            $("#cabinet .interests select[data-cat='"+(level+1)+"']").append("<option value=''>...</option>");
                            $("#cabinet .interests span[data-cat='"+(level+1)+"']").removeClass("hide");
                            $("#cabinet .interests select[data-cat='"+(level+1)+"']").removeClass("hide");
                            $("#cabinet .interests").attr("data-level", level+1);
                            $("#cabinet .interests .categories li[data-id='"+id+"']>ul>li").each(function(){
                                var id = $(this).data("id");
                                var name = $(this).data("name");
                                $("#cabinet .interests select[data-cat='"+(level+1)+"']").append("<option value='"+id+"'>"+name+"</option>");
                            });
                        } else {
                            $("#cabinet .interests").attr("data-level", level);
                            $("#cabinet .interests span[data-cat='"+(level+1)+"']").addClass("hide");
                            $("#cabinet .interests select[data-cat='"+(level+1)+"']").addClass("hide");
                            $("#cabinet .interests span[data-cat='"+(level+2)+"']").addClass("hide");
                            $("#cabinet .interests select[data-cat='"+(level+2)+"']").addClass("hide");

                        }
                        return false;
                    });
                    $("#cabinet .interests select:first").change();
                    GM.View.InitCounter();
                },
                () => {

                }
            );
        },
        
        Profile: function(){
            if ($("#cabinet").length){
                if ($("#cabinet_profile").length){
                    GM.Model.Cabinet.GetProfile().then(
                        (data) => {
                            $("#cabinet_profile").html(data);

                            GM.View.Cabinet.GetInterestsList();
                            GM.View.ColorBox.init();

                            $("#profile").cc_validate({
                                settings: {required_class:'required', error_class:'error'},
                                rules : [
                                    {element:"input[name='email']", rule:'check', url:'/users/checkEmail/1/',need:'false'},
                                    {element:"input[name='password_confirm']", rule:'compare', compare:"input[name='password']"},
                                    {element:"input[name='password']", rule:'min_length_null', min_length:6},
                                    {element:"input[name='old_password']", rule:'check', url:'/users/checkPassword/',need:'true'}
                                ],
                                warning: function(elem, rule, result){
                                    elem.closest(".form-group").find(".label-warning-"+rule).removeClass("hide");
                                    var err = elem.attr("data-error");
                                    elem.closest(".form-group").find(".label").removeClass("hide"+err);
                                },
                                hide_warning: function(elem, rule, result){
                                    elem.closest(".form-group").find(".label-warning-"+rule).addClass("hide");
                                    var err = elem.attr("data-error");
                                    elem.closest(".form-group").find(".label").addClass("hide"+err);

                                },
                                success: function(form){
                                    form.submit();
                                }
                            });

                            $("#cabinet .profile .avatar span.remove").click(function(){
                                $("#cabinet .profile .saving").removeClass("hide");

                                GM.Model.Cabinet.RemovePhoto().then(
                                    (data) => {
                                        GM.View.Cabinet.Profile();
                                        setTimeout(function(){
                                            $("#cabinet .profile .saving").addClass("hide");
                                        },1000);
                                    },
                                    () => {}
                                );
                            });
                        },
                        () => {}
                    );
                };
            };
        }
    };
};
