/mob/living/simple_animal
	name = "animal"
	icon = 'icons/mob/animal.dmi'
	health = 20
	maxHealth = 20
	gender = PLURAL //placeholder

	universal_understand = TRUE
	universal_speak = FALSE
	status_flags = CANPUSH

	var/icon_living = ""
	var/icon_dead = ""
	var/icon_resting = ""
	/// We only try to show a gibbing animation if this exists.
	var/icon_gib = null
	/// Flip the sprite upside down on death. Mostly here for things lacking custom dead sprites.
	var/flip_on_death = FALSE

	var/list/speak = list()
	var/speak_chance = 0
	/// Hearable emotes
	var/list/emote_hear = list()
	/// Unlike speak_emote, the list of things in this variable only show by themselves with no spoken text. IE: Ian barks, Ian yaps
	var/list/emote_see = list()

	var/turns_per_move = 1
	var/turns_since_move = 0
	/// Use this to temporarely stop random movement or to if you write special movement code for animals.
	var/stop_automated_movement = FALSE
	/// Does the mob wander around when idle?
	var/wander = TRUE
	/// When set to TRUE this stops the animal from moving when someone is pulling it.
	var/stop_automated_movement_when_pulled = TRUE

	//Interaction
	var/response_help   = "pokes"
	var/response_disarm = "shoves"
	var/response_harm   = "hits"
	var/harm_intent_damage = 3
	/// Minimum force required to deal any damage
	var/force_threshold = 0

	//Temperature effect
	var/minbodytemp = 250
	var/maxbodytemp = 350
	/// Amount of damage applied if animal's body temperature is higher than maxbodytemp
	var/heat_damage_per_tick = 2
	/// Same as heat_damage_per_tick, only if the bodytemperature it's lower than minbodytemp
	var/cold_damage_per_tick = 2
	/// If the mob can catch fire
	var/can_be_on_fire = FALSE
	/// Damage the mob will take if it is on fire
	var/fire_damage = 2

	/// Healable by medical stacks? Defaults to yes.
	var/healable = TRUE

	/// Atmos effect - Yes, you can make creatures that require plasma or co2 to survive. N2O is a trace gas and handled separately, hence why it isn't here. It'd be hard to add it. Hard and me don't mix (Yes, yes make all the dick jokes you want with that.) - Errorage
	var/list/atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0) //Leaving something at 0 means it's off - has no maximum
	/// This damage is taken when atmos doesn't fit all the requirements above
	var/unsuitable_atmos_damage = 2

	/// LETTING SIMPLE ANIMALS ATTACK? WHAT COULD GO WRONG. Defaults to zero so Ian can still be cuddly
	var/melee_damage_lower = 0
	var/melee_damage_upper = 0
	/// How much damage this simple animal does to objects, if any
	var/obj_damage = 0
	/// Flat armour reduction, occurs after percentage armour penetration.
	var/armour_penetration_flat = 0
	/// Percentage armour reduction, happens before flat armour reduction.
	var/armour_penetration_percentage = 0
	/// Damage type of a simple mob's melee attack, should it do damage.
	var/melee_damage_type = BRUTE
	/// 1 for full damage , 0 for none , -1 for 1:1 heal from that source
	var/list/damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
	var/attacktext = "attacks"
	var/attack_sound = null
	/// If the mob does no damage with it's attack
	var/friendly = "nuzzles"
	/// Set to 1 to allow breaking of crates,lockers,racks,tables; 2 for walls; 3 for Rwalls
	var/environment_smash = ENVIRONMENT_SMASH_NONE

	/// Higher speed is slower, negative speed is faster
	var/speed = 1
	var/can_hide = FALSE
	/// Allows a mob to pass unbolted doors while hidden
	var/pass_door_while_hidden = FALSE

	var/obj/item/petcollar/pcollar = null
	/// If the mob has collar sprites, define them.
	var/collar_type
	/// If the mob can be renamed
	var/unique_pet = FALSE
	/// Can add collar to mob or not
	var/can_collar = FALSE

	/// Hot simple_animal baby making vars
	var/list/childtype = null
	var/next_scan_time = 0
	/// Sorry, no spider+corgi buttbabies.
	var/animal_species
	var/current_offspring = 0
	var/max_offspring = DEFAULT_MAX_OFFSPRING

	/// Was this mob spawned by xenobiology magic? Used for mobcapping.
	var/xenobiology_spawned = FALSE
	/// If the mob can be spawned with a gold slime core. HOSTILE_SPAWN are spawned with plasma, FRIENDLY_SPAWN are spawned with blood
	var/gold_core_spawnable = NO_SPAWN
	/// Holding var for determining who own/controls a sentient simple animal (for sentience potions).
	var/mob/living/carbon/human/master_commander = null

	var/datum/component/spawner/nest
	/// Sentience type, for slime potions
	var/sentience_type = SENTIENCE_ORGANIC
	/// List of things spawned at mob's loc when it dies
	var/list/loot = list()
	/// Causes mob to be deleted on death, useful for mobs that spawn lootable corpses
	var/del_on_death = FALSE
	var/deathmessage = ""
	/// The sound played on death
	var/death_sound = null

	var/allow_movement_on_non_turfs = FALSE

	var/attacked_sound = "punch"
	/// The Status of our AI, can be set to AI_ON (On, usual processing), AI_IDLE (Will not process, but will return to AI_ON if an enemy comes near), AI_OFF (Off, Not processing ever)
	var/AIStatus = AI_ON
	/// Once we have become sentient, we can never go back
	var/can_have_ai = TRUE

	/// Convenience var for forcibly waking up an idling AI on next check.
	var/shouldwakeup = FALSE

	/// I don't want to confuse this with client registered_z
	var/my_z
	/// What kind of footstep this mob should have. Null if it shouldn't have any.
	var/footstep_type
	/// Can this simple mob crawl or not? If FALSE, it won't get immobilized by crawling
	var/can_crawl = FALSE

/mob/living/simple_animal/Initialize(mapload)
	. = ..()
	GLOB.simple_animals[AIStatus] += src
	if(gender == PLURAL)
		gender = pick(MALE, FEMALE)
	if(!real_name)
		real_name = name
	if(!loc)
		stack_trace("Simple animal being instantiated in nullspace")
	verbs -= /mob/verb/observe
	if(can_hide)
		var/datum/action/innate/hide/hide = new()
		hide.Grant(src)
	if(pcollar)
		pcollar = new(src)
		regenerate_icons()
	if(footstep_type)
		AddComponent(/datum/component/footstep, footstep_type)

/mob/living/simple_animal/Destroy()
	/// We need to clear the reference to where we're walking to properly GC
	walk_to(src, 0)
	QDEL_NULL(pcollar)
	for(var/datum/action/innate/hide/hide in actions)
		hide.Remove(src)
	master_commander = null
	GLOB.simple_animals[AIStatus] -= src
	if(SSnpcpool.state == SS_PAUSED && LAZYLEN(SSnpcpool.currentrun))
		SSnpcpool.currentrun -= src

	if(nest)
		nest.spawned_mobs -= src
		nest = null

	var/turf/T = get_turf(src)
	if(T && AIStatus == AI_Z_OFF)
		SSidlenpcpool.idle_mobs_by_zlevel[T.z] -= src

	return ..()

/mob/living/simple_animal/handle_atom_del(atom/A)
	if(A == pcollar)
		pcollar = null
	return ..()

/mob/living/simple_animal/examine(mob/user)
	. = ..()
	if(stat == DEAD)
		. += "<span class='deadsay'>Upon closer examination, [p_they()] appear[p_s()] to be dead.</span>"
		return
	if(IsSleeping())
		. += "<span class='notice'>Upon closer examination, [p_they()] appear[p_s()] to be asleep.</span>"

/mob/living/simple_animal/updatehealth(reason = "none given")
	..(reason)
	health = clamp(health, 0, maxHealth)
	med_hud_set_health()

/mob/living/simple_animal/on_lying_down(new_lying_angle)
	..()
	if(icon_resting && stat != DEAD)
		icon_state = icon_resting
		if(collar_type)
			collar_type = "[initial(collar_type)]_rest"
			regenerate_icons()
	if(!can_crawl)
		ADD_TRAIT(src, TRAIT_IMMOBILIZED, LYING_DOWN_TRAIT) //simple mobs cannot crawl (unless they can)

/mob/living/simple_animal/on_standing_up()
	..()
	if(icon_resting && stat != DEAD)
		icon_state = icon_living
		if(collar_type)
			collar_type = "[initial(collar_type)]"
			regenerate_icons()

/mob/living/simple_animal/update_stat(reason = "none given")
	if(status_flags & GODMODE)
		return
	if(stat != DEAD)
		if(health <= 0)
			death()
			create_debug_log("died of damage, trigger reason: [reason]")
		else
			if(HAS_TRAIT(src, TRAIT_KNOCKEDOUT))
				if(stat == CONSCIOUS)
					KnockOut()
					create_debug_log("knocked out, trigger reason: [reason]")
			else if(stat == UNCONSCIOUS)
				WakeUp()
				create_debug_log("woke up, trigger reason: [reason]")
	med_hud_set_status()

/mob/living/simple_animal/proc/handle_automated_action()
	set waitfor = FALSE
	return

/mob/living/simple_animal/proc/handle_automated_movement()
	set waitfor = FALSE
	if(!stop_automated_movement && wander)
		if((isturf(loc) || allow_movement_on_non_turfs) && !IS_HORIZONTAL(src) && !buckled && (mobility_flags & MOBILITY_MOVE))		//This is so it only moves if it's not inside a closet, gentics machine, etc.
			turns_since_move++
			if(turns_since_move >= turns_per_move)
				if(!(stop_automated_movement_when_pulled && pulledby)) //Soma animals don't move when pulled
					var/anydir = pick(GLOB.cardinal)
					if(Process_Spacemove(anydir))
						Move(get_step(src,anydir), anydir)
						turns_since_move = 0
			return 1

/mob/living/simple_animal/proc/handle_automated_speech(override)
	set waitfor = FALSE
	if(speak_chance)
		if(prob(speak_chance) || override)
			if(speak && speak.len)
				if((emote_hear && emote_hear.len) || (emote_see && emote_see.len))
					var/length = speak.len
					if(emote_hear && emote_hear.len)
						length += emote_hear.len
					if(emote_see && emote_see.len)
						length += emote_see.len
					var/randomValue = rand(1,length)
					if(randomValue <= speak.len)
						say(pick(speak))
					else
						randomValue -= speak.len
						if(emote_see && randomValue <= emote_see.len)
							custom_emote(EMOTE_VISIBLE, pick(emote_see))
						else
							custom_emote(EMOTE_AUDIBLE, pick(emote_hear))
				else
					say(pick(speak))
			else
				if(!(emote_hear && emote_hear.len) && (emote_see && emote_see.len))
					custom_emote(EMOTE_VISIBLE, pick(emote_see))
				if((emote_hear && emote_hear.len) && !(emote_see && emote_see.len))
					custom_emote(EMOTE_AUDIBLE, pick(emote_hear))
				if((emote_hear && emote_hear.len) && (emote_see && emote_see.len))
					var/length = emote_hear.len + emote_see.len
					var/pick = rand(1,length)
					if(pick <= emote_see.len)
						custom_emote(EMOTE_VISIBLE, pick(emote_see))
					else
						custom_emote(EMOTE_AUDIBLE, pick(emote_hear))


/mob/living/simple_animal/handle_environment(datum/gas_mixture/environment)
	var/atmos_suitable = 1

	var/areatemp = get_temperature(environment)

	if(abs(areatemp - bodytemperature) > 5 && !HAS_TRAIT(src, TRAIT_NOBREATH))
		var/diff = areatemp - bodytemperature
		diff = diff / 5
		bodytemperature += diff

	var/tox = environment.toxins
	var/oxy = environment.oxygen
	var/n2 = environment.nitrogen
	var/co2 = environment.carbon_dioxide

	if(atmos_requirements["min_oxy"] && oxy < atmos_requirements["min_oxy"])
		atmos_suitable = 0
		throw_alert("not_enough_oxy", /obj/screen/alert/not_enough_oxy)
	else if(atmos_requirements["max_oxy"] && oxy > atmos_requirements["max_oxy"])
		atmos_suitable = 0
		throw_alert("too_much_oxy", /obj/screen/alert/too_much_oxy)
	else
		clear_alert("not_enough_oxy")
		clear_alert("too_much_oxy")

	if(atmos_requirements["min_tox"] && tox < atmos_requirements["min_tox"])
		atmos_suitable = 0
		throw_alert("not_enough_tox", /obj/screen/alert/not_enough_tox)
	else if(atmos_requirements["max_tox"] && tox > atmos_requirements["max_tox"])
		atmos_suitable = 0
		throw_alert("too_much_tox", /obj/screen/alert/too_much_tox)
	else
		clear_alert("too_much_tox")
		clear_alert("not_enough_tox")

	if(atmos_requirements["min_n2"] && n2 < atmos_requirements["min_n2"])
		atmos_suitable = 0
	else if(atmos_requirements["max_n2"] && n2 > atmos_requirements["max_n2"])
		atmos_suitable = 0

	if(atmos_requirements["min_co2"] && co2 < atmos_requirements["min_co2"])
		atmos_suitable = 0
	else if(atmos_requirements["max_co2"] && co2 > atmos_requirements["max_co2"])
		atmos_suitable = 0

	if(!atmos_suitable)
		adjustHealth(unsuitable_atmos_damage)

	handle_temperature_damage()

/mob/living/simple_animal/proc/handle_temperature_damage()
	if(bodytemperature < minbodytemp)
		adjustHealth(cold_damage_per_tick)
	else if(bodytemperature > maxbodytemp)
		adjustHealth(heat_damage_per_tick)

/mob/living/simple_animal/gib()
	if(icon_gib)
		flick(icon_gib, src)
	if(butcher_results)
		var/atom/Tsec = drop_location()
		for(var/path in butcher_results)
			for(var/i in 1 to butcher_results[path])
				new path(Tsec)
	if(pcollar)
		pcollar.forceMove(drop_location())
		pcollar = null
	..()
/mob/living/simple_animal/say_quote(message)
	var/verb = "says"

	if(speak_emote.len)
		verb = pick(speak_emote)

	return verb

/mob/living/simple_animal/movement_delay()
	. = speed
	if(forced_look)
		. += 3
	. += GLOB.configuration.movement.animal_delay

/mob/living/simple_animal/Stat()
	..()
	if(statpanel("Status"))
		stat(null, "Health: [round((health / maxHealth) * 100)]%")
		return TRUE

/mob/living/simple_animal/proc/drop_loot()
	if(loot.len)
		for(var/i in loot)
			new i(loc)

/mob/living/simple_animal/revive()
	..()
	density = initial(density)

/mob/living/simple_animal/death(gibbed)
	// Only execute the below if we successfully died
	. = ..()
	if(!.)
		return FALSE
	flying = FALSE
	if(nest)
		nest.spawned_mobs -= src
		nest = null
	drop_loot()
	if(!gibbed)
		if(death_sound)
			playsound(get_turf(src),death_sound, 200, 1)
		if(deathmessage)
			visible_message("<span class='danger'>\The [src] [deathmessage]</span>")
		else if(!del_on_death)
			visible_message("<span class='danger'>\The [src] stops moving...</span>")
	if(xenobiology_spawned)
		SSmobs.xenobiology_mobs--
	if(del_on_death)
		//Prevent infinite loops if the mob Destroy() is overridden in such
		//a manner as to cause a call to death() again
		del_on_death = FALSE
		ghostize()
		qdel(src)
	else
		health = 0
		icon_state = icon_dead
		if(flip_on_death)
			transform = transform.Turn(180)
		density = FALSE
		if(collar_type)
			collar_type = "[initial(collar_type)]_dead"
			regenerate_icons()

/mob/living/simple_animal/proc/CanAttack(atom/the_target)
	if(see_invisible < the_target.invisibility)
		return FALSE
	if(ismob(the_target))
		var/mob/M = the_target
		if(M.status_flags & GODMODE)
			return FALSE
	if(isliving(the_target))
		var/mob/living/L = the_target
		if(L.stat != CONSCIOUS)
			return FALSE
	if(ismecha(the_target))
		var/obj/mecha/M = the_target
		if(M.occupant)
			return FALSE
	return TRUE

/mob/living/simple_animal/handle_fire()
	if(!can_be_on_fire)
		return FALSE
	. = ..()
	if(!.)
		return
	adjustFireLoss(fire_damage) // Slowly start dying from being on fire

/mob/living/simple_animal/IgniteMob()
	if(!can_be_on_fire)
		return FALSE
	return ..()

/mob/living/simple_animal/ExtinguishMob()
	if(!can_be_on_fire)
		return
	return ..()


/mob/living/simple_animal/update_fire()
	if(!can_be_on_fire)
		return
	overlays -= image("icon"='icons/mob/OnFire.dmi', "icon_state"="Generic_mob_burning")
	if(on_fire)
		overlays += image("icon"='icons/mob/OnFire.dmi', "icon_state"="Generic_mob_burning")

/mob/living/simple_animal/revive()
	..()
	health = maxHealth
	icon = initial(icon)
	icon_state = icon_living
	density = initial(density)
	flying = initial(flying)
	if(collar_type)
		collar_type = "[initial(collar_type)]"
		regenerate_icons()

/mob/living/simple_animal/proc/make_babies() // <3 <3 <3
	if(current_offspring >= max_offspring)
		return FALSE
	if(gender != FEMALE || stat || next_scan_time > world.time || !childtype || !animal_species || !SSticker.IsRoundInProgress())
		return FALSE
	next_scan_time = world.time + 400

	var/mob/living/simple_animal/partner
	var/children = 0

	for(var/mob/M in oview(7, src))
		if(M.stat != CONSCIOUS) //Check if it's conscious FIRST.
			continue
		else if(istype(M, childtype)) //Check for children SECOND.
			children++
		else if(istype(M, animal_species))
			if(M.ckey)
				continue
			else if(!istype(M, childtype) && M.gender == MALE) //Better safe than sorry ;_;
				partner = M
		else if(isliving(M) && !faction_check_mob(M)) //shyness check. we're not shy in front of things that share a faction with us.
			return //we never mate when not alone, so just abort early

	// The children check here isn't the total number of offspring, but the
	// number of offspring within a visible 7-tile radius. It doesn't seem very
	// effective at preventing population explosions but there you go.
	if(partner && children < 3)
		var/childspawn = pickweight(childtype)
		var/turf/target = get_turf(loc)
		if(target)
			current_offspring += 1
			return new childspawn(target)

/mob/living/simple_animal/show_inv(mob/user as mob)
	if(!can_collar)
		return

	user.set_machine(src)
	var/dat = "<table><tr><td><B>Collar:</B></td><td><A href='?src=[UID()];item=[SLOT_HUD_COLLAR]'>[(pcollar && !(pcollar.flags & ABSTRACT)) ? html_encode(pcollar) : "<font color=grey>Empty</font>"]</A></td></tr></table>"
	dat += "<A href='?src=[user.UID()];mach_close=mob\ref[src]'>Close</A>"

	var/datum/browser/popup = new(user, "mob\ref[src]", "[src]", 440, 250)
	popup.set_content(dat)
	popup.open()

/mob/living/simple_animal/get_item_by_slot(slot_id)
	switch(slot_id)
		if(SLOT_HUD_COLLAR)
			return pcollar
	. = ..()

/mob/living/simple_animal/can_equip(obj/item/I, slot, disable_warning = 0)
	// . = ..() // Do not call parent. We do not want animals using their hand slots.
	switch(slot)
		if(SLOT_HUD_COLLAR)
			if(pcollar)
				return FALSE
			if(!can_collar)
				return FALSE
			if(!istype(I, /obj/item/petcollar))
				return FALSE
			return TRUE

/mob/living/simple_animal/equip_to_slot(obj/item/W, slot, initial = FALSE)
	if(!istype(W))
		return FALSE

	if(!slot)
		return FALSE

	W.layer = ABOVE_HUD_LAYER
	W.plane = ABOVE_HUD_PLANE

	switch(slot)
		if(SLOT_HUD_COLLAR)
			add_collar(W)

/mob/living/simple_animal/unEquip(obj/item/I, force, silent = FALSE)
	. = ..()
	if(!. || !I)
		return

	if(I == pcollar)
		pcollar = null
		regenerate_icons()

/mob/living/simple_animal/get_access()
	. = ..()
	if(pcollar)
		. |= pcollar.GetAccess()

/mob/living/simple_animal/update_transform()
	var/matrix/ntransform = matrix(transform) //aka transform.Copy()
	var/changed = FALSE

	if(resize != RESIZE_DEFAULT_SIZE)
		changed = TRUE
		ntransform.Scale(resize)
		resize = RESIZE_DEFAULT_SIZE

	if(changed)
		animate(src, transform = ntransform, time = 2, easing = EASE_IN|EASE_OUT)

/mob/living/simple_animal/proc/sentience_act() //Called when a simple animal gains sentience via gold slime potion
	toggle_ai(AI_OFF)
	can_have_ai = FALSE

/mob/living/simple_animal/grant_death_vision()
	sight |= SEE_TURFS
	sight |= SEE_MOBS
	sight |= SEE_OBJS
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_OBSERVER
	sync_lighting_plane_alpha()

/mob/living/simple_animal/update_sight()
	if(!client)
		return

	if(stat == DEAD)
		grant_death_vision()
		return

	see_invisible = initial(see_invisible)
	see_in_dark = initial(see_in_dark)
	sight = initial(sight)

	if(client.eye != src)
		var/atom/A = client.eye
		if(A.update_remote_sight(src)) //returns 1 if we override all other sight updates.
			return

	SEND_SIGNAL(src, COMSIG_MOB_UPDATE_SIGHT)
	sync_lighting_plane_alpha()

/mob/living/simple_animal/proc/toggle_ai(togglestatus)
	if(!can_have_ai && (togglestatus != AI_OFF))
		return
	if(AIStatus != togglestatus)
		if(togglestatus > 0 && togglestatus < 5)
			if(togglestatus == AI_Z_OFF || AIStatus == AI_Z_OFF)
				var/turf/T = get_turf(src)
				if(AIStatus == AI_Z_OFF)
					SSidlenpcpool.idle_mobs_by_zlevel[T.z] -= src
				else
					SSidlenpcpool.idle_mobs_by_zlevel[T.z] += src
			GLOB.simple_animals[AIStatus] -= src
			GLOB.simple_animals[togglestatus] += src
			AIStatus = togglestatus
		else
			stack_trace("Something attempted to set simple animals AI to an invalid state: [togglestatus]")

/mob/living/simple_animal/proc/consider_wakeup()
	if(pulledby || shouldwakeup)
		toggle_ai(AI_ON)

/mob/living/simple_animal/adjustHealth(amount, updating_health = TRUE)
	. = ..()
	if(!ckey && !stat)//Not unconscious
		if(AIStatus == AI_IDLE)
			toggle_ai(AI_ON)

/mob/living/simple_animal/onTransitZ(old_z, new_z)
	..()
	if(AIStatus == AI_Z_OFF)
		SSidlenpcpool.idle_mobs_by_zlevel[old_z] -= src
		toggle_ai(initial(AIStatus))

/mob/living/simple_animal/proc/add_collar(obj/item/petcollar/P, mob/user)
	if(!istype(P) || QDELETED(P) || pcollar)
		return
	if(user && !user.unEquip(P))
		return
	P.forceMove(src)
	P.equipped(src)
	pcollar = P
	regenerate_icons()
	if(user)
		to_chat(user, "<span class='notice'>You put [P] around [src]'s neck.</span>")
	if(P.tagname && !unique_pet)
		name = P.tagname
		real_name = P.tagname

/mob/living/simple_animal/regenerate_icons()
	cut_overlays()
	if(pcollar && collar_type)
		add_overlay("[collar_type]collar")
		add_overlay("[collar_type]tag")

/mob/living/simple_animal/Login()
	..()
	walk(src, 0) // if mob is moving under ai control, then stop AI movement

/mob/living/simple_animal/proc/npc_safe(mob/user)
	return FALSE

/mob/living/simple_animal/deadchat_plays(mode = DEADCHAT_ANARCHY_MODE, cooldown = 12 SECONDS)
	. = AddComponent(/datum/component/deadchat_control/cardinal_movement, mode, list(), cooldown, CALLBACK(src, PROC_REF(end_dchat_plays)))

	if(. == COMPONENT_INCOMPATIBLE)
		return

	stop_automated_movement = TRUE

/mob/living/simple_animal/proc/end_dchat_plays()
	stop_automated_movement = FALSE
