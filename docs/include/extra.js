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


function item_maximize(event){
  console.log("item_maximize")
  console.log(event)
  $(".item_maximized").attr("class","item_thumbnail")
  target=$(event.currentTarget)
  target.attr("class","item_maximized")
  target.off("click",item_maximize)
  target.on("click",item_minimize)

  $([document.documentElement, document.body]).animate({
    scrollTop: ($(target).offset().top - 200)
  }, 500);

}


function item_minimize(event){
  console.log("item_minimize")
  console.log(event)
  target=$(event.currentTarget)
  target.attr("class","item_thumbnail")
  target.off("click",item_minimize)
  target.on("click",item_maximize)

  $([document.documentElement, document.body]).animate({
    scrollTop: ($(target).offset().top - 200)
  }, 500);

}


$( window ).on("load",function() {
    console.log( "jquery ready!" );
    //falls ich jquery brauche
    $(".market-box").on("click",flip_marketbox)
    $(".market-box").on("tap",flip_marketbox)
    $(".item_thumbnail").on("click",item_maximize)
});