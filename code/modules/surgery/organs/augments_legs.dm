/obj/item/organ/internal/cyberimp/leg
	name = "leg implant"
	desc = "You shouldn't see this! Adminhelp and report this as an issue on github!"
	parent_organ = BODY_ZONE_R_LEG
	icon_state = "implant-leg"
	w_class = WEIGHT_CLASS_NORMAL

	//to determine what type of implant for checking if both legs are the same
	var/implant_type = "leg implant"
	COOLDOWN_DECLARE(emp_notice)

/obj/item/organ/internal/cyberimp/leg/Initialize(mapload)
	. = ..()
	update_icon()
	slot = parent_organ + "_device"

/obj/item/organ/internal/cyberimp/leg/emp_act(severity)
	. = ..()
	if(emp_proof)
		return

	var/obj/item/organ/external/E = owner.get_organ(parent_organ)
	if(!E)	//how did you get an implant in a limb you don't have?
		return

	E.receive_damage(5,0,10)	//always take a least a little bit of damage to the leg

	if(prob(50))	//you're forced to use two of these for them to work so let's give em a chance to not get completely fucked
		if(COOLDOWN_FINISHED(src, emp_notice))
			to_chat(owner, span_warning("The EMP causes [src] in [E] to twitch randomly!"))
			COOLDOWN_START(src, emp_notice, 30 SECONDS)
		return

	if(severity & EMP_HEAVY && prob(25) )	//put probabilities into a calculator before you try fucking with this
		to_chat(owner, span_warning("The EMP causes your [src] to thrash [E] around wildly, breaking it!"))
		E.receive_damage(40)
	else if(COOLDOWN_FINISHED(src, emp_notice))
		to_chat(owner, span_warning("The EMP causes your [src] to seize up, preventing [E] from moving!"))
		COOLDOWN_START(src, emp_notice, 30 SECONDS)

/obj/item/organ/internal/cyberimp/leg/update_icon()
	if(parent_organ == BODY_ZONE_R_LEG)
		transform = null
	else // Mirroring the icon
		transform = matrix(-1, 0, 0, 0, 1, 0)

/obj/item/organ/internal/cyberimp/leg/examine(mob/user)
	. = ..()
	. += span_notice("[src] is assembled in the [parent_organ == BODY_ZONE_R_LEG ? "right" : "left"] leg configuration. You can use a screwdriver to reassemble it.")
	. += span_info("You will need two of the same type of implant for them to properly function.")

/obj/item/organ/internal/cyberimp/leg/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(parent_organ == BODY_ZONE_R_LEG)
		parent_organ = BODY_ZONE_L_LEG
	else
		parent_organ = BODY_ZONE_R_LEG
	SetSlot()
	to_chat(user, "<span class='notice'>You modify [src] to be installed on the [parent_organ == BODY_ZONE_R_LEG ? "right" : "left"] leg.</span>")
	update_icon()


/obj/item/organ/internal/cyberimp/leg/insert(mob/living/carbon/M, special, dont_remove_slot)
	. = ..()
	if(HasBoth())
		AddEffect()

/obj/item/organ/internal/cyberimp/leg/remove(mob/living/carbon/M, special)
	RemoveEffect()
	. = ..()

/obj/item/organ/internal/cyberimp/leg/proc/HasBoth()
	if(owner.get_organ_slot("r_leg_device") && owner.get_organ_slot("l_leg_device"))
		var/obj/item/organ/internal/cyberimp/leg/left = owner.get_organ_slot("r_leg_device")
		var/obj/item/organ/internal/cyberimp/leg/right = owner.get_organ_slot("l_leg_device")
		if(left.implant_type == right.implant_type)
			return TRUE
	return FALSE

/obj/item/organ/internal/cyberimp/leg/proc/AddEffect()
	return

/obj/item/organ/internal/cyberimp/leg/proc/RemoveEffect()
	return

/obj/item/organ/internal/cyberimp/leg/proc/SetSlot()
	switch(parent_organ)
		if(BODY_ZONE_L_LEG)
			slot = "l_leg_device"
		if(BODY_ZONE_R_LEG)
			slot = "r_leg_device"
		else
			CRASH("Invalid zone for [type]")

//100 lines of code for only one fucking implant

//------------dash boots implant
/obj/item/organ/internal/cyberimp/leg/jumpboots
	name = "jumpboots implant"
	desc = "An implant with a specialized propulsion system for rapid foward movement."
	implant_type = "jumpboots"
	var/datum/action/bhop/implant_ability

/obj/item/organ/internal/cyberimp/leg/jumpboots/l
	parent_organ = BODY_ZONE_L_LEG

/obj/item/organ/internal/cyberimp/leg/jumpboots/AddEffect()
	implant_ability = new(src)
	implant_ability.Grant(owner)

/obj/item/organ/internal/cyberimp/leg/jumpboots/RemoveEffect()
	if(implant_ability)
		implant_ability.Remove(owner)

/datum/action/bhop
	name = "Activate Jump Boots"
	desc = "Activates the jump boot's internal propulsion system, allowing the user to dash over 4-wide gaps."
	icon_icon = 'icons/mob/actions/actions.dmi'
	button_icon_state = "jetboot"
	var/jumpdistance = 5 //-1 from to see the actual distance, e.g 4 goes over 3 tiles
	var/jumpspeed = 3
	var/recharging_rate = 60 //default 6 seconds between each dash
	var/recharging_time = 0 //time until next dash
	var/datum/callback/last_jump = null

/datum/action/bhop/Trigger()
	if(recharging_time > world.time)
		to_chat(owner, "<span class='warning'>The boot's internal propulsion needs to recharge still!</span>")
		return

	var/atom/target = get_edge_target_turf(owner, owner.dir) //gets the user's direction

	if(last_jump) //in case we are trying to perfom jumping while first jump was not complete
		last_jump.Invoke()
	var/isflying = owner.flying
	owner.flying = TRUE
	var/after_jump_callback = CALLBACK(src, PROC_REF(after_jump), owner, isflying)
	if(owner.throw_at(target, jumpdistance, jumpspeed, spin = FALSE, diagonals_first = TRUE, callback = after_jump_callback))
		last_jump = after_jump_callback
		playsound(src, 'sound/effects/stealthoff.ogg', 50, 1, 1)
		owner.visible_message("<span class='warning'>[usr] dashes forward into the air!</span>")
		recharging_time = world.time + recharging_rate
	else
		to_chat(owner, "<span class='warning'>Something prevents you from dashing forward!</span>")
		after_jump(owner, isflying)

/datum/action/bhop/proc/after_jump(mob/owner, isflying)
	owner.flying = isflying
	last_jump = null


