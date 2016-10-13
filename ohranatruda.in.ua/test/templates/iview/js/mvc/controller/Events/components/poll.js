export default function poll(){
    return (function(){

        //Голосование. Нажатие на кнопку "Голосовать"
        $("body").on("click",".poll .vote", function(){
            GM.View.Poll.Vote($(this));
        });
    })();
}
