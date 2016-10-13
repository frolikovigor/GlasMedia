export default function getIntroJs(){

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

    return {
        init: function(){
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
            };
        }
    };
}
