/obj/item/organ/internal/cyberimp
	name = "cybernetic implant"
	desc = "a state-of-the-art implant that improves a baseline's functionality."
	status = ORGAN_ROBOT
	var/implant_color = "#FFFFFF"
	var/implant_overlay
	var/crit_fail = FALSE //Used by certain implants to disable them.
	tough = TRUE // Immune to damage

/obj/item/organ/internal/cyberimp/New(mob/M = null)
	. = ..()
	if(implant_overlay)
		var/mutable_appearance/overlay = mutable_appearance(icon, implant_overlay)
		overlay.color = implant_color
		add_overlay(overlay)

/obj/item/organ/internal/cyberimp/emp_act()
	return // These shouldn't be hurt by EMPs in the standard way

//[[[[BRAIN]]]]

/obj/item/organ/internal/cyberimp/brain
	name = "cybernetic brain implant"
	desc = "injectors of extra sub-routines for the brain."
	icon_state = "brain_implant"
	implant_overlay = "brain_implant_overlay"
	parent_organ = "head"

/obj/item/organ/internal/cyberimp/brain/emp_act(severity)
	if(!owner || emp_proof)
		return
	var/weaken_time = (5 + (severity - 1 ? 0 : 5)) STATUS_EFFECT_CONSTANT
	owner.Weaken(weaken_time)
	to_chat(owner, "<span class='warning'>Your body seizes up!</span>")
	return weaken_time


/obj/item/organ/internal/cyberimp/brain/anti_drop
	name = "Anti-drop implant"
	desc = "This cybernetic brain implant will allow you to force your hand muscles to contract, preventing item dropping. Twitch ear to toggle."
	var/active = FALSE
	var/l_hand_ignore = FALSE
	var/r_hand_ignore = FALSE
	var/obj/item/l_hand_obj = null
	var/obj/item/r_hand_obj = null
	implant_color = "#DE7E00"
	slot = "brain_antidrop"
	origin_tech = "materials=4;programming=5;biotech=4"
	actions_types = list(/datum/action/item_action/organ_action/toggle)

/obj/item/organ/internal/cyberimp/brain/anti_drop/ui_action_click()
	active = !active
	if(active)
		l_hand_obj = owner.l_hand
		r_hand_obj = owner.r_hand
		if(l_hand_obj)
			if(owner.l_hand.flags & NODROP)
				l_hand_ignore = TRUE
			else
				owner.l_hand.flags |= NODROP
				l_hand_ignore = FALSE

		if(r_hand_obj)
			if(owner.r_hand.flags & NODROP)
				r_hand_ignore = TRUE
			else
				owner.r_hand.flags |= NODROP
				r_hand_ignore = FALSE

		if(!l_hand_obj && !r_hand_obj)
			to_chat(owner, "<span class='notice'>You are not holding any items, your hands relax...</span>")
			active = FALSE
		else
			var/msg = 0
			msg += !l_hand_ignore && l_hand_obj ? 1 : 0
			msg += !r_hand_ignore && r_hand_obj ? 2 : 0
			switch(msg)
				if(1)
					to_chat(owner, "<span class='notice'>Your left hand's grip tightens.</span>")
				if(2)
					to_chat(owner, "<span class='notice'>Your right hand's grip tightens.</span>")
				if(3)
					to_chat(owner, "<span class='notice'>Both of your hand's grips tighten.</span>")
	else
		release_items()
		to_chat(owner, "<span class='notice'>Your hands relax...</span>")
		l_hand_obj = null
		r_hand_obj = null

/obj/item/organ/internal/cyberimp/brain/anti_drop/emp_act(severity)
	if(!owner || emp_proof)
		return
	var/range = severity ? 10 : 5
	var/atom/A
	var/obj/item/L_item = owner.l_hand
	var/obj/item/R_item = owner.r_hand

	release_items()
	..()
	if(L_item)
		A = pick(oview(range))
		L_item.throw_at(A, range, 2)
		to_chat(owner, "<span class='notice'>Your left arm spasms and throws [L_item]!</span>")
		l_hand_obj = null
	if(R_item)
		A = pick(oview(range))
		R_item.throw_at(A, range, 2)
		to_chat(owner, "<span class='notice'>Your right arm spasms and throws [R_item]!</span>")
		r_hand_obj = null

/obj/item/organ/internal/cyberimp/brain/anti_drop/proc/release_items()
	active = FALSE
	if(!l_hand_ignore && l_hand_obj && (l_hand_obj == owner.l_hand))
		l_hand_obj.flags &= ~NODROP
	if(!r_hand_ignore && r_hand_obj && (r_hand_obj == owner.r_hand))
		r_hand_obj.flags &= ~NODROP

/obj/item/organ/internal/cyberimp/brain/anti_drop/remove(mob/living/carbon/M, special = 0)
	if(active)
		ui_action_click()
	return ..()

/obj/item/organ/internal/cyberimp/brain/anti_drop/hardened
	name = "Hardened Anti-drop implant"
	desc = "A military-grade version of the standard implant, for NT's more elite forces."
	origin_tech = "materials=6;programming=5;biotech=5"
	emp_proof = TRUE

/obj/item/organ/internal/cyberimp/brain/anti_stam
	name = "CNS Rebooter implant"
	desc = "This implant will automatically give you back control over your central nervous system, reducing downtime when fatigued. Incompatible with the Neural Jumpstarter."
	implant_color = "#FFFF00"
	slot = "brain_antistun"
	origin_tech = "materials=5;programming=4;biotech=5"
	/// How much we multiply the owners stamina regen block modifier by.
	var/stamina_crit_time_multiplier = 0.4
	/// Are we currently modifying somoeones stamina regen block modifier? If so, we will want to undo it on removal.
	var/currently_modifying_stamina = FALSE
	COOLDOWN_DECLARE(implant_cooldown)

/obj/item/organ/internal/cyberimp/brain/anti_stam/insert(mob/living/carbon/M, special = FALSE)
	..()
	RegisterSignal(M, COMSIG_CARBON_ENTER_STAMINACRIT, PROC_REF(on_enter))
	RegisterSignal(M, COMSIG_CARBON_EXIT_STAMINACRIT, PROC_REF(on_exit))
	RegisterSignal(M, COMSIG_CARBON_STAMINA_REGENERATED, PROC_REF(on_regen))

/obj/item/organ/internal/cyberimp/brain/anti_stam/remove(mob/living/carbon/M, special = FALSE)
	UnregisterSignal(M, list(COMSIG_CARBON_ENTER_STAMINACRIT, COMSIG_CARBON_EXIT_STAMINACRIT, COMSIG_CARBON_STAMINA_REGENERATED))
	on_exit()
	return ..()

/obj/item/organ/internal/cyberimp/brain/anti_stam/proc/on_enter()
	SIGNAL_HANDLER // COMSIG_CARBON_ENTER_STAMINACRIT
	if(currently_modifying_stamina || !COOLDOWN_FINISHED(src, implant_cooldown))
		return
	owner.stamina_regen_block_modifier *= stamina_crit_time_multiplier
	currently_modifying_stamina = TRUE

/obj/item/organ/internal/cyberimp/brain/anti_stam/proc/on_exit()
	SIGNAL_HANDLER // COMSIG_CARBON_EXIT_STAMINACRIT
	if(!currently_modifying_stamina)
		return
	owner.stamina_regen_block_modifier /= stamina_crit_time_multiplier
	currently_modifying_stamina = FALSE

/obj/item/organ/internal/cyberimp/brain/anti_stam/proc/on_regen()
	SIGNAL_HANDLER // COMSIG_CARBON_STAMINA_REGENERATED
	owner.update_stamina() //This is here so they actually get unstaminacrit when it triggers, vs 2-4 seconds later

/obj/item/organ/internal/cyberimp/brain/anti_stam/emp_act(severity)
	..()
	COOLDOWN_START(src, implant_cooldown, 1 MINUTES / severity)

/obj/item/organ/internal/cyberimp/brain/anti_stam/hardened
	name = "Hardened CNS Rebooter implant"
	desc = "A military-grade version of the standard implant, for NT's more elite forces."
	origin_tech = "materials=6;programming=5;biotech=5"
	emp_proof = TRUE

/obj/item/organ/internal/cyberimp/brain/anti_sleep
	name = "Neural Jumpstarter implant"
	desc = "This implant will automatically attempt to jolt you awake when it detects you have fallen unconscious. Has a short cooldown, incompatible with the CNS Rebooter."
	implant_color = "#0356fc"
	slot = "brain_antistun" //one or the other not both.
	origin_tech = "materials=5;programming=4;biotech=5"
	var/cooldown = FALSE

/obj/item/organ/internal/cyberimp/brain/anti_sleep/on_life()
	..()
	if(crit_fail)
		return
	if(owner.stat == UNCONSCIOUS && !cooldown)
		owner.AdjustSleeping(-200 SECONDS)
		owner.AdjustParalysis(-200 SECONDS)
		to_chat(owner, "<span class='notice'>You feel a rush of energy course through your body!</span>")
		cooldown = TRUE
		addtimer(CALLBACK(src, PROC_REF(sleepy_timer_end)), 50)

/obj/item/organ/internal/cyberimp/brain/anti_sleep/proc/sleepy_timer_end()
		cooldown = FALSE
		to_chat(owner, "<span class='notice'>You hear a small beep in your head as your Neural Jumpstarter finishes recharging.</span>")

/obj/item/organ/internal/cyberimp/brain/anti_sleep/emp_act(severity)
	. = ..()
	if(crit_fail || emp_proof)
		return
	crit_fail = TRUE
	owner.AdjustSleeping(400 SECONDS)
	cooldown = TRUE
	addtimer(CALLBACK(src, PROC_REF(reboot)), 90 / severity)

/obj/item/organ/internal/cyberimp/brain/anti_sleep/proc/reboot()
	crit_fail = FALSE
	cooldown = FALSE

/obj/item/organ/internal/cyberimp/brain/anti_sleep/hardened
	name = "Hardened Neural Jumpstarter implant"
	desc = "A military-grade version of the standard implant, for NT's more elite forces."
	origin_tech = "materials=6;programming=5;biotech=5"
	emp_proof = TRUE

/obj/item/organ/internal/cyberimp/brain/anti_sleep/hardened/compatible
	name = "Hardened Neural Jumpstarter implant"
	desc = "A military-grade version of the standard implant, for NT's more elite forces. This one is compatible with the CNS Rebooter implant."
	slot = "brain_antisleep"
	emp_proof = TRUE

/obj/item/organ/internal/cyberimp/brain/clown_voice
	name = "Comical implant"
	desc = "<span class='sans'>Uh oh.</span>"
	implant_color = "#DEDE00"
	slot = "brain_clownvoice"
	origin_tech = "materials=2;biotech=2"

/obj/item/organ/internal/cyberimp/brain/clown_voice/insert(mob/living/carbon/M, special = FALSE)
	..()
	ADD_TRAIT(M, TRAIT_COMIC_SANS, "augment")

/obj/item/organ/internal/cyberimp/brain/clown_voice/remove(mob/living/carbon/M, special = FALSE)
	REMOVE_TRAIT(M, TRAIT_COMIC_SANS, "augment")
	return ..()

/obj/item/organ/internal/cyberimp/brain/speech_translator //actual translating done in human/handle_speech_problems
	name = "Speech translator implant"
	desc = "While known as a translator, this implant actually generates speech based on the user's thoughts when activated, completely bypassing the need to speak."
	implant_color = "#C0C0C0"
	slot = "brain_speechtranslator"
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "materials=4;biotech=6"
	actions_types = list(/datum/action/item_action/organ_action/toggle)
	var/active = TRUE
	var/speech_span = ""
	var/speech_verb = "states"

/obj/item/organ/internal/cyberimp/brain/speech_translator/clown
	name = "Comical speech translator implant"
	implant_color = "#DEDE00"
	speech_span = "sans"

/obj/item/organ/internal/cyberimp/brain/speech_translator/emp_act(severity)
	if(emp_proof)
		return
	if(owner && active && !crit_fail)
		to_chat(owner, "<span class='danger'>Your translator implant shuts down with a harsh buzz.</span>")
		addtimer(CALLBACK(src, PROC_REF(reboot)), 60 SECONDS)
		crit_fail = TRUE
		active = FALSE

/obj/item/organ/internal/cyberimp/brain/speech_translator/proc/reboot()
	crit_fail = FALSE
	if(owner)
		to_chat(owner, "<span class='notice'>Your translator implant beeps.</span>")
		SEND_SOUND(owner, sound('sound/machines/twobeep.ogg'))

/obj/item/organ/internal/cyberimp/brain/speech_translator/ui_action_click()
	if(owner && crit_fail)
		to_chat(owner, "<span class='warning'>The implant is still rebooting.</span>")
	else if(owner && !active)
		to_chat(owner, "<span class='notice'>You turn on your translator implant.</span>")
		active = TRUE
	else if(owner && active)
		to_chat(owner, "<span class='notice'>You turn off your translator implant.</span>")
		active = FALSE

/obj/item/organ/internal/cyberimp/brain/wire_interface
	name = "Wire interface implant"
	desc = "This cybernetic brain implant will allow you to interface with electrical currents to sense the purpose of wires."
	implant_color = "#fff782"
	slot = "brain_wire_interface"
	origin_tech = "materials=5;programming=4;biotech=4"

/obj/item/organ/internal/cyberimp/brain/wire_interface/insert(mob/living/carbon/M, special = FALSE)
	..()
	ADD_TRAIT(M, TRAIT_SHOW_WIRE_INFO, "show_wire_info[UID()]")

/obj/item/organ/internal/cyberimp/brain/wire_interface/remove(mob/living/carbon/M, special = FALSE)
	REMOVE_TRAIT(M, TRAIT_SHOW_WIRE_INFO, "show_wire_info[UID()]")
	return ..()

/obj/item/organ/internal/cyberimp/brain/wire_interface/hardened
	name = "Hardened Wire interface implant"
	desc = "This wire interface implant is actually wireless, to avoid issues with electromagnetic pulses."
	origin_tech = "materials=6;programming=6;biotech=6"
	emp_proof = TRUE


//[[[[MOUTH]]]]
/obj/item/organ/internal/cyberimp/mouth
	parent_organ = "mouth"

/obj/item/organ/internal/cyberimp/mouth/breathing_tube
	name = "breathing tube implant"
	desc = "This simple implant adds an internals connector to your back, allowing you to use internals without a mask and protecting you from being choked."
	icon_state = "implant_mask"
	slot = "breathing_tube"
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "materials=2;biotech=3"

/obj/item/organ/internal/cyberimp/mouth/breathing_tube/emp_act(severity)
	if(emp_proof)
		return
	if(prob(60/severity) && owner)
		to_chat(owner, "<span class='warning'>Your breathing tube suddenly closes!</span>")
		owner.AdjustLoseBreath(4 SECONDS)

//[[[[CHEST]]]]
/obj/item/organ/internal/cyberimp/chest
	name = "cybernetic torso implant"
	desc = "implants for the organs in your torso."
	icon_state = "chest_implant"
	implant_overlay = "chest_implant_overlay"
	parent_organ = "chest"

/obj/item/organ/internal/cyberimp/chest/nutriment
	name = "Nutriment pump implant"
	desc = "This implant will synthesize a small amount of nutriment and pumps it directly into your bloodstream when you are starving."
	implant_color = "#00AA00"
	var/hunger_threshold = NUTRITION_LEVEL_STARVING
	var/synthesizing = 0
	var/poison_amount = 5
	var/disabled_by_emp = FALSE
	slot = "stomach"
	origin_tech = "materials=2;powerstorage=2;biotech=2"

/obj/item/organ/internal/cyberimp/chest/nutriment/examine(mob/user)
	. = ..()
	if(emp_proof)
		. += " The implant has been hardened. It is invulnerable to EMPs."

/obj/item/organ/internal/cyberimp/chest/nutriment/on_life()
	if(!owner)
		return
	if(synthesizing)
		return
	if(disabled_by_emp)
		return
	if(owner.stat == DEAD)
		return
	if(owner.nutrition <= hunger_threshold)
		synthesizing = TRUE
		to_chat(owner, "<span class='notice'>You feel less hungry...</span>")
		owner.adjust_nutrition(50)
		addtimer(CALLBACK(src, PROC_REF(synth_cool)), 50)

/obj/item/organ/internal/cyberimp/chest/nutriment/proc/synth_cool()
	synthesizing = FALSE

/obj/item/organ/internal/cyberimp/chest/nutriment/proc/emp_cool()
	disabled_by_emp = FALSE

/obj/item/organ/internal/cyberimp/chest/nutriment/emp_act(severity)
	if(!owner || emp_proof)
		return
	owner.vomit(100, FALSE, TRUE, 3, FALSE)	// because when else do we ever use projectile vomiting
	owner.visible_message("<span class='warning'>The contents of [owner]'s stomach erupt violently from [owner.p_their()] mouth!</span>",
		"<span class='warning'>You feel like your insides are burning as you vomit profusely!</span>",
		"<span class='warning'>You hear vomiting and a sickening splattering against the floor!</span>")
	owner.reagents.add_reagent("????",poison_amount / severity) //food poisoning
	disabled_by_emp = TRUE		// Disable the implant for a little bit so this effect actually matters
	synthesizing = FALSE
	addtimer(CALLBACK(src, PROC_REF(emp_cool)), 60 SECONDS)

/obj/item/organ/internal/cyberimp/chest/nutriment/plus
	name = "Nutriment pump implant PLUS"
	desc = "This implant will synthesize a small amount of nutriment and pumps it directly into your bloodstream when you are hungry."
	implant_color = "#006607"
	hunger_threshold = NUTRITION_LEVEL_HUNGRY
	poison_amount = 10
	origin_tech = "materials=4;powerstorage=3;biotech=3"

/obj/item/organ/internal/cyberimp/chest/nutriment/hardened
	name = "hardened nutriment pump implant"
	emp_proof = TRUE

/obj/item/organ/internal/cyberimp/chest/nutriment/plus/hardened
	name = "hardened nutriment pump implant PLUS"
	emp_proof = TRUE

/obj/item/organ/internal/cyberimp/chest/reviver
	name = "Reviver implant"
	desc = "This implant will attempt to heal you out of critical condition. For the faint of heart!"
	implant_color = "#AD0000"
	origin_tech = "materials=5;programming=4;biotech=4"
	slot = "heartdrive"
	var/revive_cost = 0
	var/reviving = FALSE
	var/cooldown = 0

/obj/item/organ/internal/cyberimp/chest/reviver/hardened
	name = "Hardened reviver implant"
	emp_proof = TRUE

/obj/item/organ/internal/cyberimp/chest/reviver/hardened/Initialize(mapload)
	. = ..()
	desc += " The implant has been hardened. It is invulnerable to EMPs."

/obj/item/organ/internal/cyberimp/chest/reviver/on_life()
	if(cooldown > world.time || owner.suiciding) // don't heal while you're in cooldown!
		return
	if(reviving)
		reviving = FALSE
		if(owner.health <= HEALTH_THRESHOLD_CRIT + 10) //We do not want to leave them on the end of crit constantly.
			addtimer(CALLBACK(src, PROC_REF(heal)), 30)
			reviving = TRUE
		if(owner.health > HEALTH_THRESHOLD_CRIT && owner.HasDisease(new /datum/disease/critical/shock(0)) && prob(15)) //We do not do an else, as we need them to cure shock inside this magic zone of 10 damage
			for(var/datum/disease/critical/shock/S in owner.viruses)
				S.cure()
				revive_cost += 150
				to_chat(owner, "<span class='notice'>You feel better.</span>")
		if(!reviving)
			return
	cooldown = revive_cost + world.time
	revive_cost = 0
	reviving = TRUE

/obj/item/organ/internal/cyberimp/chest/reviver/proc/heal()
	if(QDELETED(owner))
		return
	if(prob(90) && owner.getOxyLoss())
		owner.adjustOxyLoss(-3)
		revive_cost += 5
	if(prob(75) && owner.getBruteLoss())
		owner.adjustBruteLoss(-2)
		revive_cost += 15
	if(prob(75) && owner.getFireLoss())
		owner.adjustFireLoss(-2)
		revive_cost += 15
	if(prob(40) && owner.getToxLoss())
		owner.adjustToxLoss(-1)
		revive_cost += 25


/obj/item/organ/internal/cyberimp/chest/reviver/emp_act(severity)
	if(!owner || emp_proof)
		return
	if(reviving)
		revive_cost += 200
	else
		cooldown += 200
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		if(H.stat != DEAD && prob(50 / severity))
			H.set_heartattack(TRUE)
			addtimer(CALLBACK(src, PROC_REF(undo_heart_attack)), 600 / severity)

/obj/item/organ/internal/cyberimp/chest/reviver/proc/undo_heart_attack()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return
	H.set_heartattack(FALSE)
	if(H.stat == CONSCIOUS)
		to_chat(H, "<span class='notice'>You feel your heart beating again!</span>")

/obj/item/organ/internal/cyberimp/chest/ipc_repair
	name = "Reactive Repair Implant"
	desc = "This implant reworks the IPC frame, in order to incorporate materials that return to their original shape after being damaged. Requires power to function."
	implant_color = "#0ac0d8"
	origin_tech = "materials=4;programming=4;biotech=4;magnets=4;engineering=4"
	slot = "stomach" //Can't have a nutriment pump with it.
	requires_machine_person = TRUE

/obj/item/organ/internal/cyberimp/chest/ipc_repair/on_life()
	if(crit_fail)
		return
	if(owner.maxHealth == owner.health)
		owner.adjust_nutrition(-0.5)
		return //Passive damage scanning

	owner.adjustBruteLoss(-0.5, robotic = TRUE)
	owner.adjustFireLoss(-0.5, robotic = TRUE)
	owner.adjust_nutrition(-4) //Very power inefficent. Hope you got an APC nearby.

/obj/item/organ/internal/cyberimp/chest/ipc_repair/emp_act(severity)
	if(!owner || emp_proof || crit_fail)
		return
	crit_fail = TRUE
	addtimer(VARSET_CALLBACK(src, crit_fail, FALSE), 30 SECONDS / severity)

/obj/item/organ/internal/cyberimp/chest/ipc_joints
	name = "IPC ER-OR Joint Implant"
	desc = "This is a basetype. Notify a coder!"
	implant_color = "#eeff00"
	origin_tech = "materials=5;programming=4;biotech=4"
	slot = "joints"
	requires_machine_person = TRUE

/obj/item/organ/internal/cyberimp/chest/ipc_joints/magnetic_joints
	name = "Magnetic Joints Implant"
	desc = "This implant modifies IPC joints to use magnets, allowing easy re-attachment and fluid movement."
	implant_color = "#670db1"
	origin_tech = "materials=4;programming=4;biotech=4;magnets=4;engineering=4"

/obj/item/organ/internal/cyberimp/chest/ipc_joints/magnetic_joints/emp_act(severity)
	if(!owner || emp_proof)
		return
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		to_chat(H, "<span class='userdanger'>Your magnetic joints lose power!</span>")
		for(var/obj/item/organ/external/E in H.bodyparts)
			if(E.body_part != UPPER_TORSO && E.body_part != LOWER_TORSO)
				E.droplimb(TRUE) //lego disasemble sound

/obj/item/organ/internal/cyberimp/chest/ipc_joints/magnetic_joints/insert(mob/living/carbon/M, special = FALSE)
	..()
	ADD_TRAIT(M, TRAIT_IPC_JOINTS_MAG, "ipc_joint[UID()]")

/obj/item/organ/internal/cyberimp/chest/ipc_joints/magnetic_joints/remove(mob/living/carbon/M, special = FALSE)
	REMOVE_TRAIT(M, TRAIT_IPC_JOINTS_MAG, "ipc_joint[UID()]")
	return ..()

/obj/item/organ/internal/cyberimp/chest/ipc_joints/sealed
	name = "Sealed Joints Implant"
	desc = "This implant seals and reinforces IPC joints, securing the limbs better for industrial work, though prone to locking up."
	implant_color = "#b10d0d"
	origin_tech = "materials=4;programming=4;biotech=4;engineering=4;combat=4;"

/obj/item/organ/internal/cyberimp/chest/ipc_joints/sealed/emp_act(severity)
	if(!owner || emp_proof)
		return
	var/weaken_time = (10 + (severity - 1 ? 0 : 10)) SECONDS
	owner.Weaken(weaken_time) //Pop it and lock it
	to_chat(owner, "<span class='warning'>Your body seizes up!</span>")
	return weaken_time

/obj/item/organ/internal/cyberimp/chest/ipc_joints/sealed/insert(mob/living/carbon/M, special = FALSE)
	..()
	ADD_TRAIT(M, TRAIT_IPC_JOINTS_SEALED, "ipc_joint[UID()]")
	owner.physiology.stamina_mod *= 1.15 //15% more stamina damage, representing extra friction in limbs. I guess.

/obj/item/organ/internal/cyberimp/chest/ipc_joints/sealed/remove(mob/living/carbon/M, special = FALSE)
	REMOVE_TRAIT(M, TRAIT_IPC_JOINTS_SEALED, "ipc_joint[UID()]")
	owner.physiology.stamina_mod /= 1.15
	return ..()

//BOX O' IMPLANTS

/obj/item/storage/box/cyber_implants
	name = "boxed cybernetic implants"
	desc = "A sleek, sturdy box."
	icon_state = "cyber_implants_box"
	var/list/boxed = list(
		/obj/item/autosurgeon/organ/syndicate/thermal_eyes,
		/obj/item/autosurgeon/organ/syndicate/xray_eyes,
		/obj/item/autosurgeon/organ/syndicate/anti_stam,
		/obj/item/autosurgeon/organ/syndicate/reviver)
	var/amount = 5

/obj/item/storage/box/cyber_implants/populate_contents()
	var/implant
	while(length(contents) <= amount)
		implant = pick(boxed)
		new implant(src)
