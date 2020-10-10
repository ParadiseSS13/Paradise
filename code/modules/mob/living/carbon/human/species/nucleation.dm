/datum/species/nucleation
	name = "Nucleation"
	name_plural = "Nucleations"

	blurb = "Work in progress, nerds."

	icobase = 'icons/mob/human_races/r_nucleation.dmi'
	blacklisted = TRUE
	language = "Sol Common"

	forced_heartattack = TRUE // No blood, but they should still get heart-attacks
	burn_mod = 1.3 // Rather weak to brute damage on account of crystalline structure.
	brute_mod = 0.9 // But a little more resilient to burns thanks to the supermatter crystals absorbing the energy.
	siemens_coeff = 2 // Their bodies are comprised of electricity, and electricity doesn't play well with itself if exceeding circuit limits.
	species_traits = list(IS_WHITELISTED, NO_BREATHE, NO_BLOOD, NO_SCAN, RADIMMUNE, NO_GERMS, NO_DECAY, NO_STARVING)
	dies_at_threshold = TRUE
	dietflags = 0
	taste_sensitivity = TASTE_SENSITIVITY_NO_TASTE

	//Default styles for created mobs.
	default_hair = "Nucleation Crystals"

	reagent_tag = PROCESS_ORG
	has_organ = list(
		"heart" =    /obj/item/organ/internal/heart/crystal,
		"crystallized brain" =    /obj/item/organ/internal/brain/crystal,
		"eyes" =     /obj/item/organ/internal/eyes/luminescent_crystal, //Standard darksight of 2.
		)
	vision_organ = /obj/item/organ/internal/eyes/luminescent_crystal
	var/hunger_threshold = NUTRITION_LEVEL_FED

/datum/species/nucleation/on_species_gain(mob/living/carbon/human/H)
	..()
	H.light_color = "#162900"
	H.set_light(2)
	H.AddSpell(new /obj/effect/proc_holder/spell/targeted/touch/drain_charge(null))
	H.AddSpell(new /obj/effect/proc_holder/spell/targeted/touch/supply_charge(null))

/datum/species/nucleation/handle_death(gibbed, mob/living/carbon/human/H)
	if(H.nutrition >= NUTRITION_LEVEL_FULL)
		H.visible_message("<span class='danger'>[H] lets off a massive burst of electricity as [H.p_they()] lose cohesion.</span>")
		tesla_zap(H, 5, H.nutrition * 2)
	else
		H.visible_message("<span class='danger'>[H] rapidly loses cohesion, collapsing in a flash of sparks.</span>")
		do_sparks(3, FALSE, get_turf(H))
	H.dust()

/datum/species/nucleation/handle_life(mob/living/carbon/human/H)
	switch(H.nutrition) //Very simple calculations being performed on Life() so that the relevant info only updates when the nutrition threshold changes.
		if(NUTRITION_LEVEL_FAT to INFINITY)
			if(hunger_threshold != NUTRITION_LEVEL_FAT)
				hunger_threshold = NUTRITION_LEVEL_FAT
				handle_nutrition_threshold(H, hunger_threshold)
		if(NUTRITION_LEVEL_FULL to NUTRITION_LEVEL_FAT)
			if(hunger_threshold != NUTRITION_LEVEL_FULL)
				hunger_threshold = NUTRITION_LEVEL_FULL
				handle_nutrition_threshold(H, hunger_threshold)
		if(NUTRITION_LEVEL_WELL_FED to NUTRITION_LEVEL_FULL)
			if(hunger_threshold != NUTRITION_LEVEL_WELL_FED)
				hunger_threshold = NUTRITION_LEVEL_WELL_FED
				handle_nutrition_threshold(H, hunger_threshold)
		if(NUTRITION_LEVEL_FED to NUTRITION_LEVEL_WELL_FED)
			if(hunger_threshold != NUTRITION_LEVEL_FED)
				hunger_threshold = NUTRITION_LEVEL_FED
				handle_nutrition_threshold(H, hunger_threshold)
		if(NUTRITION_LEVEL_HUNGRY to NUTRITION_LEVEL_FED)
			if(hunger_threshold != NUTRITION_LEVEL_HUNGRY)
				hunger_threshold = NUTRITION_LEVEL_HUNGRY
				handle_nutrition_threshold(H, hunger_threshold)
		if(NUTRITION_LEVEL_CURSED to NUTRITION_LEVEL_HUNGRY)
			if(hunger_threshold != NUTRITION_LEVEL_STARVING)
				hunger_threshold = NUTRITION_LEVEL_STARVING
				handle_nutrition_threshold(H, hunger_threshold)
	
	if(H.nutrition <= NUTRITION_LEVEL_HYPOGLYCEMIA && H.get_active_hand() && H.get_active_hand().get_cell() && H.get_active_hand().get_cell().charge > 0)
		var/obj/item/stock_parts/cell/cell = H.get_active_hand().get_cell()
		to_chat(H, "<span class='danger'>Due to your energy deficiency, you reflexively drain the charge from [H.get_active_hand()].</span>")
		H.nutrition += cell.charge / 25
		cell.charge = 0


/datum/species/nucleation/proc/handle_nutrition_threshold(mob/living/carbon/human/H, threshold)
	switch(threshold)
		if(NUTRITION_LEVEL_FAT)
			hunger_drain = HUNGER_FACTOR * 3
			H.set_light(5)
			H.adjust_max_health(110)
		if(NUTRITION_LEVEL_FULL)
			hunger_drain = HUNGER_FACTOR * 2
			H.set_light(4)
			H.adjust_max_health(105)
		if(NUTRITION_LEVEL_WELL_FED)
			hunger_drain = HUNGER_FACTOR * 1.5
			H.set_light(3)
			H.adjust_max_health(100)
		if(NUTRITION_LEVEL_FED)
			hunger_drain = HUNGER_FACTOR
			H.set_light(2)
			H.adjust_max_health(90)
		if(NUTRITION_LEVEL_HUNGRY)
			hunger_drain = HUNGER_FACTOR * 0.9
			H.set_light(1)
			H.adjust_max_health(80)
		if(NUTRITION_LEVEL_STARVING)
			hunger_drain = HUNGER_FACTOR * 0.8
			H.set_light(0)
			H.adjust_max_health(70)

// The relevant abilities for Nucleations which allows them to manipulate electricity.

//Drain charge from cells for nutrition.
/obj/effect/proc_holder/spell/targeted/touch/drain_charge
	name = "Drain Energy"
	desc = "Use your innate electrical affinity to feed yourself by draining electricity from devices."
	hand_path = /obj/item/melee/touch_attack/drain_charge
	charge_max = 0
	clothes_req = FALSE
	spell_charge_desc = "<span class='notice'>You fill your palm with a void of energy, leading within.</span>"
	var/drain_per_proc = 500

/obj/effect/proc_holder/spell/targeted/touch/drain_charge/proc/drain_charge(atom/movable/target, mob/living/user)
	if(!target)
		return FALSE
	var/obj/item/stock_parts/cell/cell = target.get_cell()
	if(!cell)
		return FALSE
	if(cell.charge >= drain_per_proc)
		cell.charge -= drain_per_proc
		user.nutrition += 25
		return TRUE
	user.nutrition += cell.charge/20
	cell.charge = 0
	return FALSE

/obj/effect/proc_holder/spell/targeted/touch/drain_charge/cast(list/targets, mob/user = usr)
	if(!user.get_active_hand())
		return ..(targets, user)
	if(!user.get_active_hand())
		return FALSE
	if(istype(user.get_active_hand(), /obj/item/melee/touch_attack))
		var/obj/item/melee/touch_attack/atk = user.get_active_hand()
		atk.attached_spell.Click(user)
		return FALSE
	if(!user.get_active_hand().get_cell())
		to_chat(user, "<span class = 'warning'>[user.get_active_hand()] does not seem to contain any energy at all.</span>")
		return FALSE
	if(user.get_active_hand().get_cell().charge <= 0)
		to_chat(user, "<span class = 'warning'>[user.get_active_hand()] does not contain enough energy to drain.</span>")
		return FALSE

	to_chat(user, "<span class = 'notice'>You begin drawing energy from [user.get_active_hand()].</span>")
	var/drainSuccess
	do
		drainSuccess = FALSE
		if(do_after(user, 5, needhand = FALSE, target = user.get_active_hand()))
			if(!user.get_active_hand() || !user.get_active_hand().get_cell())
				break
			drainSuccess = drain_charge(user.get_active_hand(), user)
	while(drainSuccess == TRUE)
	if(user.get_active_hand() && user.get_active_hand().get_cell() && user.get_active_hand().get_cell().charge <= 0)
		to_chat(user, "<span class = 'notice'>You completely drain the energy from [user.get_active_hand()].</span>")
	else
		to_chat(user, "<span class = 'warning'>You stop draining energy.</span>")

/obj/item/melee/touch_attack/drain_charge
	name = "\improper negatively charged hand"
	desc = "Allows you to consume energy from most anything with an electric charge."
	icon_state = "negcharge"
	catchphrase = null

/obj/item/melee/touch_attack/drain_charge/afterattack(atom/tar, mob/user, proximity)
	if(!proximity)
		return
	
	if(!ismovable(tar))
		return
	var/atom/movable/target = tar

	if(!istype(attached_spell,/obj/effect/proc_holder/spell/targeted/touch/drain_charge))
		to_chat(user,"<span class = 'danger'>Something has gone horribly wrong! Call a coder!</span>")
		return

	var/obj/effect/proc_holder/spell/targeted/touch/drain_charge/spell = attached_spell

	if(!target.get_cell())
		to_chat(user, "<span class = 'warning'>[target] does not seem to contain any energy at all.</span>")
		return FALSE
	if(target.get_cell().charge <= 0)
		to_chat(user, "<span class = 'warning'>[target] does not contain enough energy to drain.</span>")
		return FALSE

	to_chat(user, "<span class = 'notice'>You begin drawing energy from [target].</span>")
	var/drainSuccess = FALSE
	do
		drainSuccess = FALSE
		if(do_after(user, 5, needhand = FALSE, target = target))
			drainSuccess = spell.drain_charge(target, user)
	while(drainSuccess == TRUE)
	if(target.get_cell() && target.get_cell().charge <= 0)
		to_chat(user, "<span class = 'notice'>You completely drain the energy from [target].</span>")
	else
		to_chat(user, "<span class = 'warning'>You stop draining energy.</span>")

//Supply charge to cells and machines.
/obj/effect/proc_holder/spell/targeted/touch/supply_charge
	name = "Supply Energy"
	desc = "Use your innate electrical affinity to fulfill the energy needs of other devices."
	hand_path = /obj/item/melee/touch_attack/supply_charge
	charge_max = 0
	clothes_req = FALSE
	spell_charge_desc = "<span class='notice'>You fill your palm with energy from within.</span>"
	var/supply_per_proc = 200

/obj/effect/proc_holder/spell/targeted/touch/supply_charge/proc/supply_charge(atom/movable/target, mob/living/user)
	if(!target)
		return FALSE
	var/obj/item/stock_parts/cell/cell = target.get_cell()
	if(!cell || user.nutrition <= NUTRITION_LEVEL_STARVING)
		return FALSE
	var/difference = cell.maxcharge - cell.charge
	if(supply_per_proc < difference)
		cell.charge += supply_per_proc
		user.nutrition -= 100
		return TRUE
	user.nutrition -= difference/2
	cell.charge = cell.maxcharge
	return FALSE

/obj/effect/proc_holder/spell/targeted/touch/supply_charge/cast(list/targets, mob/user = usr)
	if(!user.get_active_hand())
		return ..(targets, user)
	if(!user.get_active_hand())
		return FALSE
	if(istype(user.get_active_hand(), /obj/item/melee/touch_attack))
		var/obj/item/melee/touch_attack/atk = user.get_active_hand()
		atk.attached_spell.Click(user)
		return FALSE
	if(!user.get_active_hand().get_cell())
		to_chat(user, "<span class = 'warning'>[user.get_active_hand()] does not seem to be able to contain any energy.</span>")
		return FALSE
	if(user.get_active_hand().get_cell().charge >= user.get_active_hand().get_cell().maxcharge)
		to_chat(user, "<span class = 'warning'>[user.get_active_hand()] is fully charged.</span>")
		return FALSE

	to_chat(user, "<span class = 'notice'>You begin venting energy into [user.get_active_hand()].</span>")
	var/fillSuccess
	do
		fillSuccess = FALSE
		if(do_after(user, 5, needhand = FALSE, target = user.get_active_hand()))
			if(!user.get_active_hand() || !user.get_active_hand().get_cell())
				break
			fillSuccess = supply_charge(user.get_active_hand(), user)
	while(fillSuccess == TRUE)
	if(user.get_active_hand() && user.get_active_hand().get_cell() && user.get_active_hand().get_cell().charge >= user.get_active_hand().get_cell().maxcharge)
		to_chat(user, "<span class = 'notice'>You completely fill [user.get_active_hand()] with energy.</span>")
	else if(user.nutrition <= NUTRITION_LEVEL_STARVING)
		to_chat(user, "<span class = 'warning'>You no longer have enough energy to fill [user.get_active_hand()]</span>")
	else
		to_chat(user, "<span class = 'warning'>You stop supplying energy.</span>")

/obj/item/melee/touch_attack/supply_charge
	name = "\improper positively charged hand"
	desc = "Allows you to consume energy from most anything with an electric charge."
	icon_state = "poscharge"
	catchphrase = null
	var/being_used = FALSE
	var/datum/power_redirect/nucleation/redirect

/obj/item/melee/touch_attack/supply_charge/afterattack(atom/tar, mob/user, proximity)
	if(!proximity)
		return
	
	if(!ismovable(tar))
		return
	var/atom/movable/target = tar

	if(!istype(attached_spell,/obj/effect/proc_holder/spell/targeted/touch/supply_charge))
		to_chat(user,"<span class = 'danger'>Something has gone horribly wrong! Call a coder!</span>")
		return

	if(!target.get_cell() && istype(target, /obj/machinery)) //We only want machinery without cells, since we'd want to fill SMES's and such.
		if(being_used)
			to_chat(user,"<span class = 'warning'>You are already supplying power!</span>")
			return FALSE
		being_used = TRUE
		to_chat(user,"<span class = 'notice'>You begin supplying power to [target].</span>")
		var/obj/machinery/M = target
		if(!redirect)
			redirect = new(user, owner = user)
		redirect.supply_to(M)
		
		while(do_after(user, 5, needhand = FALSE, target = target))
			if(!redirect.powered())
				break
		if(!redirect.powered())
			to_chat(user,"<span class = 'warning'>You no longer have enough power to keep [target] running.</span>")
		redirect.cut_target()
		being_used = FALSE
		return TRUE

	var/obj/effect/proc_holder/spell/targeted/touch/supply_charge/spell = attached_spell
	if(!target.get_cell())
		to_chat(user, "<span class = 'warning'>[target] does not seem to be able to contain any energy.</span>")
		return FALSE
	if(target.get_cell().charge >= target.get_cell().maxcharge)
		to_chat(user, "<span class = 'warning'>[target] is fully charged.</span>")
		return FALSE

	if(being_used)
		to_chat(user,"<span class = 'warning'>You are already supplying power!</span>")
		return FALSE

	to_chat(user, "<span class = 'notice'>You begin venting energy into [target].</span>")
	var/fillSuccess = FALSE
	being_used = TRUE
	do
		fillSuccess = FALSE
		if(do_after(user, 5, needhand = FALSE, target = target))
			fillSuccess = spell.supply_charge(target, user)
	while(fillSuccess == TRUE)
	being_used = FALSE
	if(target.get_cell() && target.get_cell().charge >= target.get_cell().maxcharge)
		to_chat(user, "<span class = 'notice'>You completely fill [target] with energy.</span>")
	else if(user.nutrition <= NUTRITION_LEVEL_STARVING)
		to_chat(user, "<span class = 'warning'>You no longer have enough energy to fill [target]</span>")
	else
		to_chat(user, "<span class = 'warning'>You stop supplying energy.</span>")

/obj/item/melee/touch_attack/supply_charge/Destroy()
	qdel(redirect)
	return ..()

/datum/power_redirect/nucleation
	name = "Nucleation Redirect"
	var/mob/living/owner

/datum/power_redirect/nucleation/New(object, mob/living/owner = null)
	. = ..(object)
	src.owner = owner

/datum/power_redirect/nucleation/powered()
	if(owner && owner.nutrition > NUTRITION_LEVEL_STARVING)
		return TRUE
	return FALSE

/datum/power_redirect/nucleation/use_power(amount)
	if(owner)
		owner.nutrition -= amount/15