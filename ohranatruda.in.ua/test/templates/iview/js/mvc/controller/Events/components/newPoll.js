export default function newPoll(){
    
    return {
        Init: (function(){
            if ($(".new_poll_block").length) {
                $("body").on("change", ".new_poll_block #new_poll_form select, .new_poll_block #new_poll_form input:not(.poll .variants input), .new_poll_block #new_poll_form textarea", function () {
                    if ($(this).attr('name') == 'data[country]') {
                        $("select[name='data[region]").val('');
                        $("select[name='data[city]").val('');
                    }
                    if ($(this).attr('name') == 'data[region]') {
                        $("select[name='data[city]").val('');
                    }
                    GM.View.NewPoll.refreshNewPoll(true, ($(this).attr("reload_form") != undefined) ? true : false);
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

                    if (GM.Model.NewPoll.PTime === false){
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
                                    GM.View.NewPoll.refreshNewPoll(false, true);
                                    return false;
                                } else {
                                    if (data.url != undefined){
                                        location.href = data.url;
                                    } else location.href = "/cabinet/";
                                }
                            }
                        });
                    } else
                        GM.Model.NewPoll.LastClick = ".save_poll";
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
            };
        })(),

        PollCreateFromTemplate: function(id){
            $.ajax({
                url : '/vote/editPoll/'+id+'/0/1/',
                type : 'POST',
                dataType : 'html',
                success : function(data) {
                    GM.View.NewPoll.refreshNewPoll(false, true);
                    var destination = $(".new_poll_block").offset().top;
                    destination -= 50;
                    if (destination > 0)
                        $('html,body').animate( { scrollTop: destination }, 600);
                }
            });
        }
    };
}
