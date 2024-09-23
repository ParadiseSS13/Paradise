/obj
	//var/datum/module/mod		//not used
	var/origin_tech = null	//Used by R&D to determine what research bonuses it grants.
	animate_movement = SLIDE_STEPS
	var/list/species_exception = null	// list() of species types, if a species cannot put items in a certain slot, but species type is in list, it will be able to wear that item
	var/sharp = FALSE		// whether this object cuts
	var/in_use = FALSE // If we have a user using us, this will be set on. We will check if the user has stopped using us, and thus stop updating and LAGGING EVERYTHING!
	var/damtype = "brute"
	var/force = 0
	// You can define armor as a list in datum definition (e.g. `armor = list("fire" = 80, "brute" = 10)`),
	// which would be converted to armor datum during initialization.
	// Setting `armor` to a list on an *existing* object would inevitably runtime. Use `getArmor()` instead.
	var/datum/armor/armor
	var/obj_integrity	//defaults to max_integrity
	var/max_integrity = 500
	var/integrity_failure = 0 //0 if we have no special broken behavior
	///Damage under this value will be completely ignored
	var/damage_deflection = 0

	var/resistance_flags = NONE // INDESTRUCTIBLE
	var/custom_fire_overlay // Update_fire_overlay will check if a different icon state should be used

	var/acid_level = 0 //how much acid is on that obj

	var/can_be_hit = TRUE //can this be bludgeoned by items?

	var/being_shocked = FALSE
	var/speed_process = FALSE

	var/on_blueprints = FALSE //Are we visible on the station blueprints at roundstart?
	var/force_blueprints = FALSE //forces the obj to be on the blueprints, regardless of when it was created.
	var/suicidal_hands = FALSE // Does it requires you to hold it to commit suicide with it?
	/// Is it emagged or not?
	var/emagged = FALSE

	// Access-related fields
	var/list/req_access = null
	var/req_access_txt = "0"
	var/list/req_one_access = null
	var/req_one_access_txt = "0"

/obj/Initialize(mapload)
	. = ..()
	if(islist(armor))
		armor = getArmor(arglist(armor))
	else if(!armor)
		armor = getArmor()
	else if(!istype(armor, /datum/armor))
		stack_trace("Invalid type [armor.type] found in .armor during /obj Initialize()")
	if(sharp)
		AddComponent(/datum/component/surgery_initiator)

	if(obj_integrity == null)
		obj_integrity = max_integrity
	if(on_blueprints && isturf(loc))
		var/turf/T = loc
		if(force_blueprints)
			T.add_blueprints(src)
		else
			T.add_blueprints_preround(src)

/obj/Topic(href, href_list, nowindow = FALSE, datum/ui_state/state = GLOB.default_state)
	// Calling Topic without a corresponding window open causes runtime errors
	if(!nowindow && ..())
		return TRUE

	// In the far future no checks are made in an overriding Topic() beyond if(..()) return
	// Instead any such checks are made in CanUseTopic()
	if(ui_status(usr, state, href_list) == UI_INTERACTIVE)
		var/atom/host = ui_host()
		host.add_fingerprint(usr)
		return FALSE

	return TRUE

/obj/Destroy()
	if(!ismachinery(src))
		if(!speed_process)
			STOP_PROCESSING(SSobj, src) // TODO: Have a processing bitflag to reduce on unnecessary loops through the processing lists
			// AA 2024-05-20 - processing var?????
		else
			STOP_PROCESSING(SSfastprocess, src)
	return ..()

//Output a creative message and then return the damagetype done
/obj/proc/suicide_act(mob/user)
	return FALSE

/obj/proc/handle_internal_lifeform(mob/lifeform_inside_me, breath_request, datum/gas_mixture/environment)
	//Return: (NONSTANDARD)
	//		null if object handles breathing logic for lifeform
	//		datum/air_group to tell lifeform to process using that breath return
	//DEFAULT: Take air from turf to give to have mob process

	if(breath_request > 0)
		var/datum/gas_mixture/air = return_obj_air()
		if(isnull(air))
			air = environment
		if(isnull(air))
			return

		var/breath_percentage = BREATH_VOLUME / air.return_volume()
		return air.remove(air.total_moles() * breath_percentage)
	else
		return null

/obj/proc/updateUsrDialog()
	if(in_use)
		var/is_in_use = FALSE
		var/list/nearby = viewers(1, src)
		for(var/mob/M in nearby)
			if(M.client && M.machine == src)
				is_in_use = TRUE
				src.attack_hand(M)
		if(isAI(usr) || isrobot(usr))
			if(!(usr in nearby))
				if(usr.client && usr.machine==src) // && M.machine == src is omitted because if we triggered this by using the dialog, it doesn't matter if our machine changed in between triggering it and this - the dialog is probably still supposed to refresh.
					is_in_use = TRUE
					src.attack_ai(usr)

		// check for TK users

		if(ishuman(usr))
			if(istype(usr.l_hand, /obj/item/tk_grab) || istype(usr.r_hand, /obj/item/tk_grab/))
				if(!(usr in nearby))
					if(usr.client && usr.machine == src)
						is_in_use = TRUE
						src.attack_hand(usr)
		in_use = is_in_use

/obj/proc/updateDialog()
	// Check that people are actually using the machine. If not, don't update anymore.
	if(in_use)
		var/list/nearby = viewers(1, src)
		var/is_in_use = FALSE
		for(var/mob/M in nearby)
			if(M.client && M.machine == src)
				is_in_use = TRUE
				src.interact(M)
		var/ai_in_use = AutoUpdateAI(src)

		if(!ai_in_use && !is_in_use)
			in_use = FALSE

/obj/proc/interact(mob/user)
	return

/mob/proc/unset_machine()
	if(machine)
		UnregisterSignal(machine, COMSIG_PARENT_QDELETING)
		machine = null


/mob/proc/set_machine(obj/O)
	if(src.machine)
		unset_machine()
	src.machine = O
	if(istype(O))
		O.in_use = TRUE
		RegisterSignal(O, COMSIG_PARENT_QDELETING, PROC_REF(unset_machine))

/obj/item/proc/updateSelfDialog()
	var/mob/M = src.loc
	if(istype(M) && M.client && M.machine == src)
		src.attack_self(M)

/obj/proc/hide(h)
	return

/obj/proc/hear_talk(mob/M, list/message_pieces)
	return

/obj/proc/hear_message(mob/M, text)
	return

/obj/proc/default_welder_repair(mob/user, obj/item/I) //Returns TRUE if the object was successfully repaired. Fully repairs an object (setting BROKEN to FALSE), default repair time = 40
	if(obj_integrity >= max_integrity)
		to_chat(user, "<span class='notice'>[src] does not need repairs.</span>")
		return
	if(I.tool_behaviour != TOOL_WELDER)
		return
	if(!I.tool_use_check(user, 0))
		return
	var/time = max(50 * (1 - obj_integrity / max_integrity), 5)
	WELDER_ATTEMPT_REPAIR_MESSAGE
	if(I.use_tool(src, user, time, volume = I.tool_volume))
		WELDER_REPAIR_SUCCESS_MESSAGE
		obj_integrity = max_integrity
		update_icon()
	return TRUE

/obj/proc/default_unfasten_wrench(mob/user, obj/item/I, time = 20)
	if(!anchored && !isfloorturf(loc))
		user.visible_message("<span class='warning'>A floor must be present to secure [src]!</span>")
		return FALSE
	if(I.tool_behaviour != TOOL_WRENCH)
		return FALSE
	if(!I.tool_use_check(user, 0))
		return FALSE
	if(!(flags & NODECONSTRUCT))
		to_chat(user, "<span class='notice'>Now [anchored ? "un" : ""]securing [name].</span>")
		if(I.use_tool(src, user, time, volume = I.tool_volume))
			to_chat(user, "<span class='notice'>You've [anchored ? "un" : ""]secured [name].</span>")
			anchored = !anchored
		return TRUE
	return FALSE

/obj/water_act(volume, temperature, source, method = REAGENT_TOUCH)
	. = ..()
	extinguish()
	acid_level = 0

/obj/singularity_pull(S, current_size)
	..()
	if(!anchored || current_size >= STAGE_FIVE)
		step_towards(src, S)

/obj/proc/container_resist(mob/living)
	return

/obj/proc/on_mob_move(dir, mob/user)
	return

/obj/proc/makeSpeedProcess()
	if(speed_process)
		return
	speed_process = TRUE
	STOP_PROCESSING(SSobj, src)
	START_PROCESSING(SSfastprocess, src)

/obj/proc/makeNormalProcess()
	if(!speed_process)
		return
	speed_process = FALSE
	START_PROCESSING(SSobj, src)
	STOP_PROCESSING(SSfastprocess, src)

/obj/vv_get_dropdown()
	. = ..()
	.["Delete all of type"] = "?_src_=vars;delall=[UID()]"
	if(!speed_process)
		.["Make speed process"] = "?_src_=vars;makespeedy=[UID()]"
	else
		.["Make normal process"] = "?_src_=vars;makenormalspeed=[UID()]"
	.["Modify armor values"] = "?_src_=vars;modifyarmor=[UID()]"

/obj/proc/check_uplink_validity()
	return TRUE

/obj/proc/cult_conceal() //Called by cult conceal spell
	return

/obj/proc/cult_reveal() //Called by cult reveal spell and chaplain's bible
	return

/// Set whether the item should be sharp or not
/obj/proc/set_sharpness(new_sharp_val)
	if(sharp == new_sharp_val)
		return
	sharp = new_sharp_val
	SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_SHARPNESS)
	if(!sharp && new_sharp_val)
		AddComponent(/datum/component/surgery_initiator)


/obj/proc/force_eject_occupant(mob/target)
	// This proc handles safely removing occupant mobs from the object if they must be teleported out (due to being SSD/AFK, by admin teleport, etc) or transformed.
	// In the event that the object doesn't have an overriden version of this proc to do it, log a runtime so one can be added.
	CRASH("Proc force_eject_occupant() is not overridden on a machine containing a mob.")

/obj/hit_by_thrown_mob(mob/living/C, datum/thrownthing/throwingdatum, damage, mob_hurt, self_hurt)
	damage *= 0.75 //Define this probably somewhere, we want objects to hurt less than walls, unless special impact effects.
	playsound(src, 'sound/weapons/punch1.ogg', 35, 1)
	if(mob_hurt) //Density check probably not needed, one should only bump into something if it is dense, and blob tiles are not dense, because of course they are not.
		return
	C.visible_message("<span class='danger'>[C] slams into [src]!</span>", "<span class='userdanger'>You slam into [src]!</span>")
	C.take_organ_damage(damage)
	if(!self_hurt)
		take_damage(damage, BRUTE)
	if(issilicon(C))
		C.Weaken(3 SECONDS)
	else
		C.KnockDown(3 SECONDS)

/obj/handle_ricochet(obj/item/projectile/P)
	. = ..()
	if(. && receive_ricochet_damage_coeff)
		// pass along receive_ricochet_damage_coeff damage to the structure for the ricochet
		take_damage(P.damage * receive_ricochet_damage_coeff, P.damage_type, P.flag, 0, REVERSE_DIR(P.dir), P.armour_penetration_flat, P.armour_penetration_percentage)

/obj/proc/return_obj_air()
	RETURN_TYPE(/datum/gas_mixture)
	if(isobj(loc))
		var/obj/O = loc
		return O.return_obj_air()
	else
		return null
