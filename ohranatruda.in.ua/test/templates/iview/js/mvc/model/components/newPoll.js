export default function newPoll(){

    return {
        PTime: undefined,
        LastClick: false,

        GetNewPollForm: function(modify, fast, uri){
            return new Promise(function(resolve, reject){
                $.ajax({
                    url : "/udata/vote/getNewPollForm/"+modify+"/"+fast+"?transform=/modules/vote/new_poll_ajax.xsl",
                    type : "POST",
                    dataType : 'html',
                    data : uri,
                    success : function(data) {
                        resolve(data);
                    }
                });
            });
            
        }
    };
}
