//При нажатии на back в браузере, выполняется перезагрузка
var reloadValue = new Date();
reloadValue = reloadValue.getTime();
if (document.getElementById('reloadValue').value == ""){
    document.getElementById('reloadValue').value = reloadValue;
} else{
    document.getElementById('reloadValue').value = '';
    location.reload();
}