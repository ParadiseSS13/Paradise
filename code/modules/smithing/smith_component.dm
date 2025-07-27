/obj/item/smithed_item/component
	name = "Debug smithed component"
	desc = "Debug smithed component part. If you see this, notify the development team."
	/// What type of part is it
	var/part_type
	/// What is this a part of
	var/finished_product
	/// Heat stacks on the component
	var/heat = 5
	/// How often does a component lose heat stacks
	var/cool_time = 10 SECONDS
	/// How many times the component needs to be shaped to be considered ready
	var/hammer_time = 3

/obj/item/smithed_item/component/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(cool_off)), cool_time)

/obj/item/smithed_item/component/update_icon_state()
	. = ..()
	if(heat)
		icon_state = "[initial(icon_state)]_hot"
	else
		icon_state = "[initial(icon_state)]"

/obj/item/smithed_item/component/proc/powerhammer()
	hammer_time--
	if(!hammer_time)
		heat = 0
	update_icon(UPDATE_ICON_STATE)

/obj/item/smithed_item/component/proc/heat_up(heat_to_add)
	heat += heat_to_add
	if(heat)
		addtimer(CALLBACK(src, PROC_REF(cool_off)), cool_time)
	update_icon(UPDATE_ICON_STATE)

/obj/item/smithed_item/component/proc/cool_off()
	heat = max(heat - 1, 0)
	if(heat)
		addtimer(CALLBACK(src, PROC_REF(cool_off)), cool_time)
	else
		update_icon(UPDATE_ICON_STATE)

/obj/item/smithed_item/component/examine(mob/user)
	. = ..()
	if(hammer_time)
		. += "It is incomplete. It looks like it needs [hammer_time] more cycles in the power hammer."
	else
		. += "It is complete."
	if(heat)
		. +="<span class='warning'>It is glowing hot!</span>"

/obj/item/smithed_item/component/attack_hand(mob/user)
	if(!heat)
		return ..()
	if(burn_check(user))
		burn_user(user)
		return
	return ..()

/obj/item/smithed_item/component/proc/set_worktime()
	if(!quality)
		return
	hammer_time = ROUND_UP(initial(hammer_time) * quality.work_mult)

/obj/item/smithed_item/component/proc/burn_check(mob/user)
	if(!heat)
		return FALSE
	var/burn_me = TRUE
	var/mob/living/carbon/human/H = user
	if(!istype(H))
		return TRUE
	if(H.gloves)
		var/obj/item/clothing/gloves/G = H.gloves
		if(G.max_heat_protection_temperature)
			burn_me = !(G.max_heat_protection_temperature > 360)

	if(!burn_me ||  HAS_TRAIT(user, TRAIT_RESISTHEAT) || HAS_TRAIT(user, TRAIT_RESISTHEATHANDS))
		return FALSE
	return TRUE

/obj/item/smithed_item/component/proc/burn_user(mob/user)
	var/mob/living/carbon/human/H = user
	if(!istype(H))
		return
	to_chat(user, "<span class='warning'>You burn your hand as you try to pick up [src]!</span>")
	var/obj/item/organ/external/affecting = H.get_organ("[user.hand ? "l" : "r" ]_hand")
	if(affecting.receive_damage(0, 10)) // 10 burn damage
		H.UpdateDamageIcon()
	H.updatehealth()
