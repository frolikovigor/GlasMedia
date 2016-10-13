export default function comments(){


    return {
        Init: function(){
            //Комментарии
            $(".comment").each(function(){
                var c = $(this);
                var ta = c.children("textarea");
                ta.focus(function(){
                    ta.stop().animate({height: "75px"}, 250);
                });
                ta.blur(function(){
                    if(ta.val() == '') ta.stop().animate({height: "50px"}, 250);
                });
            });

            //Если количество блоков .comment.float больше 1, удаляем лишние
            $(".comment.float").each(function(i){
                if (i>0) $(this).remove();
            });

            $("body").on("click", ".comment_this", function(){
                var this_ = $(this);
                if (this_.attr("data-opened") == undefined){
                    $(".comment_this").removeAttr("data-opened");
                    this_.attr("data-opened", "1");
                    $(".comment.float").slideUp("fast",function(){
                        this_.closest(".comment_content").children(".answer").append($(".comment.float"));
                        $(".comment.float input,.comment.float textarea").val('');
                        $(".comment.float").slideDown("fast",function(){
                            setTimeout(function(){GM.View.Masonry.init();},200);
                        });
                        $(".comment.float").attr("data-parent",this_.attr('data-parent'));
                        $(".comment.float").attr("data-page",this_.attr('data-page'));
                        $(".comment.float").attr("data-per_page",this_.attr('data-per_page'));
                        $(".comment_this").removeClass('hide');
                        $(".cancel_comment_this").addClass('hide');
                        this_.addClass('hide');
                        this_.closest(".comment_content").children(".cancel_comment_this").removeClass("hide");
                    });
                }
            });
            $("body").on("click", ".cancel_comment_this", function(){
                $(".comment.float").slideUp("fast", function(){
                    setTimeout(function(){
                        GM.View.Masonry.init();
                    },200);
                });
                $(this).addClass("hide");
                $(this).closest(".comment_content").children(".comment_this").removeClass("hide");
                $(".comment_this").removeAttr("data-opened");
            });
        },

        //Отправка комментария
        SendComment: function(elem){
            var comment = elem.closest(".comment");
            var objId = comment.attr("data-page");
            var parentId = comment.attr("data-parent");
            var per_page = comment.attr("data-per_page");
            var content = comment.find("textarea").val();
            var anonymous = comment.find("input[name='anonymous']").prop("checked") ? "1" : "0";
            var name = comment.find("input[name='name']").val();
            var existName = comment.find("input[name='name']").length ? true : false;
            if (!content || (existName && !name)) {
                if (!content) comment.find("textarea").focus();
                if (!name) comment.find("input[name='name']").focus();
                return false;
            } else {
                if (objId != undefined){
                    if (elem.attr("data-captcha") == undefined){
                        elem.removeAttr("data-send");
                        comment.find("img.preloader").removeClass("hide");
                        $.ajax({
                            url : "/udata/content/sendComment/?transform=modules/comments/comments.xsl",
                            type : "POST",
                            dataType : 'html',
                            data : {objId: objId, parent_id: (parentId != undefined) ? parentId : "", name : name, content: content, per_page:per_page, anonymous:anonymous},
                            success : function(data) {
                                comment.find("img.preloader").addClass("hide");
                                comment.find("input[name='name'], textarea").val('');
                                comment.find("input[name='anonymous']").prop('checked', false);
                                var comments = comment.closest(".comments");
                                comments.append($(".comment.float"));
                                $(".comment.float").slideUp(function(){
                                    comments.find(".comments_list").html(data);
                                    var comments_amount = comments.find(".comments_amount").html();
                                    comments.find(".title span").html(comments_amount);
                                    GM.View.Masonry.init();
                                });
                            }
                        });
                    } else {
                        $(".comment button").removeAttr("data-send");
                        elem.attr("data-send","1");
                    }
                }
            }
        },

        //Подгрузка комментариев ajax
        GetListComments: function(elem,objId, per_page){
            elem.find("span").addClass("hide");
            elem.find("img").removeClass("hide");
            var per_page = parseInt(per_page) + 20;
            var comments_list = elem.closest(".comments_list");
            $.ajax({
                url : "/udata/content/getListComments/"+objId+"/"+per_page+"?transform=modules/comments/comments.xsl",
                type : "POST",
                dataType : 'html',
                success : function(data) {
                    comments_list.html(data);
                    GM.View.CutContent();
                    GM.View.Masonry.init();
                }
            });
            return false;
        }

    };
};
