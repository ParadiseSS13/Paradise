// Disables all links for one second after the browser window opens.

(function(){
  // If there's already an onload, let's not clobber it
  var oldonload = window.onload;
  window.onload = function(){
    if(typeof oldonload == 'function'){
      oldonload();
    }
    var onclicks = Array();
    var links = document.getElementsByTagName("a");
    var returnfalse = function(){return false;};
    for(var i = 0; i < links.length; i++){
      onclicks.push(links[i].onclick);
      links[i].onclick = returnfalse;
    }
    setTimeout(function(){
      for(var i = 0; i < links.length; i++){
        // Reset onclick, but only if something else hasn't already changed it
        if(links[i].onclick == returnfalse){
          links[i].onclick = onclicks[i];
        }
      }
    }, 1000);
  };
})();
