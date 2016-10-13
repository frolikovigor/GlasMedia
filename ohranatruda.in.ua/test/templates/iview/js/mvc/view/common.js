import getGridster from './components/gridster';
import newPoll from './components/newPoll';
import newArticle from './components/newArticle';
import getMasonry from './components/masonry';
import getIntroJs from './components/introJs';
import getColorBox from './components/colorBox';
import getCabinet from './components/cabinet';
import getGoogleMap from './components/googleMap';
import getComments from './components/comments';
import getFeedback from './components/feedback';
import getPoll from './components/poll';
import getFeed from './components/feed';
import getImages from './components/image';

export default class view{
    constructor(){
        this.Gridster = getGridster();
        this.NewPoll = newPoll();
        this.NewArticle = newArticle();
        this.Masonry = getMasonry();
        this.IntroJs = getIntroJs(); //Пошаговые подсказки
        this.ColorBox = getColorBox();
        this.Cabinet = getCabinet();
        this.GoogleMap = getGoogleMap();
        this.Comments = getComments();
        this.Feedback = getFeedback();
        this.Poll = getPoll();
        this.Feed = getFeed();
        this.Images = getImages();
    };

    CutContent(){
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
            setTimeout(function(){GM.View.Masonry.init();},500);
            return false;
        });
    };

    //Вывод в панель информации содержимого блоков .set_info
    InitSetInfo(){
        $("#panel_info .content").html("");
        $(".set_info.clone").remove();
        if($(".set_info").length){
            $(".shell").addClass("ib");
            $(".set_info").each(function(){
                $(this).clone().removeClass("hide").addClass("clone").appendTo("#panel_info .content");
            });
            this.InitWysiwyg();
        } else {
            $(".shell").removeClass("ib");
        };
        this.OpenAlerts();
    };

    InitWysiwyg(){
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
    };

    //Автоматическое открытие alert'ов которые прописаны в cookies
    OpenAlerts(){
        //Для открывающихся текстов
        $("body").on("click", ".slidedown_title", function(){
            var id = $(this).attr("data-for-content");
            $(this).toggleClass("dropup");
            $(".slidedown_content[data-id='"+id+"']").toggleClass("hide");
            if($(this).hasClass("dropup")) $.cookie('alert_slidedown_'+id, null,{ path:'/' }); else $.cookie('alert_slidedown_'+id, 1,{ path:'/' });
        });

        $("#panel_info .alert .slidedown_title[data-for-content]").each(function(){
            var id = $(this).attr("data-for-content");
            if ($.cookie('alert_slidedown_'+id) === null) $(this).click();
        });
    };

    InitTooltips(){
        $(function () {
            $('[data-toggle="tooltip"]').tooltip()
        })
    };

    //Создает элементы option
    InitCounter(){
        $("body").find("option[data-counter_from]").each(function(){
            var from = parseInt($(this).attr("data-counter_from"));
            var to = parseInt($(this).attr("data-counter_to"));
            var this_ = $(this);
            var selected = (this_.closest("select").attr("data-select") != undefined) ? parseInt(this_.closest("select").attr("data-select")) : false;
            this_.removeAttr("data-counter_from");
            this_.removeAttr("data-counter_to");
            this_.attr("value", from);
            this_.text(from);
            for(var index = from+1; index<=to; index++){
                var clone = this_.clone();
                clone.attr("value", index);
                clone.text(index);
                if (selected !== false) if (index == selected) clone.attr("selected","selected");
                this_.closest("select").append(clone);
            }
            $(this).closest('select').find("[data-remove='1']").remove();
        });
    };

    //Инициализация капчи
    InitCaptcha(){
        $("[data-captcha = '1']").each(function(){
            $(this).click(function(){
                $("#captcha_enter").modal();
                $('#captcha_enter').on('shown.bs.modal', function (e) {
                    $("#captcha").focus();
                })
            });
        });
    };

    //Показ адаптивных изображений
    AdaptiveImage(){
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
    };

    //Если есть get параметр goto, переходит на позицию элемента с указанным идентификатором
    Goto(){
        var goto = $("#service-information").attr("data-goto");
        if (goto)
            if ($(".poll."+goto).length){
                var destination = $(".poll."+goto).offset().top;
                destination -= 50;
                if (destination > 0)
                    $('html,body').animate( { scrollTop: destination }, 600);
            }
        return false;
    };

    //Пагинация
    Paginate(this_){
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
                    GM.View.CutContent();
                    GM.View.Comments.Init();
                    GM.View.Masonry.init();
                    GM.View.InitCaptcha();
                    if ($("[data-block='"+block+"'] .last_page").length){
                        this_.remove();
                        $("[data-block='"+block+"'] .last_page").remove();
                    } else
                        this_.removeClass('wait');

                    $(selector).animate({opacity:1.0},300, function(){

                    });
                })
            }
        });
    };
    
};
