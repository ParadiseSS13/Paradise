function Prize(id,css, crane) {
    var top = css['top'];  
    var left = css['left'];
    var original_left = css['left'];
	hspd = 15;
	vspd = 5;
	var state = 'falling';
	var error;

	var rand = Math.floor(Math.random()*10);
	var rand2 = Math.floor(Math.random()*8);
	var item = ['item.2618.png','item.3122.png','item.6358.png',
		'aurum.png','item.7857.png','item.7868.png','item.7843.png','item.7842.png',
	
	];
	css['background'] = 'url(images/'+item[rand2]+') no-repeat center';
	var pic = $('<div></div>').attr({'id':'prize'+id,class:'prize-ball'}).css(css);
	var ball = $('<div></div>').css({height: 60,'background':'url(images/prizeorbs.png) no-repeat -4px -'+62*rand+'px'});
	$(pic).append(ball);
	$('#game').append(pic);

	//console.log(crane);
	this.GetState = function() {return state};
	
	var CheckBoundaries = function () {
		
		if(left < 52)
			left = 52;
		else if(left > 812)
			left = 812;	
		
		if(top < 30)
			top = 30;
		else if(top > 347 && state !='won' && state !='hidden') {
			top = 347;	
			state = 'resting';
		} else if(top > 500 && state =='won') {
			top=500;
		}
	};
	
	var CheckGrabbed = function() {
		 
		var tmp = Math.floor(Math.random()*100);
		if(tmp>error) {
			setTimeout(function(){
				state='falling';
				$('#debug-streak').html(0); //reset streak	
			},4*error+300);
		 } 
		 
		state = 'is grabbed';
	};
	
	var IsGrabbed = function() {
		top = crane.GetTop()+65;
		
		if(top > 347) 
			top = 347;	
			
		left = crane.GetLeft()+23;
		if(left <= 60) {
			left = 60;
			state = 'won';
		} 
	};
	
	this.GetError = function(offset) {
		return Math.floor(160/(.1*offset+1)-60);
	};
	
	this.Update = function () {
	
		if(crane.GetState() == 'down' && state=='resting') {
			var offset = Math.abs(left - crane.GetLeft()-23);
			error = this.GetError(offset);
			if(error > 0) {				
				state = 'being grabbed';
				$('#debug-errorpx').html(Math.abs(offset)+'px');
				$('#debug-errordrop').html(error+'%');//debugging
			}
		}
		
		if(crane.GetState() == 'up' && state=='being grabbed')
			CheckGrabbed();
		
		if((crane.GetState() == 'drop' || crane.GetState() == 'up') && state=='is grabbed')
			IsGrabbed();
		
		if(state=='falling'||state=='won')
			top += vspd;
		
		if(state=='won' && top > 460) {
			$('#prize'+id).remove();//css({visibility:'hidden'});
			state='hidden';
			
			$('#debug-streak').html(parseInt($('#debug-streak').html())+1); //inc streak
			
			//spawn new prize
			setTimeout(function(){
				prizes[prizes.length] = new Prize(prizes.length,{top: Math.ceil(Math.random()*100),left: original_left},crane);}
				,1000);	
			
		}
		
		CheckBoundaries();
	};
	
	this.Repaint = function () {
        $('#prize'+id).css({'top':top, 'left':left});
		//$('#'+id+' #crane-handle-top').css({height: handleHeight});
    };
	
}