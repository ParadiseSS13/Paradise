/*NOTES:
These are general powers. Specific powers are stored under the appropriate alien creature type.
*/

/*Alien spit now works like a taser shot. It won't home in on the target but will act the same once it does hit.
Doesn't work on other aliens/AI.*/
#define WORLD_VIEW "15x15"

/datum/action/innate/xeno_action
	background_icon_state = "bg_alien"

/datum/action/innate/xeno_action/Activate()


/**
 * `turf_check` is optional, checks for weed planting.
 * `plasma_amount` can be null.
 */
/datum/action/proc/plasmacheck(plasma_amount, turf_check)
	var/mob/living/carbon/alien/host = owner

	if(!IsAvailable())
		to_chat(host, span_noticealien("You can't do that yet."))
		return FALSE

	if(plasma_amount && host.getPlasma() < plasma_amount)
		to_chat(host, span_noticealien("Not enough plasma stored."))
		return FALSE

	if(turf_check && (!isturf(host.loc) || istype(host.loc, /turf/space)))
		to_chat(host, span_noticealien("You can't place that here!"))
		return FALSE

	return TRUE


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

/obj/effect/proc_holder/spell/xeno_plant
	name = "Plant Weeds (50)"
	desc = "Plants some alien weeds"
	action_icon_state = "alien_plant"
	action_background_icon_state = "bg_alien"
	clothes_req = FALSE
	charge_max = 10 SECONDS
	var/no_plasma = FALSE

/obj/effect/proc_holder/spell/xeno_plant/Click()
	if(cast_check())
		var/mob/living/carbon/alien/host = action?.owner
		if(!host)
			return

		if(locate(/obj/structure/alien/weeds/node) in get_turf(host))
			to_chat(host, "<span class='noticealien'>There's already a weed node here.</span>")
			return

		if(action.plasmacheck(no_plasma? 0 : 50, 1))
			host.adjustPlasma(-50)
			for(var/mob/O in viewers(host, null))
				O.show_message(text("<span class='alertalien'>[host] has planted some alien weeds!</span>"), 1)
			new /obj/structure/alien/weeds/node(host.loc)
			playsound_xenobuild(host)
			charge_counter = 0
			start_recharge()
	return

/obj/effect/proc_holder/spell/xeno_plant/cast_check()
	if(!can_cast())
		return FALSE
	if(action)
		action.UpdateButtonIcon()
	return TRUE

/obj/effect/proc_holder/spell/xeno_plant/can_cast(mob/user)
	if(charge_counter < charge_max)
		return FALSE
	return TRUE

/obj/effect/proc_holder/spell/xeno_plant/queen
	name = "Plant Weeds"
	no_plasma = TRUE

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
	name = "Corrossive Acid"
	desc = "Drench an object in acid, destroying it over time."
	button_icon_state = "alien_acid"
	var/cost = 200
	var/acid_power = 400

/datum/action/innate/xeno_action/corrosive_acid/sentinel
	cost = 150

/datum/action/innate/xeno_action/corrosive_acid/praetorian
	cost = 100

/datum/action/innate/xeno_action/corrosive_acid/queen
	cost = 50
	acid_power = 1000

/datum/action/innate/xeno_action/corrosive_acid/New()
	name = "[name] ([cost])"
	..()

/datum/action/innate/xeno_action/corrosive_acid/Activate(var/atom/target)
	var/mob/living/carbon/alien/host = owner

	if(!plasmacheck(cost))
		return

	if(target)
		if(!(owner.Adjacent(target)))
			to_chat(host, "<span class='alertalien'> Target is too far away!</span>")
			return
		if(target.acid_act(acid_power, 100))
			host.visible_message("<span class='alertalien'>[host] vomits globs of vile stuff all over [target]. It begins to sizzle and melt under the bubbling mess of acid!</span>")
			host.adjustPlasma(-cost)
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

	if(L.acid_act(acid_power, 100))
		host.visible_message("<span class='alertalien'>[host] vomits globs of vile stuff all over [L]. It begins to sizzle and melt under the bubbling mess of acid!</span>")
		host.adjustPlasma(-cost)
	else
		to_chat(src, "<span class='noticealien'>You cannot dissolve this object.</span>")

/obj/effect/proc_holder/spell/neurotoxin
	name = "Spit Neurotoxin (50)"
	desc = "Spits neurotoxin at someone, paralyzing them for a short time."
	action_icon_state = "alien_neurotoxin"
	action_background_icon_state = "bg_alien"
	clothes_req = FALSE
	charge_max = 0.5 SECONDS
	can_select = TRUE

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
		P.preparePixelProjectile(target, get_turf(target), host, params)
		P.fire()
		host.newtonian_move(get_dir(U, T))
		charge_counter = 0
		start_recharge()
	return


/// Defines include required plasma in brackets
#define ALIEN_RESIN_WALL		"Resin Wall (60)"
#define ALIEN_RESIN_DOOR		"Resin Door (50)"
#define ALIEN_RESIN_MEMBRANE	"Resin Membrane (40)"
#define ALIEN_RESIN_NEST		"Resin Nest (30)"


/datum/action/innate/xeno_action/resin
	name = "Secrete Resin"
	desc = "Secrete tough malleable resin (Use Ctrl+Click on self)."
	button_icon_state = "alien_resin"
	check_flags = AB_CHECK_RESTRAINED | AB_CHECK_STUNNED | AB_CHECK_LYING | AB_CHECK_CONSCIOUS | AB_CHECK_TURF
	var/in_process = FALSE
	COOLDOWN_DECLARE(last_used_xeno_resin)


/datum/action/innate/xeno_action/resin/Activate()
	var/mob/living/carbon/alien/host = owner

	if(in_process)
		to_chat(host, span_noticealien("Ability is already in use!"))
		return

	if(!COOLDOWN_FINISHED(src, last_used_xeno_resin))
		to_chat(host, span_noticealien("Ability is still recharging!"))
		return

	var/list/resin_params = list()

	resin_params["Plasma Amount"] = list(
		ALIEN_RESIN_WALL 		= 60,
		ALIEN_RESIN_DOOR 		= 50,
		ALIEN_RESIN_MEMBRANE 	= 40,
		ALIEN_RESIN_NEST 		= 30
	)

	resin_params["Process Time"] = list(
		ALIEN_RESIN_WALL 		= 2 SECONDS,
		ALIEN_RESIN_DOOR 		= 5 SECONDS,
		ALIEN_RESIN_MEMBRANE 	= 2 SECONDS,
		ALIEN_RESIN_NEST 		= 1 SECONDS
	)

	resin_params["Cooldown"] = list(
		ALIEN_RESIN_WALL 		= 3 SECONDS,
		ALIEN_RESIN_DOOR 		= 10 SECONDS,
		ALIEN_RESIN_MEMBRANE 	= 3 SECONDS,
		ALIEN_RESIN_NEST 		= 2 SECONDS
	)

	resin_params["Structure"] = list(
		ALIEN_RESIN_WALL 		= /obj/structure/alien/resin/wall,
		ALIEN_RESIN_DOOR 		= /obj/structure/alien/resin/door,
		ALIEN_RESIN_MEMBRANE 	= /obj/structure/alien/resin/membrane,
		ALIEN_RESIN_NEST 		= /obj/structure/bed/nest
	)

	resin_params["Image"] = list(
		ALIEN_RESIN_WALL		= image(icon = 'icons/obj/smooth_structures/alien/resin_wall.dmi', icon_state = "resin"),
		ALIEN_RESIN_DOOR		= image(icon = 'icons/obj/smooth_structures/alien/resin_door.dmi', icon_state = "resin_door_closed"),
		ALIEN_RESIN_MEMBRANE 	= image(icon = 'icons/obj/smooth_structures/alien/resin_membrane.dmi', icon_state = "membrane"),
		ALIEN_RESIN_NEST 		= image(icon = 'icons/mob/alien.dmi', icon_state = "nest")
	)

	var/choice = show_radial_menu(host, host, resin_params["Image"], custom_check = CALLBACK(src, PROC_REF(check_availability), host))

	if(!choice || !check_availability(host, resin_params["Plasma Amount"][choice]))
		return

	host.visible_message(span_warning("[host] starts vomitting purple substance on the surface!"), \
		span_notice("You start vomitting resin for future use."))

	in_process = TRUE
	if(!do_after(host, resin_params["Process Time"][choice], target = host))
		in_process = FALSE
		return
	in_process = FALSE

	if(!check_availability(host, resin_params["Plasma Amount"][choice]))
		return

	COOLDOWN_START(src, last_used_xeno_resin, resin_params["Cooldown"][choice])
	host.adjustPlasma(-(resin_params["Plasma Amount"][choice]))

	var/build_path = resin_params["Structure"][choice]
	var/obj/alien_structure = new build_path(host.loc)

	playsound_xenobuild(alien_structure)
	host.visible_message(span_warning("[host] vomits up a thick purple substance and shapes it into the [alien_structure.name]!"), \
		span_alertalien("You finished shaping vomited resin into the [alien_structure.name]."))


/datum/action/innate/xeno_action/resin/proc/check_availability(mob/living/carbon/user, plasma_amount)
	if(!istype(user))
		return FALSE

	if(QDELETED(user) || QDELETED(src))
		return FALSE

	if(!plasmacheck(plasma_amount, turf_check = TRUE))
		return FALSE

	if(user.incapacitated())
		to_chat(user, span_noticealien("You can't do this right now!"))
		return FALSE

	var/turf/source_turf = get_turf(user)
	if((locate(/obj/structure/alien/resin) in source_turf.contents) || (locate(/obj/structure/bed/nest) in source_turf.contents))
		to_chat(user, span_noticealien("This place is already occupied!"))
		return FALSE

	return TRUE


/mob/living/carbon/alien/humanoid/CtrlClick(mob/living/carbon/alien/humanoid/alien)
	if(!istype(alien) || usr != alien)
		return

	var/datum/action/innate/xeno_action/resin/resin = locate() in alien.actions
	if(!resin)
		return

	resin.Activate()


#undef ALIEN_RESIN_WALL
#undef ALIEN_RESIN_DOOR
#undef ALIEN_RESIN_MEMBRANE
#undef ALIEN_RESIN_NEST


/datum/action/innate/xeno_action/break_vents
	name = "Break Welded Vent"
	icon_icon = 'icons/obj/pipes_and_stuff/atmospherics/atmos/vent_pump.dmi'
	button_icon_state = "map_vent"

/datum/action/innate/xeno_action/break_vents/Activate()
	var/mob/living/carbon/alien/host = owner

	var/obj/machinery/atmospherics/unary/vent_pump/pump_target
	var/obj/machinery/atmospherics/unary/vent_scrubber/scrubber_target
	for(var/obj/machinery/atmospherics/unary/vent_pump/P in range(1, get_turf(host)))
		if(P.welded)
			pump_target = P
			break
	for(var/obj/machinery/atmospherics/unary/vent_scrubber/S in range(1, get_turf(host)))
		if(S.welded)
			scrubber_target = S
			break
	if(!pump_target && !scrubber_target)
		to_chat(host, "<span class='warning'>No welded vent or scrubber nearby!</span>")
		return
	playsound(get_turf(host),'sound/weapons/bladeslice.ogg' , 100, 0)
	if(do_after(host, 4 SECONDS, target = (pump_target? pump_target.loc : scrubber_target.loc)))
		playsound(get_turf(host),'sound/weapons/bladeslice.ogg' , 100, 0)
		if(pump_target?.welded)
			pump_target.welded = 0
			pump_target.update_icon()
			pump_target.update_pipe_image()
			host.forceMove(pump_target.loc)
			pump_target.visible_message("<span class='danger'>[host] smashes the welded cover off [pump_target]!</span>")
			return
		if(scrubber_target?.welded)
			scrubber_target.welded = 0
			scrubber_target.update_icon()
			scrubber_target.update_pipe_image()
			host.forceMove(scrubber_target.loc)
			scrubber_target.visible_message("<span class='danger'>[host] smashes the welded cover off [scrubber_target]!</span>")
			return

		to_chat(host, "<span class='danger'>There is no welded vent or scrubber close enough to do this.</span>")

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


/proc/playsound_xenobuild(object)
	var/turf/object_turf = get_turf(object)

	if(!object_turf)
		return

	playsound(object_turf, pick('sound/creatures/alien/xeno_resin_build1.ogg', \
								'sound/creatures/alien/xeno_resin_build2.ogg', \
								'sound/creatures/alien/xeno_resin_build3.ogg'), 30)


#undef WORLD_VIEW
