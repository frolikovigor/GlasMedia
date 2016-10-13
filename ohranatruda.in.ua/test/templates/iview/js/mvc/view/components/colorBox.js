export default function colorBox(){

    return {
        init: function(){
            $('a.popup_img:not(.video)').colorbox({
                current : "{current} из {total}"
            });
            $('a.popup_img.video').colorbox({iframe:true, innerWidth:640, innerHeight:390});
        }
    };
}
