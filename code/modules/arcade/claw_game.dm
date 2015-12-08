
/obj/machinery/arcade/claw
	name = "Claw Game"
	desc = "One of the most infuriating ways to win a toy."
	icon = 'icons/obj/arcade.dmi'
	icon_state = "clawmachine_on"
	token_price = 15
	var/bonus_prize_chance = 5		//chance to dispense a SECOND prize if you win, increased by matter bin rating

	//This is to make sure the images are available
	var/list/img_resources = list('icons/obj/arcade_images/backgroundsprite.png',
								'icons/obj/arcade_images/clawpieces.png',
								'icons/obj/arcade_images/crane_bot.png',
								'icons/obj/arcade_images/crane_top.png',
								'icons/obj/arcade_images/prize_inside.png',
								'icons/obj/arcade_images/prizeorbs.png')

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
	usr << "YOU WIN!"
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
	if(!tokens && !freeplay)
		user << "The game doesn't have enough credits to play! Pay first!"
		return
	if(!playing && tokens)
		user.set_machine(src)
		playing = 1
		if(!freeplay)
			tokens -= 1
	if(playing && (src != user.machine))
		user << "Someone else is already playing, please wait your turn!"
		return

	user << browse_rsc('page.css')
	for(var/i=1, i<=img_resources.len, i++)
		user << browse_rsc(img_resources[i])
	user << browse('crane.html', "window=Claw Game;size=600x600")
	return

/obj/machinery/arcade/claw/Topic(href, list/href_list)
	if(..())
		return
	if(href_list["prizeWon"])
		usr << browse(null, "window=Claw Game")	//just in case
		win()
