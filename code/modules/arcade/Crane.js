function Crane(id) {
	//console.log("crane created");
    var top = 131; //private
    var left = 100;
	var hspd = 6;
	var vspd = 4;
	var state = false;
	var handleHeight = 83;
	var frames = {
		normal: {'background-position': '-36px -34px',left:11},
		half: {'background-position': '-36px -148px',left:6},
		open: {'background-position': '-28px -270px',left:-2}
	};
	
	this.GetState = function() {return state};
	this.GetLeft = function() {return left};
	this.GetTop = function() {return top};
	
	var Grab = function () {
		top += (state == 'down')?vspd:-vspd; 
		handleHeight += (state == 'down')?vspd:-vspd;

		if(top > 300 && state == 'down') { //when going down
			top = 300;
			//handleHeight = ;
			state = 'up';
			$('#'+id+' #crane-claw').css(frames['half']); 
		} else if(top < 131 && state == 'up') { //when going up
			top = 131;
			handleHeight = 83;
			state = 'drop';
			
		} else if(state == 'drop') { //when up and dropping
			left -= hspd;
			top = 131;
			handleHeight = 83;
			if(left < 30) {
				left = 30;
				$('#'+id+' #crane-claw').css(frames['open']);
				setTimeout(function(){$('#'+id+' #crane-claw').css(frames['normal']);state = false;},500);
				
			}
		}
    };
	
	var CheckBoundaries = function () {
		
		if(left < 30)
			left = 30;
		else if(left > 788)
			left = 788;	
	};
	
	this.Update = function () {
		//console.log(left);
		if(keys["left"] && !state) //left
			left -= hspd;
			
		if(keys["right"] && !state) //right
			left += hspd;
			
		if(keys["down"] && !state) { //space
			state = 'down';
			
			$('#'+id+' #crane-claw').css(frames['open']);
		}
		
		if(state) {
			Grab();
		}
			
		CheckBoundaries();
	};
	
	this.Repaint = function () {
        $('#'+id).css({'top':top, 'left':left});
		$('#'+id+' #crane-handle-top').css({height: handleHeight});
    };
}