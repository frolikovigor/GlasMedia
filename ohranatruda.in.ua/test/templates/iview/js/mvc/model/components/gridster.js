export default function gridster(){
    return {
        //Подбор масштаба изображения вписанного в прямоугольник
        ScaleSelection: function(imgWidth, imgHeight, rWidth, rHeight, widthImgPers, imgTop, imgLeft){
            imgWidth = Number(imgWidth);
            imgHeight = Number(imgHeight);
            rWidth = Number(rWidth);
            rHeight = Number(rHeight);
            widthImgPers = Number(widthImgPers);
            imgTop = Number(imgTop);
            imgLeft = Number(imgLeft);


            if (imgWidth && imgHeight && rWidth && rHeight){
                var img_koef = imgWidth / imgHeight;
                var li_koef = rWidth / rHeight;
                if (img_koef > li_koef) {
                    var s_width = 100 * img_koef / li_koef;
                    if (widthImgPers < s_width) {
                        widthImgPers = Math.round(s_width);
                    }
                } else {
                    if (widthImgPers < 100) {
                        widthImgPers = 100;
                    }
                }
            }

            imgHeight = !imgHeight ? 1 : imgHeight;
            var koef_img = imgWidth / imgHeight;

            rHeight = !rHeight ? 1 : rHeight;

            var koef_li = rWidth / rHeight;
            var min_width = (koef_img <= koef_li) ? 100 : 100 * koef_img/ koef_li;

            widthImgPers = Math.round((widthImgPers < min_width) ? min_width : widthImgPers);
            widthImgPers = (koef_img <= koef_li) ? (widthImgPers > 250 ? 250 : widthImgPers) : (widthImgPers / (koef_img/koef_li) > 250 ? 250*koef_img/koef_li : widthImgPers);
            imgTop = (imgTop > 0) ? 0 : imgTop;
            imgLeft = (imgLeft > 0) ? 0 : imgLeft;
            var maxDeltaT = ((widthImgPers / 100) * rWidth) / koef_img - rHeight;
            imgTop = (imgTop < -maxDeltaT) ? -maxDeltaT : imgTop;
            var maxDeltaL = (widthImgPers / 100) * rWidth - rWidth;
            imgLeft = (imgLeft < -maxDeltaL) ? -maxDeltaL : imgLeft;

            return {
                top: Math.round(imgTop),
                left: Math.round(imgLeft),
                width: Math.round(widthImgPers)
            }
        }
    };
};