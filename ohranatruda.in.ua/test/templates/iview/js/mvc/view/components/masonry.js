export default function masonry(){
    var initMasonryInstance = false;

    return {
        init: function(){
            if (initMasonryInstance)
                $(".masonry").masonry('destroy');

            var scrollTop = $("body").scrollTop();

            $(".masonry").each(function(){
                var getClass = $(this).attr("data-class-masonry");
                var getGutter = parseInt($(this).attr("data-masonry-gutter"));
                $(this).masonry({
                    itemSelector: '.'+getClass,
                    gutter: getGutter
                });
            });
            initMasonryInstance = true;
            $("body").scrollTop(scrollTop);
        }
    };
};
