
/obj/effect/nanomob
	name = "Nano-Mob Avatar"					//will be overridden by the mob datum name value when created
	desc = "A wild Nano-Mob appeared! Hit it with your PDA with the game open to attempt to capture it!"
	invisibility = 101							//normally invisible, this gets adjusted through the game's scanning
	alpha = 128
	anchored = 1								//just in case
	density = 0
	icon = 'icons/effects/mob_hunt.dmi'
	//icon_state gets set in New() because it is determined by the mob_hunt datum being used
	var/datum/mob_hunt/mob_info = null
	var/list/clients_encountered = list()		//tracks who has already interacted with us, so they can't attempt a second capture

/obj/effect/nanomob/New(loc, datum/mob_hunt/new_info)
	..()
	if(!new_info)
		qdel(src)
		return
	mob_info = new_info
	update_self()
	forceMove(mob_info.spawn_point)
	if(!mob_info.is_trap)
		addtimer(src, "despawn", mob_info.lifetime)

/obj/effect/nanomob/proc/update_self()
	if(!mob_info)
		return
	name = mob_info.mob_name
	desc = "A wild [name] (level [mob_info.level]) appeared! Hit it with your PDA with the game open to attempt to capture it!"
	if(mob_info.is_shiny)
		icon_state = mob_info.icon_state_shiny
	else
		icon_state = mob_info.icon_state_normal

/obj/effect/nanomob/attackby(obj/item/O, mob/user)
	if(invisibility)	//no catching mobs you can't normally see!
		return
	if(istype(O, /obj/item/device/pda))
		var/obj/item/device/pda/P = O
		attempt_capture(P, -20)		//attempting a melee capture reduces the mob's effective run_chance by 20% to balance the risk of triggering a trap mob
		return 1

/obj/effect/nanomob/hitby(obj/item/O)
	if(invisibility)	//no catching mobs you can't normally see!
		return
	if(istype(O, /obj/item/device/pda))
		var/obj/item/device/pda/P = O
		attempt_capture(P)			//attempting a ranged capture does not affect the mob's effective run_chance but does prevent you from being shocked by a trap mob
		return 1

/obj/effect/nanomob/proc/attempt_capture(obj/item/device/pda/P, catch_mod = 0)		//negative catch_mods lower effective run chance,
	if(!P || !P.current_app || !istype(P.current_app, /datum/data/pda/app/mob_hunter_game) || !P.cartridge)
		return

	var/datum/data/pda/app/mob_hunter_game/client = P.current_app
	var/total_catch_mod = client.catch_mod + catch_mod		//negative values decrease the chance of the mob running, positive values makes it more likely to flee
	if(!client.connected)	//must be connected to attempt captures
		P.audible_message("[bicon(P)] No server connection. Capture aborted.", null, 4)
		return

	if(mob_info.is_trap)		//traps work even if you ran into them before, which is why this is before the clients_encountered check
		if(client.hacked)		//hacked copies of the game (copies capable of setting traps) are protected from traps
			return
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
		var/effective_run_chance = mob_info.run_chance + total_catch_mod
		if((effective_run_chance > 0) && prob(effective_run_chance))
			message += "Capture failed! [name] escaped [P.owner ? "from [P.owner]" : "from this hunter"]!"
		else
			if(client.register_capture(mob_info, 1))
				message += "Capture success! [P.owner ? P.owner : "This hunter"] captured [name]!"
			else
				message += "Capture error! Try again."
				clients_encountered -= cart_ref		//if the capture registration failed somehow, let them have another chance with this mob
		P.audible_message(message, null, 4)

/obj/effect/nanomob/proc/despawn()
	if(mob_hunt_server)
		if(mob_info.is_trap)
			mob_hunt_server.trap_spawns -= src
			mob_hunt_server.check_stability()
		else
			mob_hunt_server.normal_spawns -= src
	qdel(src)

/obj/effect/nanomob/proc/reveal()
	if(invisibility == 101)
		invisibility = 0
		spawn(30)
			if(src)
				invisibility = 101
