export default function cabinet(){

    return {
        GetInterestsOfUser: function(){
            return new Promise(function (resolve, reject) {
                $.ajax({
                    url : "/udata/users/getInterestsOfUser/?transform=modules/users/get_profile_ajax.xsl",
                    type : "POST",
                    dataType : 'html',
                    success : function(data) {
                        resolve(data);
                    }
                });
            });
        },

        RemoveInterestsOfUser: function(id){
            return new Promise(function (resolve, reject) {
                $.ajax({
                    url : "/udata/users/removeInterestsOfUser/",
                    type : "POST",
                    dataType : 'html',
                    data: {id:id},
                    success : function(data) {
                        resolve(data);
                    }
                });
            });
        },

        AddInterestsOfUser: function(id){
            return new Promise(function (resolve, reject) {
                $.ajax({
                    url : "/udata/users/addInterestsOfUser/",
                    type : "POST",
                    dataType : 'html',
                    data: {id:id},
                    success : function(data) {
                        resolve(data);
                    }
                });
            });
        },

        GetProfile: function(){
            return new Promise(function (resolve, reject) {
                $.ajax({
                    url : "/udata/users/getProfile/?transform=modules/users/get_profile_ajax.xsl",
                    type : "POST",
                    dataType : 'html',
                    success : function(data) {
                        resolve(data);
                    }
                });
            });
        },

        RemovePhoto: function(){
            return new Promise(function (resolve, reject) {
                $.ajax({
                    url : "/udata/users/removePhoto/",
                    type : "POST",
                    dataType : 'html',
                    success : function(data) {
                        resolve(data);
                    }
                });
            });
        }
        
    };
};
