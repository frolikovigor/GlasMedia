export default function newPoll(){
    var XHR = false;
    
    return {
        refreshNewPoll: function(change, reload_form){
            if ($(".new_poll_block").length){
                var modify = change ? "1" : "0";
                if (reload_form) $("#disabled_screen").removeClass("hide");
                if (GM.Model.NewPoll.PTime) clearTimeout(GM.Model.NewPoll.PTime);
                GM.Model.NewPoll.PTime = setTimeout(function(){
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

                if (XHR !== false) {
                    clearTimeout(XHR);
                };

                XHR = setTimeout(function(){
                    GM.Model.NewPoll.GetNewPollForm(
                        modify,
                        fast,
                        $(".new_poll_block #new_poll_form").serialize()+"&data_for="+data_for+"&data_id="+data_id+"&url="+encodeURIComponent(location.href)
                    ).then((data)=>{
                        XHR = false;
                        if (reload_form) {
                            var heightImages = $(".new_poll_block .images").outerHeight();
                            $(".new_poll_block").html(data);
                            $(".new_poll_block .images").css("height", heightImages+"px");

                            $(".new_poll_block .chanels").scrollTop(scrollTextarea);

                            if (GM.Model.Images.upload_image_currXhr != undefined) GM.Model.Images.upload_image_currXhr.abort();

                            GM.View.Gridster.refreshGridster();

                            setTimeout(function(){
                                GM.View.Masonry.init();
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

                                GM.View.IntroJs.init();
                            },500);

                            GM.View.CutContent();
                            GM.View.ColorBox.init();
                            GM.View.InitSetInfo();
                            GM.View.InitTooltips();
                        };

                        $("#disabled_screen").addClass("hide");
                        clearTimeout(GM.Model.NewPoll.PTime);
                        GM.Model.NewPoll.PTime = false;
                        if (GM.Model.NewPoll.LastClick !== false) {
                            $(GM.Model.NewPoll.LastClick).prop("disabled",false);
                            $(GM.Model.NewPoll.LastClick).click();
                            GM.Model.NewPoll.LastClick = false;
                        }
                    });
                }, 500);
            };
        }
    };
}
