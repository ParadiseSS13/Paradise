//this function places received data into element with specified id.
#define JS_BYJAX {"

function replaceContent() {
	var args = Array.prototype.slice.call(arguments);
	var id = args\[0\];
	var content = args\[1\];
	var callback  = null;
	if(args\[2\]){
		callback = args\[2\];
		if(args\[3\]){
			args = args.slice(3);
		}
	}
	var parent = document.getElementById(id);
	if(typeof(parent)!=='undefined' && parent!=null){
		parent.innerHTML = content?content:'';
	}
	if(callback && window\[callback\]){
		window\[callback\].apply(null,args);
	}
}
"}

/*
sends data to control_id:replaceContent

receiver - mob
control_id - window id (for windows opened with browse(), it'll be "windowname.browser")
target_element - HTML element id
new_content - HTML content
callback - js function that will be called after the data is sent
callback_args - arguments for callback function

Be sure to include required js functions in your page, or it'll raise an exception.

And yes I know this is a proc in a defines file, but its highly relevant so it can be here
*/
proc/send_byjax(receiver, control_id, target_element, new_content=null, callback=null, list/callback_args=null)
	if(receiver && target_element && control_id) // && winexists(receiver, control_id))
		var/list/argums = list(target_element, new_content)
		if(callback)
			argums += callback
			if(callback_args)
				argums += callback_args
		argums = list2params(argums)
/*		if(callback_args)
			argums += "&[list2params(callback_args)]"
*/
		receiver << output(argums,"[control_id]:replaceContent")
	return


// Misc JS for some dropdowns
#define JS_DROPDOWNS {"
function dropdowns() {
    var divs = document.getElementsByTagName('div');
    var headers = new Array();
    var links = new Array();
    for(var i=0;i<divs.length;i++){
        if(divs\[i\].className=='header') {
            divs\[i\].className='header closed';
            divs\[i\].innerHTML = divs\[i\].innerHTML+' +';
            headers.push(divs\[i\]);
        }
        if(divs\[i\].className=='links') {
            divs\[i\].className='links hidden';
            links.push(divs\[i\]);
        }
    }
    for(var i=0;i<headers.length;i++){
        if(typeof(links\[i\])!== 'undefined' && links\[i\]!=null) {
            headers\[i\].onclick = (function(elem) {
                return function() {
                    if(elem.className.search('visible')>=0) {
                        elem.className = elem.className.replace('visible','hidden');
                        this.className = this.className.replace('open','closed');
                        this.innerHTML = this.innerHTML.replace('-','+');
                    }
                    else {
                        elem.className = elem.className.replace('hidden','visible');
                        this.className = this.className.replace('closed','open');
                        this.innerHTML = this.innerHTML.replace('+','-');
                    }
                return false;
                }
            })(links\[i\]);
        }
    }
}
"}
