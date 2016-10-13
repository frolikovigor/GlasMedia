export default function image(){
    var upload_image_crop = false;
    var fragment;
    
    return {
        UploadImage: function(do_, elem){
            var this_ = this;
            upload_image_crop = false;
            $("#upload_image form input[type='file']").unbind();
            $("#upload_image .form-group>input[type='text']").unbind();
            $("#upload_image .apply").unbind();
            $("#upload_image .close_abort").unbind();
            $("#upload_image form").ajaxFormUnbind();
            $("#upload_image .apply").prop("disabled", true);
            $("#upload_image input").val("");
            $("#upload_image input[type='text']").attr("old_value","");
            $("#upload_image .cropper>img").cropper("destroy");
            $('#upload_image .cropper').html('');

            fragment = elem.attr("data-fragment");
            var data_url = elem.attr("data-url");
            var data_parameters = elem.attr("data-parameters");
            $("#upload_image").attr("data-fragment", fragment);
            $("#upload_image .cropper").attr("data-fragment", fragment);
            $("#upload_image form").attr("action", data_url);
            $("#upload_image input[name='parameters']").val(data_parameters);

            $("#upload_image").modal();

            $("#upload_image form input[type='file']").unbind();
            $("#upload_image form input[type='file']").on("change", function(){
                $("#upload_image form").submit();
            });

            $("#upload_image .form-group>input[type='text']").unbind();
            $("#upload_image .form-group>input[type='text']").on("keyup", function(){
                var stat = false;
                if ($(this).attr("old_value") != undefined){
                    if ($(this).attr("old_value") != $(this).val()) stat = true;
                } else stat = true;

                if (stat){
                    $("#upload_image .preloader").removeClass("hide");
                    $(this).attr("old_value", $(this).val());
                    $("#upload_image .apply").prop("disabled", true);
                    $.ajax({
                        url : "/udata/content/checkImageUrl/.json",
                        type : "POST",
                        dataType : 'json',
                        data : {url:$(this).val()},
                        success : function(data) {
                            if (data.result != "0") $("#upload_image .apply").prop("disabled", false);
                            else $("#upload_image .apply").prop("disabled", true);
                            $("#upload_image .preloader").addClass("hide");
                        }
                    });
                }
            });

            $("#upload_image .apply").unbind();
            $("#upload_image .apply").click(function(){
                var crop = "";
                if (upload_image_crop != false){
                    var cropX = upload_image_crop.x;
                    var cropY = upload_image_crop.y;
                    var cropWidth = upload_image_crop.width;
                    var cropHeight = upload_image_crop.height;
                    crop = cropX + "_" + cropY + "_" + cropWidth + "_" + cropHeight;
                    $("#upload_image input[name='crop']").val(crop);
                }
                var parameters = $("#upload_image input[name='parameters']").val();

                $("#upload_image .preloader").removeClass("hide");
                $("#upload_image input[type='text'],#upload_image button.apply").prop("disabled",true);
                $.ajax({
                    url : $("#upload_image form").attr("action") + "1",
                    type : "POST",
                    dataType : 'html',
                    data : {url:$("#upload_image .form-group>input[type='text']").val(), crop:crop, parameters:parameters},
                    success : function(data) {
                        if ((fragment != '') && (upload_image_crop === false)) this_.UploadImageFragment(do_);
                        else this_.UploadImageComplete(do_);
                    }
                });
            });
            $("#upload_image .close_abort").unbind();
            $("#upload_image .close_abort").on("click", function(){
                if (GM.Model.Images.upload_image_currXhr) GM.Model.Images.upload_image_currXhr.abort();
            });

            $("#upload_image form").ajaxForm({
                beforeSend: function(xhr){
                    GM.Model.Images.upload_image_currXhr = xhr;
                    $("#upload_image .preloader").removeClass("hide");
                    $("#upload_image input[type='text'],#upload_image button.apply").prop("disabled",true);
                },
                uploadProgress: function(event, position, total, percentComplete){
                    $("#upload_image .progress_bar").removeClass("hide");
                    $("#upload_image .progress_bar").html(percentComplete+"%");
                },
                success: function(){
                    $("#upload_image .progress_bar").addClass("hide");
                },
                complete: function(response){
                    if (fragment != '') this_.UploadImageFragment(do_);
                    else this_.UploadImageComplete(do_);
                },
                error: function(){

                }
            });
        },

        InitCropper: function(){
            $('.cropper').each(function(){
                var fragment = parseFloat($(this).attr("data-fragment"));
                fragment = (fragment == 0) ? NaN : fragment;

                var findImg = $(this).find('img');

                if (findImg.length){
                    var image = new Image();
                    image.src = findImg.attr("src");
                    var widthImage;
                    image.onload = function() {
                        widthImage = this.width;
                    };

                    findImg.cropper({
                        aspectRatio: fragment,
                        movable: false,
                        zoomable: false,
                        rotatable: false,
                        responsive: false,
                        scalable: false,
                        autoCropArea: 0.8,
                        /*minContainerWidth: 300,*/
                        minContainerHeight: 300,
                        minCropBoxWidth: 50,
                        minCropBoxHeight: 50,
                        crop: function(e) {
                            upload_image_crop = e;

                            if (isNaN(fragment)){
                                var aspect = e.width/e.height;
                                var widthWindow = $(".cropper-canvas").width();

                                if (aspect < 0.967){
                                    $(this).cropper('setCropBoxData',{width:(e.width * widthWindow/widthImage + 1)});
                                }
                                if (aspect > 2.9){
                                    $(this).cropper('setCropBoxData',{width:(e.width * widthWindow/widthImage - 1)});
                                }
                            }
                        }
                    });
                }
            });
        },

        //Выбор фрагмента изображения после загрузки
        UploadImageFragment: function(do_){
            var this_ = this;
            $("#upload_image .preloader").addClass("hide");
            $("#upload_image input[type='text'],#upload_image button.apply").prop("disabled",false);
            $.ajax({
                url : "/udata/content/getImageName/.json",
                type : "POST",
                dataType : 'json',
                data : {session_name: do_},
                success : function(data) {
                    $('#upload_image .cropper img').remove();
                    $('#upload_image .cropper').unbind();
                    $('#upload_image .cropper').html('<label>Выберите фрагмент изображения</label><img class="hide" src="'+data.image+".jpg"+'" />');
                    this_.InitCropper();
                }
            });
        },

        //Закрытие окна загрузки изображения и обновление страницы
        UploadImageComplete: function(do_){
            $("#upload_image .cropper>img").cropper("destroy");

            $("#upload_image button.apply").prop("disabled", true);
            $("#upload_image .preloader").addClass("hide");
            $("#upload_image input[type='text'],#upload_image button.apply").prop("disabled",false);
            $("#upload_image").modal('hide');
            $("body").removeClass("modal-open");
            switch (do_){
                case "poll_new_image":
                    GM.View.NewPoll.refreshNewPoll(true, true);
                    break;
                case "upload_image_article":
                    GM.View.NewArticle.refreshNewArticle(true, true);
                    break;
                case "upload_image_profile":
                    GM.View.Cabinet.Profile();
                    break;
                case "upload_image_feed":
                    location.reload();
                    break;
            }
        }
    };
};
