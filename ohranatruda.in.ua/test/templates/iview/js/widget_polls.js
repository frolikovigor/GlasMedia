var sort_widget_preview = [1,2,3,4];
var cloneWidgetItem = [''];

function drawChart(type) {
    var answers = [['Task', 'Hours per Day']];
    $("input[name='widget_polls[answer][]'][type='text']").each(function(i){
        answers.push([$(this).val(), i]);
    });

    var data = google.visualization.arrayToDataTable(answers);
    var options = {
        pieSliceText: 'label',
        title: 'My Daily Activities',
        legend: 'none',
        slices: {   2: {offset: 0.2},
            4: {offset: 0.3},
            6: {offset: 0.4},
            8: {offset: 0.5}
        }
    };
    switch (type){
        case 'PieChart':
            var chart = new google.visualization.PieChart(document.getElementById('result'));
            break;
        case 'ColumnChart':
            var chart = new google.visualization.ColumnChart(document.getElementById('result'));
            break;
    }
    chart.draw(data, options);
}

jQuery(document).ready(function(){
    $("#widget_preview_template").find("li.item").each(function(){cloneWidgetItem.push($(this).clone());});
    if ($("#new_widget_polls").length > 0){
        //Загрузка
        $.getScript("/templates/iview/js/jquery.form.js",function(){
            $("#new_widget_polls").ajaxForm({
                beforeSend: function(){
                    $("#new_widget_polls .progress").removeClass("hide");
                    $("#new_widget_polls .progress .progress-bar").html("0%");
                    $("#new_widget_polls .progress .progress-bar").css("width","0%");
                    $("#new_widget_polls #select_file").prop("disabled", true);
                },
                uploadProgress: function(event, position, total, percentComplete){
                    $("#new_widget_polls .progress .progress-bar").html(percentComplete+"%");
                    $("#new_widget_polls .progress .progress-bar").css("width",percentComplete+"%");
                },
                success: function(){ 

                },
                complete: function(response){
                    $("#new_widget_polls #url_image").val(response.responseText);
                    refresh_preview();
                    $("#new_widget_polls .progress").addClass("hide");
                    $("#new_widget_polls #select_file").prop("disabled", false);
                },
                error: function(){

                }
            });
        });

        //Инициализация colorpicker
        $.getScript("/templates/iview/js/colorpicker.js",function(){
            $('.color_select').each(function(){
                var this_ = $(this);
                this_.ColorPicker({
                    onSubmit: function(hsb, hex, rgb, el) {
                        this_.attr("value", "#"+hex);
                        $(el).ColorPickerHide();
                        refresh_preview();
                        /*$(el).val(hex);*/
                    },
                    onBeforeShow: function () {
                        $(this).ColorPickerSetColor(this.value);
                    },
                    onChange: function (hsb, hex, rgb, el){
                        this_.val("#"+hex);
                        refresh_preview();
                    }
                }).bind('keyup', function(){
                    $(this).ColorPickerSetColor(this.value);
                                    });
            })
        });

        //Инициализация sortable
        $("#widget_preview").children("ul").sortable({
            items: "> li",
            containment: "#widget_preview",
            placeholder: "ui-state-highlight",
            distance: 15,
            out: function( event, ui ) {
                sort_widget_preview = [];
                $("#widget_preview li.item").each(function(){
                    sort_widget_preview.push($(this).attr("item"));
                });
            },
            sort: function( event, ui){
                var currentItem = ui.item;
                $("#widget_preview li.ui-state-highlight").css("height",currentItem.outerHeight());
            }
        });
        $("#widget_preview").children("ul").disableSelection();

        //Валидация при вводе
        $("#new_widget_polls").on("keypress", "input[type='number']", function (e) {
            if(e.which == 13) {
                $(this).closest(".toolbar").change();
                $(this).blur();
                return false;
            };
            if (e.which != 8 && e.which != 0 && (e.which < 48 || e.which > 57)) return false;
        });
        $("#new_widget_polls").on("change", "input[type='number']", function(){
            var min = $(this).attr("min");
            var max = $(this).attr("max");
            var val = parseInt($(this).val());
            if (min != undefined) if (parseInt(val) < parseInt(min)) $(this).val(min);
            if (max != undefined) if (parseInt(val) > parseInt(max)) $(this).val(max);
        });

        //Добавление / удаление вариантов ответов
        $("#new_widget_polls .add_del .add").on("click", function(e){
            e.preventDefault();
            if ($("#new_widget_polls .variant").find("input[type='text']:last").val()){
                var item = $("#new_widget_polls .variant").find("input[type='text']:first").clone();
                item.val("");
                $("#new_widget_polls .variant").append(item);
                refresh_preview();
            }
        });
        $("#new_widget_polls .add_del .del").on("click", function(e){
            e.preventDefault();
            if ($("#new_widget_polls .variant").find("input[type='text']").length > 2)
                $("#new_widget_polls .variant").find("input[type='text']:last").remove();
            refresh_preview();
        });

        //Переход по меню
        $(".nav-new_widget_polls").on("click", "a[alt_name]", function(e){
            e.preventDefault();
            var altName = $(this).attr("alt_name");
            changeItemMenu(altName);
        });
        $("#new_widget_polls .next").on("click", function(){
            var altName = $(this).attr("alt_name");
            changeItemMenu(altName);
        });
        $("#new_widget_polls .prev").on("click", function(){
            var altName = $(this).attr("alt_name");
            changeItemMenu(altName);
        });

        $("div[alt_name='settings_item'] ul.nav li a").on("click", function(e){
            e.preventDefault();
            var item = $(this).closest("li").attr("item");
            $("div[alt_name='settings_item'] ul.nav li").removeClass("active");
            $(this).closest("li").addClass("active");
            $("div[alt_name='settings_item'] .container div[item]").addClass("hide");
            $("div[alt_name='settings_item'] .container div[item='"+item+"']").removeClass("hide");
        });

        $("#new_widget_polls").on("change", "input, select:not(#type_diagram)", function(){
            refresh_preview();
        });

        $("#new_widget_polls").on("change", "#type_diagram", function(){
            var type = $(this).val();
            drawChart(type);
        });

        changeItemMenu('info');
        refresh_preview();

    }

});

function changeItemMenu(altName){
    if ($("body").scrollTop()>140){
        $("body").animate({
            scrollTop:140
        }, ($("body").scrollTop() - 140) < 100 ? 400 : 800, function(){changeItemMenuDo(altName)});
    } else changeItemMenuDo(altName);
    return false;
}

function changeItemMenuDo(altName){
    var stat = false;
    var setAltName = false;
    var exist = false;
    $("#new_widget_polls div[alt_name]").each(function(){
        var currentAltName = $(this).attr("alt_name");
        if (currentAltName == altName) exist = true;
        $(this).find("input.required").each(function(){
            if (!valid($(this))){
                if (!exist) $(this).addClass("error"); else $(this).removeClass("error");
                if (!setAltName) setAltName = $(this).closest("div[alt_name]").attr("alt_name");
            } else $(this).removeClass("error");
        });
        li = $(".nav-new_widget_polls").find("a[alt_name='"+currentAltName+"']").closest("li");
        if (!setAltName) li.removeClass("disabled");
        else li.addClass("disabled");
        if (!setAltName && !stat && (currentAltName==altName)) stat = true;
    });
    if (setAltName) $(".nav-new_widget_polls").find("a[alt_name='"+setAltName+"']").closest("li").removeClass("disabled");
    if (stat) setAltName = altName;
    $(".nav-new_widget_polls").find("li").removeClass("active");
    $(".nav-new_widget_polls a[alt_name='"+setAltName+"']").closest("li").addClass("active");
    $("#new_widget_polls div[alt_name]").addClass('hide');
    $("#new_widget_polls div[alt_name='"+setAltName+"']").removeClass('hide');
    $("#head_widget_polls div[alt_name]").addClass('hide');
    $("#head_widget_polls div[alt_name='"+setAltName+"']").removeClass('hide');
    if (setAltName=='position') {
        $("#widget_preview_template").addClass("sortable");
        $("#widget_preview").addClass("sortable");
        $("#widget_preview").children("ul").sortable({disabled: false});
        $("#widget_preview ul[item='0']").css("min-height",$("#widget_preview ul[item='0']").outerHeight());
    } else {
        $("#widget_preview_template").removeClass("sortable");
        $("#widget_preview").removeClass("sortable");
        $("#widget_preview").children("ul").sortable({disabled: true});
        $("#widget_preview ul[item='0']").css("min-height","");
    }
    if (setAltName == 'result'){
        var width_preview = $("#widget_preview ul").width();
        $("#widget_preview").children("ul").html("<li id='result' style='width: "+width_preview+"px; height:"+parseInt(width_preview)*1.2+"px;'></li>");
        drawChart($("#new_widget_polls #type_diagram").val());
    } else
    if (setAltName == 'get_code') {
        $("div[alt_name='get_code']").find('textarea').val($("#widget_preview").html());
    }
    else refresh_preview();
    return false;
}

function valid(elem){
    var value = elem.val();
    if (!value) return false;
    if (elem.hasClass('url')){
        return value.match(/^(ht|f)tps?:\/\/[a-z0-9-\.]+\.[a-z]{2,4}\/?([^\s<>\#%"\,\{\}\\|\\\^\[\]`]+)?$/);
    }
    return true;
}

function is_valid_url(url){
    return url.match(/^(ht|f)tps?:\/\/[a-z0-9-\.]+\.[a-z]{2,4}\/?([^\s<>\#%"\,\{\}\\|\\\^\[\]`]+)?$/);
}

function refresh_preview(){
    var set_style = [];
    var values = [];
    $("#new_widget_polls").find("input, select").each(function(){
        if ($(this).attr("set_style")!=undefined){
            if (!set_style[$(this).attr("item")]) set_style[$(this).attr("item")] = '';
            var index = $(this).attr("item");
            var setStyle = $(this).attr("set_style");
            var checkbox = $("#new_widget_polls").find("input[type='checkbox'][for_item='"+index+"'][for_set_style='"+setStyle+"']");
            if (checkbox.length) if (!checkbox.prop("checked")) return;
            var radiobutton = $("#new_widget_polls").find("input[type='radio'][for_item='"+index+"'][for_set_style='"+setStyle+"']");
            if (radiobutton.length) if (!radiobutton.prop("checked")) return;

            if ($(this).val() || ($(this).attr('value')!=undefined)){
                set_style[index] = set_style[index] + setStyle + $(this).val();
                if ($(this).attr("suffix") != undefined) set_style[index] += $(this).attr("suffix");
            }
        }
        if ($(this).attr("name")!=undefined){
            if (!values[$(this).attr("name")]) values[$(this).attr("name")] = [];
            var index = $(this).attr("name");
            values[index].push($(this).val());
        }
        if ($(this).attr("set_visible_item")!=undefined)
            if (!$(this).prop('checked')){
                var item = $(this).attr("set_visible_item");
                set_style[item] = "display:none;"
            }
    });

    $("#widget_preview").children("ul").html("");

    for(i in sort_widget_preview) $("#widget_preview").children('ul').append(cloneWidgetItem[sort_widget_preview[i]].clone());
    for(i in set_style) $("#widget_preview").find("[item='"+i+"']").attr("style",set_style[i]);
    for(i in values) {
        for(y in values[i]) $("#widget_preview li[name='"+i+"']:eq("+y+")").find("span").html(values[i][y]);
        var num = $("#widget_preview li[name='"+i+"']").length;
        for(var del=(parseInt(num)-1); del>parseInt(y); del--) $("#widget_preview li[name='"+i+"']:eq("+del+")").remove();
    }
}