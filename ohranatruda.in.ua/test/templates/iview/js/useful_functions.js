/* ������ ���� �������� ��� �������� ��� ������ ������� */



/**
 * ���������� ��������� �������� �� �������� ������ ��������
 * 
 * @param $name string �������� ���������
 * 
 * @param $def_value mixed ��������, ������������ ���� �������� �� ������
 * 
 * @return string ���������� �������� ���������, ��� 0, ���� �������� �� ������.
 */ 
urlParam = function(name, def_value){
	if(def_value == null) def_value = '';
	
	var results = new RegExp('[\\?&]' + name + '=([^&#]*)').exec(window.location.href);
	if (results==null){
		return def_value;
	}else{
		return results[1] || def_value;
	}	
}

formatPrice = function(elt) {
     $(elt).text((String(sum)).replace(/(\d)(?=(\d\d\d)+([^\d]|$))/g, '$1 '));
}


/*morph remake*/
/*xslt*/
/*<span data-modify="morph" data-count="{$msg_count}" data-rules="Новое|Новых|Новых" data-option="nocount"></span>*/	
/*<span data-modify="morph" data-count="{$msg_count}" data-rules="Новое|Новых|Новых"></span>*/
/*<span data-modify="morph" data-count="{$msg_count}" data-rules="Новое|Новых|Новых" data-word-container="#word" data-number-container="#number"></span>*/
function morphWords(count, rules){
	response = {word: "", count: ""};
	words = rules.split('|');
	if((count%10) == 1 && count != 11)
	{
		response.word = words[0];
		response.count = count;
	}
	if((count%10) >= 2 && (count%10) <= 4)
	{
		response.word = words[1];
		response.count = count;
	}
	if(((count%10) >= 5 || (count%10) == 0) || (count >= 11 && count <= 14))
	{
		response.word = words[2];
		response.count = count;
	}
	return response;
}

$(document).ready(function(){
if($('[data-modify = "morph"]').length){
	$('[data-modify = "morph"]').each(function(){
		var count = $(this).attr("data-count");
		var rules = $(this).attr("data-rules");
		var wCont = $(this).attr("data-word-container");
		var cCont = $(this).attr("data-number-container");
		var noCount = $(this).attr("data-option");
		modifed = morphWords(count,rules);
		if(wCont != undefined && cCont != undefined){
			$("'"+wCont+"'").html(modifed.word);
			if(noCount === undefined){
				$("'"+cCont+"'").html(modifed.count);
			}
		} else $(this).html(((noCount === undefined) ? modifed.count + " " : "") + modifed.word);
	});
}
});