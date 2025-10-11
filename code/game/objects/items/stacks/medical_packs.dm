/obj/item/stack/medical
	name = "medical pack"
	singular_name = "medical pack"
	icon = 'icons/obj/medical.dmi'
	amount = 6
	max_amount = 6
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	resistance_flags = FLAMMABLE
	max_integrity = 40
	parent_stack = TRUE
	var/heal_brute = 0
	var/heal_burn = 0
	var/delay = 20
	var/unique_handling = FALSE //some things give a special prompt, do we want to bypass some checks in parent?
	var/stop_bleeding = 0
	var/healverb = "bandage"

/obj/item/stack/medical/proc/apply(mob/living/M, mob/user)
	if(get_amount() <= 0)
		if(is_cyborg)
			to_chat(user, "<span class='warning'>You don't have enough energy to dispense more [singular_name]\s!</span>")
		return TRUE

	if(!iscarbon(M) && !isanimal_or_basicmob(M))
		to_chat(user, "<span class='danger'>[src] cannot be applied to [M]!</span>")
		return TRUE

	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='danger'>You don't have the dexterity to do this!</span>")
		return TRUE


	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/affecting = H.get_organ(user.zone_selected)

		if(!H.can_inject(user, TRUE))
			return TRUE

		if(!affecting)
			to_chat(user, "<span class='danger'>That limb is missing!</span>")
			return TRUE

		if(affecting.is_robotic())
			to_chat(user, "<span class='danger'>This can't be used on a robotic limb.</span>")
			return TRUE

		if(M == user && !unique_handling)
			user.visible_message("<span class='notice'>[user] starts to apply [src] on [H]...</span>")
			if(!do_mob(user, H, delay))
				return TRUE
		return

	if(isanimal_or_basicmob(M))
		var/mob/living/critter = M
		if(!(critter.healable))
			to_chat(user, "<span class='notice'>You cannot use [src] on [critter]!</span>")
			return
		else if(critter.health == critter.maxHealth)
			to_chat(user, "<span class='notice'>[critter] is at full health.</span>")
			return
		else if(heal_brute < 1)
			to_chat(user, "<span class='notice'>[src] won't help [critter] at all.</span>")
			return

		critter.heal_organ_damage(heal_brute, heal_burn)
		user.visible_message("<span class='green'>[user] applies [src] on [critter].</span>", \
							"<span class='green'>You apply [src] on [critter].</span>")

		use(1)

	else
		M.heal_organ_damage(heal_brute, heal_burn)
		user.visible_message("<span class='green'>[user] applies [src] on [M].</span>", \
							"<span class='green'>You apply [src] on [M].</span>")
		use(1)

/obj/item/stack/medical/attack__legacy__attackchain(mob/living/M, mob/user)
	return apply(M, user)

/obj/item/stack/medical/attack_self__legacy__attackchain(mob/user)
	return apply(user, user)

/obj/item/stack/medical/proc/heal(mob/living/M, mob/user)
	var/mob/living/carbon/human/H = M
	var/obj/item/organ/external/affecting = H.get_organ(user.zone_selected)
	user.visible_message("<span class='green'>[user] [healverb]s the wounds on [H]'s [affecting.name].</span>", \
						"<span class='green'>You [healverb] the wounds on [H]'s [affecting.name].</span>" )

	var/rembrute = max(0, heal_brute - affecting.brute_dam) // Maxed with 0 since heal_damage let you pass in a negative value
	var/remburn = max(0, heal_burn - affecting.burn_dam) // And deduct it from their health (aka deal damage)
	var/nrembrute = rembrute
	var/nremburn = remburn
	affecting.heal_damage(heal_brute, heal_burn)
	var/list/achildlist
	if(!isnull(affecting.children))
		achildlist = affecting.children.Copy()
	var/parenthealed = FALSE
	while(rembrute + remburn > 0) // Don't bother if there's not enough leftover heal
		var/obj/item/organ/external/E
		if(LAZYLEN(achildlist))
			E = pick_n_take(achildlist) // Pick a random children and then remove it from the list
		else if(affecting.parent && !parenthealed) // If there's a parent and no healing attempt was made on it
			E = affecting.parent
			parenthealed = TRUE
		else
			break // If the organ have no child left and no parent / parent healed, break
		if(E.status & ORGAN_ROBOT || E.open) // Ignore robotic or open limb
			continue
		else if(!E.brute_dam && !E.burn_dam) // Ignore undamaged limb
			continue
		nrembrute = max(0, rembrute - E.brute_dam) // Deduct the healed damage from the remain
		nremburn = max(0, remburn - E.burn_dam)
		E.heal_damage(rembrute, remburn)
		rembrute = nrembrute
		remburn = nremburn
		user.visible_message("<span class='green'>[user] [healverb]s the wounds on [H]'s [E.name] with the remaining medication.</span>", \
							"<span class='green'>You [healverb] the wounds on [H]'s [E.name] with the remaining medication.</span>" )
	return affecting

//Bruise Packs//

/obj/item/stack/medical/bruise_pack
	name = "roll of gauze"
	singular_name = "gauze length"
	desc = "Some sterile gauze to wrap around bloody stumps."
	icon = 'icons/obj/stacks/miscellaneous.dmi'
	icon_state = "gauze"
	origin_tech = "biotech=2"
	merge_type = /obj/item/stack/medical/bruise_pack
	max_amount = 12
	heal_brute = 5
	stop_bleeding = 1800
	dynamic_icon_state = TRUE

/obj/item/stack/medical/bruise_pack/attackby__legacy__attackchain(obj/item/I, mob/user, params)
	if(I.sharp)
		if(get_amount() < 2)
			to_chat(user, "<span class='warning'>You need at least two gauzes to do this!</span>")
			return
		new /obj/item/stack/sheet/cloth(user.drop_location())
		user.visible_message("[user] cuts [src] into pieces of cloth with [I].", \
					"<span class='notice'>You cut [src] into pieces of cloth with [I].</span>", \
					"<span class='italics'>You hear cutting.</span>")
		use(2)
	else
		return ..()

/obj/item/stack/medical/bruise_pack/apply(mob/living/M, mob/user)
	if(..())
		return TRUE

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/affecting = H.get_organ(user.zone_selected)
		for(var/obj/item/organ/external/E in H.bodyparts)
			if(E.open >= ORGAN_ORGANIC_OPEN)
				to_chat(user, "<span class='warning'>[E] is cut open, you'll need more than a bandage!</span>")
				return
		affecting.germ_level = 0

		if(stop_bleeding)
			if(!H.bleedsuppress) //so you can't stack bleed suppression
				H.suppress_bloodloss(stop_bleeding)

		heal(H, user)

		H.UpdateDamageIcon()
		use(1)

/obj/item/stack/medical/bruise_pack/improvised
	name = "improvised gauze"
	singular_name = "improvised gauze"
	desc = "A roll of cloth roughly cut from something that can stop bleeding, but does not heal wounds."
	merge_type = /obj/item/stack/medical/bruise_pack/improvised
	heal_brute = 0
	stop_bleeding = 900

/obj/item/stack/medical/bruise_pack/advanced
	name = "advanced trauma kit"
	icon = 'icons/obj/medical.dmi'
	singular_name = "advanced trauma kit"
	desc = "An advanced trauma kit for severe injuries."
	icon_state = "traumakit"
	belt_icon = "traumakit"
	merge_type = /obj/item/stack/medical/bruise_pack/advanced
	max_amount = 6
	heal_brute = 25
	stop_bleeding = 0
	dynamic_icon_state = FALSE

/obj/item/stack/medical/bruise_pack/advanced/cyborg
	energy_type = /datum/robot_storage/energy/medical/adv_brute_kit
	is_cyborg = TRUE

/obj/item/stack/medical/bruise_pack/advanced/cyborg/syndicate
	energy_type = /datum/robot_storage/energy/medical/adv_brute_kit/syndicate

//Ointment//


/obj/item/stack/medical/ointment
	name = "ointment"
	desc = "Used to treat those nasty burns."
	gender = PLURAL
	icon = 'icons/obj/stacks/miscellaneous.dmi'
	singular_name = "ointment"
	icon_state = "ointment"
	origin_tech = "biotech=2"
	healverb = "salve"
	heal_burn = 5
	dynamic_icon_state = TRUE
	merge_type = /obj/item/stack/medical/ointment

/obj/item/stack/medical/ointment/apply(mob/living/M, mob/user)
	if(..())
		return 1

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/affecting = H.get_organ(user.zone_selected)

		if(affecting.open == ORGAN_CLOSED)
			affecting.germ_level = 0

			heal(H, user)

			H.UpdateDamageIcon()
			use(1)
		else
			to_chat(user, "<span class='warning'>[affecting] is cut open, you'll need more than some ointment!</span>")

/obj/item/stack/medical/ointment/heal(mob/living/M, mob/user)
	var/obj/item/organ/external/affecting = ..()
	if((affecting.status & ORGAN_BURNT) && !(affecting.status & ORGAN_SALVED))
		to_chat(affecting.owner, "<span class='notice'>As [src] is applied to your burn wound, you feel a soothing cold and relax.</span>")
		affecting.status |= ORGAN_SALVED
		addtimer(CALLBACK(affecting, TYPE_PROC_REF(/obj/item/organ/external, remove_ointment), heal_burn), 3 MINUTES)

/obj/item/organ/external/proc/remove_ointment(heal_amount) //de-ointmenterized D:
	status &= ~ORGAN_SALVED
	perma_injury = max(perma_injury - heal_amount, 0)
	if(owner)
		owner.updatehealth("permanent injury removal")
	if(!perma_injury)
		fix_burn_wound(update_health = FALSE)
		to_chat(owner, "<span class='notice'>You feel your [src.name]'s burn wound has fully healed, and the rest of the salve absorbs into it.</span>")
	else
		to_chat(owner, "<span class='notice'>You feel your [src.name]'s burn wound has healed a little, but the applied salve has already vanished.</span>")

/obj/item/stack/medical/ointment/advanced
	name = "advanced burn kit"
	singular_name = "advanced burn kit"
	desc = "An advanced treatment kit for severe burns."
	icon = 'icons/obj/medical.dmi'
	icon_state = "burnkit"
	belt_icon = "burnkit"
	heal_burn = 25
	dynamic_icon_state = FALSE
	merge_type = /obj/item/stack/medical/ointment/advanced

/obj/item/stack/medical/ointment/advanced/cyborg
	energy_type = /datum/robot_storage/energy/medical/adv_burn_kit
	is_cyborg = TRUE

/obj/item/stack/medical/ointment/advanced/cyborg/syndicate
	energy_type = /datum/robot_storage/energy/medical/adv_burn_kit/syndicate

//Medical Herbs//
/obj/item/stack/medical/bruise_pack/comfrey
	name = "\improper Comfrey poultice"
	singular_name = "Comfrey poultice"
	desc = "A medical poultice for treating brute injuries, made from crushed comfrey leaves. The effectiveness of the poultice depends on the potency of the comfrey it was made from."
	icon = 'icons/obj/medical.dmi'
	icon_state = "traumapoultice"
	max_amount = 6
	stop_bleeding = 0
	heal_brute = 12
	drop_sound = 'sound/misc/moist_impact.ogg'
	mob_throw_hit_sound = 'sound/misc/moist_impact.ogg'
	hitsound = 'sound/misc/moist_impact.ogg'
	dynamic_icon_state = FALSE

/obj/item/stack/medical/bruise_pack/comfrey/heal(mob/living/M, mob/user)
	playsound(src, 'sound/misc/soggy.ogg', 30, TRUE)
	return ..()

/obj/item/stack/medical/ointment/aloe
	name = "\improper Aloe Vera poultice"
	singular_name = "Aloe Vera poultice"
	desc = "A medical poultice for treating burns, made from crushed aloe vera leaves. The effectiveness of the poultice depends on the potency of the aloe it was made from."
	icon = 'icons/obj/medical.dmi'
	icon_state = "burnpoultice"
	heal_burn = 12
	drop_sound = 'sound/misc/moist_impact.ogg'
	mob_throw_hit_sound = 'sound/misc/moist_impact.ogg'
	hitsound = 'sound/misc/moist_impact.ogg'
	dynamic_icon_state = FALSE

/obj/item/stack/medical/ointment/aloe/heal(mob/living/M, mob/user)
	playsound(src, 'sound/misc/soggy.ogg', 30, TRUE)
	return ..()

// Splints
/obj/item/stack/medical/splint
	name = "medical splints"
	singular_name = "medical splint"
	icon_state = "splint"
	unique_handling = TRUE
	delay = 100
	merge_type = /obj/item/stack/medical/splint
	var/other_delay = 0

/obj/item/stack/medical/splint/apply(mob/living/M, mob/user)
	if(..())
		return TRUE

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/affecting = H.get_organ(user.zone_selected)
		var/limb = affecting.name

		if(affecting.status & ORGAN_SPLINTED)
			to_chat(user, "<span class='danger'>[H]'s [limb] is already splinted!</span>")
			if(tgui_alert(user, "Would you like to remove the splint from [H]'s [limb]?", "Splint removal", list("Yes", "No")) == "Yes")
				affecting.status &= ~ORGAN_SPLINTED
				H.handle_splints()
				to_chat(user, "<span class='notice'>You remove the splint from [H]'s [limb].</span>")
			return TRUE

		if((M == user && delay > 0) || (M != user && other_delay > 0))
			user.visible_message("<span class='notice'>[user] starts to apply [src] to [H]'s [limb].</span>", \
									"<span class='notice'>You start to apply [src] to [H]'s [limb].</span>", \
									"<span class='notice'>You hear something being wrapped.</span>")

		if(M == user && !do_mob(user, H, delay))
			return TRUE
		else if(!do_mob(user, H, other_delay))
			return TRUE

		user.visible_message("<span class='notice'>[user] applies [src] to [H]'s [limb].</span>", \
								"<span class='notice'>You apply [src] to [H]'s [limb].</span>")

		affecting.status |= ORGAN_SPLINTED
		affecting.splinted_count = H.step_count
		H.handle_splints()
		use(1)

/obj/item/stack/medical/splint/cyborg
	energy_type = /datum/robot_storage/energy/medical/splint
	is_cyborg = TRUE

/obj/item/stack/medical/splint/cyborg/syndicate
	energy_type = /datum/robot_storage/energy/medical/splint/syndicate

/obj/item/stack/medical/splint/tribal
	name = "tribal splints"
	icon_state = "tribal_splint"
	other_delay = 50

// Sutures and burn meshes

/obj/item/stack/medical/suture
	name = "sutures"
	singular_name = "suture"
	desc = "A bundle of sterilized sutures used for sealing up minor cuts and lacerations."
	icon_state = "suture"
	gender = PLURAL
	merge_type = /obj/item/stack/medical/suture
	amount = 10
	max_amount = 10
	heal_brute = 10
	stop_bleeding = 1200
	dynamic_icon_state = TRUE
	delay = 1 SECONDS
	healverb = "suturing"
	var/healverb_past = "sutured"
	var/self_delay = 3 SECONDS
	var/mob/current_target
	/// The type of the item we create when depleted
	var/depleted_type = /obj/item/suture_needle

/obj/item/stack/medical/suture/apply(mob/living/carbon/human/target, mob/user)
	. = TRUE
	if(current_target)
		if(current_target != target)
			to_chat(user, "<span class='warning'>You're already suturing [current_target].</span>")
			return
		// Allow for cancelling of the target by clicking again
		interrupt_do_after_once(user, current_target)
		to_chat(user, "<span class='warning'>You stop [healverb] [target.i_yourself(user)].</span>")
		return
	if(!ishuman(target) || !target.can_inject(user, TRUE))
		return
	var/heal_type = (heal_brute ? BRUTE : BURN)
	var/heal_display = (heal_brute ? BRUTE : "burn")
	if(!target.get_damage_amount(heal_type))
		to_chat(user, "<span class='warning'>[target.i_you(user, TRUE)] [target.i_do(user)]n't have any [heal_display] damage.</span>")
		return

	var/obj/item/organ/external/current_limb = target.get_organ(user.zone_selected)
	if(!current_limb)
		to_chat(user, "<span class='warning'>That limb is missing!</span>")
		return
	if(current_limb.is_robotic())
		to_chat(user, "<span class='warning'>This can't be used on a robotic limb.</span>")
		return
	// Swap to another limb if the current one has no damage.
	if(!most_damaged_limb(target))
		to_chat(user, "<span class='warning'>[target.i_you(user, TRUE)] [target.i_do(user)]n't have any [heal_display] damage that could be [healverb_past].</span>")
		return

	var/mend_time = delay
	if(target == user)
		mend_time = self_delay

	user.visible_message("<span class='notice'>[user] begins [healverb] [target.e_themselves(user)] with [src].</span>", "<span class='notice'>You begin [healverb] [target.i_your(user)] [current_limb.name] with [src].</span>")
	current_limb = try_swap_to_most_damaged_limb(target, user, current_limb)
	if(!current_limb)
		return

	var/last_targetted_zone = user.zone_selected
	current_target = target
	while(do_after_once(user, mend_time, target = target))
		if(!target.can_inject(user, TRUE, current_limb.limb_name))
			break

		var/cut_open = FALSE
		if(stop_bleeding)
			for(var/obj/item/organ/external/E in target.bodyparts)
				if(E.open >= ORGAN_ORGANIC_OPEN)
					cut_open = TRUE
					to_chat(user, "<span class='warning'>[target]'s [E.name] is cut open, you'll need more than some [name] to stop [target.i_your(user)] bleeding.</span>")
					break
		if(!apply_to(target, user, current_limb, !cut_open))
			break
		if(is_zero_amount(FALSE))
			if(depleted_type)
				var/needle = new depleted_type(src.loc)
				if(ishuman(user))
					var/mob/living/carbon/human/human_user = user
					human_user.put_in_active_hand(needle)
			qdel(src)
			break
		if(!target.get_damage_amount(heal_type))
			user.visible_message("<span class='warning'>[user] finishes [healverb] [target.e_themselves(user)] with [src].</span>", "<span class='notice'>You finish [healverb] [target.i_yourself(user)] with [src].</span>")
			break

		var/skip_swap = FALSE
		if(last_targetted_zone != user.zone_selected)
			last_targetted_zone = user.zone_selected
			var/new_limb = on_target_zone_change(target, user)
			if(new_limb && current_limb != new_limb)
				current_limb = new_limb
				skip_swap = TRUE
				to_chat(user, "<span class='notice'>You switch to [healverb] [target.i_your(user)] <b>[current_limb.name]</b>.</span>")

		if(!skip_swap)
			current_limb = try_swap_to_most_damaged_limb(target, user, current_limb)
			if(!current_limb)
				user.visible_message("<span class='warning'>[user] finishes [healverb] [target.e_themselves(user)] with [src].</span>", "<span class='notice'>You finish [healverb] [target.i_yourself(user)] with [src].</span>")
				break

		if(!target.can_inject(user, TRUE, current_limb.limb_name))
			break
	current_target = null
	user.changeNext_move(CLICK_CD_MELEE)

/obj/item/stack/medical/suture/proc/apply_to(mob/living/carbon/human/target, mob/user, obj/item/organ/external/current_limb, allow_stop_bleeding = TRUE)
	if(!use(1))
		return FALSE

	current_limb.heal_damage(heal_brute, heal_burn, FALSE, FALSE, updating_health = TRUE)
	target.UpdateDamageIcon()

	if(stop_bleeding && !target.bleedsuppress && allow_stop_bleeding)
		target.suppress_bloodloss(stop_bleeding)
	return TRUE

/obj/item/stack/medical/suture/proc/most_damaged_limb(mob/living/carbon/human/target)
	var/obj/item/organ/external/most_damaged
	var/most_damaged_amount = 0
	var/focus_brute = (heal_brute > 0)
	for(var/obj/item/organ/external/E in target.bodyparts)
		if(QDELETED(E))
			continue
		if(E.is_robotic())
			continue
		if(focus_brute)
			if(E.brute_dam > most_damaged_amount)
				most_damaged = E
				most_damaged_amount = E.brute_dam
		else if(E.burn_dam > most_damaged_amount)
			most_damaged = E
			most_damaged_amount = E.burn_dam
	return most_damaged

/obj/item/stack/medical/suture/proc/try_swap_to_most_damaged_limb(mob/living/carbon/human/target, mob/user, obj/item/organ/external/current_limb)
	if(heal_brute && current_limb.brute_dam)
		return current_limb
	if(heal_burn && current_limb.burn_dam)
		return current_limb

	var/obj/item/organ/external/new_limb = most_damaged_limb(target)
	if(!new_limb)
		return
	if(current_limb != new_limb)
		to_chat(user, "<span class='notice'>You begin [healverb] [target.i_your(user)] <b>[new_limb.name]</b>.</span>")
	if(!do_after(user, delay / 2, target = target))
		return
	return new_limb

/obj/item/stack/medical/suture/proc/on_target_zone_change(mob/living/carbon/human/target, mob/user)
	var/obj/item/organ/external/new_limb = target.get_organ(user.zone_selected)
	if(!new_limb)
		to_chat(user, "<span class='warning'>That limb is missing!</span>")
		return FALSE
	if(new_limb.is_robotic())
		to_chat(user, "<span class='warning'>This can't be used on a robotic limb.</span>")
		return FALSE

	if(heal_brute && new_limb.brute_dam)
		return new_limb
	if(heal_burn && new_limb.burn_dam)
		return new_limb
	return FALSE

/obj/item/stack/medical/suture/emergency
	name = "emergency sutures"
	singular_name = "emergency suture"
	desc = "A small bundle of cheap sutures. They're not pretty, but still quite effective at keeping the blood inside your body."
	icon_state = "suture_emer"
	merge_type = /obj/item/stack/medical/suture/emergency
	heal_brute = 5

/obj/item/stack/medical/suture/medicated
	name = "medicated sutures"
	singular_name = "medicated suture"
	desc = "A bundle of sterilized sutures used for sealing up minor cuts and lacerations. These have been treated with potent healing chemicals, dramatically improving their wound-sealing capability."
	icon_state = "suture_medicated"
	merge_type = /obj/item/stack/medical/suture/medicated
	heal_brute = 15
	stop_bleeding = 2000

/obj/item/stack/medical/suture/regen_mesh
	name = "regenerative mesh"
	desc = "A sheet of bacteriostatic mesh used to graft minor burns, housed in a sterile packet."
	singular_name = "mesh piece"
	icon_state = "regen_mesh"
	merge_type = /obj/item/stack/medical/suture/regen_mesh
	healverb = "grafting"
	healverb_past = "grafted"
	heal_brute = 0
	heal_burn = 10
	depleted_type = null
	/// This var determines if the sterile packaging of the mesh has been opened.
	var/is_open = TRUE

/obj/item/stack/medical/suture/regen_mesh/Initialize(mapload, new_amount, merge)
	. = ..()
	if(amount == max_amount)  // only seal full mesh packs
		is_open = FALSE
		update_appearance()

/obj/item/stack/medical/suture/regen_mesh/update_icon_state()
	if(is_open)
		return ..()
	icon_state = "[initial(icon_state)]_closed"

/obj/item/stack/medical/suture/regen_mesh/apply(mob/living/carbon/human/target, mob/user)
	open_mesh()
	. = ..()

/obj/item/stack/medical/suture/regen_mesh/change_stack(mob/user, amount)
	open_mesh()
	. = ..()

/obj/item/stack/medical/suture/regen_mesh/proc/open_mesh()
	if(!is_open)
		is_open = TRUE
		update_icon(UPDATE_ICON_STATE)
		playsound(src, 'sound/items/poster_ripped.ogg', 20, TRUE)

/obj/item/stack/medical/suture/regen_mesh/advanced
	name = "advanced regenerative mesh"
	desc = "A sheet of medically-treated bacteriostatic mesh used to graft moderate burns, housed in a sterile packet."
	icon_state = "advanced_mesh"
	merge_type = /obj/item/stack/medical/suture/regen_mesh/advanced
	heal_burn = 15

/obj/item/suture_needle
	name = "suture needle"
	desc = "A curved needle used for suturing wounds. It doesn't seem to have any thread attached."
	icon = 'icons/obj/medical.dmi'
	icon_state = "suture_needle"
	force = 1
	attack_verb = list("poked", "pricked", "stabbed")
	hitsound = null
	w_class = WEIGHT_CLASS_TINY

/obj/item/suture_needle/examine(mob/user)
	. = ..()
	. += "<span class='notice'>You can add thread with the <i>crafting menu</i>.</span>"

/obj/item/biomesh
	name = "biomesh"
	desc = "A lattice of easily-dissolved plastics used to hold gels in place over open wounds."
	icon = 'icons/obj/medical.dmi'
	icon_state = "biomesh"
	hitsound = null
	w_class = WEIGHT_CLASS_TINY

/obj/item/biomesh/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It can be made into both normal and advanced regenerative mesh with the <i>crafting menu</i>.</span>"
