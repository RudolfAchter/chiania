$( document ).ready(function() {
    console.log( "jquery ready!" );
    //falls ich jquery brauche

    function flip_marketbox(event){
        //alert("You open the mysterious box")
        console.log(event)
        console.log($(event.target).parent())
        $("#market-messages").html(("You open " + $(event.target).parent().attr("name")))
        $(event.target).parent().css('transform', 'rotateY(180deg)')

        $(event.target).parent().parent().bind("click",get_marketbox_offer)
        
    }

    function get_marketbox_offer(event){
        //alert("You open the mysterious box")
        console.log(event)
        console.log($(event.target).parent())
        $("#market-messages").html(("You investigate offer " + $(event.target).attr("alt")))
        //$(event.target).parent().css('transform', 'rotateY(-180deg)')
        
    }

    $(".market-box").bind("click",flip_marketbox)
    $(".market-box").bind("tap",flip_marketbox)
    
});