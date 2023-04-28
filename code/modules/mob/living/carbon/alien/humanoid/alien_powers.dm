/*NOTES:
These are general powers. Specific powers are stored under the appropriate alien creature type.
*/

/*Alien spit now works like a taser shot. It won't home in on the target but will act the same once it does hit.
Doesn't work on other aliens/AI.*/
#define WORLD_VIEW "15x15"

/datum/action/innate/xeno_action

/datum/action/innate/xeno_action/Activate()

/datum/action/proc/plasmacheck(X, Y)//Y is optional, checks for weed planting. X can be null.
	var/mob/living/carbon/alien/host = owner

	if(!IsAvailable())
		to_chat(host, "<span class='noticealien'>You can't do that yet.</span>")
		return 0
	if(X && host.getPlasma() < X)
		to_chat(host, "<span class='noticealien'>Not enough plasma stored.</span>")
		return 0
	if(Y && (!isturf(host.loc) || istype(host.loc, /turf/space)))
		to_chat(host, "<span class='noticealien'>You can't place that here!</span>")
		return 0
	return 1

/datum/action/innate/xeno_action/nightvisiontoggle
	name = "Toggle Night Vision"
	button_icon_state = "meson"

/datum/action/innate/xeno_action/nightvisiontoggle/Activate()
	var/mob/living/carbon/alien/host = owner

	if(!host.nightvision)
		host.see_in_dark = 8
		host.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
		host.nightvision = TRUE
		usr.hud_used.nightvisionicon.icon_state = "nightvision1"
		host.update_sight()
		return

	if(host.nightvision)
		host.see_in_dark = initial(host.see_in_dark)
		host.lighting_alpha = initial(host.lighting_alpha)
		host.nightvision = FALSE
		usr.hud_used.nightvisionicon.icon_state = "nightvision0"
		host.update_sight()
		return

/datum/action/innate/xeno_action/plant
	name = "Plant Weeds (50)"
	desc = "Plants some alien weeds"
	button_icon_state = "alien_plant"

/datum/action/innate/xeno_action/plant/Activate()
	var/mob/living/carbon/alien/host = owner

	if(locate(/obj/structure/alien/weeds/node) in get_turf(owner))
		to_chat(owner, "<span class='noticealien'>There's already a weed node here.</span>")
		return

	if(plasmacheck(50,1))
		host.adjustPlasma(-50)
		for(var/mob/O in viewers(owner, null))
			O.show_message(text("<span class='alertalien'>[owner] has planted some alien weeds!</span>"), 1)
		new /obj/structure/alien/weeds/node(owner.loc)
	return

/datum/action/innate/xeno_action/whisper
	name = "Whisper (10)"
	desc = "Whisper to someone"
	button_icon_state = "alien_whisper"

/datum/action/innate/xeno_action/whisper/Activate()
	var/mob/living/carbon/alien/host = owner

	if(!plasmacheck(10))
		return
	var/list/target_list = list()
	for(var/mob/living/possible_target in view(WORLD_VIEW, host))
		if(possible_target == host || !possible_target.client || isalien(possible_target))
			continue
		target_list += possible_target

	if(!length(target_list))
		to_chat(host, "<span class='alertalien'> There's nobody nearby to whisper to!</span>")
		return

	var/mob/living/L = input(host, "Target", "Send a Whisper to whom?", target_list) as null|anything in target_list
	if(!L)
		return

	var/msg = stripped_input("Message:", "Alien Whisper")
	if(!msg)
		return
	host.adjustPlasma(-10)
	add_say_logs(host, msg, L, "Alien Whisper")
	to_chat(L, "<span class='noticealien'>You hear a strange, alien voice in your head...<span class='noticealien'>[msg]")
	to_chat(host, "<span class='noticealien'>You said: [msg] to [L]</span>")
	for(var/mob/dead/observer/G in GLOB.player_list)
		G.show_message("<i>Alien message from <b>[host]</b> ([ghost_follow_link(host, ghost=G)]) to <b>[L]</b> ([ghost_follow_link(L, ghost=G)]): [msg]</i>")

/datum/action/innate/xeno_action/transfer_plasma
	name = "Transfer Plasma"
	desc = "Transfer Plasma to another alien"
	button_icon_state = "alien_transfer"

/datum/action/innate/xeno_action/transfer_plasma/Activate()
	var/mob/living/carbon/alien/host = owner

	var/list/target_list = list()
	for(var/mob/living/carbon/alien/possible_target in oview(WORLD_VIEW, host))
		target_list += possible_target


	if(!length(target_list))
		to_chat(host, "<span class='alertalien'> There's nobody nearby to transfer plasma to!</span>")
		return

	var/mob/living/carbon/alien/L = input(host, "Target", "Send a plasma to whom?", target_list) as null|anything in target_list
	if(!L)
		return

	var/amount = input("Amount:", "Transfer Plasma to [L]") as num
	if(amount)
		amount = abs(round(amount))
		if(plasmacheck(amount))
			if(get_dist(host,L) <= 1)
				L.adjustPlasma(amount)
				host.adjustPlasma(-amount)
				to_chat(L, "<span class='noticealien'>[host] has transfered [amount] plasma to you.</span>")
				to_chat(host, {"<span class='noticealien'>You have trasferred [amount] plasma to [L]</span>"})
			else
				to_chat(host, "<span class='noticealien'>You need to be closer.</span>")
	return

/datum/action/innate/xeno_action/corrosive_acid
	name = "Corrossive Acid (200)"
	desc = "Drench an object in acid, destroying it over time."
	button_icon_state = "alien_acid"

/datum/action/innate/xeno_action/corrosive_acid/Activate(var/atom/target)
	var/mob/living/carbon/alien/host = owner

	if(!plasmacheck(200))
		return

	if(target)
		if(!(owner.Adjacent(target)))
			to_chat(host, "<span class='alertalien'> Target is too far away!</span>")
			return
		if(target.acid_act(200, 100))
			host.visible_message("<span class='alertalien'>[host] vomits globs of vile stuff all over [target]. It begins to sizzle and melt under the bubbling mess of acid!</span>")
			host.adjustPlasma(-200)
			return

	var/list/target_list = list()
	for(var/atom/possible_target in oview(1, host))
		if(!(isitem(possible_target) || isstructure(possible_target) || iswallturf(possible_target) || ismachinery(possible_target)))
			continue
		if(owner.Adjacent(possible_target))
			target_list += possible_target

	if(!length(target_list))
		to_chat(host, "<span class='alertalien'> There's nothing to melt!</span>")
		return

	var/atom/L = input(host, "Target", "What to melt?", target_list) as null|anything in target_list
	if(!L)
		return

	if(L.acid_act(200, 100))
		host.visible_message("<span class='alertalien'>[host] vomits globs of vile stuff all over [L]. It begins to sizzle and melt under the bubbling mess of acid!</span>")
		host.adjustPlasma(-200)
	else
		to_chat(src, "<span class='noticealien'>You cannot dissolve this object.</span>")

/obj/effect/proc_holder/spell/neurotoxin
	name = "Spit Neurotoxin (50)"
	desc = "Spits neurotoxin at someone, paralyzing them for a short time."
	action_icon_state = "alien_neurotoxin"
	action_background_icon_state = "bg_default"
	clothes_req = FALSE
	charge_max = 5

/obj/effect/proc_holder/spell/neurotoxin/Click()
	if(cast_check())
		if(active)
			remove_ranged_ability(usr, "<span class='alertalien'>You relax your neurotoxin gland...</span>")
		else
			add_ranged_ability(usr, "<span class='alertalien'>You prepare to spit a neurotoxin...</span>")
	return

/obj/effect/proc_holder/spell/neurotoxin/cast_check()
	if(!can_cast())
		return FALSE
	if(action)
		action.UpdateButtonIcon()
	return TRUE

/obj/effect/proc_holder/spell/neurotoxin/can_cast(mob/user = usr)
	if(is_admin_level(user.z) && !centcom_cancast) //Certain spells are not allowed on the centcom zlevel
		return FALSE

	if(charge_counter < charge_max)
		return FALSE

	if(user.stat)
		return FALSE

	return TRUE

/obj/effect/proc_holder/spell/neurotoxin/InterceptClickOn(mob/living/user, params, atom/target)
	if(..())
		return

	if(action.plasmacheck(50))
		var/mob/living/carbon/alien/host = user
		host.adjustPlasma(-50)
		host.visible_message("<span class='danger'>[host] spits neurotoxin!", "<span class='alertalien'>You spit neurotoxin.</span>")

		var/turf/T = host.loc
		var/turf/U = get_step(host, host.dir) // Get the tile infront of the move, based on their direction
		if(!isturf(U) || !isturf(T))
			return FALSE

		var/obj/item/projectile/bullet/neurotoxin/P = new(usr.loc)
		P.current = get_turf(host)
		P.preparePixelProjectile(target, get_turf(target), host)
		P.fire()
		host.newtonian_move(get_dir(U, T))
		charge_counter = 0
		start_recharge()
	return

/datum/action/innate/xeno_action/resin // -- TLE
	name = "Secrete Resin (55)"
	desc = "Secrete tough malleable resin."
	button_icon_state = "alien_resin"

/datum/action/innate/xeno_action/resin/Activate()
	var/mob/living/carbon/alien/host = owner

	if(plasmacheck(55))
		var/choice = input("Choose what you wish to shape.","Resin building") as null|anything in list("resin wall","resin membrane","resin nest") //would do it through typesof but then the player choice would have the type path and we don't want the internal workings to be exposed ICly - Urist

		if(!choice || !plasmacheck(55))	return
		var/turf/T = get_turf(host.loc)
		if(locate(/obj/structure/alien/resin) in T.contents || locate(/obj/structure/bed/nest) in T.contents)
			to_chat(host, "<span class ='warning'>Это место уже занято!</span>")
			return
		host.adjustPlasma(-55)
		for(var/mob/O in viewers(host, null))
			O.show_message(text("<span class='alertalien'>[host] vomits up a thick purple substance and shapes it!</span>"), 1)
		switch(choice)
			if("resin wall")
				new /obj/structure/alien/resin/wall(host.loc)
			if("resin membrane")
				new /obj/structure/alien/resin/membrane(host.loc)
			if("resin nest")
				new /obj/structure/bed/nest(host.loc)
	return

/datum/action/innate/xeno_action/regurgitate
	name = "Regurgitate"
	desc = "Empties the contents of your stomach"
	button_icon_state = "alien_barf"

/datum/action/innate/xeno_action/regurgitate/Activate()
	var/mob/living/carbon/alien/host = owner

	if(plasmacheck())
		if(LAZYLEN(host.stomach_contents))
			for(var/mob/M in host)
				LAZYREMOVE(host.stomach_contents, M)
				M.forceMove(host.drop_location())
			host.visible_message("<span class='alertalien'><B>[host] hurls out the contents of [p_their()] stomach!</span>")

/mob/living/carbon/proc/getPlasma()
 	var/obj/item/organ/internal/xenos/plasmavessel/vessel = get_int_organ(/obj/item/organ/internal/xenos/plasmavessel)
 	if(!vessel) return 0
 	return vessel.stored_plasma


/mob/living/carbon/proc/adjustPlasma(amount)
 	var/obj/item/organ/internal/xenos/plasmavessel/vessel = get_int_organ(/obj/item/organ/internal/xenos/plasmavessel)
 	if(!vessel) return
 	vessel.stored_plasma = max(vessel.stored_plasma + amount,0)
 	vessel.stored_plasma = min(vessel.stored_plasma, vessel.max_plasma) //upper limit of max_plasma, lower limit of 0
 	return 1

/mob/living/carbon/alien/adjustPlasma(amount)
	. = ..()
	updatePlasmaDisplay()

/mob/living/carbon/proc/usePlasma(amount)
	if(getPlasma() >= amount)
		adjustPlasma(-amount)
		return 1

	return 0

#undef WORLD_VIEW
