export default function newArticle(){
    var newArticle_refreshNewArticleTime;

    return {
        GetArticleTime: function(){
            return newArticle_refreshNewArticleTime;
        },
        
        refreshNewArticle: function(change, reload_form){
            if ($("#new_article").length){
                var modify = change ? "1" : "0";
                var textarea_height = [];
                if (reload_form) {
                    $(".wysiwyg").each(function () {
                        var id = $(this).attr("id");
                        var editor = CKEDITOR.instances[id];
                        if (editor){
                            $("input[type='hidden'][data-for='"+id+"']").val(CKEDITOR.instances[id].getData());
                            textarea_height[id] = $("#cke_"+id).height() - 7;
                        }
                    });

                    $("#disabled_screen").removeClass("hide");
                }
                if (newArticle_refreshNewArticleTime) clearTimeout(newArticle_refreshNewArticleTime);
                newArticle_refreshNewArticleTime = setTimeout(function(){
                    $("#disabled_screen").addClass("hide");
                    location.reload();
                },10000);

                $.ajax({
                    url : "/udata/content/getNewArticleForm/"+modify+"/"+"?transform=/modules/content/new_article_ajax.xsl",
                    type : "POST",
                    dataType : 'html',
                    data : $("#new_article #new_article_form").serialize()+"&url="+location.href,
                    success : function(data) {
                        if (reload_form) {
                            $("#new_article").html(data);
                            if (GM.Model.Images.upload_image_currXhr != undefined) GM.Model.Images.upload_image_currXhr.abort();
                            GM.View.CutContent();
                            GM.View.ColorBox.init();

                            //Чтобы не было скачков в высоте Wysiwyg при перезагрузке, установливаем высоту, сохраненную в textarea_height
                            for (var key in textarea_height) {
                                $("#"+key).height(textarea_height[key]);
                            }

                            GM.View.InitWysiwyg();
                            GM.View.InitSetInfo();
                            GM.View.InitTooltips();
                        }
                        $("#disabled_screen").addClass("hide");
                        clearTimeout(newArticle_refreshNewArticleTime);
                        newArticle_refreshNewArticleTime = false;
                        if (GM.Model.NewArticle.newArticle_last_click !== false) {
                            $(GM.Model.NewArticle.newArticle_last_click).prop("disabled",false);
                            $(GM.Model.NewArticle.newArticle_last_click).click();
                            GM.Model.NewArticle.newArticle_last_click = false;
                        }
                    }
                });
            };
        }
    };
}
