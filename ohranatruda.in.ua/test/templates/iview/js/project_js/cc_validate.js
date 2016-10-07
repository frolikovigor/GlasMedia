(function($){
    $.fn.cc_validate = function(options) {
        var sets = $.extend({
            settings: {required_class:'required', error_class:'error'}, warning:function(){},
            hide_warning:function(){},
            success:function(){}
        }, options);

        this.each(function() {
            var a=$(this); var id = "#"+a.attr("id"); var sel = id+" input[type='text'],"+id+" input[type='password'],"+id+" textarea, "+id+" select";
            a.on("click", "input[type='submit']", function(event) {cc_validate_inner(a, null, sel); event.preventDefault();});
            a.on("click", "button[type='submit']", function(event) {cc_validate_inner(a, null, sel); event.preventDefault();});
            $(sel).on("change", function(event) {cc_validate_inner(a,$(this),sel); event.preventDefault();});
        });

        function cc_validate_inner(a,c,sel){
            var j = false; var g = c ? c : $(sel);
            var d = new RegExp(/^(("[\w-\s]+")|([\w-]+(?:\.[\w-]+)*)|("[\w-\s]+")([\w-]+(?:\.[\w-]+)*))(@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$)|(@\[?((25[0-5]\.|2[0-4][0-9]\.|1[0-9]{2}\.|[0-9]{1,2}\.))((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[0-9]{1,2})\.){2}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[0-9]{1,2})\]?$)/i);
            var sr = []; var ur = sets.rules; for(var i in ur)
                if(ur[i].rule == 'compare') sr[sr.length] = {element:ur[i].compare, rule:'_compare', compare:ur[i].element};
            var fr = ur.concat(sr);
            g.each(function(){
                var e=$(this); e.removeClass(sets.settings.error_class);
                if ((e.val()=='') && (e.hasClass(sets.settings.required_class))) {
                    sets.warning(e,'required'); e.addClass(sets.settings.error_class); if (!j && !c) {e.focus(); j = true};
                } else{
                    sets.hide_warning(e,'required');
                    if ((e.hasClass('email')) && !d.test(e.val())){
                        sets.warning(e,'email'); e.addClass(sets.settings.error_class); if (!j && !c) {e.focus(); j = true};
                    } else sets.hide_warning(e,'email');
                }
                for(var i in fr) {
                    var h = $('#'+a.attr('id')+" "+fr[i].element);
                    e.addClass('cc_validate');
                    if (h.hasClass('cc_validate')){
                        switch (fr[i].rule){
                            case 'required':
                                if (h.val()==''){
                                    sets.warning(e,'required');
                                    h.addClass(sets.settings.error_class); if (!j && !c) {h.focus(); j = true};
                                } else sets.hide_warning(e,'required');
                                break;
                            case 'email':
                                if (!d.test(h.val())){
                                    sets.warning(e,'email');
                                    h.addClass(sets.settings.error_class); if (!j && !c) {h.focus(); j = true};
                                } else sets.hide_warning(e,'email');
                                break;
                            case 'check':
                                $.ajax({url:fr[i].url,async:false,type:"POST",dataType:'html',data:a.serialize(),success:function(r){
                                    if (r != fr[i].need) {
                                        sets.warning(e,'check',r);
                                        h.addClass(sets.settings.error_class);
                                        if (!j && !c) {h.focus(); j = true};
                                    } else sets.hide_warning(e,'check',r);
                                }});
                                break;
                            case 'compare':
                                if (h.val()!= $('#'+a.attr('id')+' '+fr[i].compare).val()) {
                                    sets.warning(e,'compare');
                                    h.addClass(sets.settings.error_class); if (!j && !c) {h.focus(); j = true};
                                } else sets.hide_warning(e,'compare');
                                break;
                            case '_compare':
                                var sc = $('#'+a.attr('id')+' '+fr[i].compare);
                                if (h.val()!= sc.val()) {
                                    sets.warning(sc,'compare');
                                    sc.addClass(sets.settings.error_class); if (!j && !c) {sc.focus(); j = true};
                                } else {sc.removeClass(sets.settings.error_class); sets.hide_warning(sc,fr[i].rule);}
                                break;
                            case 'eqless':
                                if (parseFloat(h.val()) > parseFloat(fr[i].eqless)) {
                                    sets.warning(e,'eqless');
                                    h.addClass(sets.settings.error_class); if (!j && !c) {h.focus(); j = true};
                                } else sets.hide_warning(e,'eqless');
                                break;
                            case 'eqmore':
                                if (parseFloat(h.val()) < parseFloat(fr[i].eqmore)) {
                                    sets.warning(e,'eqmore');
                                    h.addClass(sets.settings.error_class); if (!j && !c) {h.focus(); j = true};
                                } else sets.hide_warning(e,'eqmore');
                                break;
                            case 'min_length':
                                if (h.val().length<fr[i].min_length) {
                                    sets.warning(e,'min_length');
                                    h.addClass(sets.settings.error_class); if (!j) {h.focus(); j = true};
                                } else sets.hide_warning(e,'min_length');
                                break;
                            case 'min_length_null':
                                if ((h.val().length<fr[i].min_length)&&h.val().length) {
                                    sets.warning(e,'min_length');
                                    h.addClass(sets.settings.error_class); if (!j) {h.focus(); j = true};
                                } else sets.hide_warning(e,'min_length');
                                break;
                        }
                    }
                    e.removeClass('cc_validate');
                }
            });
            if ((!$(a).find('.'+sets.settings.error_class).length) && !c) sets.success($(a));
        }
    };
})( jQuery );