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

// allows for perfect pristine organ extraction. Only available from non-lavaland abductor tech
/obj/item/dissector/alien
	name = "Alien Dissection Manager"
	desc = "A tool of alien origin, capable of near impossible levels of precision during dissections."
	icon_state = "dissector_alien"
	origin_tech = "abductor=3"

/obj/item/dissector/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_ADVANCED_SURGICAL, ROUNDSTART_TRAIT)
	RegisterSignal(src, COMSIG_BIT_ATTACH, PROC_REF(add_bit))
	RegisterSignal(src, COMSIG_CLICK_ALT, PROC_REF(remove_bit))

/datum/surgery_step/generic/dissect
	name = "dissect"
	allowed_tools = list(
		/obj/item/dissector/alien = 100,
		/obj/item/dissector/upgraded = 70,
		TOOL_DISSECTOR = 40,
		/obj/item/scalpel/laser/manager = 10,
		/obj/item/wirecutters = 5,
		/obj/item/kitchen/utensil/fork = 1,
	)

	preop_sound = 'sound/surgery/organ1.ogg'
	success_sound = 'sound/surgery/organ2.ogg'
	failure_sound = 'sound/effects/bone_break_1.ogg'
	time = 1.6 SECONDS

/obj/item/regen_mesh
	name = "Regenerative Organ Mesh"
	desc = "A specialized mesh carved from a fleshling that can improve the quality of any organ its used on."
	icon = 'icons/obj/lavaland/ash_flora.dmi'
	icon_state = "mushroom_leaf_p" // its unused and looks fine soooo whatever lol

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
	is_xeno_organ = TRUE

/obj/item/organ/internal/heart/xenobiology
	name = "Unidentified Mass"
	desc = "This is a parent object and should not appear. Contact a developer."
	icon = 'icons/obj/xeno_organs.dmi'
	icon_state = "organ4"
	dead_icon = null
	origin_tech = null
	tough = TRUE
	is_xeno_organ = TRUE
	var/can_paradox = FALSE

/obj/item/organ/internal/lungs/xenobiology
	name = "Unidentified Mass"
	desc = "This is a parent object and should not appear. Contact a developer."
	icon = 'icons/obj/xeno_organs.dmi'
	icon_state = "organ4"
	dead_icon = null
	origin_tech = null
	tough = TRUE
	is_xeno_organ = TRUE

/obj/item/organ/internal/kidneys/xenobiology
	name = "Unidentified Mass"
	desc = "This is a parent object and should not appear. Contact a developer."
	icon = 'icons/obj/xeno_organs.dmi'
	icon_state = "organ4"
	dead_icon = null
	origin_tech = null
	tough = TRUE
	is_xeno_organ = TRUE

/obj/item/organ/internal/appendix/xenobiology
	name = "Unidentified Mass"
	desc = "This is a parent object and should not appear. Contact a developer."
	icon = 'icons/obj/xeno_organs.dmi'
	icon_state = "organ4"
	dead_icon = null
	origin_tech = null
	tough = TRUE
	is_xeno_organ = TRUE

/obj/item/organ/internal/eyes/xenobiology
	name = "Unidentified Mass"
	desc = "This is a parent object and should not appear. Contact a developer."
	icon = 'icons/obj/xeno_organs.dmi'
	icon_state = "organ4"
	dead_icon = null
	origin_tech = null
	tough = TRUE
	is_xeno_organ = TRUE

/obj/item/organ/internal/ears/xenobiology
	name = "Unidentified Mass"
	desc = "This is a parent object and should not appear. Contact a developer."
	icon = 'icons/obj/xeno_organs.dmi'
	icon_state = "organ4"
	dead_icon = null
	origin_tech = null
	tough = TRUE
	is_xeno_organ = TRUE

/obj/item/organ/internal/cell/xenobiology
	name = "Unidentified Electronic"
	desc = "This is a parent object and should not appear. Contact a developer."
	icon = 'icons/obj/xeno_organs.dmi'
	icon_state = "organ4"
	dead_icon = null
	origin_tech = null
	tough = TRUE
	is_xeno_organ = TRUE

/obj/item/organ/internal/cyberimp/mouth/xenobiology
	name = "Unidentified Electronic"
	desc = "This is a parent object and should not appear. Contact a developer."
	icon = 'icons/obj/xeno_organs.dmi'
	icon_state = "organ4"
	dead_icon = null
	origin_tech = null
	tough = TRUE
	is_xeno_organ = TRUE

/obj/item/organ/internal/liver/xenobiology/toxic
	name = "Toxic Glands"
	desc = "These fleshy glands' alien chemistry are incompatible with most humanoid life."

/obj/item/organ/internal/liver/xenobiology/toxic/on_life()
	. = ..()
	if(!(owner.mob_biotypes & MOB_ORGANIC))
		return
	to_chat(owner, "<span class='notice'>You feel nauseous as your insides feel like they're disintegrating!</span>")
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
	can_paradox = TRUE

/obj/item/organ/internal/heart/xenobiology/vestigial/on_life()
	. = ..()
	if(!owner.undergoing_cardiac_arrest())
		owner.set_heartattack(TRUE) // what did you expect?

/obj/item/organ/internal/heart/xenobiology/incompatible
	name = "Incompatible Organ"
	desc = "This organ is largely incompatible with humanoid physiology. you might be able to get it to work, but will likely cause a host of other issues."
	can_paradox = TRUE

/obj/item/organ/internal/heart/xenobiology/incompatible/on_life()
	if(prob(0.3)) // it'll fail... eventually
		if(!owner.undergoing_cardiac_arrest())
			owner.set_heartattack(TRUE) // yeah probably shouldnt use this
	if(prob(20))
		owner.AdjustConfused(5 SECONDS)
	if(prob(20))
		owner.AdjustJitter(5 SECONDS)
	if(prob(20))
		owner.vomit(20)

/obj/item/organ/internal/lungs/xenobiology/flame_sack
	name = "Flame Sack"
	desc = "An unusual set of aerosolizing glands capable of starting light fires."
	analyzer_price = 50
	hidden_origin_tech = TECH_PLASMA
	hidden_tech_level = 5

/obj/item/organ/internal/lungs/xenobiology/flame_sack/insert(mob/living/carbon/M, special = 0, dont_remove_slot = 0)
	. = ..()
	if(!isunathi(M))
		var/datum/action/innate/unathi_ignite/fire = new
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
	var/datum/spell/create_sinew/sinew_spell = new
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
			to_chat(user, "<span class='warning'>The bands don't detach cleanly, ripping some flesh away with it!</span>")
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
	can_paradox = TRUE
	hidden_origin_tech = TECH_BIO
	hidden_tech_level = 5

/obj/item/organ/internal/heart/xenobiology/hyperactive/on_life()
	. = ..()
	switch(organ_quality)
		if(ORGAN_DAMAGED)
			if(prob(20)) // about saline level
				owner.adjustBruteLoss(-2)
				owner.adjustFireLoss(-2)
			if(owner.getBruteLoss() > 10 || owner.getFireLoss() > 10) // this shits exhausting!
				if(prob(30))
					owner.setStaminaLoss(15)
		if(ORGAN_NORMAL)
			if(owner.getBruteLoss() > 10 || owner.getFireLoss() > 10) // this shits exhausting!
				if(prob(20))
					owner.setStaminaLoss(15)
			owner.adjustBruteLoss(-1)
			owner.adjustFireLoss(-1)
		if(ORGAN_PRISTINE)
			owner.adjustBruteLoss(-1)
			owner.adjustFireLoss(-1)

/obj/item/organ/internal/kidneys/xenobiology/metallic
	name = "Metallic Processor"
	desc = "A dense, metallic organ that enables the consumption of precious metals as food. No guarentee for taste, though"
	analyzer_price = 20
	///Component that handles the ability to eat precious metals
	var/datum/component/special_tastes/special_tastes

/obj/item/organ/internal/kidneys/xenobiology/metallic/insert(mob/living/carbon/organ_owner, special = FALSE, dont_remove_slot = FALSE)
	. = ..()
	var/list/edible_minerals = list(
		/obj/item/stack/sheet/mineral/silver = list(
			"reagents" = list(
				"nutriment" = 1,
				"vitamin" = 1,
			),
			"tastes" = list(
				"metal and blood. ow" = 1,
			),
		),
		/obj/item/stack/sheet/mineral/uranium = list(
			"reagents" = list(
				"nutriment" = 1,
				"uranium" = 1,
			),
			"tastes" = list(
				"metal and blood. ow" = 1,
				"bad ideas" = 1,
			),
		)
	)
	if(organ_quality >= ORGAN_NORMAL)
		edible_minerals += list(
			/obj/item/stack/sheet/mineral/gold = list(
				"reagents" = list(
					"salglu_solution" = 5,
					"nutriment" = 1,
					"vitamin" = 1,
				),
				"tastes" = list(
					"metal and blood. ow" = 1,
				),
			)
		)
	if(organ_quality >= ORGAN_PRISTINE)
		edible_minerals += list(
			/obj/item/stack/sheet/mineral/diamond = list(
				"reagents" = list(
					"nutriment" = 1,
					"bicaridine" = 3,
					"kelotane" = 3,
					"vitamin" = 1,
				),
				"tastes" = list(
					"like your teeth. owch" = 1,
				),
			)
		)
	special_tastes = organ_owner.AddComponent(/datum/component/special_tastes, edible_minerals)

/obj/item/organ/internal/kidneys/xenobiology/metallic/remove(mob/living/carbon/organ_owner, special = FALSE)
	special_tastes.RemoveComponent()
	return ..()

/obj/item/organ/internal/cyberimp/mouth/xenobiology/vocal_remnants
	name = "Vocal Coord Remnants"
	desc = "The remnants of a great beast's vocal coords. While only a fraction of the true organ's power, these could probably still get decently loud."
	analyzer_price = 35
	hidden_origin_tech = TECH_COMBAT
	hidden_tech_level = 7

/obj/item/organ/internal/cyberimp/mouth/xenobiology/vocal_remnants/Initialize(mapload)
	. = ..()
	icon_state = pick("colossus1", "colossus2", "colossus3", "colossus4")

/obj/item/organ/internal/cyberimp/mouth/xenobiology/vocal_remnants/insert(mob/living/carbon/M, special = 0, dont_remove_slot = 0)
	. = ..()
	ADD_TRAIT(M, TRAIT_LOUD, ORGAN_TRAIT)
/obj/item/organ/internal/cyberimp/mouth/xenobiology/vocal_remnants/remove(mob/living/carbon/M, special = 0)
	. = ..()
	REMOVE_TRAIT(M, TRAIT_LOUD, ORGAN_TRAIT)

/obj/item/organ/internal/appendix/xenobiology/toxin_stinger
	name = "Hidden Stinger"
	desc = "This organ holds a deceptive stinger tucked inside of itself, dripping with venom."
	analyzer_price = 35
	var/terror = FALSE
	hidden_origin_tech = TECH_COMBAT
	hidden_tech_level = 5

/obj/item/organ/internal/appendix/xenobiology/toxin_stinger/insert(mob/living/carbon/M, special = 0, dont_remove_slot = 0)
	. = ..()
	var/datum/spell/organ_sting/spell = new
	if(organ_quality == ORGAN_DAMAGED)
		spell.base_cooldown = 8 MINUTES
	if(terror)
		spell.terror = TRUE
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
	var/terror = FALSE

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
	if(dist > 2) // Too far, don't bother pathfinding
		to_chat(user, "<span class='warning'>Our target is too far for our sting!</span>")
		revert_cast()
		return FALSE
	if(!length(get_path_to(user, target, max_distance = 2, simulated_only = FALSE, skip_first = FALSE)))
		to_chat(user, "<span class='warning'>Our sting is blocked from reaching our target!</span>")
		revert_cast()
		return
	if(ismachineperson(target))
		to_chat(user, "<span class='warning'>This won't work on synthetics.</span>")
		revert_cast()
		return FALSE
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		to_chat(target, "<span class='warning'>You feel a sharp prick in your side!</span>")
		if(quality == ORGAN_PRISTINE)
			if(terror)
				H.reagents.add_reagent("terror_black_toxin", 10)
			else
				H.reagents.add_reagent("venom", 10)
		else
			if(terror)
				H.reagents.add_reagent("venom", 10)
			else
				H.reagents.add_reagent("toxin", 10)
	else
		to_chat(user, "<span class='warning'>We wouldn't get much use out of stinging that.</span>")
		revert_cast()

/obj/item/organ/internal/heart/xenobiology/contortion
	name = "Contortion Fibers"
	desc = "A set of bands that wrap around joints and ligaments and muscles alike, pulling the body into unnatural shapes."
	analyzer_price = 75
	can_paradox = TRUE
	hidden_origin_tech = TECH_BIO
	hidden_tech_level = 7

/obj/item/organ/internal/heart/xenobiology/contortion/insert(mob/living/carbon/human/M, special = 0, dont_remove_slot = 0)
	. = ..()
	if(/datum/antagonist/changeling in M.mind.antag_datums)
		return // we shouldnt be giving free abilities to lings who have them
	var/datum/action/changeling/contort_body/xenobiology/spell = new
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
	can_paradox = TRUE
	hidden_origin_tech = TECH_BLUESPACE
	hidden_tech_level = 7

/obj/item/organ/internal/heart/xenobiology/bloody_sack/insert(mob/living/carbon/M, special = 0, dont_remove_slot = 0)
	. = ..()
	var/datum/spell/absorb_blood/spell = new
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
	hidden_origin_tech = TECH_BIO
	hidden_tech_level = 7

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
	desc = "This organ is constantly squirming and writhing around. Yuck."
	analyzer_price = 20
	hidden_origin_tech = TECH_BIO
	hidden_tech_level = 5

/obj/item/organ/internal/appendix/xenobiology/tendril/insert(mob/living/carbon/human/M, special = 0, dont_remove_slot = 0)
	. = ..()
	var/datum/spell/tendril_grab/spell = new
	spell.quality = organ_quality
	if(organ_quality == ORGAN_DAMAGED)
		spell.base_cooldown = 45 SECONDS
	M.AddSpell(spell)

/obj/item/organ/internal/appendix/xenobiology/tendril/remove(mob/living/carbon/M, special = 0)
	. = ..()
	M.RemoveSpell(/datum/spell/tendril_grab)

/datum/spell/tendril_grab
	name = "Prehensile Tendril"
	desc = "Dig a tendril though the floor to grab at an item, throwing it towards you."
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
	var/turf/target_loc
	if(!isturf(target))
		target_loc = target.loc
	else
		target_loc = target
	new /obj/effect/temp_visual/goliath_flick(target_loc, target, quality, user)

/obj/effect/temp_visual/goliath_flick
	name = "Writhing Tendril"
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "Goliath_tentacle_spawn"
	layer = BELOW_MOB_LAYER

/obj/effect/temp_visual/goliath_flick/Initialize(mapload, atom/target, organ_quality, mob/user)
	. = ..()
	timerid = addtimer(CALLBACK(src, PROC_REF(retract), target, organ_quality, user), 7)

/obj/effect/temp_visual/goliath_flick/proc/retract(atom/target, organ_quality, mob/user)
	icon_state = "Goliath_tentacle_retract"
	timerid = QDEL_IN(src, 7)
	if(target.loc == src.loc)
		if(isliving(target))
			var/mob/living/M = target
			playsound(M, 'sound/weapons/slap.ogg', 50, TRUE, -1, falloff_exponent = 4) // let it travel a little further
			if(organ_quality == ORGAN_PRISTINE)
				M.adjustBruteLoss(10)
		else if(istype(target, /atom/movable))
			var/atom/movable/T = target
			if(!T.anchored)
				var/dist = get_dist(user.loc, target.loc)
				T.throw_at(user, dist - 1, 1, user, spin = TRUE)
			else
				T.visible_message("<span class='warning'>[T] refuses to budge!</span>")

/obj/item/organ/internal/eyes/xenobiology/glowing
	name = "Glowing Core"
	desc = "This organ glows with a strange energy from its depths. Is it even appropiate to call this an organ?"
	analyzer_price = 40
	hidden_origin_tech = TECH_BLUESPACE
	hidden_tech_level = 6

/obj/item/organ/internal/eyes/xenobiology/glowing/Initialize(mapload)
	. = ..()
	icon_state = pick("hiero1", "hiero2")

/obj/item/organ/internal/eyes/xenobiology/glowing/insert(mob/living/carbon/M, special = 0, dont_remove_slot = 0)
	. = ..()
	var/datum/spell/turf_teleport/organ_teleport/spell = new
	spell.quality = organ_quality
	if(organ_quality == ORGAN_PRISTINE)
		spell.base_cooldown = 90 SECONDS
	M.AddSpell(spell)

/obj/item/organ/internal/eyes/xenobiology/glowing/remove(mob/living/carbon/M, special = 0)
	. = ..()
	M.RemoveSpell(/datum/spell/turf_teleport/organ_teleport)

/datum/spell/turf_teleport/organ_teleport
	name = "Unstable blink"
	desc = "Touch someone to destabilize their location in bluespace for a moment."
	base_cooldown = 3 MINUTES
	clothes_req = FALSE
	stat_allowed = CONSCIOUS
	invocation_type = "none"
	action_icon_state = "spell_teleport"
	sound = null
	active = FALSE
	sound1 = 'sound/magic/blink.ogg'
	sound2 = 'sound/magic/blink.ogg'
	var/quality

/datum/spell/turf_teleport/organ_teleport/create_new_targeting()
	var/datum/spell_targeting/clicked_atom/external/C = new()
	C.range = 20
	return C

/datum/spell/turf_teleport/organ_teleport/cast(list/targets, mob/living/user)
	var/atom/target = targets[1]
	if(!isliving(target))
		to_chat(user, "<span class = 'warning'>We can only teleport living things!</span>")
		return
	if(target == user)
		to_chat(user, "<span class = 'warning'>We are unable to teleport ourself!</span>")
		revert_cast()
		return
	if(get_dist(target.loc, user.loc) > 2)
		to_chat(user, "<span class = 'warning'>They're too far away!</span>")
		revert_cast()
	if(!length(get_path_to(user, target, max_distance = 2, simulated_only = FALSE, skip_first = FALSE)))
		to_chat(user, "<span class='warning'>Something is blocking the way!</span>")
		revert_cast()
		return
	if(quality == ORGAN_BROKEN)
		if(prob(25))
			targets += user
			user.adjustBruteLoss(10)
			user.adjustFireLoss(10)
			to_chat(user, "<span class = 'danger'>You get dragged along into bluespace, your flesh searing from the unstable energies!</span>")
		else
			to_chat(user, "<span class = 'danger'>Drawing upon unstable energy singes your flesh!</span>")
			user.adjustFireLoss(8)
	user.mob_light(LIGHT_COLOR_PURPLE, 3, _duration = 3)
	new /obj/effect/temp_visual/hierophant/telegraph/teleport(get_turf(target))
	. = ..()

/obj/item/organ/internal/kidneys/xenobiology/shivering
	name = "Shivering Organ"
	desc = "It constantly shivers, seeking to warm itself from its environment."
	analyzer_price = 30

/obj/item/organ/internal/kidneys/xenobiology/shivering/on_life()
	. = ..()
	if(owner.get_temperature() < owner.dna.species.cold_level_1 + 40)
		switch(organ_quality)
			if(ORGAN_DAMAGED)
				owner.bodytemperature += 15
			if(ORGAN_NORMAL)
				owner.bodytemperature += 20
			if(ORGAN_PRISTINE)
				owner.bodytemperature += 30

/obj/item/organ/internal/kidneys/xenobiology/sweating
	name = "Sweaty Organ"
	desc = "It constantly sweats, seeking to cool itself off from its environment."
	analyzer_price = 30
	hidden_origin_tech = TECH_TOXINS
	hidden_tech_level = 6

/obj/item/organ/internal/kidneys/xenobiology/shivering/on_life()
	. = ..()
	if(owner.get_temperature() > owner.dna.species.heat_level_1 - 40)
		switch(organ_quality)
			if(ORGAN_DAMAGED)
				owner.bodytemperature -= 15
			if(ORGAN_NORMAL)
				owner.bodytemperature -= 20
			if(ORGAN_PRISTINE)
				owner.bodytemperature -= 30

/obj/item/organ/internal/liver/xenobiology/soupy
	name = "Soupy Organ"
	desc = "This organ seems to barely keep its own form together. It also reeks of tomato sauce."
	analyzer_price = 15
	var/original_name
	var/original_own_species_blood
	var/original_exotic_blood
	var/original_blood_color
	var/original_blood_type
	hidden_origin_tech = TECH_BIO
	hidden_tech_level = 6

/obj/item/organ/internal/liver/xenobiology/soupy/insert(mob/living/carbon/human/M, special = 0, dont_remove_slot = 0)
	. = ..()
	original_name = M.dna.species.name
	original_own_species_blood = M.dna.species.own_species_blood
	original_exotic_blood = M.dna.species.exotic_blood
	original_blood_color = M.dna.species.blood_color
	original_blood_type = M.dna.blood_type

	M.dna.species.name = "Tomato Hybrid"
	M.dna.species.own_species_blood = TRUE
	M.dna.species.exotic_blood = "tomatojuice"
	M.dna.species.blood_color = "#e25821"
	M.dna.blood_type = "Tomato"
	to_chat(owner, "<span class='userdanger'>You feel unnaturally soupy</span>")

/obj/item/organ/internal/liver/xenobiology/soupy/remove(mob/living/carbon/human/M, special = 0)
	. = ..()
	M.dna.species.name = original_name
	M.dna.species.own_species_blood = original_own_species_blood
	M.dna.species.exotic_blood = original_exotic_blood
	M.dna.species.blood_color = original_blood_color
	M.dna.blood_type = original_blood_type
	to_chat(owner, "<span class='userdanger'>You no longer constantly taste ketchup.</span>")

/obj/item/organ/internal/appendix/xenobiology/toxin_stinger/terror
	name = "Hidden Terror Stinger"
	desc = "This organ holds a deceptive stinger tucked inside of itself, dripping with potent venom."
	analyzer_price = 60
	terror = TRUE
	hidden_origin_tech = TECH_COMBAT
	hidden_tech_level = 7

/obj/item/organ/internal/lungs/xenobiology/mirror
	name = "Silvered Organ"
	desc = "This organ is dazzlingly reflective."
	analyzer_price = 30
	hidden_origin_tech = TECH_MATERIAL
	hidden_tech_level = 7

/obj/item/organ/internal/lungs/xenobiology/mirror/insert(mob/living/carbon/human/M, special = 0, dont_remove_slot = 0)
	. = ..()
	var/datum/spell/create_mirror/spell = new
	spell.quality = organ_quality
	M.AddSpell(spell)

/obj/item/organ/internal/lungs/xenobiology/mirror/remove(mob/living/carbon/M, special = 0)
	. = ..()
	M.RemoveSpell(/datum/spell/create_mirror)

/datum/spell/create_mirror
	name = "Create Mirror"
	desc = "Regurgitate a slick, mirrored surface where you are standing. Disgusting."
	clothes_req = FALSE
	stat_allowed = CONSCIOUS
	invocation_type = "none"
	action_icon = 'icons/mob/actions/actions_elites.dmi'
	action_icon_state = "herald_mirror"
	action_background_icon_state = "bg_default"
	sound = 'sound/effects/splat.ogg'
	active = FALSE
	base_cooldown = 3 MINUTES
	var/quality

/datum/spell/create_mirror/create_new_targeting()
	. = ..()
	return new /datum/spell_targeting/self

/datum/spell/create_mirror/cast(list/targets, mob/user)
	. = ..()
	var/turf/T = get_turf(user)
	var/obj/M = new /obj/structure/mirror/organ(T)
	M.anchored = FALSE
	if(quality == ORGAN_PRISTINE)
		M.icon = 'icons/mob/lavaland/lavaland_elites.dmi'
		M.icon_state = "herald_mirror"

/obj/item/organ/internal/heart/xenobiology/squirming
	name = "Squirming Organ"
	desc = "This organ refuses to sit still, constantly moving about however it can."
	analyzer_price = 75
	can_paradox = TRUE
	hidden_origin_tech = TECH_POWER
	hidden_tech_level = 7

/obj/item/organ/internal/heart/xenobiology/squirming/Initialize(mapload)
	. = ..()
	icon_state = pick("legion1", "legion2")

/obj/item/organ/internal/heart/xenobiology/squirming/on_life()
	. = ..()
	if(owner.getStaminaLoss() > 10)
		if(prob(10)) // dont wear yourself out
			src.receive_damage(10, 0)
		switch(organ_quality)
			if(ORGAN_DAMAGED) // also damages other organs. oops!
				for(var/obj/item/organ/internal/organ in owner.internal_organs)
					if(organ == src)
						continue
					if(prob(10))
						organ.receive_damage(10, 0)
				owner.adjustStaminaLoss(-3)
			if(ORGAN_NORMAL)
				owner.adjustStaminaLoss(-5)
			if(ORGAN_PRISTINE)
				owner.adjustStaminaLoss(-10)

/obj/item/organ/internal/appendix/xenobiology/electro_strands
	name = "Electromagnetic Strands"
	desc = "A large number of electrically sensitive strands all bundled up together. Its lost most of its potential."
	analyzer_price = 30
	hidden_origin_tech = TECH_MAGNETS
	hidden_tech_level = 7

/obj/item/organ/internal/appendix/xenobiology/electro_strands/insert(mob/living/carbon/human/M, special = 0, dont_remove_slot = 0)
	. = ..()
	var/datum/spell/aoe/flicker_lights/spell = new
	spell.from_organ = TRUE
	M.AddSpell(spell)

/obj/item/organ/internal/appendix/xenobiology/electro_strands/remove(mob/living/carbon/M, special = 0)
	. = ..()
	M.RemoveSpell(/datum/spell/aoe/flicker_lights)


/obj/item/organ/internal/liver/xenobiology/sharp
	name = "Sharp organ"
	desc = "This organ sprouts several sharp points out of itself, which you can't imagine would feel good to get implanted."
	analyzer_price = 30
	var/original_unarmed
	hidden_origin_tech = TECH_COMBAT
	hidden_tech_level = 7

/obj/item/organ/internal/liver/xenobiology/sharp/insert(mob/living/carbon/human/M, special = 0, dont_remove_slot = 0)
	. = ..()
	original_unarmed = owner.dna.species.unarmed_type
	if(original_unarmed != /datum/unarmed_attack/claws)
		var/datum/unarmed_attack/claws/claws = new
		owner.adjustBruteLoss(20) // OUCH!!! Son of a-
		owner.emote("scream")
		if(organ_quality == ORGAN_PRISTINE)
			claws.has_been_sharpened = TRUE
		owner.dna.species.unarmed = claws

/obj/item/organ/internal/liver/xenobiology/sharp/remove(mob/living/carbon/human/M, special = 0)
	. = ..()
	if(original_unarmed != /datum/unarmed_attack/claws)
		M.dna.species.unarmed = original_unarmed

/obj/item/organ/internal/appendix/xenobiology/noisemaker
	name = "Mimicry Organ"
	desc = "This organ continues to make odd sounds, copying things that it has heard."
	analyzer_price = 15
	hidden_origin_tech = TECH_ENGINEERING
	hidden_tech_level = 5

/obj/item/organ/internal/appendix/xenobiology/noisemaker/insert(mob/living/carbon/human/M, special = 0, dont_remove_slot = 0)
	. = ..()
	var/datum/action/innate/migo_noise/noisy = new()
	noisy.Grant(M)

/obj/item/organ/internal/appendix/xenobiology/noisemaker/remove(mob/living/carbon/human/M, special = 0)
	. = ..()
	for(var/datum/action/innate/migo_noise/noisy in M.actions)
		noisy.Remove(M)

/obj/item/organ/internal/appendix/xenobiology/noisemaker/on_life()
	. = ..()
	if(organ_quality == ORGAN_BROKEN && prob(1))
		owner.custom_emote("honks") // you just cant help it
		playsound(owner.loc, 'sound/items/bikehorn.ogg', 50, FALSE)

/datum/action/innate/migo_noise
	name = "Make some noise!"
	desc = "Your organ YEARNS to make noises of all kinds. Let it loose for a moment!"
	button_overlay_icon = 'icons/mob/animal.dmi'
	button_overlay_icon_state = "mi-go"
	var/cooldown = 0
	var/static/list/migo_sounds

	COOLDOWN_DECLARE(migo_cooldown)

/datum/action/innate/migo_noise/New(Target)
	. = ..()
	migo_sounds = list('sound/items/bubblewrap.ogg', 'sound/items/change_jaws.ogg', 'sound/items/crowbar.ogg', 'sound/items/drink.ogg', 'sound/items/deconstruct.ogg', 'sound/items/change_drill.ogg', 'sound/items/dodgeball.ogg', 'sound/items/eatfood.ogg', 'sound/items/screwdriver.ogg', 'sound/items/weeoo1.ogg', 'sound/items/wirecutter.ogg', 'sound/items/welder.ogg', 'sound/items/zip.ogg', 'sound/items/rped.ogg', 'sound/items/ratchet.ogg', 'sound/items/polaroid1.ogg', 'sound/items/pshoom.ogg', 'sound/items/airhorn.ogg', 'sound/voice/bcreep.ogg', 'sound/voice/biamthelaw.ogg', 'sound/voice/ed209_20sec.ogg', 'sound/voice/hiss3.ogg', 'sound/voice/hiss6.ogg', 'sound/voice/mpatchedup.ogg', 'sound/voice/mfeelbetter.ogg', 'sound/weapons/sear.ogg', 'sound/ambience/antag/tatoralert.ogg', 'sound/mecha/nominal.ogg', 'sound/mecha/weapdestr.ogg', 'sound/mecha/critdestr.ogg', 'sound/mecha/imag_enh.ogg', 'sound/effects/adminhelp.ogg', 'sound/effects/alert.ogg', 'sound/effects/attackblob.ogg', 'sound/effects/bamf.ogg', 'sound/effects/blobattack.ogg', 'sound/effects/break_stone.ogg', 'sound/effects/bubbles.ogg', 'sound/effects/bubbles2.ogg', 'sound/effects/clang.ogg', 'sound/effects/clownstep2.ogg', 'sound/effects/dimensional_rend.ogg', 'sound/effects/doorcreaky.ogg', 'sound/effects/empulse.ogg', 'sound/effects/explosionfar.ogg', 'sound/effects/explosion1.ogg', 'sound/effects/grillehit.ogg', 'sound/effects/genetics.ogg', 'sound/effects/heartbeat.ogg', 'sound/effects/hyperspace_begin.ogg', 'sound/effects/hyperspace_end.ogg', 'sound/goonstation/effects/screech.ogg', 'sound/effects/phasein.ogg', 'sound/effects/picaxe1.ogg', 'sound/effects/sparks1.ogg', 'sound/effects/smoke.ogg', 'sound/effects/splat.ogg', 'sound/effects/snap.ogg', 'sound/effects/tendril_destroyed.ogg', 'sound/effects/supermatter.ogg', 'sound/misc/desceration-01.ogg', 'sound/misc/desceration-02.ogg', 'sound/misc/desceration-03.ogg', 'sound/misc/bloblarm.ogg', 'sound/goonstation/misc/airraid_loop.ogg', 'sound/misc/interference.ogg', 'sound/misc/notice1.ogg', 'sound/misc/notice2.ogg', 'sound/misc/sadtrombone.ogg', 'sound/misc/slip.ogg', 'sound/weapons/armbomb.ogg', 'sound/weapons/chainsaw.ogg', 'sound/weapons/emitter.ogg', 'sound/weapons/emitter2.ogg', 'sound/weapons/blade1.ogg', 'sound/weapons/bladeslice.ogg', 'sound/weapons/blastcannon.ogg', 'sound/weapons/blaster.ogg', 'sound/weapons/bulletflyby3.ogg', 'sound/weapons/circsawhit.ogg', 'sound/weapons/cqchit2.ogg', 'sound/weapons/drill.ogg', 'sound/weapons/genhit1.ogg', 'sound/weapons/gunshots/gunshot_silenced.ogg', 'sound/weapons/gunshots/gunshot.ogg', 'sound/weapons/handcuffs.ogg', 'sound/weapons/homerun.ogg', 'sound/weapons/kenetic_accel.ogg', 'sound/machines/fryer/deep_fryer_emerge.ogg', 'sound/machines/airlock_alien_prying.ogg', 'sound/machines/airlock_close.ogg', 'sound/machines/airlockforced.ogg', 'sound/machines/airlock_open.ogg', 'sound/machines/alarm.ogg', 'sound/machines/blender.ogg', 'sound/machines/boltsdown.ogg', 'sound/machines/boltsup.ogg', 'sound/machines/buzz-sigh.ogg', 'sound/machines/buzz-two.ogg', 'sound/machines/chime.ogg', 'sound/machines/defib_charge.ogg', 'sound/machines/defib_failed.ogg', 'sound/machines/defib_ready.ogg', 'sound/machines/defib_zap.ogg', 'sound/machines/deniedbeep.ogg', 'sound/machines/ding.ogg', 'sound/machines/disposalflush.ogg', 'sound/machines/door_close.ogg', 'sound/machines/door_open.ogg', 'sound/machines/engine_alert1.ogg', 'sound/machines/engine_alert2.ogg', 'sound/machines/hiss.ogg', 'sound/machines/honkbot_evil_laugh.ogg', 'sound/machines/juicer.ogg', 'sound/machines/ping.ogg', 'sound/ambience/signal.ogg', 'sound/machines/synth_no.ogg', 'sound/machines/synth_yes.ogg', 'sound/machines/terminal_alert.ogg', 'sound/machines/twobeep.ogg', 'sound/machines/ventcrawl.ogg', 'sound/machines/warning-buzzer.ogg', 'sound/ai/outbreak5.ogg', 'sound/ai/outbreak7.ogg', 'sound/ai/alert.ogg', 'sound/ai/radiation.ogg', 'sound/ai/eshuttle_call.ogg', 'sound/ai/eshuttle_dock.ogg', 'sound/ai/eshuttle_recall.ogg', 'sound/ai/aimalf.ogg', 'sound/ambience/ambigen1.ogg', 'sound/ambience/ambigen3.ogg', 'sound/ambience/ambigen4.ogg', 'sound/ambience/ambigen5.ogg', 'sound/ambience/ambigen6.ogg', 'sound/ambience/ambigen10.ogg', 'sound/hallucinations/over_here1.ogg', 'sound/hallucinations/over_here2.ogg', 'sound/hallucinations/over_here3.ogg')

/datum/action/innate/migo_noise/Activate()
	var/mob/living/carbon/human/user = owner
	if(!COOLDOWN_FINISHED(src, migo_cooldown))
		to_chat(user, "<span class='warning'>You cant get your noisy organ to speak again so soon!</span>")
		return
	var/chosen_sound = pick(migo_sounds)
	playsound(owner.loc, chosen_sound, 50, TRUE)
	COOLDOWN_START(src, migo_cooldown, 10 SECONDS)

/obj/item/organ/internal/eyes/xenobiology/receptors
	name = "Photosensitive Receptors"
	desc = "A set of organs receptive to light in the spectrum of- hey wait a second. Arn't these just eyes?"
	analyzer_price = 40
	hidden_origin_tech = TECH_BIO
	hidden_tech_level = 7

/obj/item/organ/internal/eyes/xenobiology/receptors/insert(mob/living/carbon/M, special, dont_remove_slot)
	switch(organ_quality)
		if(ORGAN_BROKEN)
			see_in_dark = 4
		if(ORGAN_NORMAL)
			see_in_dark = 8
		if(ORGAN_PRISTINE)
			see_in_dark = 8
			vision_flags = SEE_OBJS | SEE_TURFS // slightly better mesons
	. = ..()

/obj/item/organ/internal/heart/xenobiology/paradox
	name = "Paradoxical Organ"
	desc = "The organ is constantly shifting and morphing, each time you look away its something new."
	analyzer_price = 40
	var/list/acceptable_hearts = list()

/obj/item/organ/internal/heart/xenobiology/paradox/Initialize(mapload)
	. = ..()
	icon_state = pick("hiero1", "hiero2")
/obj/item/organ/internal/heart/xenobiology/paradox/insert(mob/living/carbon/human/M, special, dont_remove_slot)
	for(var/obj/item/organ/internal/heart/xenobiology/temp_organ as anything in subtypesof(/obj/item/organ/internal/heart/xenobiology))
		if(temp_organ::can_paradox)
			acceptable_hearts += temp_organ
	var/obj/item/organ/internal/heart/new_organ = pick(acceptable_hearts)
	new_organ = new new_organ
	new_organ.organ_quality = organ_quality
	new_organ.insert(M)
	qdel(src)

/obj/item/organ/internal/heart/xenobiology/bananium
	name = "Bananium Laced Heart"
	desc = "Squeak squeak squeak sqonk honk honk snorf"
	analyzer_price = 5
	can_paradox = TRUE
	hidden_origin_tech = TECH_SYNDICATE
	hidden_tech_level = 3

/obj/item/organ/internal/heart/xenobiology/bananium/insert(mob/living/carbon/human/M, special, dont_remove_slot)
	. = ..()
	if(M.mind)
		if(M.mind.assigned_role == "Clown")
			M.AddComponent(/datum/component/squeak, null, null, null, null, null, TRUE, falloff_exponent = 20)
			to_chat(M, "<span class='userdanger'>You feel great!</span>")
			return
		else if(M.mind.assigned_role == "Mime")
			M.AddComponent(/datum/component/squeak)
			M.AddElement(/datum/element/waddling)
			ADD_TRAIT(M, TRAIT_COMIC_SANS, name)
			to_chat(M, "<span class='userdanger'>UH OH</span>")
		else
			M.emote("scream")
			M.AdjustJitter(20 SECONDS)
			addtimer(CALLBACK(M, TYPE_PROC_REF(/mob/living/carbon/human/, bananatouched_harmless)), 3 SECONDS)

/obj/item/organ/internal/heart/xenobiology/bananium/on_life()
	. = ..()
	if(!owner.mind)
		return
	if(owner.mind.assigned_role == "Clown" && organ_quality == ORGAN_PRISTINE)
		owner.adjustBruteLoss(-3)
		owner.adjustFireLoss(-3)
	else if(owner.mind.assigned_role == "Mime")
		if(prob(20))
			owner.emote("scream")
			owner.vomit(20)
			owner.EyeBlurry(10 SECONDS)
			owner.AdjustJitter(20 SECONDS, 0, 100 SECONDS)
			owner.AdjustDizzy(20 SECONDS, 0, 100 SECONDS)
			owner.Druggy(30 SECONDS)
		if(owner.dna.species.tox_mod <= 0) // If they can't take tox damage, make them take burn damage
			owner.adjustFireLoss(1.5 * REAGENTS_EFFECT_MULTIPLIER, robotic = TRUE)
		else
			owner.adjustToxLoss(1.5 * REAGENTS_EFFECT_MULTIPLIER)
		if(prob(6))
			var/list/clown_message = list("You feel light-headed.",
			"You can't see straight.",
			"You feel about as funny as the station clown.",
			"Bright colours and rainbows cloud your vision.",
			"Your funny bone aches.",
			"What was that?!",
			"You can hear bike horns in the distance.",
			"You feel like <em>SHOUTING</em>!",
			"Sinister laughter echoes in your ears.",
			"Your legs feel like jelly.",
			"You feel like telling a pun.",
			)
			to_chat(owner, "<span class='warning'>[pick(clown_message)]</span>")


/obj/item/organ/internal/heart/xenobiology/bananium/remove(mob/living/carbon/human/M, special)
	. = ..()
	if(M.mind)
		if(M.mind.assigned_role == "Clown")
			M.DeleteComponent(/datum/component/squeak)
			to_chat(M, "<span class='userdanger'>You feel great!</span>")
		else
			M.RemoveElement(/datum/element/waddling)
			M.DeleteComponent(/datum/component/squeak)
			REMOVE_TRAIT(M, TRAIT_COMIC_SANS, name)
			to_chat(M, "<span class='danger'>Blissful silence...</span>")

/obj/item/organ/internal/heart/xenobiology/cursed_bananium
	name = "Cursed Bananium Heart"
	desc = "This organ is wreathed in foul energy from cursed bananium. There may be great power here, but only the truest of souls could bring it forward."
	analyzer_price = 50
	unremovable = TRUE
	layer = ABOVE_MOB_LAYER // front and center baybee
	hidden_origin_tech = TECH_SYNDICATE
	hidden_tech_level = 3
	var/list/clown_noises = list(
		"HONK!",
		"SQUEAK!",
		"TEEHEE!",
		"HONK HONK HONK HONK HONK!!!",
		"THEY MUST ALL BE HONKED!",
	)

/obj/item/organ/internal/heart/xenobiology/cursed_bananium/insert(mob/living/carbon/human/M, special, dont_remove_slot)
	if(tgui_alert(src, "This is a permanent action, guarenteeing this person will be removed from the round. Are you sure?", "Insert Cursed Bananium Heart", list("Yes", "No")) != "Yes")
		return
	if(M.mind.assigned_role == "Clown")
		addtimer(CALLBACK(src, PROC_REF(glorious_death), M), 5 MINUTES)
		to_chat(owner, "<span class='userdanger'>YOU FEEL THE PURE, UNFILTERED JOY OF THE HONKMOTHER!!!</span>")
		playsound(M, 'sound/magic/magic_block_holy.ogg', 60)
		ADD_TRAIT(M, TRAIT_GOTTAGOFAST, ORGAN_TRAIT)
		M.color = rgb(255, 251, 0)
		M.set_light(2, 5, rgb(255, 251, 0))
		M.AddComponent(/datum/component/squeak)
	else
		M.emote("scream")
		M.SetJitter(20 SECONDS)
		addtimer(CALLBACK(M, TYPE_PROC_REF(/mob/living/carbon/human/, makeCluwne)), 5 SECONDS)
	. = ..()

/obj/item/organ/internal/heart/xenobiology/cursed_bananium/proc/glorious_death(mob/living/carbon/human/M)
	playsound(M.loc, 'sound/effects/pray.ogg', 60, extrarange = 10, falloff_exponent = 2, ignore_walls = TRUE, pressure_affected = FALSE)
	M.color = rgb(255, 252, 82)
	M.set_light(10, 25, rgb(255, 252, 82))
	M.add_filter("sacrifice_glow", 2, list("type" = "outline", "color" = "#fbff00d2", "size" = 2))
	if(M.buckled)
		unbuckle_mob(M, force = TRUE)
	M.move_resist = INFINITY
	M.Stun(10 SECONDS)
	M.dir = 2
	animate(M, pixel_y = 64, time = 2 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(finalize_death), M), 2 SECONDS)
	to_chat(owner, "<span class='userdanger'>THE JOY! THE POWER! YOU CAN FEEL THE HONKMOTHERS SMILE! YOU CAN FEEL- oh no</span>")

/obj/item/organ/internal/heart/xenobiology/cursed_bananium/proc/finalize_death(mob/living/carbon/human/M)
	explosion(get_turf(M),0,2,4,4, smoke = TRUE, cause = owner)
	M.gib()

/obj/item/organ/internal/heart/xenobiology/cursed_bananium/on_life()
	. = ..()
	if(owner.mind) // I AM A GOD!!!!
		if(owner.mind.assigned_role == "Clown")
			owner.adjustBruteLoss(-15)
			owner.adjustFireLoss(-15)
			owner.adjustOxyLoss(-15)
			owner.adjustToxLoss(-15)
			owner.adjustStaminaLoss(-30)
			owner.SetJitter(500 SECONDS) //High numbers for violent convulsions
			if(prob(10))
				to_chat(owner, "<span class='userdanger'>[pick(clown_noises)]</span>")

/obj/item/organ/internal/cell/xenobiology/supercharged
	name = "Supercharged Core"
	desc = "This specialized core thrumms with potental and energy. It desperately seeks release."
	analyzer_price = 80
	hidden_origin_tech = TECH_TOXINS
	hidden_tech_level = 7
/obj/item/organ/internal/cell/xenobiology/supercharged/Initialize(mapload)
	. = ..()
	icon_state = pick("vetus1", "vetus2")

/obj/item/organ/internal/cell/xenobiology/supercharged/insert(mob/living/carbon/human/M, special = 0, dont_remove_slot = 0)
	. = ..()
	var/datum/spell/charge_up/explode/spell = new
	spell.quality = organ_quality
	M.AddSpell(spell)

/obj/item/organ/internal/cell/xenobiology/supercharged/remove(mob/living/carbon/human/M, special = 0)
	. = ..()
	M.RemoveSpell(/datum/spell/charge_up/explode)

/datum/spell/charge_up/explode
	name = "Detonate"
	desc = "Build up energy in your core, allowing for a fiery detonation!"
	clothes_req = FALSE
	stat_allowed = CONSCIOUS
	invocation_type = "none"
	action_icon_state = "genetic_incendiary"
	action_background_icon_state = "bg_flayer"
	max_charge_time = 10 SECONDS
	base_cooldown = 10 MINUTES
	charge_sound = new /sound('sound/magic/lightning_chargeup.ogg', channel = 7)
	stop_charging_text = "You cool your core before it goes critical."
	start_charging_text = "You begin to overload your core!"
	stop_charging_fail_text = "You try to stop your cores charge but it's too late!"
	var/quality

/datum/spell/charge_up/explode/New()
	..()
	charge_up_overlay = image(icon = 'icons/effects/effects.dmi', icon_state = "purplesparkles", layer = EFFECTS_LAYER)

/datum/spell/charge_up/explode/create_new_targeting()
	return new /datum/spell_targeting/self

/datum/spell/charge_up/explode/Click()
	if(cast_check(TRUE, FALSE, usr))
		if(!start_time)
			INVOKE_ASYNC(src, PROC_REF(StartChargeup), usr)
		else
			if(!try_stop_buildup(usr))
				return // Don't remove the click intercept

/datum/spell/charge_up/explode/Discharge(mob/user)
	. = ..()
	if(quality == ORGAN_DAMAGED)
		explosion(user.loc, 1, 2, 3, 3, cause = user) // gaurenteed gib, just about
	else
		explosion(user.loc, 0, 2, 3, 3, cause = user)
	if(quality == ORGAN_PRISTINE)
		user.status_flags |= GODMODE
		addtimer(CALLBACK(src, PROC_REF(cleanup), user), 0.3 SECONDS) // juuust long enough to survive the blast itself.

/datum/spell/charge_up/explode/proc/cleanup(mob/living/carbon/human/user)
	user.status_flags &= ~GODMODE
	if(user.nutrition > 140) // overloading your powersource will do that
		user.nutrition = 140
	else
		user.nutrition = max(user.nutrition - 75, 5)
	for(var/obj/item/organ/internal/cell/C in user.internal_organs)
		C.damage += 40 // ouch. Maybe dont blow up

/obj/item/organ/internal/heart/xenobiology/megacarp
	name = "Rancid Clump"
	desc = "It reeks of fish and... soy sauce?"
	analyzer_price = 40
	can_paradox = TRUE

/obj/item/organ/internal/heart/xenobiology/megacarp/insert(mob/living/carbon/human/M, special = 0, dont_remove_slot = 0)
	if(!M.mind)
		M.visible_message("The organ doesnt look like its going to fit right now! It refuses.")
		return
	var/datum/spell/shapeshift/megacarp/spell = new
	spell.quality = organ_quality
	M.mind.AddSpell(spell)
	. = ..()

/obj/item/organ/internal/heart/xenobiology/megacarp/remove(mob/living/carbon/human/M, special)
	if(!M.mind)
		return
	M.mind.RemoveSpell(/datum/spell/shapeshift/megacarp)
	. = ..()

/datum/spell/shapeshift/megacarp
	name = "Fish Form"
	desc = "Take on the shape of a massive fish after a short delay."
	invocation = "*scream"
	var/quality

/datum/spell/shapeshift/megacarp/New()
	. = ..()
	if(quality == ORGAN_PRISTINE)
		shapeshift_type = /mob/living/simple_animal/hostile/carp/megacarp/xeno_organ
		current_shapes = list(/mob/living/simple_animal/hostile/carp/megacarp/xeno_organ)
		current_casters = list()
		possible_shapes = list(/mob/living/simple_animal/hostile/carp/megacarp/xeno_organ)
	else
		shapeshift_type = /mob/living/simple_animal/hostile/carp/xeno_organ
		current_shapes = list(/mob/living/simple_animal/hostile/carp/xeno_organ)
		current_casters = list()
		possible_shapes = list(/mob/living/simple_animal/hostile/carp/xeno_organ)

/datum/spell/shapeshift/megacarp/Shapeshift(mob/living/carbon/human/M)
	M.visible_message("<span class='danger'>[M] screams in agony as scales and fins erupt out of their flesh!</span>",
		"<span class='dangeruser'>You begin channeling the painful transformation.</span>")
	if(!do_after(M, 5 SECONDS, FALSE, M))
		to_chat(M, "<span class='warning'>You lose concentration of the spell!</span>")
		return
	. = ..()

/mob/living/simple_animal/hostile/carp/xeno_organ
	maxHealth = 100
	health = 100
	gold_core_spawnable = NO_SPAWN
	universal_speak = TRUE
	universal_understand = TRUE
	pass_flags = PASSTABLE

/mob/living/simple_animal/hostile/carp/megacarp/xeno_organ
	maxHealth = 175
	health = 175
	gold_core_spawnable = NO_SPAWN
	universal_speak = TRUE
	universal_understand = TRUE
	pass_flags = PASSTABLE

/obj/item/organ/internal/appendix/xenobiology/feverish
	name = "Feverish Organ"
	desc = "This organ is warm, and looks sickly. Yet by all means, there doesnt appear to be any infections."
	analyzer_price = 15


/obj/item/organ/internal/appendix/xenobiology/feverish/on_life()
	. = ..()
	if(owner.bodytemperature > 600)
		return
	switch(organ_quality)
		if(ORGAN_DAMAGED)
			owner.bodytemperature += 15
		if(ORGAN_NORMAL)
			owner.bodytemperature += 20
		if(ORGAN_PRISTINE)
			owner.bodytemperature += 30

/obj/item/organ/internal/appendix/xenobiology/freezing
	name = "Freezing Organ"
	desc = "This organ is cold to the touch, despite seeming to be very active."
	analyzer_price = 15

/obj/item/organ/internal/appendix/xenobiology/freezing/on_life()
	. = ..()
	if(owner.bodytemperature < 30)
		return
	switch(organ_quality)
		if(ORGAN_DAMAGED)
			owner.bodytemperature -= 15
		if(ORGAN_NORMAL)
			owner.bodytemperature -= 20
		if(ORGAN_PRISTINE)
			owner.bodytemperature -= 30

/obj/item/organ/internal/kidneys/xenobiology/lethargic
	name = "Lethargic Organ"
	desc = "This organ barely seems to do anything, only being just active enough to keep itself alive. However, it seems exceptionally hardy."
	analyzer_price = 20

/obj/item/organ/internal/kidneys/xenobiology/lethargic/insert(mob/living/carbon/human/M, special = 0, dont_remove_slot = 0)
	. = ..()
	ADD_TRAIT(M, TRAIT_GOTTAGOSLOW, ORGAN_TRAIT)
	if(organ_quality == ORGAN_DAMAGED)
		M.maxHealth += 10
	if(organ_quality == ORGAN_NORMAL)
		M.maxHealth += 25
	if(organ_quality == ORGAN_PRISTINE)
		M.maxHealth += 50

/obj/item/organ/internal/kidneys/xenobiology/lethargic/remove(mob/living/carbon/M, special)
	. = ..()
	REMOVE_TRAIT(M, TRAIT_GOTTAGOSLOW, ORGAN_TRAIT)
	if(organ_quality == ORGAN_DAMAGED)
		M.maxHealth -= 10
	if(organ_quality == ORGAN_NORMAL)
		M.maxHealth -= 25
	if(organ_quality == ORGAN_PRISTINE)
		M.maxHealth -= 50

/obj/item/organ/internal/ears/xenobiology/colorful
	name = "Colorful Organ"
	desc = "This organ seems to constantly color and mold the other flesh around it. Thankfully, the changes are only aesthetic."
	analyzer_price = 20
	var/next_change = 1

	COOLDOWN_DECLARE(hair_change)


/obj/item/organ/internal/ears/xenobiology/colorful/on_life()
	. = ..()
	if(!COOLDOWN_FINISHED(src, hair_change))
		return
	COOLDOWN_START(src, hair_change, 1 MINUTES)
	scramble(1, owner, 100)

/obj/item/organ/internal/ears/xenobiology/sinister
	name = "Sinister Organ"
	desc = "This organ is brimming with foul aura. Small buds seem to be growing out of it"
	analyzer_price = 60
	hidden_origin_tech = TECH_COMBAT
	hidden_tech_level = 6

/obj/item/organ/internal/ears/xenobiology/sinister/Initialize(mapload)
	. = ..()
	icon_state = pick("legion1", "legion2")

/obj/item/organ/internal/ears/xenobiology/sinister/insert(mob/living/carbon/M, special = 0, dont_remove_slot = 0)
	. = ..()
	var/datum/spell/head_attack/spell = new
	spell.quality = organ_quality
	if(organ_quality == ORGAN_PRISTINE)
		spell.base_cooldown = 3 MINUTES
	M.AddSpell(spell)

/obj/item/organ/internal/ears/xenobiology/sinister/remove(mob/living/carbon/M, special = 0)
	. = ..()
	M.RemoveSpell(/datum/spell/head_attack)

/datum/spell/head_attack
	name = "Aggressive Budding"
	desc = "Grow and detach a new head from yourself to send towards your enemies. Cast again to destroy any existing heads."
	base_cooldown = 5 MINUTES
	clothes_req = FALSE
	stat_allowed = CONSCIOUS
	invocation_type = "*scream"
	action_icon = 'icons/mob/actions/actions_elites.dmi'
	action_icon_state = "head_detach"
	action_background_icon_state = "bg_default"
	sound = 'sound/effects/blood1.ogg'
	sound = null
	active = FALSE
	var/quality
	var/mob/living/simple_animal/hostile/asteroid/elite/legionnairehead/xenobiology/newhead

/datum/spell/head_attack/create_new_targeting(list/targets, mob/living/user)
	. = ..()
	var/datum/spell_targeting/clicked_atom/external/C = new()
	C.range = 20
	return C

/datum/spell/head_attack/Click(mob/user)
	. = ..()
	if(newhead)
		to_chat(user, "<span class='notice'>We disperse the summoned head.</span>")
		on_head_death()
		return

/datum/spell/head_attack/cast(list/targets, mob/living/carbon/human/user)
	. = ..()
	if(!isliving(targets[1]))
		to_chat(user, "<span class='warning'>We can only select living targets!</span>")
		revert_cast()
		return
	var/mob/living/target = targets[1] // only ever one target
	if(!user.get_organ("head"))
		to_chat(user, "<span class='warning'>We cant use this without a head!</span>")
		revert_cast()
		return
	if(target == user)
		to_chat(user, "<span class='warning'>It would be a bad idea to target ourself.</span>")
		revert_cast()
		return
	if(target.stat == DEAD)
		to_chat(user, "<span class='warning'>Our new head wont attack corpses</span>")
		revert_cast()
		return
	if(!newhead)
		if(quality == ORGAN_DAMAGED && prob(30))
			user.adjustBruteLoss(15) // ouch!
		user.visible_message("<span class='warning'>[src] produces a new head!</span>", "<span class='warning'>You produce a new head and send it to your target!</span>")
		newhead = new /mob/living/simple_animal/hostile/asteroid/elite/legionnairehead/xenobiology(user.loc)
		newhead.GiveTarget(target)
		newhead.faction = user.faction.Copy()
		newhead.icon = null
		newhead.name = "[user]'s head"
		newhead.parent_spell = src
		newhead.faction = list(user)
		newhead.permanent_target = target
		var/obj/item/user_head = user.get_organ("head")
		var/obj/item/dupe_head = DuplicateObject(user_head, perfectcopy=1, sameloc=0, newloc=newhead.contents)
		newhead.mounted_head = dupe_head
		var/matrix/M = matrix()
		dupe_head.transform = M
		var/image/IM = image(dupe_head.icon, dupe_head.icon_state)
		IM.pixel_y -= 6
		IM.overlays = dupe_head.overlays.Copy()
		newhead.overlays += IM
		qdel(dupe_head)
		revert_cast()

/datum/spell/head_attack/proc/on_head_death()
	cooldown_handler.start_recharge()
	QDEL_NULL(newhead)

/mob/living/simple_animal/hostile/asteroid/elite/legionnairehead/xenobiology
	desc = "The floating head of a crew member, sent to destroy their enemies."
	maxHealth = 50
	health = 50
	density = FALSE
	melee_damage_lower = 5
	melee_damage_upper = 5
	var/datum/spell/head_attack/parent_spell
	var/mob/living/permanent_target
	var/obj/item/organ/external/head/mounted_head

	COOLDOWN_DECLARE(time_to_live)

/mob/living/simple_animal/hostile/asteroid/elite/legionnairehead/xenobiology/Initialize(mapload)
	. = ..()
	COOLDOWN_START(src, time_to_live, 30 SECONDS)

/mob/living/simple_animal/hostile/asteroid/elite/legionnairehead/xenobiology/death()
	if(parent_spell)
		parent_spell.on_head_death()
	. = ..()

/mob/living/simple_animal/hostile/asteroid/elite/legionnairehead/xenobiology/Life(seconds, times_fired)
	if(target != permanent_target)
		src.visible_message("<span class ='notice'>With no valid targets, the head crumbles into a pile of flesh</span>")
		parent_spell.on_head_death()
	if(COOLDOWN_FINISHED(src, time_to_live))
		src.visible_message("<span class ='notice'>The head loses energy, and crumbles into a pile of flesh</span>")
		parent_spell.on_head_death()
	. = ..()
