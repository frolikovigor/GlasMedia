export default function gridster(){

    var viewImageTimer = undefined;
    var newPoll_gridsterTimer = undefined;
    var newPoll_gridster_li_move = false;
    var newPoll_gridster;
    var newPoll_gridster_move_time = false;
    var newPoll_gridster_move_time_start = false;

    return {
        refreshGridster: function () {
            var this__ = this;

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
                        this__.reViewImages().then(
                            GM.View.NewPoll.refreshNewPoll(true, false),
                            function(){}
                        );
                    }
                },
                draggable:{
                    stop: function(event, ui){
                        this__.reViewImages().then(
                            GM.View.NewPoll.refreshNewPoll(true, false),
                            function(){}
                        );
                    }
                },
                max_size_x: max_size_item[0],
                max_size_y: max_size_item[0],
                max_cols: max_size_item[0]
            }).data('gridster');

            this.reViewImages().then(
                GM.View.NewPoll.refreshNewPoll(true, false),
                function(){}
            );

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
                    this__.reViewImages().then(
                        GM.View.NewPoll.refreshNewPoll(true, false),
                        function(){}
                    );
                }
            });

            $(".new_poll_block .gridster ul li .move").mousedown(function(event){
                if (event.preventDefault)
                    event.preventDefault();
                else
                    event.returnValue= false;

                if(event.button == 0){
                    var this_ = $(this);
                    this__.gridster_move(this_);
                    newPoll_gridster_move_time_start = setTimeout(function(){
                        newPoll_gridster_move_time = setInterval(function(){
                            this__.gridster_move(this_);
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
                e.preventDefault();
                e.stopPropagation();

                this__.reViewImages().then(
                    GM.View.NewPoll.refreshNewPoll(true, false),
                    function(){}
                );
            });
        },


        //Обновисть изображения для gridster
        reViewImages: function(func){
            const this__ = this;
            return new Promise(function(resolve, reject) {
                var stat = true;
                if (viewImageTimer) clearInterval(viewImageTimer);
                $(".new_poll_block .gridster ul li img").each(function(){
                    if (!$(this).height()) stat = false;
                });
                if (!stat){
                    viewImageTimer = setTimeout(function(){
                        this__.reViewImages().then(
                            GM.View.NewPoll.refreshNewPoll(true, false),
                            function(){}
                        );
                    },300);
                    return;
                };

                clearInterval(viewImageTimer);

                $(".new_poll_block .images").css("height", "auto");   //При перезагрузке страницы refreshNewPoll, устанавливается высота, чтобы не было скачков. Здесь сбрасывается.
                $(".new_poll_block .gridster ul li").each(function(){
                    this__.reViewImage($(this));
                });

                if (newPoll_gridsterTimer !== false) {
                    clearTimeout(newPoll_gridsterTimer);
                    newPoll_gridsterTimer = false;
                };

                newPoll_gridsterTimer = setTimeout(function(){
                    var total_height = 0;
                    $(".new_poll_block .gridster ul li").each(function(){
                        var li = $(this);
                        var getSizeY = parseInt(li.attr('data-row')) + parseInt(li.attr('data-sizey')) - 1;
                        if (getSizeY > total_height) total_height = getSizeY;
                    });
                    if (total_height > 6) $(".new_poll_block .images").addClass("error"); else $(".new_poll_block .images").removeClass("error");
                    resolve();

                }, 1000);
                reject();
            });
        },

        //Перерисовать изображение для gridster
        reViewImage: function (elem){
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

            var object = GM.Model.Gridster.ScaleSelection(img_width, img_height, li_width, li_height, width, top, left)

            let{top:setTop, left:setLeft, width:setWidth} = object;

            elem.find("img").css("margin-top",setTop+"px");
            elem.attr("data-top",setTop);
            elem.find("img").css("margin-left",setLeft+"px");
            elem.attr("data-left",setLeft);
            elem.find("img").css("width", setWidth + "%");
            elem.attr("data-width",setWidth);
            elem.find("input[data-name='top']").val(setTop);
            elem.find("input[data-name='left']").val(setLeft);
            elem.find("input[data-name='width']").val(setWidth);
            elem.find("input[data-name='row']").val(row);
            elem.find("input[data-name='col']").val(col);
            elem.find("input[data-name='sizex']").val(sizex);
            elem.find("input[data-name='sizey']").val(sizey);
        },

        gridster_move: function(elem){
            var li = elem.closest("li");
            var top = parseInt((li.attr("data-top") != undefined) ? li.attr("data-top") : 0);
            var left = parseInt((li.attr("data-left") != undefined) ? li.attr("data-left") : 0);
            if (elem.hasClass("to_left")) left -= 10;
            if (elem.hasClass("to_top")) top -= 10;
            if (elem.hasClass("to_right")) left += 10;
            if (elem.hasClass("to_down")) top += 10;
            li.attr("data-top", top);
            li.attr("data-left", left);
            this__.reViewImages().then(
                GM.View.NewPoll.refreshNewPoll(true, false),
                function(){}
            );
        }
    };
};
