/obj/item/dissector
	name = "Dissection Manager"
	desc = "An advanced handheld device that assists with the preparation and removal of non-standard alien organs."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "dissector"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	flags = CONDUCT
	w_class = WEIGHT_CLASS_SMALL
	tool_behaviour = TOOL_DISSECTOR

/obj/item/dissector/upgraded
	name = "Improved Dissection Manager"
	desc = "An advanced handheld device that assists with the preparation and removal of non-standard alien organs. This one has had several improvements applied to it."
	icon_state = "dissector_upgrade"

/obj/item/dissector/alien
	name = "Alien Dissection Manager"
	desc = "A tool of alien origin, capable of near impossible levels of precision during dissections."
	icon_state = "dissector"

/datum/surgery_step/generic/dissect
	name = "dissect"
	allowed_tools = list(
		/obj/item/dissector/alien = 100,
		/obj/item/dissector/upgraded = 70,
		TOOL_DISSECTOR = 40,
		/obj/item/scalpel/laser/manager = 10,
		/obj/item/wirecutters = 5,
		/obj/item/kitchen/utensil/fork = 1
	)

	preop_sound = 'sound/surgery/organ1.ogg'
	success_sound = 'sound/surgery/organ2.ogg'
	failure_sound = 'sound/effects/bone_break_1.ogg'
	time = 1.6 SECONDS

// We dont want to keep the unidentified organ as an implantable version to skip the research phase
/obj/item/xeno_organ
	name = "Unidentified Mass"
	desc = "This unusual clump of flesh, though now still, holds great potential. It will require revitalization via slime therapy to get any use out of."
	icon = 'icons/obj/xeno_organs.dmi'
	icon_state = "organ4"
	origin_tech = null
	// What does this object turn into when analyzed?
	var/true_organ_type = /obj/item/organ/internal/liver/xenobiology/toxic
	//What quality will be hidden from us?
	var/unknown_quality = ORGAN_NORMAL

/obj/item/xeno_organ/Initialize(mapload)
	. = ..()
	icon_state = "organ[rand(1, 18)]"

// A list of parent objects, to inherent the functions of where they are placed.
/obj/item/organ/internal/liver/xenobiology
	name = "Unidentified Mass"
	desc = "This is a parent object and should not appear. Contact a developer."
	icon = 'icons/obj/xeno_organs.dmi'
	icon_state = "organ4"
	dead_icon = null
	origin_tech = null
	tough = TRUE

/obj/item/organ/internal/heart/xenobiology
	name = "Unidentified Mass"
	desc = "This is a parent object and should not appear. Contact a developer."
	icon = 'icons/obj/xeno_organs.dmi'
	icon_state = "organ4"
	dead_icon = null
	origin_tech = null
	tough = TRUE

/obj/item/organ/internal/lungs/xenobiology
	name = "Unidentified Mass"
	desc = "This is a parent object and should not appear. Contact a developer."
	icon = 'icons/obj/xeno_organs.dmi'
	icon_state = "organ4"
	dead_icon = null
	origin_tech = null
	tough = TRUE

/obj/item/organ/internal/kidneys/xenobiology
	name = "Unidentified Mass"
	desc = "This is a parent object and should not appear. Contact a developer."
	icon = 'icons/obj/xeno_organs.dmi'
	icon_state = "organ4"
	dead_icon = null
	origin_tech = null
	tough = TRUE

/obj/item/organ/internal/appendix/xenobiology
	name = "Unidentified Mass"
	desc = "This is a parent object and should not appear. Contact a developer."
	icon = 'icons/obj/xeno_organs.dmi'
	icon_state = "organ4"
	dead_icon = null
	origin_tech = null
	tough = TRUE

/obj/item/organ/internal/cyberimp/arm/xenobiology
	name = "Unidentified Mass"
	desc = "This is a parent object and should not appear. Contact a developer."
	icon = 'icons/obj/xeno_organs.dmi'
	icon_state = "organ4"
	dead_icon = null
	origin_tech = null
	tough = TRUE

/obj/item/organ/internal/cyberimp/chest/xenobiology
	name = "Unidentified Mass"
	desc = "This is a parent object and should not appear. Contact a developer."
	icon = 'icons/obj/xeno_organs.dmi'
	icon_state = "organ4"
	dead_icon = null
	origin_tech = null
	tough = TRUE

/obj/item/organ/internal/cyberimp/brain/xenobiology
	name = "Unidentified Mass"
	desc = "This is a parent object and should not appear. Contact a developer."
	icon = 'icons/obj/xeno_organs.dmi'
	icon_state = "organ4"
	dead_icon = null
	origin_tech = null
	tough = TRUE

/obj/item/organ/internal/cyberimp/mouth/xenobiology
	name = "Unidentified Mass"
	desc = "This is a parent object and should not appear. Contact a developer."
	icon = 'icons/obj/xeno_organs.dmi'
	icon_state = "organ4"
	dead_icon = null
	origin_tech = null
	tough = TRUE

/obj/item/organ/internal/liver/xenobiology/toxic
	name = "Toxic Glands"
	desc = "These fleshy glands' alien chemistry are incompatable with most humanoid life."

/obj/item/organ/internal/liver/xenobiology/toxic/on_life()
	. = ..()
	if(!(owner.mob_biotypes & MOB_ORGANIC))
		return
	to_chat(owner, "<span class='notice'>You feel nausious as your insides feel like they're disintegrating!</span>")
	switch(organ_quality)
		if(ORGAN_DAMAGED)
			owner.adjustToxLoss(1)
		if(ORGAN_NORMAL)
			owner.adjustToxLoss(2)
		if(ORGAN_PRISTINE)
			owner.adjustToxLoss(5)
			if(prob(5))
				owner.add_vomit_floor(toxvomit = TRUE)
				owner.AdjustConfused(rand(4 SECONDS, 6 SECONDS))

/obj/item/organ/internal/liver/xenobiology/detox
	name = "Chemical Neutralizers"
	desc = "These glands seem to absorb any liquid they come in contact with, neutralizing any unnatural substances."
	analyzer_price = 25

/obj/item/organ/internal/liver/xenobiology/detox/on_life()
	. = ..()
	if(!(owner.mob_biotypes & MOB_ORGANIC))
		return
	switch(organ_quality)
		if(ORGAN_DAMAGED)
			owner.adjustToxLoss(-1)
		if(ORGAN_NORMAL)
			owner.adjustToxLoss(-2)
		if(ORGAN_PRISTINE) // careful, it removes good shit too
			owner.adjustToxLoss(-3)
			for(var/datum/reagent/R in owner.reagents.reagent_list)
				if(R != src)
					owner.reagents.remove_reagent(R.id,4)

/obj/item/organ/internal/heart/xenobiology/vestigial
	name = "Vestigial Organ"
	desc = "Whether this has ever had any function is a mystery. It certainly doesnt work in its current state."

/obj/item/organ/internal/heart/xenobiology/vestigial/on_life()
	. = ..()
	if(!owner.undergoing_cardiac_arrest())
		owner.set_heartattack(TRUE) // what did you expect?

/obj/item/organ/internal/heart/xenobiology/incompatible
	name = "Incompatable Organ"
	desc = "This organ is largely incompatable with humanoid physiology. It will probablywork, but will cause a host of other issues."

/obj/item/organ/internal/heart/xenobiology/incompatible/on_life()
	if(!next_activation || next_activation <= world.time)
		if(prob(1))
			if(!owner.undergoing_cardiac_arrest())
				owner.set_heartattack(TRUE) // yeah probably shouldnt use this
		owner.AdjustConfused(5 SECONDS)
		owner.vomit(20)
		next_activation = world.time + 20 SECONDS

/obj/item/organ/internal/lungs/xenobiology/flame_sack
	name = "Flame Sack"
	desc = "An unusual set of aerosolizing glands capable of starting light fires."
	analyzer_price = 50

/obj/item/organ/internal/lungs/xenobiology/flame_sack/insert(mob/living/carbon/M, special = 0, dont_remove_slot = 0)
	. = ..()
	if(!isunathi(M))
		var/datum/action/innate/unathi_ignite/fire = new()
		fire.Grant(M)
	if(organ_quality == ORGAN_PRISTINE) // grants a 3-range ash drake breath
		M.AddSpell(new /datum/spell/drake_breath)

/obj/item/organ/internal/lungs/xenobiology/flame_sack/remove(mob/living/carbon/M, special = 0)
	. = ..()
	if(!isunathi(M))
		for(var/datum/action/innate/unathi_ignite/fire in M.actions)
			fire.Remove(M)
	M.RemoveSpell(/datum/spell/drake_breath)

/datum/spell/drake_breath
	name = "Drake Breath"
	desc = "Draw from special glands in your body to produce a small, but dazzling flame!"
	base_cooldown = 3 MINUTES
	clothes_req = FALSE
	stat_allowed = CONSCIOUS
	invocation_type = "none"
	action_icon_state = "fireball0"
	sound = 'sound/magic/fireball.ogg'
	active = FALSE

	selection_activated_message = "<span class='notice'>You take in a deep bread, readying to breathe fire!</span>"
	selection_deactivated_message = "<span class='notice'>You relax your breaths as you decide not to breathe fire.</span>"

/datum/spell/drake_breath/create_new_targeting()
	var/datum/spell_targeting/clicked_atom/external/C = new()
	C.range = 20
	return C

/datum/spell/drake_breath/update_spell_icon()
	if(!action)
		return
	action.button_overlay_icon_state = "fireball[active]"
	action.UpdateButtons()

/datum/spell/drake_breath/cast(list/targets, mob/living/user)
	. = ..()
	var/target = targets[1] //There is only ever one target
	var/turfs = line_target(0, 3, target, user)
	dragon_fire_line(user, turfs)

/datum/spell/drake_breath/proc/line_target(offset, range, atom/at, mob/living/user)
	if(!at)
		return
	var/angle = ATAN2(at.x - user.x, at.y - user.y) + offset
	var/turf/T = get_turf(user)
	for(var/i in 1 to range)
		var/turf/check = locate(user.x + cos(angle) * i, user.y + sin(angle) * i, user.z)
		if(!check)
			break
		T = check
	return (get_line(user, T) - get_turf(user))

/obj/item/organ/internal/kidneys/xenobiology/sinew
	name = "Sinewous Bands"
	desc = "Long, strands of durable fibers that seem to grow at astonishing speeds."
	analyzer_price = 25

/obj/item/organ/internal/kidneys/xenobiology/sinew/insert(mob/living/carbon/M, special = 0, dont_remove_slot = 0)
	. = ..()
	var/datum/spell/create_sinew/sinew_spell = new /datum/spell/create_sinew
	sinew_spell.quality = organ_quality
	M.AddSpell(sinew_spell)

/obj/item/organ/internal/kidneys/xenobiology/sinew/remove(mob/living/carbon/M, special = 0)
	. = ..()
	M.RemoveSpell(/datum/spell/create_sinew)

/datum/spell/create_sinew
	name = "Create Sinew Bands"
	desc = "Detatch some of your sinewous bands to create a durable restraint"
	action_icon = 'icons/obj/mining.dmi'
	action_icon_state = "sinewcuff"
	invocation_type = "none"
	clothes_req = FALSE
	stat_allowed = CONSCIOUS
	base_cooldown = 5 MINUTES
	var/quality = ORGAN_NORMAL
	var/cooldown = 0

/datum/spell/create_sinew/create_new_targeting()
	return new /datum/spell_targeting/self

/datum/spell/create_sinew/cast(list/targets, mob/living/user)
	. = ..()
	var/obj/item/restraints/handcuffs/sinew_cuffs = new /obj/item/restraints/handcuffs/sinew
	switch(quality)
		if(ORGAN_DAMAGED)
			user.adjustBruteLoss(10)
			to_chat(user, "<span class='warning'>The bands refuse to detach cleanly, ripping some flesh away with them!</span>")
			user.put_in_hands(sinew_cuffs)
		if(ORGAN_NORMAL)
			user.put_in_hands(sinew_cuffs)
		if(ORGAN_PRISTINE)
			sinew_cuffs.name = "Strong sinew cuffs"
			sinew_cuffs.breakouttime = 45 SECONDS
			user.put_in_hands(sinew_cuffs)

/obj/item/organ/internal/heart/xenobiology/hyperactive
	name = "Hyperactive Organ"
	desc = "This organ replaces it's own cells so quickly, that it appears to spread this effect to other cells around it in a rather exhaustive process."
	analyzer_price = 25

/obj/item/organ/internal/heart/xenobiology/hyperactive/on_life()
	. = ..()
	switch(organ_quality)
		if(ORGAN_DAMAGED)
			if(prob(20)) // about saline level
				owner.adjustBruteLoss(-2)
				owner.adjustFireLoss(-2)
			if(owner.getBruteLoss() > 10 || owner.getFireLoss() > 10) // this shits exhausting!
				if(prob(15))
					owner.setStaminaLoss(30)
		if(ORGAN_NORMAL)
			if(owner.getBruteLoss() > 10 || owner.getFireLoss() > 10) // this shits exhausting!
				if(prob(5))
					owner.setStaminaLoss(30)
			owner.adjustBruteLoss(-1)
			owner.adjustFireLoss(-1)
		if(ORGAN_PRISTINE)
			owner.adjustBruteLoss(-1)
			owner.adjustFireLoss(-1)

/obj/item/organ/internal/kidneys/xenobiology/metallic
	name = "Metallic Processor"
	desc = "A dense, metallic organ that enables the consumption of precious metals as food. No guarentee for taste, though"
	analyzer_price = 20

/obj/item/organ/internal/kidneys/xenobiology/metallic/insert(mob/living/carbon/M, special = 0, dont_remove_slot = 0)
	. = ..()
	ADD_TRAIT(M, TRAIT_MINERAL_EATER, ORGAN_TRAIT)
	switch(organ_quality)
		if(ORGAN_DAMAGED)
			ADD_TRAIT(M, TRAIT_SILVER_EATER, ORGAN_TRAIT)
		if(ORGAN_NORMAL)
			ADD_TRAIT(M, TRAIT_SILVER_EATER, ORGAN_TRAIT)
			ADD_TRAIT(M, TRAIT_GOLD_EATER, ORGAN_TRAIT)
		if(ORGAN_PRISTINE)
			ADD_TRAIT(M, TRAIT_SILVER_EATER, ORGAN_TRAIT)
			ADD_TRAIT(M, TRAIT_GOLD_EATER, ORGAN_TRAIT)
			ADD_TRAIT(M, TRAIT_DIAMOND_EATER, ORGAN_TRAIT)

/obj/item/organ/internal/kidneys/xenobiology/metallic/remove(mob/living/carbon/M, special = 0)
	. = ..()
	REMOVE_TRAIT(M, TRAIT_MINERAL_EATER, ORGAN_TRAIT)
	switch(organ_quality)
		if(ORGAN_DAMAGED)
			REMOVE_TRAIT(M, TRAIT_SILVER_EATER, ORGAN_TRAIT)
		if(ORGAN_NORMAL)
			REMOVE_TRAIT(M, TRAIT_SILVER_EATER, ORGAN_TRAIT)
			REMOVE_TRAIT(M, TRAIT_GOLD_EATER, ORGAN_TRAIT)
		if(ORGAN_PRISTINE)
			REMOVE_TRAIT(M, TRAIT_SILVER_EATER, ORGAN_TRAIT)
			REMOVE_TRAIT(M, TRAIT_GOLD_EATER, ORGAN_TRAIT)
			REMOVE_TRAIT(M, TRAIT_DIAMOND_EATER, ORGAN_TRAIT)

/obj/item/organ/internal/cyberimp/mouth/xenobiology/vocal_remnants
	name = "Vocal Coord Remnants"
	desc = "The remnants of a great beast's vocal coords. While only a fraction of the true organ's power, these could probably still get decently loud."
	analyzer_price = 35

/obj/item/organ/internal/cyberimp/mouth/xenobiology/vocal_remnants/insert(mob/living/carbon/M, special = 0, dont_remove_slot = 0)
	. = ..()
	ADD_TRAIT(M, TRAIT_LOUD, ORGAN_TRAIT)
/obj/item/organ/internal/cyberimp/mouth/xenobiology/vocal_remnants/remove(mob/living/carbon/M, special = 0)
	. = ..()
	REMOVE_TRAIT(M, TRAIT_LOUD, ORGAN_TRAIT)

/obj/item/organ/internal/appendix/xenobiology/toxin_stinger
	name = "Vocal Coord Remnants"
	desc = "The remnants of a great beast's vocal coords. While only a fraction of the true organ's power, these could probably still get decently loud."
	analyzer_price = 35

/obj/item/organ/internal/appendix/xenobiology/toxin_stinger/insert(mob/living/carbon/M, special = 0, dont_remove_slot = 0)
	. = ..()
	var/datum/spell/organ_sting/spell = new /datum/spell/organ_sting
	if(organ_quality == ORGAN_DAMAGED)
		spell.base_cooldown = 8 MINUTES
	M.AddSpell(spell)

/obj/item/organ/internal/appendix/xenobiology/toxin_stinger/remove(mob/living/carbon/M, special = 0)
	. = ..()
	M.RemoveSpell(/datum/spell/organ_sting)

/datum/spell/organ_sting
	name = "Toxic Sting"
	desc = "Silently sting an unsuspecting victim with a mild coctail of poisons"
	action_icon_state = "sting_blind"
	action_background_icon_state = "bg_changeling"
	invocation_type = "none"
	clothes_req = FALSE
	stat_allowed = CONSCIOUS
	base_cooldown = 5 MINUTES
	var/quality = ORGAN_NORMAL
	var/cooldown = 0

	selection_activated_message = "<span class='notice'>unfold your stinger from your body, ready to sting someone.</span>"
	selection_deactivated_message = "<span class='notice'>You retract your stinger for now.</span>"

/datum/spell/organ_sting/create_new_targeting(list/targets, mob/living/user)
	. = ..()
	var/datum/spell_targeting/clicked_atom/external/C = new()
	C.range = 20
	return C

/datum/spell/organ_sting/cast(list/targets, mob/user)
	. = ..()
	var/atom/target = targets[1] //There is only ever one target
	var/dist = get_dist(user.loc, target.loc)
	if(target.z != user.z || dist > 2)
		to_chat(user, "<span class='warning'>Thats too far away!</span>")
		revert_cast()
		return
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(quality == ORGAN_PRISTINE)
			H.reagents.add_reagent("venom", 10)
		else
			H.reagents.add_reagent("toxin", 10)
	else
		to_chat(user, "<span class='warning'>We shouldnt get much use out of stinging that.</span>")
		revert_cast()

/obj/item/organ/internal/heart/xenobiology/contortion
	name = "Contortion Fibers"
	desc = "A set of bands that wrap around joints and ligaments and muscles alike, pulling the body into unnatural shapes."
	analyzer_price = 75

/obj/item/organ/internal/heart/xenobiology/contortion/insert(mob/living/carbon/human/M, special = 0, dont_remove_slot = 0)
	. = ..()
	if(/datum/antagonist/changeling in M.mind.antag_datums)
		return // we shouldnt be giving free abilities to lings who have them
	var/datum/action/changeling/contort_body/xenobiology/spell = new /datum/action/changeling/contort_body/xenobiology
	if(organ_quality == ORGAN_DAMAGED)
		spell.cooldown = 8 MINUTES
	spell.organ_quality = organ_quality
	spell.Grant(M)

/obj/item/organ/internal/heart/xenobiology/contortion/remove(mob/living/carbon/human/M, special = 0)
	. = ..()
	if(/datum/antagonist/changeling in M.mind.antag_datums)
		return
	for(var/datum/action/changeling/contort_body/xenobiology/X in M.actions)
		X.Remove(M)

/obj/item/organ/internal/heart/xenobiology/bloody_sack
	name = "Bloody Sack"
	desc = "A large sack spilling with blood. Despite the fact it oozes with blood, you can feel its hunger for more."
	analyzer_price = 75

/obj/item/organ/internal/heart/xenobiology/bloody_sack/insert(mob/living/carbon/M, special = 0, dont_remove_slot = 0)
	. = ..()
	var/datum/spell/absorb_blood/spell = new /datum/spell/absorb_blood
	spell.quality = organ_quality
	M.AddSpell(spell)

/obj/item/organ/internal/heart/xenobiology/bloody_sack/remove(mob/living/carbon/M, special = 0)
	. = ..()
	M.RemoveSpell(/datum/spell/absorb_blood)

/datum/spell/absorb_blood
	name = "Call to Blood"
	desc = "Draw upon dark energies to absorb nearby blood, healing you in the process."
	clothes_req = FALSE
	stat_allowed = CONSCIOUS
	invocation_type = "none"
	action_icon = 'icons/mob/actions/actions_cult.dmi'
	action_icon_state = "blood_charge"
	sound = null
	active = FALSE
	base_cooldown = 30 SECONDS
	var/quality

/datum/spell/absorb_blood/create_new_targeting()
	return new /datum/spell_targeting/self

/datum/spell/absorb_blood/cast(list/targets, mob/living/user)
	. = ..()
	var/temp = 0
	var/turf/T = get_turf(targets[1])
	if(!T)
		return
	if(quality == ORGAN_DAMAGED)
		user.blood_volume = max(user.blood_volume - 50, 0) // Slurp slurp slurp
		to_chat(user, "<span class='danger'>You can feel your stolen organ draining you of your blood!</span>")
	for(var/obj/effect/decal/cleanable/blood/B in range(T, 3))
		if(B.blood_state == BLOOD_STATE_HUMAN && (B.can_bloodcrawl_in()))
			temp += 10
		else
			temp += max((B.bloodiness ** 2) / 800, 1)
		new /obj/effect/temp_visual/cult/turf/open/floor(get_turf(B))
		qdel(B)
	for(var/obj/effect/decal/cleanable/trail_holder/TH in range(T, 2))
		new /obj/effect/temp_visual/cult/turf/open/floor(get_turf(TH))
		qdel(TH)
	if(temp)
		user.Beam(T, icon_state = "drainbeam", time = 15)
		new /obj/effect/temp_visual/cult/sparks(get_turf(user))
		playsound(T, 'sound/misc/enter_blood.ogg', 50, extrarange = SOUND_RANGE_SET(7))
		if(quality == ORGAN_PRISTINE)
			temp = clamp(temp, 1, 40)
		else
			temp = clamp(temp, 1, 25)
		temp = round(temp)
		user.adjustBruteLoss(-temp)
	else
		user.playsound_local(T, 'sound/effects/heartbeat.ogg', 50, FALSE)

// If you decative a matter eater gene with this in, itll "cure" your organs hunger. doesnt work in reverse though.
/obj/item/organ/internal/liver/xenobiology/hungry
	name = "Hungry Organ"
	desc = "This organ seems to actively attempt to dissolve and absorb anything it touches."
	analyzer_price = 40

/obj/item/organ/internal/liver/xenobiology/hungry/insert(mob/living/carbon/human/M, special = 0, dont_remove_slot = 0)
	. = ..()
	if(/datum/mutation/grant_spell/mattereater in M.active_mutations)
		return
	else
		M.AddSpell(new /datum/spell/eat)


/obj/item/organ/internal/liver/xenobiology/hungry/remove(mob/living/carbon/M, special = 0)
	. = ..()
	if(/datum/mutation/grant_spell/mattereater in M.active_mutations)
		return
	else
		M.RemoveSpell(/datum/spell/eat)

/obj/item/organ/internal/appendix/xenobiology/tendril
	name = "Writhing Tendrils"
	desc = "This organ squirming and writhes "
	analyzer_price = 20

/obj/item/organ/internal/appendix/xenobiology/tendril/insert(mob/living/carbon/human/M, special = 0, dont_remove_slot = 0)
	. = ..()
	var/datum/spell/tendril_grab/spell = new /datum/spell/tendril_grab
	spell.quality = organ_quality
	if(organ_quality == ORGAN_DAMAGED)
		spell.base_cooldown = 45 SECONDS
	M.AddSpell(spell)

/obj/item/organ/internal/appendix/xenobiology/tendril/remove(mob/living/carbon/M, special = 0)
	. = ..()
	M.RemoveSpell(/datum/spell/tendril_grab)

/datum/spell/tendril_grab
	name = "Prehensile Tendril"
	desc = "Extend out your prehensile appendage to grab at an item."
	base_cooldown = 30 SECONDS
	clothes_req = FALSE
	stat_allowed = CONSCIOUS
	invocation_type = "none"
	action_icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	action_icon_state = "Goliath_tentacle_stationary"
	action_background_icon_state = "bg_default"
	sound = null
	active = FALSE
	var/quality

/datum/spell/tendril_grab/create_new_targeting(list/targets, mob/living/user)
	. = ..()
	var/datum/spell_targeting/clicked_atom/external/C = new()
	C.range = 20
	return C

/datum/spell/tendril_grab/cast(list/targets, mob/user)
	. = ..()
	var/atom/target = targets[1] //There is only ever one target
	new /obj/effect/temp_visual/goliath_flick(target, quality, user)

/obj/effect/temp_visual/goliath_flick
	name = "Writhing Tendril"
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "Goliath_tentacle_spawn"
	layer = BELOW_MOB_LAYER
	var/quality = ORGAN_NORMAL

/obj/effect/temp_visual/goliath_flick/Initialize(mapload, atom/target, organ_quality, mob/user)
	. = ..()
	quality = organ_quality
	timerid = addtimer(CALLBACK(src, PROC_REF(retract), target, user), 7)

/obj/effect/temp_visual/goliath_flick/proc/retract(atom/target, mob/user)
	icon_state = "Goliath_tentacle_retract"
	timerid = QDEL_IN(src, 7)
	if(target.loc == src.loc)
		if(isliving(target) && quality == ORGAN_PRISTINE)
			var/mob/living/M = target
			M.adjustBruteLoss(10)
		else if(istype(target, /atom/movable))
			var/atom/movable/T = target
			var/dist = get_dist(user.loc, target.loc)
			T.throw_at(user, dist - 1, 1, user, spin = FALSE)
