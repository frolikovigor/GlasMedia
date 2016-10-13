export default function comments(){

    return {
        Init: (function(){

        })(),

        //Удаление комментариев
        CommentRemove: function(id) {
            $.ajax({
                url : '/udata/content/comment_remove/'+id,
                type : 'POST',
                dataType : 'html',
                success : function(data) {
                    location.reload();
                }
            });
        }
    };
}
