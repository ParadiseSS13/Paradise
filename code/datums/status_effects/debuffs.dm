//Largely negative status effects go here, even if they have small benificial effects
//STUN EFFECTS
/datum/status_effect/incapacitating
	tick_interval = 0
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null

/datum/status_effect/incapacitating/on_creation(mob/living/new_owner, set_duration, updating_canmove)
	if(isnum(set_duration))
		duration = set_duration
	. = ..()
	if(.)
		if(updating_canmove)
			owner.update_canmove()
			if(issilicon(owner))
				owner.update_stat()

/datum/status_effect/incapacitating/on_remove()
	owner.update_canmove()
	if(issilicon(owner)) //silicons need stat updates in addition to normal canmove updates
		owner.update_stat()

//SLEEPING
/datum/status_effect/incapacitating/sleeping
	id = "sleeping"
	alert_type = /obj/screen/alert/status_effect/asleep
	var/mob/living/carbon/carbon_owner
	var/mob/living/carbon/human/human_owner

/datum/status_effect/incapacitating/sleeping/on_creation(mob/living/new_owner, updating_canmove)
	. = ..()
	if(.)
		if(updating_canmove)
			owner.update_stat()
		if(iscarbon(owner)) //to avoid repeated istypes
			carbon_owner = owner
		if(ishuman(owner))
			human_owner = owner

/datum/status_effect/incapacitating/sleeping/Destroy()
	carbon_owner = null
	human_owner = null
	return ..()

/datum/status_effect/incapacitating/sleeping/tick()
	var/comfort = 1
	if(owner.staminaloss)
		owner.adjustStaminaLoss(-10)
	if(istype(owner.buckled, /obj/structure/bed))
		var/obj/structure/bed/bed = owner.buckled
		comfort+= bed.comfort
	for(var/obj/item/bedsheet/bedsheet in range(owner.loc,0))
		if(bedsheet.loc != owner.loc) //bedsheets in your backpack/neck don't give you comfort
			continue
		comfort+= bedsheet.comfort
		break //Only count the first bedsheet
	if(human_owner && human_owner.drunk)
		comfort += 1 //Aren't naps SO much better when drunk?
		human_owner.AdjustDrunk(1-0.0015*comfort) //reduce drunkenness ~6% per two seconds, when on floor.
	if(comfort > 1 && prob(3))//You don't heal if you're just sleeping on the floor without a blanket.
		owner.adjustBruteLoss(-1*comfort)
		owner.adjustFireLoss(-1*comfort)
	if(prob(20))
		if(carbon_owner)
			carbon_owner.handle_dreams()
		if(prob(10) && owner.health > HEALTH_THRESHOLD_CRIT)
			owner.emote("snore")
	// Keep SSD people asleep
	if(owner.player_logged)
		owner.AdjustSleeping(2)

/datum/status_effect/incapacitating/sleeping/on_remove()
	..()
	owner.update_stat()

/obj/screen/alert/status_effect/asleep
	name = "Asleep"
	desc = "You've fallen asleep. Wait a bit and you should wake up. Unless you don't, considering how helpless you are."
	icon_state = "asleep"

/obj/screen/alert/status_effect/stunned
	name = "Stunned"
	desc = "You've been stunned by something. You can't move!"
	icon_state = "stun"

/obj/screen/alert/status_effect/knockdown
	name = "Knocked down"
	desc = "You have been knocked down! You can't move!"
	icon_state = "paralysis"

//STUN
/datum/status_effect/incapacitating/stun
	id = "stun"
	alert_type = /obj/screen/alert/status_effect/stunned

//KNOCKDOWN
/datum/status_effect/incapacitating/knockdown
	id = "knockdown"
	alert_type = /obj/screen/alert/status_effect/knockdown

//UNCONSCIOUS
/datum/status_effect/incapacitating/unconscious
	id = "unconscious"

//OTHER DEBUFFS

/datum/status_effect/cultghost //is a cult ghost and can't use manifest runes
	id = "cult_ghost"
	duration = -1
	alert_type = null

/datum/status_effect/cultghost/tick()
	if(owner.reagents)
		owner.reagents.del_reagent("holywater") //can't be deconverted

/datum/status_effect/saw_bleed
	id = "saw_bleed"
	duration = -1 //removed under specific conditions
	tick_interval = 6
	alert_type = null
	var/mutable_appearance/bleed_overlay
	var/mutable_appearance/bleed_underlay
	var/bleed_amount = 3
	var/bleed_buildup = 3
	var/delay_before_decay = 5
	var/bleed_damage = 200
	var/needs_to_bleed = FALSE

/datum/status_effect/saw_bleed/Destroy()
	if(owner)
		owner.cut_overlay(bleed_overlay)
		owner.underlays -= bleed_underlay
	QDEL_NULL(bleed_overlay)
	return ..()

/datum/status_effect/saw_bleed/on_apply()
	if(owner.stat == DEAD)
		return FALSE
	bleed_overlay = mutable_appearance('icons/effects/bleed.dmi', "bleed[bleed_amount]")
	bleed_underlay = mutable_appearance('icons/effects/bleed.dmi', "bleed[bleed_amount]")
	var/icon/I = icon(owner.icon, owner.icon_state, owner.dir)
	var/icon_height = I.Height()
	bleed_overlay.pixel_x = -owner.pixel_x
	bleed_overlay.pixel_y = FLOOR(icon_height * 0.25, 1)
	bleed_overlay.transform = matrix() * (icon_height/world.icon_size) //scale the bleed overlay's size based on the target's icon size
	bleed_underlay.pixel_x = -owner.pixel_x
	bleed_underlay.transform = matrix() * (icon_height/world.icon_size) * 3
	bleed_underlay.alpha = 40
	owner.add_overlay(bleed_overlay)
	owner.underlays += bleed_underlay
	return ..()

/datum/status_effect/saw_bleed/tick()
	if(owner.stat == DEAD)
		qdel(src)
	else
		add_bleed(-1)

/datum/status_effect/saw_bleed/proc/add_bleed(amount)
	owner.cut_overlay(bleed_overlay)
	owner.underlays -= bleed_underlay
	bleed_amount += amount
	if(bleed_amount)
		if(bleed_amount >= 10)
			needs_to_bleed = TRUE
			qdel(src)
		else
			if(amount > 0)
				tick_interval += delay_before_decay
			bleed_overlay.icon_state = "bleed[bleed_amount]"
			bleed_underlay.icon_state = "bleed[bleed_amount]"
			owner.add_overlay(bleed_overlay)
			owner.underlays += bleed_underlay
	else
		qdel(src)

/datum/status_effect/saw_bleed/on_remove()
	if(needs_to_bleed)
		var/turf/T = get_turf(owner)
		new /obj/effect/temp_visual/bleed/explode(T)
		for(var/d in alldirs)
			new /obj/effect/temp_visual/dir_setting/bloodsplatter(T, d)
		playsound(T, "desceration", 200, 1, -1)
		owner.adjustBruteLoss(bleed_damage)
	else
		new /obj/effect/temp_visual/bleed(get_turf(owner))