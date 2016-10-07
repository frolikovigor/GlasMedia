window.glasmedia = (function(){
    var fragment;
    var upload_image_currXhr = null;
    var upload_image_crop = false;
    var newPoll_refreshNewPollTime;
    var newArticle_refreshNewArticleTime;
    var wysiwyg = [];
    var newPoll_last_click = false;
    var newArticle_last_click = false;
    var newPoll_gridster_li_move = false;
    var newPoll_gridster;
    var newPoll_gridsterTimer;
    var newPoll_gridster_move_time = false;
    var newPoll_gridster_move_time_start = false;
    var googleMapEnabled = false;
    var googleMapEnabledTimer = false;
    var googleMapSelectTimer = false;
    var feedback_timer = false;
    var viewImageTimer;
    var initMasonryInstance = false;
    var paginated_ajax_load = false;

    $(document).ready(function(){
        //Ajax pagination =============================================================================
        var window_height = $(window).height();
        $(document).scroll(function(){
            if ($(".paginated_ajax").length){
                $(".paginated").remove();
                /*var paginated_ajax_top = $(".paginated_ajax").offset().top;
                 if(($("body").scrollTop() + 2*window_height) > paginated_ajax_top){
                 if (!paginated_ajax_load) $(".paginated_ajax").click();
                 paginated_ajax_load = true;
                 }*/
            }
        });
        //=============================================================================================

        //Google Map init =============================================================================
        if ($(".googleMap").length) {
            google.load("visualization", "1", {packages:["geochart"], "callback" : initGoogleMap});
        }
        //=============================================================================================

        $("body").on("click", "a[href='#']", function(e){
            e.preventDefault();
        });

        //Лимит длины для textarea
        $('textarea[maxlength]').keyup(function(){
            var limit = parseInt($(this).attr('maxlength'));
            var text = $(this).val();
            var chars = text.length;
            if(chars > limit){
                var new_text = text.substr(0, limit);
                $(this).val(new_text);
            }
        });

        $(".modal-wide").on("show.bs.modal", function() {
            var height = $(window).height() - 200;
            $(this).find(".modal-body").css("max-height", height);
        });

        //Для всех кнопок с прелоадером
        $("body").on("click", ".btn.btn-preloader", function(){
            $(this).addClass("wait");
        });

        //Просмотр новости из БД
        $(".news[data-source='bd']").click(function(){
            var id = $(this).attr('data-id');
            $("#news_view_from_bd .apply").prop("disabled",true);
            $("#news_view_from_bd .modal-body").html("<div style='text-align:center; margin:10px; font-size:11pt;'>Идет загрузка...</div>");
            $("#news_view_from_bd").modal();
            $.ajax({
                url : "/udata/news/getNewsMysql/"+id+"/?transform=modules/news/get_news_mysql_ajax.xsl",
                type : "POST",
                dataType : 'html',
                success : function(data) {
                    $("#news_view_from_bd .apply").prop("disabled",false);
                    $("#news_view_from_bd .modal-body").html(data);
                }
            });
        });

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
        }

        //Голосование. Нажатие на кнопку "Голосовать"
        $("body").on("click",".poll .vote", function(){
            this_ = $(this);
            var needreg = this_.attr("data-needreg");
            if (needreg != undefined){
                $("#authorization").modal();
                return false;
            }
            var poll = this_.closest(".poll");
            var id = poll.attr("data-id");
            this_.prop("disabled", true);
            this_.find("span").addClass("hide");
            this_.find(".preloader").removeClass("hide");
            $.ajax({
                url : "/udata/vote/votePoll/?transform=modules/vote/vote_poll.xsl",
                type : "POST",
                dataType : 'html',
                data : poll.find('form').serialize(),
                success : function(data) {
                    if (data.indexOf("Failed to open udata")!=-1) $("#unexpected_error").modal();
                    var clone_id = "poll"+id+"_clone";
                    poll.append("<div id='"+clone_id+"'></div>");
                    poll.find("#"+clone_id).html(data);
                    $(".poll.poll"+id).html(poll.find("#"+clone_id+" .poll"+id).html());
                    initCutContent();
                    poll.find("#"+clone_id).remove();
                    initMasonry();
                    initPlayVideoIcon();
                    initColorBox();
                    drawGoogleMaps();
                }
            });
        });

        //Проверка капчи
        $("#captcha_enter .apply").on("click", function(){
            this_ = $(this);
            this_.addClass("wait");
            $.ajax({
                url : "/udata/content/checkCaptcha/.json",
                type : "POST",
                dataType : 'json',
                data : {captcha: $("input#captcha").val()},
                success : function(data) {
                    if (data.result != undefined)
                        if (data.result == "1"){
                            $("#captcha_enter").modal('hide');
                            $("[data-captcha = '1']").each(function(){
                                $(this).removeAttr("data-captcha");
                                $(this).unbind();
                            });
                            $("[data-send='1']").click();
                        } else {
                            $("#captcha_reset").click();
                        }
                    this_.removeClass("wait");
                }
            });
        });

        //Вывод всех категорий
        $("#navigation").on("click", ".all_categories", function(){
            var open = $(this).attr("data-open");
            if (open=="0"){
                $("#navigation #all_catagories").slideDown("fast", function(){
                    $(".grid-item").fadeIn("fast");
                    initMasonry();
                });
                $(this).attr("data-open", "1");
                $("li.all_categories").addClass("active");
            } else {
                $("#navigation #all_catagories").slideUp("fast");
                $(this).attr("data-open", "0");
                $("li.all_categories").removeClass("active");
            }
        });


        //homepage =========================================================================================================
        //homepage =========================================================================================================
        if ($("#homepage").length){
            $(".popular_categories img").hover(function(){
                $(this).stop().animate({width:"160px", marginTop:"0px"},100);
            }, function(){
                $(this).stop().animate({width:"150px", marginTop:"5px"},100);
            });
        }
        //homepage =========================================================================================================


        //NewPoll ==========================================================================================================
        if ($(".new_poll_block").length){

            refreshNewPoll(false, true);

            $("body").on("change", ".new_poll_block #new_poll_form select, .new_poll_block #new_poll_form input:not(.poll .variants input), .new_poll_block #new_poll_form textarea", function(){
                if ($(this).attr('name') == 'data[country]'){
                    $("select[name='data[region]").val('');
                    $("select[name='data[city]").val('');
                }
                if ($(this).attr('name') == 'data[region]'){
                    $("select[name='data[city]").val('');
                }
                refreshNewPoll(true, ($(this).attr("reload_form") != undefined) ? true : false);
            });

            //Сохранение нового опроса
            $("body").on("click", ".save_poll", function(){
                $(".new_poll_block .save_poll").html("Сохранение...");
                $(".new_poll_block .save_poll").prop("disabled", true);

                var data_type = $(".new_poll_block").attr("data-type");
                var data_for = $(".new_poll_block").attr("data-for");
                data_for = (data_for != undefined) ? data_for : "";
                var data_id = $(".new_poll_block").attr("data-id");
                data_id = (data_id != undefined) ? data_id : "";

                var fast = (data_type == "fast") ? "1/" : "";

                if (newPoll_refreshNewPollTime === false){
                    $.ajax({
                        url : "/udata/vote/saveNewPoll/"+fast+".json",
                        type : "POST",
                        dataType : 'json',
                        data : $(".new_poll_block #new_poll_form").serialize(),
                        success : function(data) {
                            if (data.error != undefined) {
                                $(".new_poll_block .save_poll").prop("disabled", false);
                                switch (data.error){
                                    case "not_auth":
                                        $("#authorization").modal();
                                        return false;
                                        break;
                                    case "not_enough_data":
                                        $("#not_enough_data_poll").modal();
                                        return false;
                                        break;
                                    case "images_incorrect":
                                        $("#images_incorrect").modal();
                                        return false;
                                        break;
                                    case "homepage":
                                        location.href = "/";
                                        return false;
                                        break;
                                }
                            }
                            if (data.fast != undefined){
                                $("#fast_poll_complete").modal();
                                refreshNewPoll(false, true);
                                return false;
                            } else {
                                if (data.url != undefined){
                                    location.href = data.url;
                                } else location.href = "/cabinet/";
                            }
                        }
                    });
                } else newPoll_last_click = ".save_poll";
            });
            $('body').on('hide.bs.modal', '#not_enough_data_poll', function (e) {
                $(".new_poll_block .save_poll").html("Сохранить опрос");
            });
            $('body').on('hide.bs.modal', '#authorization', function (e) {
                $(".new_poll_block .save_poll").html("Сохранить опрос");
            });
            $('body').on('hide.bs.modal', '#images_incorrect', function (e) {
                $(".new_poll_block .save_poll").html("Сохранить опрос");
            });
        }
        //NewPoll ==========================================================================================================


        //NewArticle =======================================================================================================
        //NewArticle =======================================================================================================
        if ($("#new_article").length){
            refreshNewArticle(false, true);

            $("body").on("change", "#new_article #new_article_form select, #new_article #new_article_form input", function(){
                refreshNewArticle(true, ($(this).attr("reload_form") != undefined) ? true : false);
            });

            setInterval(function(){

                $(".wysiwyg").each(function () {
                    var id = $(this).attr("id");
                    if (CKEDITOR.instances[id].getData() != wysiwyg[id]){
                        wysiwyg[id] = CKEDITOR.instances[id].getData();
                        $("input[type='hidden'][data-for='"+id+"']").val(wysiwyg[id]);
                        refreshNewArticle(true, false);
                    }
                });

            }, 10000);

            //Уадаление изображения
            $("body").on("click","#new_article .remove", function(){
                $.ajax({
                    url : "/udata/content/newArticleRemovePhoto/",
                    type : "POST",
                    dataType : 'html',
                    success : function(data) {
                        refreshNewArticle(false, true);
                    }
                });
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

                if (newArticle_refreshNewArticleTime === false){
                    $.ajax({
                        url : "/udata/content/saveNewArticle/.json",
                        type : "POST",
                        dataType : 'json',
                        data : $("#new_article #new_article_form").serialize(),
                        success : function(data) {
                            if (data.error != undefined) {
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
                                }
                                $("#new_article .save_article").prop("disabled", false);
                            }
                            if (data.url != undefined){
                                location.href = data.url;
                            } else location.href = "/cabinet/";
                        }
                    });
                } else newArticle_last_click = ".save_article";
            });
            $('body').on('hide.bs.modal', '#new_article #not_enough_data', function (e) {
                $("#new_article .save_article").html("Сохранить статью");
            });
            $('body').on('hide.bs.modal', '#authorization', function (e) {
                $("#new_article .save_article").html("Сохранить статью");
            });
        }
        //NewArticle =======================================================================================================



        //Cabinet ==========================================================================================================
        //Cabinet ==========================================================================================================
        if ($("#cabinet").length){
            if ($("#cabinet_profile").length){
                cabinet_profile();
            }
        }
        //Cabinet ==========================================================================================================

        //Feed =============================================================================================================
        $(".feed .feed-info .subsribe button:not(.disabled)").on("click", function(){
            if (!$(this).hasClass("no-auth")){
                feedSubscribe($(this));
            }
        });

        if ($("#feeds_setting_form").length){
            initWysiwyg();

            var feedId = $("#feeds_setting_form").attr("data-feed-id");
            setTimeout(function(){
                $("#feeds_setting_form").cc_validate({
                    settings: {required_class:'required', error_class:'error'},
                    rules : [
                        {element:"input[name='name']", rule:'min_length', min_length:5},
                        {element:"input[name='url']", rule:'check', url:'/vote/checkUrlLent/'+feedId+'/?url=',need:'true'}
                    ],
                    warning: function(elem, rule, result){
                        switch (result){
                            case 'error':
                                elem.closest('div').find('span[data-warning='+rule+']').html("Недопустимый формат");
                                break;
                            case 'exist':
                                elem.closest('div').find('span[data-warning='+rule+']').html("Адрес уже занят");
                                break;
                            case 'url_short':
                                elem.closest('div').find('span[data-warning='+rule+']').html("Слишком короткий адрес");
                                break;
                        }
                        elem.closest('div').find('span[data-warning='+rule+']').removeClass('hide');
                        setTimeout(function(){
                            $("#feeds_setting_form button[type='submit']").removeClass("wait");
                        },300);
                    },
                    hide_warning: function(elem, rule, result){
                        elem.closest('div').find('span[data-warning='+rule+']').addClass('hide');
                    },
                    success: function(form){
                        var feed_description = CKEDITOR.instances.feed_description.getData();
                        $("#feed_description_hidden").val(feed_description);
                        form.submit();
                    }
                });
            },500);
        }
        //Feed =============================================================================================================

        //Feedback =========================================================================================================
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
        //Feedback =========================================================================================================

        //view_category ====================================================================================================
        if ($("#view_category").length){

        }
        //view_category ====================================================================================================

        init_counter();
        initColorBox();
        initTooltips();
        initComments();
        initCaptcha();
        initSetInfo();
        initCropper();
        initIntroJs();

        $("body").waitForImages(function(){
            $(".hidden_block").removeClass("hidden_block");
            adaptiveImage();
            init_dot();
            initCutContent();
            initMasonry();
            goto();
            initPlayVideoIcon();

        });
        if (googleMapEnabled) drawGoogleMaps();
        else{
            googleMapEnabledTimer = setInterval(function(){
                if (googleMapEnabled) {
                    clearInterval(googleMapEnabledTimer);
                    drawGoogleMaps();
                }
            }, 500);
        }

        //Для открывающихся текстов
        $("body").on("click", ".slidedown_title", function(){
            var id = $(this).attr("data-for-content");
            $(this).toggleClass("dropup");
            $(".slidedown_content[data-id='"+id+"']").toggleClass("hide");
            if($(this).hasClass("dropup")) $.cookie('alert_slidedown_'+id, null,{ path:'/' }); else $.cookie('alert_slidedown_'+id, 1,{ path:'/' });
        });
        openAlerts();

        //Если установлен get параметр preview, выполняется click по .popup_img с соответств. id
        $(".popup_img[data-id='"+$("#service-information").attr("data-preview")+"']").click();

        //Ajax пагинация
        $("body").on("click", ".paginated_ajax", function(){
            var this_ = $(this);
            var block = this_.attr("for-data-block");
            var udata = this_.attr("data-udata");
            var transform = this_.attr("data-transform");
            var page = this_.attr("data-page");
            var search_string = this_.attr("data-search_string");

            page = (page !== undefined) ? (parseInt(page) + 1) : 1;
            this_.attr("data-page", page);
            $.ajax({
                url : udata+"?transform="+transform,
                type : "POST",
                dataType : 'html',
                data : {p:page, search_string:search_string},
                success : function(data) {
                    var parsedHtml = $.parseHTML(data);

                    $("[data-block='"+block+"']").append(data);

                    var selector = "";
                    var first=true;

                    for (var i = 0; i < parsedHtml.length; i++) {
                        if (parsedHtml[i].nodeName == "DIV")
                            if (parsedHtml[i].hasAttribute("data-id")){
                                var pollId = parsedHtml[i].getAttribute("data-id");
                                if (pollId){
                                    if (!first) selector += ",";
                                    selector += ".poll.poll"+pollId;
                                    first = false;
                                }
                            }
                    }

                    $(selector).css("opacity","0.01");

                    $("[data-block='"+block+"']").waitForImages(function() {
                        initCutContent();
                        initComments();
                        initMasonry();
                        initCaptcha();
                        initPlayVideoIcon();
                        if ($("[data-block='"+block+"'] .last_page").length){
                            this_.remove();
                            $("[data-block='"+block+"'] .last_page").remove();
                        } else
                            this_.removeClass('wait');

                        $(selector).animate({opacity:1.0},300, function(){
                            paginated_ajax_load = false;
                        });
                    })
                }
            });
        });

        $(".swipe-area").swipe({
            swipeStatus:function(event, phase, direction, distance, duration, fingers)
            {
                if (phase=="move" && direction =="right") {
                    $("#left_panel").animate({left:'0px'},200, function () {
                        $("#left_panel").addClass("opened");
                    });
                    return false;
                }
                if (phase=="move" && direction =="left") {
                    $("#left_panel").animate({left:'-220px'},200, function () {
                        $("#left_panel").removeClass("opened");
                    });
                    return false;
                }
            }
        });
        $("#open_sidebar").click(function () {
            if ($("#left_panel").hasClass("opened")){
                $("#left_panel").animate({left:'-220px'},200, function () {
                    $("#left_panel").removeClass("opened");
                });
            } else {
                $("#left_panel").animate({left:'0px'},200, function () {
                    $("#left_panel").addClass("opened");
                });
            }
        });


    });


    function initColorBox(){
        $('a.popup_img:not(.video)').colorbox({
            current : "{current} из {total}"
        });
        $('a.popup_img.video').colorbox({iframe:true, innerWidth:640, innerHeight:390});
    }

    function initTooltips(){
        $(function () {
            $('[data-toggle="tooltip"]').tooltip()
        })
    }

//Создает элементы option
    function init_counter(){
        $("body").find("option[data-counter_from]").each(function(){
            var from = parseInt($(this).attr("data-counter_from"));
            var to = parseInt($(this).attr("data-counter_to"));
            var this_ = $(this);
            var selected = (this_.closest("select").attr("data-select") != undefined) ? parseInt(this_.closest("select").attr("data-select")) : false;
            this_.removeAttr("data-counter_from");
            this_.removeAttr("data-counter_to");
            this_.attr("value", from);
            this_.text(from);
            for(index = from+1; index<=to; index++){
                var clone = this_.clone();
                clone.attr("value", index);
                clone.text(index);
                if (selected !== false) if (index == selected) clone.attr("selected","selected");
                this_.closest("select").append(clone);
            }
            $(this).closest('select').find("[data-remove='1']").remove();
        });
    }

//Комментарии
    function initComments(){
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
                        setTimeout(function(){initMasonry();},200);
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
                setTimeout(function(){initMasonry();},200);
            });
            $(this).addClass("hide");
            $(this).closest(".comment_content").children(".comment_this").removeClass("hide");
            $(".comment_this").removeAttr("data-opened");
        });
    }

//Инициализация капчи
    function initCaptcha(){
        $("[data-captcha = '1']").each(function(){
            $(this).click(function(){
                $("#captcha_enter").modal();
                $('#captcha_enter').on('shown.bs.modal', function (e) {
                    $("#captcha").focus();
                })
            });
        });
    }

//Отправка комментария
    function sendComment(elem){
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
                                initMasonry();
                            });
                        }
                    });
                } else {
                    $(".comment button").removeAttr("data-send");
                    elem.attr("data-send","1");
                }
            }
        }
    }

    //Подгрузка комментариев ajax
    var getListComments = function(elem,objId, per_page){
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
                initCutContent();
                initMasonry();
            }
        });
        return false;
    }

//Обратная связь
    function feedback(elem){
        if (elem.attr("data-captcha") == undefined){
            $("#feedback").modal();
        } else {
            elem.attr("data-send","1");
        }
    }

    function refreshNewPoll(change, reload_form){
        var modify = change ? "1" : "0";
        if (reload_form) $("#disabled_screen").removeClass("hide");
        if (newPoll_refreshNewPollTime) clearTimeout(newPoll_refreshNewPollTime);
        newPoll_refreshNewPollTime = setTimeout(function(){
            $("#disabled_screen").addClass("hide");
            location.reload();
        },10000);

        var data_type = $(".new_poll_block").attr("data-type");
        var data_for = $(".new_poll_block").attr("data-for");
        data_for = (data_for != undefined) ? data_for : "";
        var data_id = $(".new_poll_block").attr("data-id");
        data_id = (data_id != undefined) ? data_id : "";

        var fast = (data_type == "fast") ? "1/" : "";

        var scrollTextarea = $(".new_poll_block .chanels").scrollTop();

        $.ajax({
            url : "/udata/vote/getNewPollForm/"+modify+"/"+fast+"?transform=/modules/vote/new_poll_ajax.xsl",
            type : "POST",
            dataType : 'html',
            data : $(".new_poll_block #new_poll_form").serialize()+"&data_for="+data_for+"&data_id="+data_id+"&url="+encodeURIComponent(location.href),
            success : function(data) {
                if (reload_form) {
                    var heightImages = $(".new_poll_block .images").outerHeight();
                    $(".new_poll_block").html(data);
                    $(".new_poll_block .images").css("height", heightImages+"px");

                    $(".new_poll_block .chanels").scrollTop(scrollTextarea);

                    if (upload_image_currXhr != undefined) upload_image_currXhr.abort();
                    refreshGridster();
                    initCutContent();
                    setTimeout(function(){
                        initMasonry();

                        if (
                            ($(".new_poll_block").attr("data-tooltips-id") != '') &&
                            ($(".new_poll_block").attr("data-tooltips-id") !== undefined)
                        )
                            $(".new_poll_block").addClass("tooltips");

                        if (
                            ($(".poll.medium[data-type='poll']:first").find(".settings_item ul").attr("data-tooltips-id") != '') &&
                            ($(".poll.medium[data-type='poll']:first").find(".settings_item ul").attr("data-tooltips-id") !== undefined)
                        ){
                            $(".poll.medium[data-type='poll']:first").find(".settings_item ul").addClass("tooltips");
                            $(".poll.medium[data-type='poll']:first").find(".settings_item").addClass("open_for_tooltip");
                        }

                        initIntroJs();
                    },500);
                    initColorBox();
                    initSetInfo();
                    initTooltips();

                }
                $("#disabled_screen").addClass("hide");
                clearTimeout(newPoll_refreshNewPollTime);
                newPoll_refreshNewPollTime = false;
                if (newPoll_last_click !== false) {
                    $(newPoll_last_click).prop("disabled",false);
                    $(newPoll_last_click).click();
                    newPoll_last_click = false;
                }
            }
        });
    }

    function refreshNewArticle(change, reload_form){
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
                    if (upload_image_currXhr != undefined) upload_image_currXhr.abort();
                    initCutContent();
                    initColorBox();

                    //Чтобы не было скачков в высоте Wysiwyg при перезагрузке, установливаем высоту, сохраненную в textarea_height
                    for (key in textarea_height) {
                        $("#"+key).height(textarea_height[key]);
                    }

                    initWysiwyg();
                    initSetInfo();
                    initTooltips();
                }
                $("#disabled_screen").addClass("hide");
                clearTimeout(newArticle_refreshNewArticleTime);
                newArticle_refreshNewArticleTime = false;
                if (newArticle_last_click !== false) {
                    $(newArticle_last_click).click();
                    newArticle_last_click = false;
                }
            }
        });
    }

    const UploadImage = function(do_, elem){
        upload_image_crop = false;
        $("#upload_image form input[type='file']").unbind();
        $("#upload_image .form-group>input[type='text']").unbind();
        $("#upload_image .apply").unbind();
        $("#upload_image .close_abort").unbind();
        $("#upload_image form").ajaxFormUnbind();
        $("#upload_image .apply").prop("disabled", true);
        $("#upload_image input").val("");
        $("#upload_image input[type='text']").attr("old_value","");
        $("#upload_image .cropper>img").cropper("destroy");
        $('#upload_image .cropper').html('');

        fragment = elem.attr("data-fragment");
        var data_url = elem.attr("data-url");
        var data_parameters = elem.attr("data-parameters");
        $("#upload_image").attr("data-fragment", fragment);
        $("#upload_image .cropper").attr("data-fragment", fragment);
        $("#upload_image form").attr("action", data_url);
        $("#upload_image input[name='parameters']").val(data_parameters);

        $("#upload_image").modal();

        $("#upload_image form input[type='file']").unbind();
        $("#upload_image form input[type='file']").on("change", function(){
            $("#upload_image form").submit();
        });

        $("#upload_image .form-group>input[type='text']").unbind();
        $("#upload_image .form-group>input[type='text']").on("keyup", function(){
            var stat = false;
            if ($(this).attr("old_value") != undefined){
                if ($(this).attr("old_value") != $(this).val()) stat = true;
            } else stat = true;

            if (stat){
                $("#upload_image .preloader").removeClass("hide");
                $(this).attr("old_value", $(this).val());
                $("#upload_image .apply").prop("disabled", true);
                $.ajax({
                    url : "/udata/content/checkImageUrl/.json",
                    type : "POST",
                    dataType : 'json',
                    data : {url:$(this).val()},
                    success : function(data) {
                        if (data.result != "0") $("#upload_image .apply").prop("disabled", false);
                        else $("#upload_image .apply").prop("disabled", true);
                        $("#upload_image .preloader").addClass("hide");
                    }
                });
            }
        });

        $("#upload_image .apply").unbind();
        $("#upload_image .apply").click(function(){
            var crop = "";
            if (upload_image_crop != false){
                var cropX = upload_image_crop.x;
                var cropY = upload_image_crop.y;
                var cropWidth = upload_image_crop.width;
                var cropHeight = upload_image_crop.height;
                crop = cropX + "_" + cropY + "_" + cropWidth + "_" + cropHeight;
                $("#upload_image input[name='crop']").val(crop);
            }
            var parameters = $("#upload_image input[name='parameters']").val();

            $("#upload_image .preloader").removeClass("hide");
            $("#upload_image input[type='text'],#upload_image button.apply").prop("disabled",true);
            $.ajax({
                url : $("#upload_image form").attr("action") + "1",
                type : "POST",
                dataType : 'html',
                data : {url:$("#upload_image .form-group>input[type='text']").val(), crop:crop, parameters:parameters},
                success : function(data) {
                    if ((fragment != '') && (upload_image_crop === false)) uploadImageFragment(do_);
                    else uploadImageComplete(do_);
                }
            });
        });
        $("#upload_image .close_abort").unbind();
        $("#upload_image .close_abort").on("click", function(){
            if (upload_image_currXhr) upload_image_currXhr.abort();
        });

        $("#upload_image form").ajaxForm({
            beforeSend: function(xhr){
                upload_image_currXhr = xhr;
                $("#upload_image .preloader").removeClass("hide");
                $("#upload_image input[type='text'],#upload_image button.apply").prop("disabled",true);
            },
            uploadProgress: function(event, position, total, percentComplete){
                $("#upload_image .progress_bar").removeClass("hide");
                $("#upload_image .progress_bar").html(percentComplete+"%");
            },
            success: function(){
                $("#upload_image .progress_bar").addClass("hide");
            },
            complete: function(response){
                if (fragment != '') uploadImageFragment(do_);
                else uploadImageComplete(do_);
            },
            error: function(){

            }
        });
    }

//Закрытие окна загрузки изображения и обновление страницы
    function uploadImageComplete(do_){
        $("#upload_image .cropper>img").cropper("destroy");

        $("#upload_image button.apply").prop("disabled", true);
        $("#upload_image .preloader").addClass("hide");
        $("#upload_image input[type='text'],#upload_image button.apply").prop("disabled",false);
        $("#upload_image").modal('hide');
        $("body").removeClass("modal-open");
        switch (do_){
            case "poll_new_image":
                refreshNewPoll(true, true);
                break;
            case "upload_image_article":
                refreshNewArticle(true, true);
                break;
            case "upload_image_profile":
                cabinet_profile();
                break;
            case "upload_image_feed":
                location.reload();
                break;
        }
    }

//Выбор фрагмента изображения после загрузки
    function uploadImageFragment(do_){
        $("#upload_image .preloader").addClass("hide");
        $("#upload_image input[type='text'],#upload_image button.apply").prop("disabled",false);
        $.ajax({
            url : "/udata/content/getImageName/.json",
            type : "POST",
            dataType : 'json',
            data : {session_name: do_},
            success : function(data) {
                $('#upload_image .cropper img').remove();
                $('#upload_image .cropper').unbind();
                $('#upload_image .cropper').html('<label>Выберите фрагмент изображения</label><img class="hide" src="'+data.image+".jpg"+'" />');
                initCropper();
            }
        });
    }


    function refreshGridster(){
        newPoll_gridsterTimer = false;
        var gridster_margins = [1,1];
        var max_size_item = [6,6];

        newPoll_gridster = $(".new_poll_block .gridster ul").gridster({
            widget_margins: gridster_margins,
            widget_base_dimensions: [145, 100],
            resize: {
                enabled: true,
                max_size: max_size_item,
                resize: function(e, ui, $widget){
                    viewImage();
                    updatePoolForGridster();
                }
            },
            draggable:{
                stop: function(event, ui){
                    viewImage();
                    updatePoolForGridster();
                }
            },
            max_size_x: max_size_item[0],
            max_size_y: max_size_item[0],
            max_cols: max_size_item[0]
        }).data('gridster');

        viewImage();

        //Отключение контекстного меню
        $(".new_poll_block .gridster").closest("#new_poll_form").on("contextmenu", false);

        $(".new_poll_block .gridster ul li").mousedown(function(event){
            if (event.preventDefault)
                event.preventDefault()
            else
                event.returnValue= false

            if(event.button == 2){
                var top = parseInt(($(this).attr("data-top") != undefined) ?  $(this).attr('data-top') : 0);
                var left = parseInt(($(this).attr("data-left") != undefined) ? $(this).attr('data-left') : 0);
                newPoll_gridster_li_move = [$(this), event.pageX, event.pageY, left, top];
            }
        });

        $(".new_poll_block .gridster ul li").hover(
            function(){
                $(this).find(".remove").fadeIn();
                $(this).find(".move").fadeIn();
            },
            function(){
                $(this).find(".remove").fadeOut();
                $(this).find(".move").fadeOut();
            }
        );

        $("body").mouseup(function(event){
            if (event.preventDefault)
                event.preventDefault()
            else
                event.returnValue= false

            if(event.button == 0){
                if (newPoll_gridster_move_time !== false){
                    clearInterval(newPoll_gridster_move_time);
                    newPoll_gridster_move_time = false;
                }
                if (newPoll_gridster_move_time_start !== false){
                    clearInterval(newPoll_gridster_move_time_start);
                    newPoll_gridster_move_time_start = false;
                }
            }

            if(event.button == 2){
                if (newPoll_gridster_li_move !== false){
                    newPoll_gridster_li_move = false;
                    //......
                    //......
                }
            }
        });

        //Передвижение изображений
        $("#new_poll_form").on("mousemove", function(event) {
            if (newPoll_gridster_li_move !== false){
                var li = newPoll_gridster_li_move[0];
                var mT = event.pageY - newPoll_gridster_li_move[2] + newPoll_gridster_li_move[4];
                var mL = event.pageX - newPoll_gridster_li_move[1] + newPoll_gridster_li_move[3];
                li.attr("data-top", Math.round(mT));
                li.attr("data-left", Math.round(mL));
                viewImage();
                updatePoolForGridster();
            }
        });

        $(".new_poll_block .gridster ul li .move").mousedown(function(event){
            if (event.preventDefault)
                event.preventDefault()
            else
                event.returnValue= false

            if(event.button == 0){
                this_ = $(this);
                gridster_move(this_);
                newPoll_gridster_move_time_start = setTimeout(function(){
                    newPoll_gridster_move_time = setInterval(function(){
                        gridster_move(this_);
                    },50);
                }, 500);

            }
        });

        //Изменение масштаба изображений
        $(".new_poll_block .gridster ul li").unbind('mousewheel DOMMouseScroll').on('mousewheel DOMMouseScroll', function(e) {
            if ($(this).attr("data-width") == undefined) $(this).attr("data-width","100");
            var width = parseInt($(this).attr("data-width"));
            var delta = Math.floor(2*(width / 100));

            if (e.deltaY < 0) var new_width = width - delta;
            else var new_width = width + delta;

            $(this).attr("data-width", Math.round(new_width));
            viewImage();
            e.preventDefault();
            e.stopPropagation();

            updatePoolForGridster();
        });

    }
    function viewImage(){
        var stat = true;
        if (viewImageTimer) clearInterval(viewImageTimer);
        $(".new_poll_block .gridster ul li img").each(function(){
            if (!$(this).height()) stat = false;
        });
        if (!stat){
            viewImageTimer = setTimeout(function(){
                viewImage();
            },300);
            return;
        }
        clearInterval(viewImageTimer);
        $(".new_poll_block .images").css("height", "auto");   //При перезагрузке страницы refreshNewPoll, устанавливается высота, чтобы не было скачков. Здесь сбрасывается.
        $(".new_poll_block .gridster ul li").each(function(){
            reViewImage($(this));
        });
    }

    function reViewImage(elem){
        var id = elem.attr("data-id");
        var left = parseInt(elem.attr("data-left"));
        var top = parseInt(elem.attr("data-top"));
        var width = parseInt(elem.attr("data-width"));
        var row = parseInt(elem.attr("data-row"));
        var col = parseInt(elem.attr("data-col"));
        var sizex = parseInt(elem.attr("data-sizex"));
        var sizey = parseInt(elem.attr("data-sizey"));

        //Подбор масштаба
        var img_width = elem.find("img").width();
        var img_height = elem.find("img").height();
        var li_width = elem.width();
        var li_height = elem.height();

        if (img_width && img_height && li_width && li_height){
            var img_koef = img_width / img_height;
            var li_koef = li_width / li_height;
            if (img_koef > li_koef) {
                var s_width = 100 * img_koef / li_koef;
                if (width < s_width) {
                    elem.attr("data-top", "0");
                    elem.attr("data-left", "0");
                    elem.attr("data-width", Math.round(s_width));
                }
            } else {
                if (width < 100) {
                    elem.attr("data-top", "0");
                    elem.attr("data-left", "0");
                    elem.attr("data-width", "100");
                }
            }
        }

        var width_img = elem.find("img").width();
        var height_img = elem.find("img").height();
        height_img = !height_img ? 1 : height_img;
        var koef_img = width_img / height_img;
        var width_li = elem.width();
        var height_li = elem.height();
        height_li = !height_li ? 1 : height_li;
        var koef_li = width_li / height_li;
        min_width = (koef_img <= koef_li) ? 100 : 100 * koef_img/ koef_li;
        width = Math.round((width < min_width) ? min_width : width);
        width = (koef_img <= koef_li) ? (width > 250 ? 250 : width) : (width / (koef_img/koef_li) > 250 ? 250*koef_img/koef_li : width);
        top = (top > 0) ? 0 : top;
        left = (left > 0) ? 0 : left;
        var maxDeltaT = ((width / 100) * width_li) / koef_img - height_li;
        top = (top < -maxDeltaT) ? -maxDeltaT : top;
        var maxDeltaL = (width / 100) * width_li - width_li;
        left = (left < -maxDeltaL) ? -maxDeltaL : left;

        elem.find("img").css("margin-top",Math.round(top)+"px");
        elem.attr("data-top",Math.round(top));
        elem.find("img").css("margin-left",Math.round(left)+"px");
        elem.attr("data-left",Math.round(left));
        elem.find("img").css("width", Math.round(width) + "%");
        elem.attr("data-width",Math.round(width));
        elem.find("input[data-name='top']").val(Math.round(top));
        elem.find("input[data-name='left']").val(Math.round(left));
        elem.find("input[data-name='width']").val(Math.round(width));
        elem.find("input[data-name='row']").val(row);
        elem.find("input[data-name='col']").val(col);
        elem.find("input[data-name='sizex']").val(sizex);
        elem.find("input[data-name='sizey']").val(sizey);
    }

    function updatePoolForGridster(){
        if (newPoll_gridsterTimer !== false) {
            clearTimeout(newPoll_gridsterTimer);
            newPoll_gridsterTimer = false;
        }
        newPoll_gridsterTimer = setTimeout(function(){
            var total_height = 0;
            $(".new_poll_block .gridster ul li").each(function(){
                var li = $(this);
                var getSizeY = parseInt(li.attr('data-row')) + parseInt(li.attr('data-sizey')) - 1;
                if (getSizeY > total_height) total_height = getSizeY;
            });
            if (total_height > 6) $(".new_poll_block .images").addClass("error"); else $(".new_poll_block .images").removeClass("error");

            refreshNewPoll(true, false);
        }, 1000);
    }

    function gridster_move(elem){
        var li = elem.closest("li");
        var top = parseInt((li.attr("data-top") != undefined) ? li.attr("data-top") : 0);
        var left = parseInt((li.attr("data-left") != undefined) ? li.attr("data-left") : 0);
        if (elem.hasClass("to_left")) left -= 10;
        if (elem.hasClass("to_top")) top -= 10;
        if (elem.hasClass("to_right")) left += 10;
        if (elem.hasClass("to_down")) top += 10;
        li.attr("data-top", top);
        li.attr("data-left", left);
        viewImage();
        updatePoolForGridster();
    }

    function getInterestsList(){
        $("#cabinet .interests .preloader").removeClass("hide");
        $.ajax({
            url : "/udata/users/getInterestsOfUser/?transform=modules/users/get_profile_ajax.xsl",
            type : "POST",
            dataType : 'html',
            success : function(data) {
                $(".interests ul.list").html(data);
                $(".interests .preloader").addClass("hide");

                $("#cabinet .interests .remove").unbind();
                $("#cabinet .interests .remove").click(function(){
                    $("#cabinet .interests .preloader").removeClass("hide");
                    var id = $(this).data('id');
                    $.ajax({
                        url : "/udata/users/removeInterestsOfUser/",
                        type : "POST",
                        dataType : 'html',
                        data: {id:id},
                        success : function(data) {
                            getInterestsList();
                        }
                    });
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
                        $.ajax({
                            url : "/udata/users/addInterestsOfUser/",
                            type : "POST",
                            dataType : 'html',
                            data: {id:id},
                            success : function(data) {
                                getInterestsList();
                            }
                        });
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
                init_counter();
            }
        });
    }

    function initMasonry(){
        if (initMasonryInstance)
            $(".masonry").masonry('destroy');

        var scrollTop = $("body").scrollTop();

        $(".masonry").each(function(){
            var getClass = $(this).attr("data-class-masonry");
            var getGutter = parseInt($(this).attr("data-masonry-gutter"));
            $(this).masonry({
                itemSelector: '.'+getClass,
                gutter: getGutter
            });
        });
        initMasonryInstance = true;
        $("body").scrollTop(scrollTop);
    }

    function initGoogleMap(){
        googleMapEnabled = true;
    }

    function drawGoogleMaps() {
        if (googleMapEnabled){
            $(".googleMap").each(function(){
                drawGoogleMap($(this), '');
            });
        }
    }

    function drawGoogleMap(elemGM, param0, param1) {
        var elem = elemGM.children("div");
        var idMap = elem.attr("id");
        var mapType = elem.attr("data-mapType");
        var pollId = (elem.attr("data-pollId") != undefined) ? elem.attr("data-pollId") : false;
        //var width = parseInt(elem.attr("data-width"));
        //var height= parseInt(elem.attr("data-height"));
        var param0 = param0 ? param0 : '';
        var param1 = param1 ? param1 : "";

        switch (mapType){
            case "poll":
                if (pollId){
                    elemGM.removeClass("hidePreloader");
                    $.ajax({
                        url : "/udata/vote/getPollMap/"+pollId+"/"+param1+"/.json",
                        type : "POST",
                        data : param0,
                        dataType : 'json',
                        success : function(getData) {
                            if ((getData.regions != undefined) && (getData.region != undefined)){
                                var rowsTable = [];
                                votes = (getData.votes.item != undefined) ? getData.votes.item : [];
                                for(var vote in votes)
                                    if ((votes[vote].region != undefined) && (votes[vote].votes !=undefined) && (votes[vote].name != undefined))
                                        rowsTable.push([votes[vote].region, votes[vote].votes, votes[vote].name]);

                                var data = new google.visualization.DataTable();
                                data.addColumn('string', 'region');
                                data.addColumn('number', 'Голосов');
                                data.addColumn('string', 'Display');
                                data.addRows(rowsTable);
                                var geochart = new google.visualization.GeoChart(
                                    document.getElementById(idMap));
                                var formatter = new google.visualization.PatternFormat('{1}');
                                formatter.format(data, [0, 2]);
                                var view = new google.visualization.DataView(data);
                                view.setColumns([0, 1]);

                                geochart.draw(view, {
                                    //width: width,
                                    //height: height,
                                    region: getData.region,
                                    resolution: getData.regions,
                                    colorAxis: {colors: ['#B9D3EE', '#104E8B']}
                                });

                                elemGM.addClass("hidePreloader");

                                if (rowsTable.length && (getData.regions != 'provinces')){
                                    google.visualization.events.addListener(geochart, 'regionClick', function(e) {
                                        drawGoogleMap(elemGM,param0,e.region);
                                    });
                                }
                                if (param1)
                                    $(".googleMapZoomOut[data-for_map='"+idMap+"']").removeClass("hide");
                                else
                                    $(".googleMapZoomOut[data-for_map='"+idMap+"']").addClass("hide");
                                $(".googleMapZoomOut[data-for_map='"+idMap+"']").unbind();
                                $(".googleMapZoomOut[data-for_map='"+idMap+"']").on("click",function(){
                                    drawGoogleMap(elemGM, param0);
                                });
                                $(".googleMapSelect").unbind();
                                $(".googleMapSelect").on("click", function(){
                                    elemGM.removeClass("hidePreloader");
                                    var active = $(this).hasClass("active") ? false : true;
                                    if (active) {
                                        $(this).addClass("active");
                                        $(this).find("input[type='hidden']").prop("disabled", false);
                                    } else {
                                        $(this).removeClass("active");
                                        $(this).find("input[type='hidden']").prop("disabled", true);
                                    }


                                    var for_map = $(this).attr("data-for_map");
                                    var serFM = '';
                                    /*if (!$(".googleMapSelect[data-for_map='"+for_map+"'].active").length)
                                     $(".googleMapSelect[data-for_map='"+for_map+"']").addClass("active");*/
                                    serFM = $(this).closest("form").serialize() + "&custom=1";
                                    /*$(".googleMapSelect[data-for_map='"+for_map+"'].active").each(function(){
                                     var variantId = $(this).attr("data-variant_id");
                                     serFM += variantId+",";
                                     });*/
                                    if (googleMapSelectTimer !== false) clearTimeout(googleMapSelectTimer);
                                    googleMapSelectTimer = setTimeout(function(){
                                        drawGoogleMap($("#"+for_map).closest(".googleMap"), serFM);
                                    }, 2000);
                                });
                            } else {
                                elemGM.addClass("hidePreloader");
                            }
                        }
                    });
                }
                break;
        }
    }

//Ограничение текста по высоте блоков класса content_cut
    function initCutContent(){
        $(".content_cut").each(function(){
            var id = $(this).attr("data-cut-id");
            var setHeight = $(this).attr("data-cut-height");
            $(this).css("height","auto");
            if (($(this).outerHeight()-50) > setHeight) {
                $(this).css("height",setHeight+"px");
                $("a.open_cut[data-for-cut='"+id+"']").removeClass("hide");
            }
        });
        $(".open_cut").click(function(){
            var id = $(this).attr("data-for-cut");
            var block = $(this).parent().find(".content_cut[data-cut-id='"+id+"']");
            block.css("height","auto");
            block.removeClass('content_cut');
            $(this).remove();
            setTimeout(function(){initMasonry();},500);
            return false;
        });
    }

    function initWysiwyg(){
        $(".wysiwyg").each(function () {
            var id = $(this).attr("id");
            var editor = CKEDITOR.instances[id];
            if (editor) editor.destroy(true);
            CKEDITOR.replace(id,{
                toolbarGroups: [
                    { name: 'document',	   groups: [ 'mode', 'document' ] },			// Displays document group with its two subgroups.
                    { name: 'clipboard',   groups: [ 'clipboard', 'undo' ] },			// Group's name will be used to create voice label.
                    { name: 'basicstyles', groups: [ 'basicstyles', 'cleanup' ] },
                ],
                toolbar: [
                    { name: 'document', items: [ 'Source' ] },	// Defines toolbar group with name (used to create voice label) and items in 3 subgroups.
                    [ 'Cut', 'Copy', 'Paste', 'PasteText', 'PasteFromWord', '-', 'Undo', 'Redo' ],			// Defines toolbar group without name.
                    { name: 'basicstyles', items: [ 'Bold', 'Italic' ] }
                ]
            });
        });
        /*if ($("#feed_description").length){
         var editor = CKEDITOR.instances['feed_description'];
         if (editor) editor.destroy(true);
         CKEDITOR.replace('feed_description',{
         toolbarGroups: [
         { name: 'basicstyles', groups: [ 'basicstyles', 'cleanup' ] }
         ],
         toolbar: [
         { name: 'basicstyles', items: [ 'Bold', 'Italic' ] }
         ]
         });
         }*/
    }

//Вывод в панель информации содержимого блоков .set_info
    function initSetInfo(){
        $("#panel_info .content").html("");
        $(".set_info.clone").remove();
        if($(".set_info").length){
            $(".shell").addClass("ib");
            $(".set_info").each(function(){
                $(this).clone().removeClass("hide").addClass("clone").appendTo("#panel_info .content");
            });
            initWysiwyg();
        } else {
            $(".shell").removeClass("ib");
        };
        openAlerts();
    }

//Показать/изменить данные пользователя в кабинете
    function cabinet_profile(){
        $.ajax({
            url : "/udata/users/getProfile/?transform=modules/users/get_profile_ajax.xsl",
            type : "POST",
            dataType : 'html',
            success : function(data) {
                $("#cabinet_profile").html(data);

                getInterestsList();
                initColorBox();

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
                    $.ajax({
                        url : "/udata/users/removePhoto/",
                        type : "POST",
                        dataType : 'html',
                        success : function(data) {
                            setTimeout(function(){
                                $("#cabinet .profile .saving").addClass("hide");
                                cabinet_profile();
                            },1000);
                        }
                    });
                });
            }
        });
    }

    function initCropper(){
        $('.cropper').each(function(){
            var fragment = parseFloat($(this).attr("data-fragment"));
            fragment = (fragment == 0) ? NaN : fragment;

            var findImg = $(this).find('img');

            if (findImg.length){
                var image = new Image();
                image.src = findImg.attr("src");
                var widthImage;
                image.onload = function() {
                    widthImage = this.width;
                }

                findImg.cropper({
                    aspectRatio: fragment,
                    movable: false,
                    zoomable: false,
                    rotatable: false,
                    responsive: false,
                    scalable: false,
                    autoCropArea: 0.8,
                    /*minContainerWidth: 300,*/
                    minContainerHeight: 300,
                    minCropBoxWidth: 50,
                    minCropBoxHeight: 50,
                    crop: function(e) {
                        upload_image_crop = e;

                        if (isNaN(fragment)){
                            var aspect = e.width/e.height;
                            var widthWindow = $(".cropper-canvas").width();

                            if (aspect < 0.967){
                                $(this).cropper('setCropBoxData',{width:(e.width * widthWindow/widthImage + 1)});
                            }
                            if (aspect > 2.9){
                                $(this).cropper('setCropBoxData',{width:(e.width * widthWindow/widthImage - 1)});
                            }
                        }
                    }
                });
            }
        });
    }

//Подписаться/отписаться на ленту
    function feedSubscribe(elem){
        var parent = elem.parent();
        elem.html("<img src='/templates/iview/images/preloader.gif' />");
        $.ajax({
            url : "/udata/vote/subscribe/"+elem.attr("data-feed-id")+"/?transform=modules/feeds/feeds.xsl",
            type : "POST",
            dataType : 'html',
            success : function(data) {
                parent.html(data);
                parent.find("button:not(.disabled)").on("click", function(){
                    if (!$(this).hasClass("no-auth")){
                        feedSubscribe($(this));
                    }
                });
            }
        });
    }

//Если есть get параметр goto, переходит на позицию элемента с указанным идентификатором
    function goto(){
        var goto = $("#service-information").attr("data-goto");
        if (goto)
            if ($(".poll."+goto).length){
                var destination = $(".poll."+goto).offset().top;
                destination -= 50;
                if (destination > 0)
                    $('html,body').animate( { scrollTop: destination }, 600);
            }
        return false;
    }

//Автоматическое открытие alert'ов которые прописаны в cookies
    function openAlerts(){
        $("#panel_info .alert .slidedown_title[data-for-content]").each(function(){
            var id = $(this).attr("data-for-content");
            if ($.cookie('alert_slidedown_'+id) === null) $(this).click();
        });
    }

//Показ адаптивных изображений
    function adaptiveImage(){
        $(".adaptive_image").each(function(){
            var width = $(this).width();
            var data_width = parseInt($(this).attr('data-width'));
            if ((data_width > (width-300)) && (data_width < (width+300))){
                $(this).attr("src",$(this).attr("data-src"));
                $(this).removeClass('adaptive_image');
                $(this).removeAttr('data-src');
                $(this).removeAttr('data-width');
            } else $(this).remove();
        });
    }

    function init_dot(){
        $(".dot").dotdotdot();
    }

//Иконка воспроизведения видео (центрирование)
    function initPlayVideoIcon(){
        $(".poll .play_ico").each(function(){
            var P = $(this).closest("td");
            var hP = P.height();
            var wP = P.width();
            var hB = $(this).height();
            var wB = $(this).width();
            $(this).css("top", (hP/2 - hB/2)+'px');
            $(this).css("left",(wP/2 - wB/2)+'px');
            $(this).removeClass('hide');
        });
    }

//Удаление комментариев
    function comment_remove(id) {
        $.ajax({
            url : '/udata/content/comment_remove/'+id,
            type : 'POST',
            dataType : 'html',
            success : function(data) {
                location.reload();
            }
        });
    }

//Создание опроса по шаблону
    function poll_create_from_template(id){
        $.ajax({
            url : '/vote/editPoll/'+id+'/0/1/',
            type : 'POST',
            dataType : 'html',
            success : function(data) {
                refreshNewPoll(false, true);
                var destination = $(".new_poll_block").offset().top;
                destination -= 50;
                if (destination > 0)
                    $('html,body').animate( { scrollTop: destination }, 600);
            }
        });
    }

//Пошаговые подсказки
    function initIntroJs(){
        var steps = [];
        var ids = '';
        $(".tooltips").each(function(){
            steps.push({element:"[data-tooltips-id='"+$(this).attr("data-tooltips-id")+"']", intro:$(this).attr("data-tooltips-content"), position:$(this).attr("data-tooltips-pos")});
            ids += $(this).attr("data-tooltips-id")+",";
        });

        if(steps.length){
            var introguide = introJs();
            introguide.setOptions({
                steps: steps,
                showStepNumbers: false,
                exitOnEsc: true,
                nextLabel: "След.",
                prevLabel: "Пред.",
                skipLabel: "Пропустить",
                doneLabel: "OK",
                // showButtons: false,
                showBullets: false,
                scrollToElement: true
            });
            introguide.start();

            introguide.onexit(function() {
                initIntroJsComplete(ids);
            });
            introguide.oncomplete(function() {
                initIntroJsComplete(ids);
            });
        }
    }
    function initIntroJsComplete(ids){
        $.ajax({
            url : "/udata/content/tooltips/",
            type : "POST",
            data : {ids:ids},
            dataType : 'html',
            success : function(data) {

            }
        });
        $(".tooltips").each(function(){
            $(this).removeClass("tooltips");
            $(this).removeAttr("data-tooltips-id");
            $(this).removeAttr("data-tooltips-content");
            $(this).removeAttr("data-tooltips-pos");
        });
        $(".open_for_tooltip").removeClass("open_for_tooltip");
    }

    //Выбор ответа в опросе
    function pollSelectVariant(elem){
        var a=elem.find("input"); a.attr("sel","");
        var p=elem.closest(".poll");
        var max=p.attr("data-multiple");
        if (max==1){
            p.find("input[type='checkbox']").each(function(){
                var b=$(this);
                b.prop("disabled",false);
                b.prop("checked", (b.attr("sel")!=undefined) ? true : false);
            });
            a.removeAttr("sel");
        } else {
            var s=a.prop("checked");
            if (!a.prop("disabled")) a.prop("checked", s ? false : true);
            var m=(p.find("input[type='checkbox']:checked").length>=max) ? true : false;
            p.find("input[type='checkbox']").each(function(){
                var b=$(this)
                b.prop("disabled", (m && !b.prop("checked")) ? true : false);
            });
        }
        if(p.find("input[type='checkbox']:checked").length) p.find(".vote").prop("disabled",false);
        else p.find(".vote").prop("disabled",true);
    }

    return {
        getListComments, UploadImage
    };
})();


