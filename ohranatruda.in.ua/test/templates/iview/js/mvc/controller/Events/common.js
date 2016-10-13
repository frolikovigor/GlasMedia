import newPoll from './components/newPoll';
import newArticle from './components/newArticle';
import getPoll from './components/poll';
import getCabinet from './components/cabinet';
import getFeed from './components/feed';
import getComments from './components/comments';

export default class events{
    constructor(){
        this.NewPoll = newPoll();
        this.NewArticle = newArticle();
        this.Poll = getPoll();
        this.Cabinet = getCabinet();
        this.Feed = getFeed();
        this.Comments = getComments();
        this.common();
    };

    common(){

        if ($("#homepage").length){
            $(".popular_categories img").hover(function(){
                $(this).stop().animate({width:"160px", marginTop:"0px"},100);
            }, function(){
                $(this).stop().animate({width:"150px", marginTop:"5px"},100);
            });
        };

        //Вывод всех категорий
        $("#navigation").on("click", ".all_categories", function(){
            var open = $(this).attr("data-open");
            if (open=="0"){
                $("#navigation #all_catagories").slideDown("fast", function(){
                    $(".grid-item").fadeIn("fast");
                    GM.View.Masonry.init();
                });
                $(this).attr("data-open", "1");
                $("li.all_categories").addClass("active");
            } else {
                $("#navigation #all_catagories").slideUp("fast");
                $(this).attr("data-open", "0");
                $("li.all_categories").removeClass("active");
            }
        });

        //Проверка капчи
        $("#captcha_enter .apply").on("click", function(){
            var this_ = $(this);
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

        //Ajax пагинация
        $("body").on("click", ".paginated_ajax", function(){
            GM.View.Paginate($(this));
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

        $("body").on("click", "a[href='#']", function(e){
            e.preventDefault();
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

        //Если установлен get параметр preview, выполняется click по .popup_img с соответств. id
        $(".popup_img[data-id='"+$("#service-information").attr("data-preview")+"']").click();

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

    };

}

