//Largely beneficial effects go here, even if they have drawbacks. An example is provided in Shadow Mend.

/datum/status_effect/his_grace
	id = "his_grace"
	duration = -1
	tick_interval = 4
	alert_type = /obj/screen/alert/status_effect/his_grace
	var/bloodlust = 0

/obj/screen/alert/status_effect/his_grace
	name = "His Grace"
	desc = "His Grace hungers, and you must feed Him."
	icon_state = "his_grace"
	alerttooltipstyle = "hisgrace"

/obj/screen/alert/status_effect/his_grace/MouseEntered(location, control, params)
	desc = initial(desc)
	var/datum/status_effect/his_grace/HG = attached_effect
	desc += "<br><font size=3><b>Current Bloodthirst: [HG.bloodlust]</b></font>\
	<br>Becomes undroppable at <b>[HIS_GRACE_FAMISHED]</b>\
	<br>Will consume you at <b>[HIS_GRACE_CONSUME_OWNER]</b>"
	..()

/datum/status_effect/his_grace/on_apply()
	add_attack_logs(owner, owner, "gained His Grace's stun immunity", ATKLOG_ALL)
	owner.add_stun_absorption("hisgrace", INFINITY, 3, null, "His Grace protects you from the stun!")
	return ..()

/datum/status_effect/his_grace/tick()
	bloodlust = 0
	var/graces = 0
	var/list/held_items = list()
	held_items += owner.l_hand
	held_items += owner.r_hand
	for(var/obj/item/his_grace/HG in held_items)
		if(HG.bloodthirst > bloodlust)
			bloodlust = HG.bloodthirst
		if(HG.awakened)
			graces++
	if(!graces)
		owner.apply_status_effect(STATUS_EFFECT_HISWRATH)
		qdel(src)
		return
	var/grace_heal = bloodlust * 0.05
	owner.adjustBruteLoss(-grace_heal)
	owner.adjustFireLoss(-grace_heal)
	owner.adjustToxLoss(-grace_heal)
	owner.adjustOxyLoss(-(grace_heal * 2))
	owner.adjustCloneLoss(-grace_heal)

/datum/status_effect/his_grace/on_remove()
	add_attack_logs(owner, owner, "lost His Grace's stun immunity", ATKLOG_ALL)
	if(islist(owner.stun_absorption) && owner.stun_absorption["hisgrace"])
		owner.stun_absorption -= "hisgrace"

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
		ADD_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, "blooddrunk")
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H.physiology.brute_mod *= 0.1
			H.physiology.burn_mod *= 0.1
			H.physiology.tox_mod *= 0.1
			H.physiology.oxy_mod *= 0.1
			H.physiology.clone_mod *= 0.1
			H.physiology.stamina_mod *= 0.1
		add_attack_logs(owner, owner, "gained blood-drunk stun immunity", ATKLOG_ALL)
		owner.add_stun_absorption("blooddrunk", INFINITY, 4)
		owner.playsound_local(get_turf(owner), 'sound/effects/singlebeat.ogg', 40, TRUE, use_reverb = FALSE)

/datum/status_effect/blooddrunk/on_remove()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.physiology.brute_mod *= 10
		H.physiology.burn_mod *= 10
		H.physiology.tox_mod *= 10
		H.physiology.oxy_mod *= 10
		H.physiology.clone_mod *= 10
		H.physiology.stamina_mod *= 10
	add_attack_logs(owner, owner, "lost blood-drunk stun immunity", ATKLOG_ALL)
	REMOVE_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, "blooddrunk")
	if(islist(owner.stun_absorption) && owner.stun_absorption["blooddrunk"])
		owner.stun_absorption -= "blooddrunk"

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
	H.physiology.brute_mod *= 0.5
	H.physiology.burn_mod *= 0.8
	H.physiology.stamina_mod *= 0.5
	H.physiology.stun_mod *= 0.5
	var/datum/antagonist/vampire/V = owner.mind.has_antag_datum(/datum/antagonist/vampire)
	if(V.get_ability(/datum/vampire_passive/blood_swell_upgrade))
		bonus_damage_applied = TRUE
		H.physiology.melee_bonus += 10
		H.dna.species.punchstunthreshold += 8 //higher chance to stun but not 100%

/datum/status_effect/bloodswell/on_remove()
	if(!ishuman(owner))
		return
	REMOVE_TRAIT(owner, TRAIT_CHUNKYFINGERS, VAMPIRE_TRAIT)
	var/mob/living/carbon/human/H = owner
	H.physiology.brute_mod /= 0.5
	H.physiology.burn_mod /= 0.8
	H.physiology.stamina_mod /= 0.5
	H.physiology.stun_mod /= 0.5
	if(bonus_damage_applied)
		bonus_damage_applied = FALSE
		H.physiology.melee_bonus -= 10
		H.dna.species.punchstunthreshold -= 8

/datum/status_effect/blood_rush
	alert_type = null
	duration = 10 SECONDS

/datum/status_effect/blood_rush/on_apply()
	ADD_TRAIT(owner, TRAIT_GOTTAGOFAST, VAMPIRE_TRAIT)
	return TRUE

/datum/status_effect/blood_rush/on_remove()
	REMOVE_TRAIT(owner, TRAIT_GOTTAGOFAST, VAMPIRE_TRAIT)

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
	var/deathTick = 0
	/// How many points the rod has to heal with, maxes at 50, or whatever heal_points_max is set to.
	var/heal_points = 50
	/// Max heal points for the rod to spend on healing people
	var/max_heal_points = 50

/datum/status_effect/hippocraticOath/on_apply()
	//Makes the user passive, it's in their oath not to harm!
	ADD_TRAIT(owner, TRAIT_PACIFISM, "hippocraticOath")
	var/datum/atom_hud/H = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	H.add_hud_to(owner)
	return ..()

/datum/status_effect/hippocraticOath/on_remove()
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
		if(heal_points < max_heal_points)
			heal_points = min(heal_points += 3, max_heal_points)
		//Heal all those around you, unbiased
		for(var/mob/living/L in view(7, owner))
			if(heal_points <= 0)
				break
			if(L.health < L.maxHealth)
				new /obj/effect/temp_visual/heal(get_turf(L), "#375637")
			if(iscarbon(L))
				L.adjustBruteLoss(-3.5)
				L.adjustFireLoss(-3.5)
				L.adjustToxLoss(-3.5)
				L.adjustOxyLoss(-3.5)
				L.adjustStaminaLoss(-3.5)
				L.adjustBrainLoss(-3.5)
				L.adjustCloneLoss(-1) //Becasue apparently clone damage is the bastion of all health
				heal_points--
				if(ishuman(L))
					var/mob/living/carbon/human/H = L
					for(var/obj/item/organ/external/E in H.bodyparts)
						if(prob(10))
							E.mend_fracture()
							E.fix_internal_bleeding()
							heal_points--
			else if(issilicon(L))
				L.adjustBruteLoss(-3.5)
				L.adjustFireLoss(-3.5)
				heal_points--
			else if(isanimal(L))
				var/mob/living/simple_animal/SM = L
				SM.adjustHealth(-3.5)
				if(prob(50))
					heal_points -- // Animals are simpler

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
	ADD_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, id)
	owner.adjustBruteLoss(-25)
	owner.adjustFireLoss(-25)
	owner.remove_CC()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.bodytemperature = H.dna.species.body_temperature
		for(var/thing in H.bodyparts)
			var/obj/item/organ/external/E = thing
			E.fix_internal_bleeding()
			E.mend_fracture()
	else
		owner.bodytemperature = BODYTEMP_NORMAL
	return TRUE

/datum/status_effect/regenerative_core/on_remove()
	REMOVE_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, id)


/datum/status_effect/speedlegs
	duration = -1
	status_type = STATUS_EFFECT_UNIQUE
	tick_interval = 4 SECONDS
	alert_type = null
	var/stacks = 0

/datum/status_effect/speedlegs/on_apply()
	ADD_TRAIT(owner, TRAIT_GOTTAGOFAST, "changeling")
	return TRUE

/datum/status_effect/speedlegs/tick()
	if(owner.stat || owner.staminaloss >= 90 || owner.mind.changeling.chem_charges <= (stacks + 1) * 3)
		to_chat(owner, "<span class='danger'>Our muscles relax without the energy to strengthen them.</span>")
		owner.Weaken(3)
		owner.remove_status_effect(STATUS_EFFECT_SPEEDLEGS)
	else
		stacks++
		owner.mind.changeling.chem_charges -= stacks * 3 //At first the changeling may regenerate chemicals fast enough to nullify fatigue, but it will stack
		if(stacks == 7) //Warning message that the stacks are getting too high
			to_chat(owner, "<span class='warning'>Our legs are really starting to hurt...</span>")

/datum/status_effect/speedlegs/before_remove()
	if(stacks < 3 && !(owner.stat || owner.staminaloss >= 90 || owner.mind.changeling.chem_charges <= (stacks + 1) * 3)) //We don't want people to turn it on and off fast, however, we need it forced off if the 3 later conditions are met.
		to_chat(owner, "<span class='notice'>Our muscles just tensed up, they will not relax so fast.</span>")
		return FALSE
	return TRUE

/datum/status_effect/speedlegs/on_remove()
	REMOVE_TRAIT(owner, TRAIT_GOTTAGOFAST, "changeling")
	if(!owner.weakened)
		to_chat(owner, "<span class='notice'>Our muscles relax.</span>")
		if(stacks >= 7)
			to_chat(owner, "<span class='danger'>We collapse in exhaustion.</span>")
			owner.Weaken(3)
			owner.emote("gasp")
	owner.mind.changeling.geneticdamage += stacks
