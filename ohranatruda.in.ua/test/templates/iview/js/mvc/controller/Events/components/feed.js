export default function feed(){

    return (function(){
        $(".feed .feed-info .subsribe button:not(.disabled)").on("click", function(){
            if (!$(this).hasClass("no-auth")){
                GM.View.Feed.FeedSubscribe($(this));
            }
        });
    })();
}
