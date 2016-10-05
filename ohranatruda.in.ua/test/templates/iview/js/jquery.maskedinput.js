/*
	Masked Input plugin for jQuery
	Copyright (c) 2007-2013 Josh Bush (digitalbush.com)
	Licensed under the MIT license (http://digitalbush.com/projects/masked-input-plugin/#license)
	Version: 1.3.1
*/
(function($) {
	function getPasteEvent() {
    var el = document.createElement('input'),
        name = 'onpaste';
    el.setAttribute(name, '');
    return (typeof el[name] === 'function')?'paste':'input';             
}

var pasteEventName = getPasteEvent() + ".mask",
	ua = navigator.userAgent,
	iPhone = /iphone/i.test(ua),
	android=/android/i.test(ua),
	caretTimeoutId;

$.mask = {
	//Predefined character definitions
	definitions: {
		'9': "[0-9]",
		'a': "[A-Za-z]",
		'*': "[A-Za-z0-9]"
	},
	dataName: "rawMaskFn",
	placeholder: '_',
};

$.fn.extend({
	//Helper Function for Caret positioning
	caret: function(begin, end) {
		var range;

		if (this.length === 0 || this.is(":hidden")) {
			return;
		}

		if (typeof begin == 'number') {
			end = (typeof end === 'number') ? end : begin;
			return this.each(function() {
				if (this.setSelectionRange) {
					this.setSelectionRange(begin, end);
				} else if (this.createTextRange) {
					range = this.createTextRange();
					range.collapse(true);
					range.moveEnd('character', end);
					range.moveStart('character', begin);
					range.select();
				}
			});
		} else {
			if (this[0].setSelectionRange) {
				begin = this[0].selectionStart;
				end = this[0].selectionEnd;
			} else if (document.selection && document.selection.createRange) {
				range = document.selection.createRange();
				begin = 0 - range.duplicate().moveStart('character', -100000);
				end = begin + range.text.length;
			}
			return { begin: begin, end: end };
		}
	},
	unmask: function() {
		return this.trigger("unmask");
	},
	mask: function(mask, settings) {
		var input,
			defs,
			tests,
			partialPosition,
			firstNonMaskPos,
			len;

		if (!mask && this.length > 0) {
			input = $(this[0]);
			return input.data($.mask.dataName)();
		}
		settings = $.extend({
			placeholder: $.mask.placeholder, // Load default placeholder
			completed: null
		}, settings);


		defs = $.mask.definitions;
		tests = [];
		partialPosition = len = mask.length;
		firstNonMaskPos = null;

		$.each(mask.split(""), function(i, c) {
			if (c == '?') {
				len--;
				partialPosition = i;
			} else if (defs[c]) {
				tests.push(new RegExp(defs[c]));
				if (firstNonMaskPos === null) {
					firstNonMaskPos = tests.length - 1;
				}
			} else {
				tests.push(null);
			}
		});

		return this.trigger("unmask").each(function() {
			var input = $(this),
				buffer = $.map(
				mask.split(""),
				function(c, i) {
					if (c != '?') {
						return defs[c] ? settings.placeholder : c;
					}
				}),
				focusText = input.val();

			function seekNext(pos) {
				while (++pos < len && !tests[pos]);
				return pos;
			}

			function seekPrev(pos) {
				while (--pos >= 0 && !tests[pos]);
				return pos;
			}

			function shiftL(begin,end) {
				var i,
					j;

				if (begin<0) {
					return;
				}

				for (i = begin, j = seekNext(end); i < len; i++) {
					if (tests[i]) {
						if (j < len && tests[i].test(buffer[j])) {
							buffer[i] = buffer[j];
							buffer[j] = settings.placeholder;
						} else {
							break;
						}

						j = seekNext(j);
					}
				}
				writeBuffer();
				input.caret(Math.max(firstNonMaskPos, begin));
			}

			function shiftR(pos) {
				var i,
					c,
					j,
					t;

				for (i = pos, c = settings.placeholder; i < len; i++) {
					if (tests[i]) {
						j = seekNext(i);
						t = buffer[i];
						buffer[i] = c;
						if (j < len && tests[j].test(t)) {
							c = t;
						} else {
							break;
						}
					}
				}
			}

			function keydownEvent(e) {
				var k = e.which,
					pos,
					begin,
					end;

				//backspace, delete, and escape get special treatment
				if (k === 8 || k === 46 || (iPhone && k === 127)) {
					pos = input.caret();
					begin = pos.begin;
					end = pos.end;

					if (end - begin === 0) {
						begin=k!==46?seekPrev(begin):(end=seekNext(begin-1));
						end=k===46?seekNext(end):end;
					}
					clearBuffer(begin, end);
					shiftL(begin, end - 1);

					e.preventDefault();
				} else if (k == 27) {//escape
					input.val(focusText);
					input.caret(0, checkVal());
					e.preventDefault();
				}
			}

			function keypressEvent(e) {
				var k = e.which,
					pos = input.caret(),
					p,
					c,
					next;

				if (e.ctrlKey || e.altKey || e.metaKey || k < 32) {//Ignore
					return;
				} else if (k) {
					if (pos.end - pos.begin !== 0){
						clearBuffer(pos.begin, pos.end);
						shiftL(pos.begin, pos.end-1);
					}

					p = seekNext(pos.begin - 1);
					if (p < len) {
						c = String.fromCharCode(k);
						if (tests[p].test(c)) {
							shiftR(p);

							buffer[p] = c;
							writeBuffer();
							next = seekNext(p);

							if(android){
								setTimeout($.proxy($.fn.caret,input,next),0);
							}else{
								input.caret(next);
							}

							if (settings.completed && next >= len) {
								settings.completed.call(input);
							}
						}
					}
					e.preventDefault();
				}
			}

			function clearBuffer(start, end) {
				var i;
				for (i = start; i < end && i < len; i++) {
					if (tests[i]) {
						buffer[i] = settings.placeholder;
					}
				}
			}

			function writeBuffer() { input.val(buffer.join('')); }

			function checkVal(allow) {
				//try to place characters where they belong
				var test = input.val(),
					lastMatch = -1,
					i,
					c;

				for (i = 0, pos = 0; i < len; i++) {
					if (tests[i]) {
						buffer[i] = settings.placeholder;
						while (pos++ < test.length) {
							c = test.charAt(pos - 1);
							if (tests[i].test(c)) {
								buffer[i] = c;
								lastMatch = i;
								break;
							}
						}
						if (pos > test.length) {
							break;
						}
					} else if (buffer[i] === test.charAt(pos) && i !== partialPosition) {
						pos++;
						lastMatch = i;
					}
				}
				if (allow) {
					writeBuffer();
				} else if (lastMatch + 1 < partialPosition) {
					input.val("");
					clearBuffer(0, len);
				} else {
					writeBuffer();
					input.val(input.val().substring(0, lastMatch + 1));
				}
				return (partialPosition ? i : firstNonMaskPos);
			}

			input.data($.mask.dataName,function(){
				return $.map(buffer, function(c, i) {
					return tests[i]&&c!=settings.placeholder ? c : null;
				}).join('');
			});

			if (!input.attr("readonly"))
				input
				.one("unmask", function() {
					input
						.unbind(".mask")
						.removeData($.mask.dataName);
				})
				.bind("focus.mask", function() {
					clearTimeout(caretTimeoutId);
					var pos,
						moveCaret;

					focusText = input.val();
					pos = checkVal();
					
					caretTimeoutId = setTimeout(function(){
						writeBuffer();
						if (pos == mask.length) {
							input.caret(0, pos);
						} else {
							input.caret(pos);
						}
					}, 10);
				})
				.bind("blur.mask", function() {
					checkVal();
					if (input.val() != focusText)
						input.change();
				})
				.bind("keydown.mask", keydownEvent)
				.bind("keypress.mask", keypressEvent)
				.bind(pasteEventName, function() {
					setTimeout(function() { 
						var pos=checkVal(true);
						input.caret(pos); 
						if (settings.completed && pos == input.val().length)
							settings.completed.call(input);
					}, 0);
				});
			checkVal(); //Perform initial check for existing values
		});
	}
});


})(jQuery);

/// <reference path="../../../lib/jquery-1.2.6.js" />
/*
	Masked Input plugin for jQuery
	Copyright (c) 2007-2009 Josh Bush (digitalbush.com)
	Licensed under the MIT license (http://digitalbush.com/projects/masked-input-plugin/#license) 
	Version: 1.2.2 (03/09/2009 22:39:06)
*/
// Modified by ramiro at conductiva.com to accept placeholder for the full mask
(function($){var w=(navigator.appName == 'Microsoft Internet Explorer'?'paste':'input')+".mask";var x=(window.orientation!=undefined);$.mask={definitions:{'9':"[0-9]",'a':"[A-Za-z]",'*':"[A-Za-z0-9]"}};$.fn.extend({caret:function(b,c){if(this.length==0)return;if(typeof b=='number'){c=(typeof c=='number')?c:b;return this.each(function(){if(this.setSelectionRange){this.focus();this.setSelectionRange(b,c)}else if(this.createTextRange){var a=this.createTextRange();a.collapse(true);a.moveEnd('character',c);a.moveStart('character',b);a.select()}})}else{if(this[0].setSelectionRange){b=this[0].selectionStart;c=this[0].selectionEnd}else if(document.selection&&document.selection.createRange){var d=document.selection.createRange();b=0-d.duplicate().moveStart('character',-100000);c=b+d.text.length}return{begin:b,end:c}}},unmask:function(){return this.trigger("unmask")},mask:function(m,n){if(!m&&this.length>0){var o=$(this[0]);var q=o.data("tests");return $.map(o.data("buffer"),function(c,i){return q[i]?c:null}).join('')}n=$.extend({placeholder:"_",completed:null},n);var r=$.mask.definitions;var q=[];var s=m.length;var u=null;var v=m.length;$.each(m.split(""),function(i,c){if(c=='?'){v--;s=i}else if(r[c]){q.push(new RegExp(r[c]));if(u==null)u=q.length-1}else{q.push(null)}});return this.each(function(){var f=$(this);var g=$.map(m.split(""),function(c,i){if(c!='?'){return r[c]?(n.placeholder.length>1?n.placeholder.charAt(i):n.placeholder):c}});var h=false;var l=f.val();f.data("buffer",g).data("tests",q);function seekNext(a){while(++a<=v&&!q[a]);return a};function shiftL(a){while(!q[a]&&--a>=0);for(var i=a;i<v;i++){if(q[i]){g[i]=n.placeholder.length>1?n.placeholder.charAt(i):n.placeholder;var j=seekNext(i);if(j<v&&q[i].test(g[j])){g[i]=g[j]}else break}}writeBuffer();f.caret(Math.max(u,a))};function shiftR(a){for(var i=a;i<v;i++){var c=n.placeholder.length>1?n.placeholder.charAt(i):n.placeholder;if(q[i]){var j=seekNext(i);var t=g[i];g[i]=c;if(j<v&&q[j].test(t))c=t;else break}}};function keydownEvent(e){var a=$(this).caret();var k=e.keyCode;h=(k<16||(k>16&&k<32)||(k>32&&k<41));if((a.begin-a.end)!=0&&(!h||k==8||k==46))clearBuffer(a.begin,a.end);if(k==8||k==46||(x&&k==127)){shiftL(a.begin+(k==46?0:-1));return false}else if(k==27){f.val(l);f.caret(0,checkVal());return false}};function keypressEvent(e){if(h){h=false;return(e.keyCode==8)?false:null}e=e||window.event;var k=e.charCode||e.keyCode||e.which;var a=$(this).caret();if(e.ctrlKey||e.altKey||e.metaKey){return true}else if((k>=32&&k<=125)||k>186){var p=seekNext(a.begin-1);if(p<v){var c=String.fromCharCode(k);if(q[p].test(c)){shiftR(p);g[p]=c;writeBuffer();var b=seekNext(p);$(this).caret(b);if(n.completed&&b==v)n.completed.call(f)}}}return false};function clearBuffer(a,b){for(var i=a;i<b&&i<v;i++){if(q[i])g[i]=n.placeholder.length>1?n.placeholder.charAt(i):n.placeholder}};function writeBuffer(){return f.val(g.join('')).val()};function checkVal(a){var b=f.val();var d=-1;for(var i=0,pos=0;i<v;i++){if(q[i]){g[i]=n.placeholder.length>1?n.placeholder.charAt(i):n.placeholder;while(pos++<b.length){var c=b.charAt(pos-1);if(q[i].test(c)){g[i]=c;d=i;break}}if(pos>b.length)break}else if(g[i]==b[pos]&&i!=s){pos++;d=i}}if(!a&&d+1<s){f.val("");clearBuffer(0,v)}else if(a||d+1>=s){writeBuffer();if(!a)f.val(f.val().substring(0,d+1))}return(s?i:u)};if(!f.attr("readonly"))f.one("unmask",function(){f.unbind(".mask").removeData("buffer").removeData("tests")}).bind("focus.mask",function(){l=f.val();var a=checkVal();writeBuffer();setTimeout(function(){if(a==m.length)f.caret(0,a);else f.caret(a)},0)}).bind("blur.mask",function(){checkVal();if(f.val()!=l)f.change()}).bind("keydown.mask",keydownEvent).bind("keypress.mask",keypressEvent).bind(w,function(){setTimeout(function(){f.caret(checkVal(true))},0)});checkVal()})}})})(jQuery);