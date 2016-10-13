export default function masonry(){
   

    return {
        Settings: function () {
            if ($("#feeds_setting_form").length){
                GM.View.InitWysiwyg();

                var feedId = $("#feeds_setting_form").attr("data-feed-id");
                setTimeout(function(){
                    $("#feeds_setting_form").cc_validate({
                        settings: {required_class:'required', error_class:'error'},
                        rules : [
                            {element:"input[name='name']", rule:'min_length', min_length:5},
                            {element:"input[name='url']", rule:'check', url:'/vote/checkUrlLent/'+feedId+'/?url=',need:'true'}
                        ],
                        warning: function(elem, rule, result){
                            switch (result){
                                case 'error':
                                    elem.closest('div').find('span[data-warning='+rule+']').html("Недопустимый формат");
                                    break;
                                case 'exist':
                                    elem.closest('div').find('span[data-warning='+rule+']').html("Адрес уже занят");
                                    break;
                                case 'url_short':
                                    elem.closest('div').find('span[data-warning='+rule+']').html("Слишком короткий адрес");
                                    break;
                            }
                            elem.closest('div').find('span[data-warning='+rule+']').removeClass('hide');
                            setTimeout(function(){
                                $("#feeds_setting_form button[type='submit']").removeClass("wait");
                            },300);
                        },
                        hide_warning: function(elem, rule, result){
                            elem.closest('div').find('span[data-warning='+rule+']').addClass('hide');
                        },
                        success: function(form){
                            var feed_description = CKEDITOR.instances.feed_description.getData();
                            $("#feed_description_hidden").val(feed_description);
                            form.submit();
                        }
                    });
                },500);
            }
        },

        //Подписаться/отписаться на ленту
        FeedSubscribe: function(elem){
            var parent = elem.parent();
            elem.html("<img src='/templates/iview/images/preloader.gif' />");
            $.ajax({
                url : "/udata/vote/subscribe/"+elem.attr("data-feed-id")+"/?transform=modules/feeds/feeds.xsl",
                type : "POST",
                dataType : 'html',
                success : function(data) {
                    parent.html(data);
                    parent.find("button:not(.disabled)").on("click", function(){
                        if (!$(this).hasClass("no-auth")){
                            GM.View.Feed.FeedSubscribe($(this));
                        }
                    });
                }
            });
        }
    };
};
