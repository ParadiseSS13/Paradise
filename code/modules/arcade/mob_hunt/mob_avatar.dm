
/obj/effect/nanomob
	name = "Nano-Mob Avatar"					//will be overridden by the mob datum name value when created
	desc = "A wild Nano-Mob appeared! Hit it with your PDA with the game open to attempt to capture it!"
	invisibility = 101
	alpha = 128
	anchored = 1								//just in case
	density = 0
	icon = 'icons/effects/mob_hunt.dmi'
	var/state_name
	var/datum/mob_hunt/mob_info = null
	var/list/clients_encountered = list()		//tracks who has already interacted with us, so they can't attempt a second capture
	var/image/avatar

/obj/effect/nanomob/New(loc, datum/mob_hunt/new_info)
	..()
	if(!new_info)
		qdel(src)
		return
	mob_info = new_info
	update_self()
	forceMove(mob_info.spawn_point)
	if(!mob_info.is_trap)
		addtimer(CALLBACK(src, .proc/despawn), mob_info.lifetime)

/obj/effect/nanomob/proc/update_self()
	if(!mob_info)
		return
	name = mob_info.mob_name
	desc = "A wild [name] (level [mob_info.level]) appeared! Hit it with your PDA with the game open to attempt to capture it!"
	if(mob_info.is_shiny)
		state_name = mob_info.icon_state_shiny
	else
		state_name = mob_info.icon_state_normal
	avatar = image(icon, src, state_name)
	avatar.override = 1
	add_alt_appearance("nanomob_avatar", avatar)

/obj/effect/nanomob/attackby(obj/item/O, mob/user)
	if(istype(O, /obj/item/pda))
		var/obj/item/pda/P = O
		attempt_capture(P, -20)		//attempting a melee capture reduces the mob's effective run_chance by 20% to balance the risk of triggering a trap mob
		return 1

/obj/effect/nanomob/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(istype(AM, /obj/item/pda))
		var/obj/item/pda/P = AM
		attempt_capture(P)			//attempting a ranged capture does not affect the mob's effective run_chance but does prevent you from being shocked by a trap mob
		return 1

/obj/effect/nanomob/proc/attempt_capture(obj/item/pda/P, catch_mod = 0)		//negative catch_mods lower effective run chance,
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
		if(iscarbon(P.loc))
			var/mob/living/carbon/C = P.loc
			//Strike them down with a lightning bolt to complete the illusion (copied from the surge reagent overdose, probably could make this a general-use proc in the future)
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

	if(client in clients_encountered)	//we've already dealt with you, go away!
		return
	else	//deal with the new hunter by either running away or getting caught
		clients_encountered += client
		var/message = "[bicon(P)] "
		var/effective_run_chance = mob_info.run_chance + total_catch_mod
		if((effective_run_chance > 0) && prob(effective_run_chance))
			message += "Capture failed! [name] escaped [P.owner ? "from [P.owner]" : "from this hunter"]!"
			conceal(client)
		else
			if(client.register_capture(mob_info, 1))
				message += "Capture success! [P.owner ? P.owner : "This hunter"] captured [name]!"
				conceal(client)
			else
				message += "Capture error! Try again."
				clients_encountered -= client		//if the capture registration failed somehow, let them have another chance with this mob
		P.audible_message(message, null, 4)

/obj/effect/nanomob/proc/despawn()
	if(SSmob_hunt)
		if(mob_info.is_trap)
			SSmob_hunt.trap_spawns -= src
		else
			SSmob_hunt.normal_spawns -= src
	qdel(src)

/obj/effect/nanomob/proc/reveal()
	if(!SSmob_hunt)
		return
	var/list/show_to = list()
	for(var/A in SSmob_hunt.connected_clients)
		if((A in clients_encountered) || !SSmob_hunt.connected_clients[A])
			continue
		show_to |= SSmob_hunt.connected_clients[A]
	display_alt_appearance("nanomob_avatar", show_to)

/obj/effect/nanomob/proc/conceal(list/hide_from)
	if(!SSmob_hunt)
		return
	var/list/hiding_from = list()
	if(hide_from)
		hiding_from = hide_from
	else
		for(var/A in SSmob_hunt.connected_clients)
			if((A in clients_encountered) && SSmob_hunt.connected_clients[A])
				hiding_from |= SSmob_hunt.connected_clients[A]
	hide_alt_appearance("nanomob_avatar", hiding_from)

//		BATTLE MOB AVATARS

/obj/effect/nanomob/battle
	name = "Nano-Mob Battle Avatar"
	desc = "A new challenger approaches!"
	invisibility = 0
	icon_state = "placeholder"
	var/obj/machinery/computer/mob_battle_terminal/my_terminal

/obj/effect/nanomob/battle/New(loc, datum/mob_hunt/new_info)
	if(new_info)
		mob_info = new_info
		update_self()

/obj/effect/nanomob/battle/update_self()
	if(!mob_info)
		name = "Nano-Mob Battle Avatar"
		desc = "A new challenger approaches"
		icon_state = "placeholder"
	else
		name = mob_info.mob_name
		desc = "A tamed [name] (level [mob_info.level]) ready for battle!"
		if(mob_info.is_shiny)
			icon_state = mob_info.icon_state_shiny
		else
			icon_state = mob_info.icon_state_normal

/obj/effect/nanomob/battle/attempt_capture(obj/item/pda/P, catch_mod = 0)
	//you can't capture battle avatars, since they belong to someone already
	return

//battle avatars are always visible, so we can ignore reveal and conceal calls for them
/obj/effect/nanomob/battle/reveal()
	return

/obj/effect/nanomob/battle/conceal()
	return
