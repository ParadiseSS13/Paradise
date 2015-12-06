var crane = new Crane('crane');
var keys = [];
var prizes = [];

window.requestAnimFrame = (function(callback){
    return window.requestAnimationFrame ||
    window.webkitRequestAnimationFrame ||
    window.mozRequestAnimationFrame ||
    window.oRequestAnimationFrame ||
    window.msRequestAnimationFrame ||
    function(callback){
        window.setTimeout(callback, 1000 / 30);
    };
})();

function animate(){
	//console.log("animate called");
	crane.Update();
	
	for(var i = 0; i< prizes.length; i++)
		prizes[i].Update();
	
	for(var i = 0; i< prizes.length; i++)
		prizes[i].Repaint();
		
	crane.Repaint();
	
	requestAnimFrame(function(){
		animate();
	});
}



function joystickControlOn(direction){
	//console.log(direction);
	keys[direction] = true;
};

function joystickControlOff(direction){
	//console.log(direction);
	keys[direction] = false;
};

//stops when text area loses focus
function handsOff(){
    //keys.length = 0;
	keys = []; //clears array
};

function gameStartUp(){ //main function
	//console.log("game start!");
	for(var i = 0; i< 5; i++)
		prizes[i] = new Prize(i,{top: Math.ceil(Math.random()*100),left: 400+i*100-Math.ceil(Math.random()*50)},crane);
		console.log("prize made");
	
	//crane.Repaint();
	animate();
};