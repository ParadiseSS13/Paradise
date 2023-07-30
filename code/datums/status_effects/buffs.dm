//Largely beneficial effects go here, even if they have drawbacks. An example is provided in Shadow Mend.

/datum/status_effect/shadow_mend
	id = "shadow_mend"
	duration = 30
	alert_type = /obj/screen/alert/status_effect/shadow_mend

/obj/screen/alert/status_effect/shadow_mend
	name = "Shadow Mend"
	desc = "Shadowy energies wrap around your wounds, sealing them at a price. After healing, you will slowly lose health every three seconds for thirty seconds."
	icon_state = "shadow_mend"

/datum/status_effect/shadow_mend/on_apply()
	owner.visible_message("<span class='notice'>Violet light wraps around [owner]'s body!</span>", "<span class='notice'>Violet light wraps around your body!</span>")
	playsound(owner, 'sound/magic/teleport_app.ogg', 50, 1)
	return ..()

/datum/status_effect/shadow_mend/tick()
	owner.adjustBruteLoss(-15)
	owner.adjustFireLoss(-15)

/datum/status_effect/shadow_mend/on_remove()
	owner.visible_message("<span class='warning'>The violet light around [owner] glows black!</span>", "<span class='warning'>The tendrils around you cinch tightly and reap their toll...</span>")
	playsound(owner, 'sound/magic/teleport_diss.ogg', 50, 1)
	owner.apply_status_effect(STATUS_EFFECT_VOID_PRICE)


/datum/status_effect/void_price
	id = "void_price"
	duration = 300
	tick_interval = 30
	alert_type = /obj/screen/alert/status_effect/void_price

/obj/screen/alert/status_effect/void_price
	name = "Void Price"
	desc = "Black tendrils cinch tightly against you, digging wicked barbs into your flesh."
	icon_state = "shadow_mend"

/datum/status_effect/void_price/tick()
	playsound(owner, 'sound/weapons/bite.ogg', 50, 1)
	owner.adjustBruteLoss(3)

/datum/status_effect/blooddrunk
	id = "blooddrunk"
	duration = 10
	tick_interval = 0
	alert_type = /obj/screen/alert/status_effect/blooddrunk

/obj/screen/alert/status_effect/blooddrunk
	name = "Blood-Drunk"
	desc = "You are drunk on blood! Your pulse thunders in your ears! Nothing can harm you!" //not true, and the item description mentions its actual effect
	icon_state = "blooddrunk"

/datum/status_effect/blooddrunk/on_apply()
	. = ..()
	if(.)
		if(ishuman(owner))
			owner.status_flags |= IGNORESLOWDOWN
			var/mob/living/carbon/human/H = owner
			for(var/X in H.bodyparts)
				var/obj/item/organ/external/BP = X
				BP.brute_mod *= 0.1
				BP.burn_mod *= 0.1
			H.dna.species.tox_mod *= 0.1
			H.dna.species.oxy_mod *= 0.1
			H.dna.species.clone_mod *= 0.1
			H.dna.species.stamina_mod *= 0.1
		add_attack_logs(owner, owner, "gained blood-drunk stun immunity", ATKLOG_ALL)
		owner.add_stun_absorption("blooddrunk", INFINITY, 4)
		owner.playsound_local(get_turf(owner), 'sound/effects/singlebeat.ogg', 40, TRUE, use_reverb = FALSE)

/datum/status_effect/blooddrunk/on_remove()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		for(var/X in H.bodyparts)
			var/obj/item/organ/external/BP = X
			BP.brute_mod *= 10
			BP.burn_mod *= 10
		H.dna.species.tox_mod *= 10
		H.dna.species.oxy_mod *= 10
		H.dna.species.clone_mod *= 10
		H.dna.species.stamina_mod *= 10
	add_attack_logs(owner, owner, "lost blood-drunk stun immunity", ATKLOG_ALL)
	owner.status_flags &= ~IGNORESLOWDOWN
	if(islist(owner.stun_absorption) && owner.stun_absorption["blooddrunk"])
		owner.stun_absorption -= "blooddrunk"

/datum/status_effect/exercised
	id = "Exercised"
	duration = 1200
	alert_type = null

/datum/status_effect/exercised/on_creation(mob/living/new_owner, ...)
	. = ..()
	STOP_PROCESSING(SSfastprocess, src)
	START_PROCESSING(SSprocessing, src) //this lasts 20 minutes, so SSfastprocess isn't needed.

/datum/status_effect/exercised/Destroy()
	. = ..()
	STOP_PROCESSING(SSprocessing, src)

//Hippocratic Oath: Applied when the Rod of Asclepius is activated.
/datum/status_effect/hippocraticOath
	id = "Hippocratic Oath"
	status_type = STATUS_EFFECT_UNIQUE
	duration = -1
	tick_interval = 25
	examine_text = "<span class='notice'>They seem to have an aura of healing and helpfulness about them.</span>"
	alert_type = null

	var/datum/component/aura_healing/aura_healing
	var/hand
	var/deathTick = 0

/datum/status_effect/hippocraticOath/on_apply()
	var/static/list/organ_healing = list(
		"brain" = 1.4,
	)

	aura_healing = owner.AddComponent( \
		/datum/component/aura_healing, \
		range = 7, \
		brute_heal = 1.4, \
		burn_heal = 1.4, \
		toxin_heal = 1.4, \
		suffocation_heal = 1.4, \
		stamina_heal = 1.4, \
		clone_heal = 0.4, \
		simple_heal = 1.4, \
		mend_fractures_chance = 5, \
		stop_internal_bleeding_chance = 5, \
		organ_healing = organ_healing, \
		healing_color = "#375637", \
	)

	//Makes the user passive, it's in their oath not to harm!
	ADD_TRAIT(owner, TRAIT_PACIFISM, "hippocraticOath")
	var/datum/atom_hud/H = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	H.add_hud_to(owner)
	return ..()

/datum/status_effect/hippocraticOath/on_remove()
	QDEL_NULL(aura_healing)
	REMOVE_TRAIT(owner, TRAIT_PACIFISM, "hippocraticOath")
	var/datum/atom_hud/H = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	H.remove_hud_from(owner)

/datum/status_effect/hippocraticOath/tick()
	if(owner.stat == DEAD)
		if(deathTick < 4)
			deathTick += 1
		else
			owner.visible_message("<span class='notice'>[owner]'s soul is absorbed into the rod, relieving the previous snake of its duty.</span>")
			var/mob/living/simple_animal/hostile/retaliate/poison/snake/healSnake = new(owner.loc)
			var/list/chems = list("bicaridine", "perfluorodecalin", "kelotane")
			healSnake.poison_type = pick(chems)
			healSnake.name = "Asclepius's Snake"
			healSnake.real_name = "Asclepius's Snake"
			healSnake.desc = "A mystical snake previously trapped upon the Rod of Asclepius, now freed of its burden. Unlike the average snake, its bites contain chemicals with minor healing properties."
			new /obj/effect/decal/cleanable/ash(owner.loc)
			new /obj/item/rod_of_asclepius(owner.loc)
			qdel(owner)
	else
		if(ishuman(owner))
			var/mob/living/carbon/human/itemUser = owner
			var/obj/item/heldItem = (hand ==  1 ? itemUser.l_hand : itemUser.r_hand)
			if(!heldItem || !istype(heldItem, /obj/item/rod_of_asclepius)) //Checks to make sure the rod is still in their hand
				var/obj/item/rod_of_asclepius/newRod = new(itemUser.loc)
				newRod.activated()
				if(hand)
					itemUser.drop_l_hand(TRUE)
					if(itemUser.put_in_l_hand(newRod, TRUE))
						to_chat(itemUser, "<span class='notice'>The Rod of Asclepius suddenly grows back out of your arm!</span>")
					else
						if(!itemUser.has_organ("l_arm"))
							new /obj/item/organ/external/arm(itemUser)
						new /obj/item/organ/external/hand(itemUser)
						itemUser.update_body()
						itemUser.put_in_l_hand(newRod, TRUE)
						to_chat(itemUser, "<span class='notice'>Your arm suddenly grows back with the Rod of Asclepius still attached!</span>")
				else
					itemUser.drop_r_hand(TRUE)
					if(itemUser.put_in_r_hand(newRod, TRUE))
						to_chat(itemUser, "<span class='notice'>The Rod of Asclepius suddenly grows back out of your arm!</span>")
					else
						if(!itemUser.has_organ("r_arm"))
							new /obj/item/organ/external/arm/right(itemUser)
						new /obj/item/organ/external/hand/right(itemUser)
						itemUser.update_body()
						itemUser.put_in_r_hand(newRod, TRUE)
						to_chat(itemUser, "<span class='notice'>Your arm suddenly grows back with the Rod of Asclepius still attached!</span>")

			//Because a servant of medicines stops at nothing to help others, lets keep them on their toes and give them an additional boost.
			if(itemUser.health < itemUser.maxHealth)
				new /obj/effect/temp_visual/heal(get_turf(itemUser), "#375637")
			itemUser.adjustBruteLoss(-1.5)
			itemUser.adjustFireLoss(-1.5)
			itemUser.adjustToxLoss(-1.5)
			itemUser.adjustOxyLoss(-1.5)
			itemUser.adjustStaminaLoss(-1.5)
			itemUser.adjustBrainLoss(-1.5)
			itemUser.adjustCloneLoss(-0.5) //Becasue apparently clone damage is the bastion of all health

/obj/screen/alert/status_effect/regenerative_core
	name = "Reinforcing Tendrils"
	desc = "You can move faster than your broken body could normally handle!"
	icon_state = "regenerative_core"
	name = "Regenerative Core Tendrils"

/datum/status_effect/regenerative_core
	id = "Regenerative Core"
	duration = 1 MINUTES
	status_type = STATUS_EFFECT_REPLACE
	alert_type = /obj/screen/alert/status_effect/regenerative_core

/datum/status_effect/regenerative_core/on_apply()
	owner.status_flags |= IGNORE_SPEED_CHANGES
	owner.adjustBruteLoss(-25)
	owner.adjustFireLoss(-25)
	owner.remove_CC()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.bodytemperature = H.dna.species.body_temperature
		if(is_mining_level(H.z))
			for(var/thing in H.bodyparts)
				var/obj/item/organ/external/E = thing
				E.internal_bleeding = FALSE
				E.mend_fracture()
		else
			to_chat(owner, "<span class='warning'>...But the core was weakened, it is not close enough to the rest of the legions of the necropolis.</span>")
	else
		owner.bodytemperature = BODYTEMP_NORMAL
	return TRUE

/datum/status_effect/regenerative_core/on_remove()
	owner.status_flags &= ~IGNORE_SPEED_CHANGES


/datum/status_effect/fleshmend
	id = "fleshmend"
	duration = -1
	status_type = STATUS_EFFECT_REFRESH
	tick_interval = 1 SECONDS
	alert_type = null
	/// This diminishes the healing of fleshmend the higher it is.
	var/tolerance = 1
	/// This diminishes the healing of fleshmend if the user is cold when it is activated
	var/freezing = FALSE
	/// Number of heal ticks.
	var/instance_duration = 10
	/// A list of integers, one for each remaining instance of fleshmend.
	var/list/active_instances = list()
	var/ticks = 0


/datum/status_effect/fleshmend/on_apply()
	apply_new_fleshmend()
	return TRUE


/datum/status_effect/fleshmend/refresh()
	apply_new_fleshmend()
	..()


/datum/status_effect/fleshmend/proc/apply_new_fleshmend()
	tolerance += 1
	freezing = (owner.bodytemperature + 50 <= owner.dna.species.body_temperature)
	if(freezing)
		to_chat(owner, span_warning("Our healing's effectiveness is reduced by our cold body!"))
	active_instances += instance_duration


/datum/status_effect/fleshmend/tick()
	if(length(active_instances) >= 1)
		var/heal_amount = (length(active_instances) / tolerance) * (freezing ? 2 : 10)
		var/blood_restore = 30 * length(active_instances)
		owner.heal_overall_damage(heal_amount, heal_amount, updating_health = FALSE)
		owner.adjustOxyLoss(-heal_amount, FALSE)
		owner.blood_volume = min(owner.blood_volume + blood_restore, BLOOD_VOLUME_NORMAL)
		owner.updatehealth()
		var/list/expired_instances = list()
		for(var/i in 1 to length(active_instances))
			active_instances[i]--
			if(active_instances[i] <= 0)
				expired_instances += active_instances[i]
		active_instances -= expired_instances
	tolerance = max(tolerance - 0.05, 1)
	if(tolerance <= 1 && length(active_instances) == 0)
		qdel(src)


/datum/status_effect/speedlegs
	id = "gottagofast"
	duration = -1
	status_type = STATUS_EFFECT_UNIQUE
	tick_interval = 4 SECONDS
	alert_type = null
	var/stacks = 0
	/// A reference to the changeling's changeling antag datum.
	var/datum/antagonist/changeling/cling


/datum/status_effect/speedlegs/on_apply()
	cling = owner?.mind?.has_antag_datum(/datum/antagonist/changeling)
	ADD_TRAIT(owner, TRAIT_GOTTAGOFAST, CHANGELING_TRAIT)
	return TRUE


/datum/status_effect/speedlegs/tick()
	if(owner.stat || owner.staminaloss >= 90 || cling.chem_charges <= (stacks + 1) * 3)
		to_chat(owner, span_danger("Our muscles relax without the energy to strengthen them."))
		owner.Weaken(6 SECONDS)
		qdel(src)
	else
		stacks++
		cling.chem_charges -= stacks * 3 //At first the changeling may regenerate chemicals fast enough to nullify fatigue, but it will stack
		if(stacks == 7) //Warning message that the stacks are getting too high
			to_chat(owner, span_warning("Our legs are really starting to hurt..."))


/datum/status_effect/speedlegs/before_remove()
	if(stacks < 3 && !(owner.stat || owner.staminaloss >= 90 || cling.chem_charges <= (stacks + 1) * 3)) //We don't want people to turn it on and off fast, however, we need it forced off if the 3 later conditions are met.
		to_chat(owner, span_notice("Our muscles just tensed up, they will not relax so fast."))
		return FALSE
	return TRUE


/datum/status_effect/speedlegs/on_remove()
	REMOVE_TRAIT(owner, TRAIT_GOTTAGOFAST, CHANGELING_TRAIT)
	if(!owner.IsWeakened())
		to_chat(owner, span_notice("Our muscles relax."))
		if(stacks >= 7)
			to_chat(owner, span_danger("We collapse in exhaustion."))
			owner.Weaken(6 SECONDS)
			owner.emote("gasp")
	cling.genetic_damage += stacks
	cling = null


/datum/status_effect/panacea
	id = "panacea"
	duration = 20 SECONDS
	tick_interval = 2 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null


/datum/status_effect/panacea/tick()
	owner.adjustToxLoss(-5) //Has the same healing as 20 charcoal, but happens faster
	owner.radiation = max(0, owner.radiation - 70) //Same radiation healing as pentetic
	owner.adjustBrainLoss(-5)
	owner.AdjustDrunk(-12 SECONDS) //50% stronger than antihol
	owner.reagents.remove_all_type(/datum/reagent/consumable/ethanol, 10)
	for(var/datum/reagent/reagent in owner.reagents.reagent_list)
		if(!reagent.harmless)
			owner.reagents.remove_reagent(reagent.id, 2)


/datum/status_effect/terror/regeneration
	id = "terror_regen"
	duration = 250
	alert_type = null

/datum/status_effect/terror/regeneration/tick()
	owner.adjustBruteLoss(-6)

/datum/status_effect/terror/food_regen
	id = "terror_food_regen"
	duration = 250
	alert_type = null


/datum/status_effect/terror/food_regen/tick()
	owner.adjustBruteLoss(-(owner.maxHealth/20))


/datum/status_effect/hope
	id = "hope"
	duration = -1
	tick_interval = 2 SECONDS
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /obj/screen/alert/status_effect/hope

/obj/screen/alert/status_effect/hope
	name = "Hope."
	desc = "A ray of hope beyond dispair."
	icon_state = "hope"

/datum/status_effect/hope/tick()
	if(owner.stat == DEAD || owner.health <= HEALTH_THRESHOLD_DEAD) // No dead healing, or healing in dead crit
		return
	if(owner.health > 50)
		if(prob(0.5))
			hope_message()
		return
	var/heal_multiplier = min(3, ((50 - owner.health) / 50 + 1)) // 1 hp at 50 health, 2 at 0, 3 at -50
	owner.adjustBruteLoss(-heal_multiplier * 0.5)
	owner.adjustFireLoss(-heal_multiplier * 0.5)
	owner.adjustOxyLoss(-heal_multiplier)
	if(prob(heal_multiplier * 2))
		hope_message()

/datum/status_effect/hope/proc/hope_message()
	var/list/hope_messages = list("You are filled with [pick("hope", "determination", "strength", "peace", "confidence", "robustness")].",
							"Don't give up!",
							"You see your [pick("friends", "family", "coworkers", "self")] [pick("rooting for you", "cheering you on", "worrying about you")].",
							"You can't give up now, keep going!",
							"But you refused to die!",
							"You have been through worse, you can do this!",
							"People need you, do not [pick("give up", "stop", "rest", "pass away", "falter", "lose hope")] yet!",
							"This person is not nearly as robust as you!",
							"You ARE robust, don't let anyone tell you otherwise!",
							"[owner], don't lose hope, the future of the station depends on you!",
							"Do not follow the light yet!")
	var/list/un_hopeful_messages = list("DON'T FUCKING DIE NOW COWARD!",
							"Git Gud, [owner]",
							"I bet a [pick("vox", "vulp", "nian", "tajaran", "baldie")] could do better than you!",
							"You hear people making fun of you for getting robusted.")
	if(prob(99))
		to_chat(owner, "<span class='notice'>[pick(hope_messages)]</span>")
	else
		to_chat(owner, "<span class='cultitalic'>[pick(un_hopeful_messages)]</span>")


/datum/status_effect/thrall_net
	id = "thrall_net"
	tick_interval = 2 SECONDS
	duration = -1
	alert_type = null
	var/blood_cost_per_tick = 5
	var/list/target_UIDs = list()
	var/datum/antagonist/vampire/vamp


/datum/status_effect/thrall_net/on_creation(mob/living/new_owner, datum/antagonist/vampire/V, ...)
	. = ..()
	vamp = V
	START_PROCESSING(SSfastprocess, src)
	target_UIDs += owner.UID()
	var/list/view_cache = view(7, owner)
	for(var/datum/mind/M in owner.mind.som.serv)
		if(!M.has_antag_datum(/datum/antagonist/mindslave/thrall))
			continue

		if(!(M.current in view_cache))
			continue

		if(M.current.stat == DEAD)
			continue

		target_UIDs += M.current.UID()
		M.current.Beam(owner, "sendbeam", time = 2 SECONDS, maxdistance = 7)


/datum/status_effect/thrall_net/tick()
	var/total_damage = 0
	var/list/view_cache = view(7, owner)
	for(var/uid in target_UIDs)
		var/mob/living/L = locateUID(uid)
		if(!(L in view_cache) || L.stat == DEAD)
			target_UIDs -= uid
			continue
		total_damage += (L.maxHealth - L.health)
		L.Beam(owner, "sendbeam", time = 2 SECONDS, maxdistance = 7)

	var/average_damage = total_damage / length(target_UIDs)

	for(var/uid in target_UIDs)
		var/mob/living/L = locateUID(uid)
		var/current_damage = L.maxHealth - L.health
		if(current_damage == average_damage)
			continue
		if(current_damage > average_damage)
			var/heal_amount = current_damage - average_damage
			L.heal_ordered_damage(heal_amount, list(BRUTE, BURN, TOX, OXY, CLONE))
		else
			var/damage_amount = average_damage - current_damage
			L.adjustFireLoss(damage_amount)

	vamp.bloodusable = max(vamp.bloodusable - blood_cost_per_tick, 0)
	if(!vamp.bloodusable || length(target_UIDs) <= 1) // if there is one left in the list, its only the vampire.
		qdel(src)


/datum/status_effect/thrall_net/on_remove()
	. = ..()
	vamp = null


/datum/status_effect/bloodswell
	id = "bloodswell"
	duration = 30 SECONDS
	tick_interval = 0
	alert_type = /obj/screen/alert/status_effect/blood_swell
	var/bonus_damage_applied = FALSE


/obj/screen/alert/status_effect/blood_swell
	name = "Blood Swell"
	desc = "Your body has been infused with crimson magics, your resistance to attacks has greatly increased!"
	icon = 'icons/mob/actions/actions.dmi'
	icon_state = "blood_swell_status"


/datum/status_effect/bloodswell/on_apply()
	. = ..()
	if(!. || !ishuman(owner))
		return FALSE

	ADD_TRAIT(owner, TRAIT_CHUNKYFINGERS, VAMPIRE_TRAIT)
	var/mob/living/carbon/human/H = owner
	H.dna.species.brute_mod *= 0.5
	H.dna.species.burn_mod *= 0.8
	H.dna.species.stamina_mod *= 0.5
	H.dna.species.stun_mod *= 0.5

	var/datum/antagonist/vampire/V = owner.mind.has_antag_datum(/datum/antagonist/vampire)
	if(V.get_ability(/datum/vampire_passive/blood_swell_upgrade))
		bonus_damage_applied = TRUE
		H.dna.species.punchdamagelow += 14
		H.dna.species.punchdamagehigh += 14
		H.dna.species.punchstunthreshold += 10 //higher chance to stun but not 100%


/datum/status_effect/bloodswell/on_remove()
	if(!ishuman(owner))
		return

	REMOVE_TRAIT(owner, TRAIT_CHUNKYFINGERS, VAMPIRE_TRAIT)
	var/mob/living/carbon/human/H = owner
	H.dna.species.brute_mod /= 0.5
	H.dna.species.burn_mod /= 0.8
	H.dna.species.stamina_mod /= 0.5
	H.dna.species.stun_mod /= 0.5

	if(bonus_damage_applied)
		bonus_damage_applied = FALSE
		H.dna.species.punchdamagelow -= 14
		H.dna.species.punchdamagehigh -= 14
		H.dna.species.punchstunthreshold -= 10


/datum/status_effect/blood_rush
	id = "bloodrush"
	alert_type = /obj/screen/alert/status_effect/blood_rush
	duration = 10 SECONDS


/datum/status_effect/blood_rush/on_apply()
	ADD_TRAIT(owner, TRAIT_GOTTAGOFAST, VAMPIRE_TRAIT)
	return TRUE


/datum/status_effect/blood_rush/on_remove()
	REMOVE_TRAIT(owner, TRAIT_GOTTAGOFAST, VAMPIRE_TRAIT)


/obj/screen/alert/status_effect/blood_rush
	name = "Blood Rush"
	desc = "Your body is infused with blood magic, boosting your movement speed."
	icon = 'icons/mob/actions/actions.dmi'
	icon_state = "blood_rush_status"

