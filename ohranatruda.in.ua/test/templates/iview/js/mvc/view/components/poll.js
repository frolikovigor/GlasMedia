export default function poll(){
    return {
        //Выбор ответа в опросе
        PollSelectVariant: function(elem){
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
        },

        Vote: function(this_){
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
                    GM.View.CutContent();
                    poll.find("#"+clone_id).remove();
                    GM.View.Masonry.init();
                    GM.View.ColorBox.init();
                    GM.View.GoogleMap.DrawGoogleMaps();
                }
            });
        }

    };
};
