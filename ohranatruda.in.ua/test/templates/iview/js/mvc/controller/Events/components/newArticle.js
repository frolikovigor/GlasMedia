export default function newArticle(){
    var wysiwyg = [];

    return (function(){
        if ($("#new_article").length){
            $("body").on("change", "#new_article #new_article_form select, #new_article #new_article_form input", function(){
                GM.View.NewArticle.refreshNewArticle(true, ($(this).attr("reload_form") != undefined) ? true : false);
            });

            //Сохранение новой статьи
            $("body").on("click", ".save_article", function(){
                $("#new_article .save_article").html("Сохранение...");
                $("#new_article .save_article").prop("disabled", true);

                $(".wysiwyg").each(function () {
                    var id = $(this).attr("id");
                    wysiwyg[id] = CKEDITOR.instances[id].getData();
                    $("input[type='hidden'][data-for='"+id+"']").val(wysiwyg[id]);
                });

                if (GM.View.NewArticle.GetArticleTime() === false){
                    $.ajax({
                        url : "/udata/content/saveNewArticle/.json",
                        type : "POST",
                        dataType : 'json',
                        data : $("#new_article #new_article_form").serialize(),
                        success : function(data) {
                            if (data.error != undefined) {
                                $("#new_article .save_article").prop("disabled", false);
                                switch (data.error){
                                    case "not_auth":
                                        $("#authorization").modal();
                                        return false;
                                        break;
                                    case "not_enough_data":
                                        $("#new_article #not_enough_data").modal();
                                        return false;
                                        break;
                                    case "homepage":
                                        location.href = "/";
                                        return false;
                                        break;
                                };
                            };
                            if (data.url != undefined){
                                location.href = data.url;
                            } else location.href = "/cabinet/";
                        }
                    });
                } else GM.Model.NewArticle.newArticle_last_click = ".save_article";
            });
            $('body').on('hide.bs.modal', '#new_article #not_enough_data', function (e) {
                $("#new_article .save_article").html("Сохранить статью");
            });
            $('body').on('hide.bs.modal', '#authorization', function (e) {
                $("#new_article .save_article").html("Сохранить статью");
            });

            //Уадаление изображения
            $("body").on("click","#new_article .remove", function(){
                $.ajax({
                    url : "/udata/content/newArticleRemovePhoto/",
                    type : "POST",
                    dataType : 'html',
                    success : function(data) {
                        GM.View.NewArticle.refreshNewArticle(false, true);
                    }
                });
            });

            //Автосохранение
            setInterval(function(){
                $(".wysiwyg").each(function () {
                    var id = $(this).attr("id");
                    if (CKEDITOR.instances[id].getData() != wysiwyg[id]){
                        wysiwyg[id] = CKEDITOR.instances[id].getData();
                        $("input[type='hidden'][data-for='"+id+"']").val(wysiwyg[id]);
                        GM.View.NewArticle.refreshNewArticle(true, false);
                    }
                });
            }, 10000);
        };
    })();
}
