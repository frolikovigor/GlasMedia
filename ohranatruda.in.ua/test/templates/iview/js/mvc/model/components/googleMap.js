export default function googleMap(){
    var Enabled = false;
    var Initiate = false;

    return {
        Init: () => {
            return new Promise(function(resolve, reject){
                if (Enabled && Initiate){
                    return resolve();
                } else {
                    if (!Initiate){
                        Initiate = true;
                        google.load("visualization", "1", {packages:["geochart"], "callback" : function(){
                            Enabled = true;
                            return resolve();
                        }});
                    }
                };
            });
        },

        GetPollMap(pollId, param0, param1){
            return new Promise(function(resolve, reject){
                $.ajax({
                    url : "/udata/vote/getPollMap/"+pollId+"/"+param1+"/.json",
                    type : "POST",
                    data : param0,
                    dataType : 'json',
                    success : function(getData) {
                        resolve(getData);
                    }
                });
            });
        }
    };
};
