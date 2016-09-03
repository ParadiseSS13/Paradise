
/obj/effect/nanomob
	name = "Nano-Mob Avatar"					//will be overridden by the mob datum name value when created
	desc = "A wild Nano-Mob appeared! Hit it with your PDA with the game open to attempt to capture it!"
	alpha = 128
	invisibility = 101							//normally invisible, this gets adjusted through the game's scanning
	anchored = 1								//just in case
	density = 0
	icon = 'icons/effects/mob_hunt.dmi'
	//icon_state gets set in New() because it is determined by the mob_hunt datum being used
	var/datum/mob_hunt/mob_info = null
	var/list/clients_encountered = list()		//tracks who has already interacted with us, so they can't attempt a second capture

/obj/effect/nanomob/New(loc, datum/mob_hunt/new_info)
	if(!new_info)
		qdel(src)
		return
	mob_info = new_info
	name = mob_info.mob_name
	if(mob_info.is_shiny)
		icon_state = mob_info.icon_state_shiny
	else
		icon_state = mob_info.icon_state_normal
	if(!mob_info.is_trap)
		addtimer(src, "despawn", mob_info.lifetime)

/obj/effect/nanomob/attackby(obj/item/O, mob/user)
	if(istype(O, /obj/item/device/pda))
		var/obj/item/device/pda/P = O
		if(P.current_app && P.current_app == /datum/data/pda/app/mob_hunter_game)
			attempt_capture(P)
			return 1

/obj/effect/nanomob/hitby(obj/item/O)
	if(istype(O, /obj/item/device/pda))
		var/obj/item/device/pda/P = O
		if(P.current_app && P.current_app == /datum/data/pda/app/mob_hunter_game)
			attempt_capture(P)
			return 1

/obj/effect/nanomob/proc/attempt_capture(obj/item/device/pda/P)
	if(!P || !P.current_app || !istype(P.current_app, /datum/data/pda/app/mob_hunter_game) || !P.cartridge)
		return

	var/datum/data/pda/app/mob_hunter_game/client = P.current_app

	if(mob_info.is_trap)		//traps work even if you ran into them before
		if(istype(P.loc, /mob/living/carbon))
			var/mob/living/carbon/C = P.loc
			//Strike them down with a lightning bolt to complete the illusion (copied from the surge reagent overdose, probably could
			playsound(get_turf(C), 'sound/effects/eleczap.ogg', 75, 1)
			var/icon/I=new('icons/obj/zap.dmi',"lightningend")
			I.Turn(-135)
			var/obj/effect/overlay/beam/B = new(get_turf(C))
			B.pixel_x = rand(-20, 0)
			B.pixel_y = rand(-20, 0)
			B.icon = I
			//then actually do the damage/stun
			C.electrocute_act(20, P, 1)		//same damage as a revenant's overload ability, except subject to gloves/species shock resistance (for human mobs at least)
		return

	var/obj/item/weapon/cartridge/cartridge = P.cartridge
	var/cart_ref = "\ref[cartridge]"
	if(cart_ref in clients_encountered)	//we've already dealt with you, go away!
		return
	else	//deal with the new hunter by either running away or getting caught
		clients_encountered += cart_ref
		var/message = "[bicon(P)] "
		if(mob_info.run_chance && prob(mob_info.run_chance))
			message += "Capture failed! [name] escaped [P.owner ? "from [P.owner]" : "from this hunter"]!"
		else
			if(client.register_capture(mob_info))
				message += "Capture success! [P.owner ? P.owner : "This hunter"] captured [name]!"
			else
				message += "Capture error! Try again."
				clients_encountered -= cart_ref		//if the capture registration failed somehow, let them have another chance with this mob
		for(var/mob/O in hearers(4, P.loc))
			O.show_message(message)

/obj/effect/nanomob/proc/despawn()
	if(mob_hunt_server)
		if(mob_info.is_trap)
			mob_hunt_server.trap_spawns -= src
			mob_hunt_server.check_stability()
		else
			mob_hunt_server.normal_spawns -= src
	qdel(src)