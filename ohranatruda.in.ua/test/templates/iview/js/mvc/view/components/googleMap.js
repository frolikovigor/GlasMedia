export default function googleMap(){

    return {
        DrawGoogleMaps: () =>{
            if ($(".googleMap").length){
                GM.Model.GoogleMap.Init().then(
                    () =>
                        $(".googleMap").each(function(){
                            GM.View.GoogleMap.DrawGoogleMap($(this), '')
                        }),
                    ()=>{}
                )
            }
        },

        DrawGoogleMap: (elemGM, param0, param1) => {
            var elem = elemGM.children("div");
            var idMap = elem.attr("id");
            var pollId = (elem.attr("data-pollId") != undefined) ? elem.attr("data-pollId") : false;
            var param0 = param0 ? param0 : '';
            var param1 = param1 ? param1 : "";

            if (pollId){
                elemGM.removeClass("hidePreloader");
                GM.Model.GoogleMap.GetPollMap(pollId, param0, param1).then(
                    (getData) => {
                        if ((getData.regions != undefined) && (getData.region != undefined)){
                            var rowsTable = [];
                            var votes = (getData.votes.item != undefined) ? getData.votes.item : [];
                            for(var vote in votes)
                                if ((votes[vote].region != undefined) && (votes[vote].votes !=undefined) && (votes[vote].name != undefined))
                                    rowsTable.push([votes[vote].region, votes[vote].votes, votes[vote].name]);

                            var data = new google.visualization.DataTable();
                            data.addColumn('string', 'region');
                            data.addColumn('number', 'Голосов');
                            data.addColumn('string', 'Display');
                            data.addRows(rowsTable);
                            var geochart = new google.visualization.GeoChart(
                                document.getElementById(idMap));
                            var formatter = new google.visualization.PatternFormat('{1}');
                            formatter.format(data, [0, 2]);
                            var view = new google.visualization.DataView(data);
                            view.setColumns([0, 1]);

                            geochart.draw(view, {
                                region: getData.region,
                                resolution: getData.regions,
                                colorAxis: {colors: ['#B9D3EE', '#104E8B']}
                            });

                            elemGM.addClass("hidePreloader");

                            if (rowsTable.length && (getData.regions != 'provinces')){
                                google.visualization.events.addListener(geochart, 'regionClick', function(e) {
                                    GM.View.GoogleMap.DrawGoogleMap(elemGM,param0,e.region);
                                });
                            }
                            if (param1)
                                $(".googleMapZoomOut[data-for_map='"+idMap+"']").removeClass("hide");
                            else
                                $(".googleMapZoomOut[data-for_map='"+idMap+"']").addClass("hide");
                            $(".googleMapZoomOut[data-for_map='"+idMap+"']").unbind();
                            $(".googleMapZoomOut[data-for_map='"+idMap+"']").on("click",() => {
                                GM.View.GoogleMap.DrawGoogleMap(elemGM, param0);
                            });
                            $(".googleMapSelect").unbind();
                            $(".googleMapSelect").on("click", () => {
                                elemGM.removeClass("hidePreloader");
                                var active = $(this).hasClass("active") ? false : true;
                                if (active) {
                                    $(this).addClass("active");
                                    $(this).find("input[type='hidden']").prop("disabled", false);
                                } else {
                                    $(this).removeClass("active");
                                    $(this).find("input[type='hidden']").prop("disabled", true);
                                }

                                var for_map = $(this).attr("data-for_map");
                                var serFM = '';
                                serFM = $(this).closest("form").serialize() + "&custom=1";
                                GM.View.GoogleMap.DrawGoogleMap($("#"+for_map).closest(".googleMap"), serFM);
                            });
                        } else {
                            elemGM.addClass("hidePreloader");
                        };
                    },
                    () => {}
                );
            }
        }
    };
};
