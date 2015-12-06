
/obj/machinery/arcade/claw
	name = "Claw Game"
	desc = "One of the most infuriating ways to win a toy."
	icon = 'icons/obj/arcade.dmi'
	icon_state = "clawmachine_on"
	token_price = 15
	var/bonus_prize_chance = 5		//chance to dispense a SECOND prize if you win, increased by matter bin rating

/obj/machinery/arcade/claw/New()
	component_parts = list()
	//component_parts += new /obj/item/weapon/circuitboard/clawgame(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/stack/cable_coil(null, 5)
	component_parts += new /obj/item/stack/sheet/glass(null, 1)
	RefreshParts()

/obj/machinery/arcade/claw/RefreshParts()
	var/bin_upgrades = 0
	for(var/obj/item/weapon/stock_parts/matter_bin/B in component_parts)
		bin_upgrades = B.rating
	bonus_prize_chance = bin_upgrades * 5	//equals +5% chance per matter bin rating level (+20% with rating 4)

/obj/machinery/arcade/claw/update_icon()
	if(stat & BROKEN)
		icon_state = "clawmachine_broken"
	else if(panel_open)
		icon_state = "clawmachine_open"
	else if(stat & NOPOWER)
		icon_state = "clawmachine_off"
	else
		icon_state = "clawmachine_on"
	return

/obj/machinery/arcade/claw/proc/win()
	icon_state = "clawmachine_win"
	//if(prob(bonus_prize_chance))
		//double prize mania!
	//	new /obj/item/toy/prizeball(get_turf(src))
	//new /obj/item/toy/prizeball(get_turf(src))
	spawn(5)
		update_icon()

/obj/machinery/arcade/claw/attack_hand(mob/user as mob)
	interact(user)

/obj/machinery/arcade/claw/interact(mob/user as mob)
	if(stat & BROKEN || panel_open)
		return
	if(!tokens)
		user << "The game doesn't have enough credits to play! Pay first!"
		return
	if(!playing && tokens)
		user.set_machine(src)
		playing = 1
		tokens -= 1
	if(playing && (src != user.machine))
		user << "Someone else is already playing, please wait your turn!"
		return
	user << browse('crane.html', "window=Claw Game;size=600x600")
	/*
	var/dat
	var/datum/browser/clawgame = new(user, "clawgame", name, 600, 600)
	clawgame.add_stylesheet("claw", 'code/modules/arcade/page.css')
	clawgame.add_script("crane", 'code/modules/arcade/Crane.js')
	clawgame.add_script("prize", 'code/modules/arcade/Prize.js')
	clawgame.add_script("main", 'code/modules/arcade/main.js')

	dat += "<div id='game' style='position: relative;'>"
	dat += "<div id='background'></div>"

	dat += "<div id='crane'>"
	dat += "<div id='crane-handle-top'></div>"
	dat += "<div id='crane-handle-bottom'></div>"

	dat += "<div id='crane-claw'></div>"
	dat += "<div id='crane-center'></div>"
	dat += "</div>"

	dat += "<div id='grayorbs-chute'></div>"

	dat += "<div id='foreground'></div>"

	dat += "</div>"

	dat += "<div style='position: absolute; top: 550px'>"
	dat += "<br><button onclick='gameStartUp()'>Play Now!</button>"
	dat += "<br>"
	dat += "<button onmouseover='joystickControlOn('left')' onmouseout='joystickControlOff('left')'>MOVE<br>LEFT</button>"
	dat += "<button onmousedown='joystickControlOn('down')' onmouseup='joystickControlOff('down')'>DROP<br>CLAW</button>"
	dat += "<button onmouseover='joystickControlOn('right')' onmouseout='joystickControlOff('right')'>MOVE<br>RIGHT</button>"
	dat += "</div>"

	clawgame.set_content(dat)
	clawgame.open()
	*/
	return
