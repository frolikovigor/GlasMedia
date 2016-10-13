import getModel from '../model/common';
import getView from '../view/common';
import getEvents from './Events/common';

export default class controller{
    constructor(){
        window.GM = Object.create(null);
        GM.Model = new getModel();
        GM.View = new getView();
        GM.Events = new getEvents();

        $(document).ready(() => this.DOMReady());
        $("body").waitForImages(() => this.IMGReady());
    };

    DOMReady(){
        GM.View.GoogleMap.DrawGoogleMaps();                 //done
        GM.View.NewPoll.refreshNewPoll(false, true);
        GM.View.NewArticle.refreshNewArticle(false, true);

        GM.View.Cabinet.Profile(); 

        GM.View.Feed.Settings();
        GM.View.InitCounter();
        GM.View.ColorBox.init();
        GM.View.InitTooltips();
        GM.View.Comments.Init();
        GM.View.InitCaptcha();
        GM.View.InitSetInfo();
        GM.View.Images.InitCropper();
        GM.View.IntroJs.init();
        GM.View.Feedback.Validate();
        GM.View.OpenAlerts();
    };

    IMGReady(){
        $(".hidden_block").removeClass("hidden_block");
        GM.View.AdaptiveImage();
        $(".dot").dotdotdot();
        GM.View.CutContent();
        GM.View.Masonry.init();
        GM.View.Goto();
    };

}
