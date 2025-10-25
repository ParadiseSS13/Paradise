/obj/item/organ/internal/cyberimp
	name = "cybernetic implant"
	desc = "a state-of-the-art implant that improves a baseline's functionality."
	status = ORGAN_ROBOT
	var/implant_color = "#FFFFFF"
	var/implant_overlay
	var/crit_fail = FALSE //Used by certain implants to disable them.
	tough = TRUE // Immune to damage
	augment_state ='icons/mob/human_races/robotic.dmi'

/obj/item/organ/internal/cyberimp/New(mob/M = null)
	. = ..()
	if(implant_overlay)
		var/mutable_appearance/overlay = mutable_appearance(icon, implant_overlay)
		overlay.color = implant_color
		add_overlay(overlay)

/obj/item/organ/internal/cyberimp/emp_act()
	return // These shouldn't be hurt by EMPs in the standard way

/obj/item/organ/internal/cyberimp/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It looks like it belongs in the [parse_zone(parent_organ)].</span>"

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
	icon_state = "brain_implant_antidrop"
	var/active = FALSE
	var/l_hand_ignore = FALSE
	var/r_hand_ignore = FALSE
	var/obj/item/l_hand_obj = null
	var/obj/item/r_hand_obj = null
	implant_overlay = null
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
				owner.l_hand.set_nodrop(TRUE, owner)
				l_hand_ignore = FALSE

		if(r_hand_obj)
			if(owner.r_hand.flags & NODROP)
				r_hand_ignore = TRUE
			else
				owner.r_hand.set_nodrop(TRUE, owner)
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
		A = pick(oview(range, owner))
		L_item.throw_at(A, range, 2)
		to_chat(owner, "<span class='notice'>Your left arm spasms and throws [L_item]!</span>")
		l_hand_obj = null
	if(R_item)
		A = pick(oview(range, owner))
		R_item.throw_at(A, range, 2)
		to_chat(owner, "<span class='notice'>Your right arm spasms and throws [R_item]!</span>")
		r_hand_obj = null

/obj/item/organ/internal/cyberimp/brain/anti_drop/proc/release_items()
	active = FALSE
	if(!l_hand_ignore && l_hand_obj)
		l_hand_obj.set_nodrop(FALSE, owner)
	if(!r_hand_ignore && r_hand_obj)
		r_hand_obj.set_nodrop(FALSE, owner)

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
	icon_state = "brain_implant_rebooter"
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
	if(status & ORGAN_DEAD)
		return
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
	if(status & ORGAN_DEAD)
		return FALSE
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
	desc = "A military-grade version of the standard implant, for NT's more elite forces. This one is compatible with the CNS Rebooter implant."
	slot = "brain_antisleep"

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

// actual translating done in human/handle_speech_problems
/obj/item/organ/internal/cyberimp/brain/speech_translator
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

/obj/item/organ/internal/cyberimp/brain/wire_interface/emp_act(severity)
	if(!owner || emp_proof)
		return
	var/time_of_emp = world.time // This lets us be emp'd multiple times, applying the trait multiple times, extending the cooldown
	ADD_TRAIT(owner, TRAIT_WIRE_BLIND, "emp'd_at_[time_of_emp]")
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(callback_remove_trait), owner, TRAIT_WIRE_BLIND, "emp'd_at_[time_of_emp]"), (2 MINUTES / severity))

/obj/item/organ/internal/cyberimp/brain/wire_interface/hardened
	name = "Hardened Wire interface implant"
	desc = "This wire interface implant is actually wireless, to avoid issues with electromagnetic pulses."
	origin_tech = "materials=6;programming=6;biotech=6"
	emp_proof = TRUE

// An implant that injects you with mephedrone on demand, acting like a bootleg sandevistan

/obj/item/organ/internal/cyberimp/brain/sensory_enhancer
	name = "\improper Qani-Laaca sensory computer"
	desc = "An experimental implant replacing the spine of organics. When activated, it can give a temporary boost to mental processing speed, \
		which many users perceive as a slowing of time and quickening of their ability to act. Due to its nature, it is incompatible with \
		systems that heavily influence the user's nervous system, like the central nervous system rebooter. \
		As a bonus effect, you are immune to the burst of heart damage that comes at the end of mephedrone usage, as the computer is able to regulate \
		your heart's rhythm back to normal after its use."
	icon_state = "sandy"
	implant_overlay = null
	implant_color = null
	slot = "brain_antistun"
	emp_proof = TRUE
	actions_types = list(/datum/action/item_action/organ_action/toggle/sensory_enhancer)
	origin_tech = "combat=6;biotech=6;syndicate=4"
	augment_icon = "sandy"
	always_show_augment = TRUE // A bit too big and bright to hide with synthetic skin.
	///The icon state used for the on mob sprite. Default is sandy. Drask and vox have their own unique sprites
	var/custom_mob_sprite = "sandy"
	COOLDOWN_DECLARE(sensory_enhancer_cooldown)

/obj/item/organ/internal/cyberimp/brain/sensory_enhancer/rnd
	emp_proof = FALSE

/obj/item/organ/internal/cyberimp/brain/sensory_enhancer/examine(mob/user)
	. = ..()
	. += "<span class='userdanger'>Epilepsy Warning: Drug has vibrant visual effects!</span>"

/obj/item/organ/internal/cyberimp/brain/sensory_enhancer/examine_more(mob/user)
	. = ..()
	. += "<i>Developed by Biotech Solutions this revolutionary full spinal cord replacement implant uses an integrated chemical synthesizer designed to administer Mephedrone: \
	a potent stimulant and hyper-movement drug. This implant dramatically enhances the user's reflexes, with many reporting an almost time-slowing effect during its operation.</i>"
	. += "<i>Biotech's experimentation with stimulant drug research has long been a cornerstone of their competitive edge, especially against their rival: \
	Interydyne Pharmaceuticals, whose efforts yielded a drug capable of enhancing reflexes, although they were never mitigate the adverse effects of said product. \
	A premature leak of the prototype implant pressured the company into accelerating its development, leaving the drug's side effects unresolved. \
	They completed the spinal implant, which is uniquely equipped with built-in vials for Mephedrone delivery. \
	Its material is solid plastitanium, and while strong in material, it surprisingly feels light, considering its spinal integration.</i>"
	. += "<i>The implant is highly sought after because of its extreme capabilities in combat. Many military groups pay a handsome fee simply for the licensing of the item. \
	In spite of this, recent Biotech shipments have come under fire from piracy, with the company quick to blame Interdyne for said attacks. Said allegations remain unverified.</i>"


/obj/item/organ/internal/cyberimp/brain/sensory_enhancer/insert(mob/living/carbon/M, special = 0)
	. = ..()
	ADD_TRAIT(M, TRAIT_MEPHEDRONE_ADAPTED, "[UID()]")

/obj/item/organ/internal/cyberimp/brain/sensory_enhancer/remove(mob/living/carbon/M, special = 0)
	. = ..()
	REMOVE_TRAIT(M, TRAIT_MEPHEDRONE_ADAPTED, "[UID()]")

/obj/item/organ/internal/cyberimp/brain/sensory_enhancer/render()
	. = ..()
	if(!.)
		return
	if(isvox(owner))
		custom_mob_sprite = "vox_sandy"
	else if(isdrask(owner))
		custom_mob_sprite = "drask_sandy"
	else
		custom_mob_sprite = "sandy"
	var/mutable_appearance/our_MA = mutable_appearance(augment_state, custom_mob_sprite, layer = -INTORGAN_LAYER)
	return our_MA

/obj/item/organ/internal/cyberimp/brain/sensory_enhancer/emp_act(severity)
	. = ..()
	if(!.)
		return
	if(!COOLDOWN_FINISHED(src, sensory_enhancer_cooldown)) //Not on cooldown? Drug them up. Heavily. We don't want people self emping to bypass cooldown.
		return
	if(!prob(100 / severity) || !owner)
		return

	for(var/datum/action/item_action/organ_action/toggle/sensory_enhancer/SE in owner.actions)
		SE.Trigger(FALSE, TRUE, TRUE)

/datum/action/item_action/organ_action/toggle/sensory_enhancer
	name = "Activate Qani-Laaca System"
	desc = "Activates your Qani-Laaca computer and grants you its powers. LMB: Short, safer activation. ALT/MIDDLE: Longer, more powerful, more dangerous activation."
	button_icon = 'icons/obj/surgery.dmi'
	button_icon_state = "sandy"
	/// Keeps track of how much mephedrone we inject into people on activation
	var/injection_amount = 10


/datum/action/item_action/organ_action/toggle/sensory_enhancer/AltTrigger()
	Trigger(FALSE, TRUE)

/datum/action/item_action/organ_action/toggle/sensory_enhancer/Trigger(left_click, attack_self, emp_triggered = FALSE)
	. = ..()
	if(istype(target, /obj/item/organ/internal/cyberimp/brain/sensory_enhancer))
		var/obj/item/organ/internal/cyberimp/brain/sensory_enhancer/ourtarget = target
		if(!COOLDOWN_FINISHED(ourtarget, sensory_enhancer_cooldown))
			to_chat(owner, "<span class='warning'>[ourtarget] is still on cooldown for another [round(COOLDOWN_TIMELEFT(ourtarget, sensory_enhancer_cooldown), 1 SECONDS) / 10] seconds!</span>")
			return

		COOLDOWN_START(ourtarget, sensory_enhancer_cooldown, 5 MINUTES)

		injection_amount = 10

		if(!left_click)
			injection_amount = 20
		if(emp_triggered)
			injection_amount = 40 //Time for a quick medical visit
		Activate()


/datum/action/item_action/organ_action/toggle/sensory_enhancer/proc/Activate(atom/target)

	var/mob/living/carbon/human/human_owner = owner

	human_owner.reagents.add_reagent("mephedrone", injection_amount)

	owner.visible_message("<span class='danger'>[owner.name] jolts suddenly as two small glass vials are fired from ports in the implant on [owner.p_their()] spine, shattering as they land.</span>", \
			"<span class='userdanger'>You jolt suddenly as your Qani-Laaca system ejects two empty glass vials rearward, shattering as they land.</span>")
	playsound(human_owner, 'sound/goonstation/items/hypo.ogg', 80, TRUE)

	var/obj/item/telegraph_vial = new /obj/item/qani_laaca_telegraph(get_turf(owner))
	var/turf/turf_we_throw_at = get_edge_target_turf(owner, REVERSE_DIR(owner.dir))
	telegraph_vial.throw_at(turf_we_throw_at, 5, 1)

	// Safety net in case the injection amount doesn't get reset. Apparently it happened to someone in a round.
	injection_amount = initial(injection_amount)

/obj/item/qani_laaca_telegraph
	name = "spent Qani-Laaca cartridge"
	desc = "A small glass vial, usually kept in a large stack inside a Qani-Laaca implant, that is broken open and ejected \
		each time the implant is used. If you're looking at one long enough to think about it this long, you either have fast eyes \
		or were lucky enough to catch one before it broke."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "blastoff_ampoule_empty"
	w_class = WEIGHT_CLASS_TINY

/obj/item/qani_laaca_telegraph/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/shatters_when_thrown, /obj/effect/decal/cleanable/glass, 1, "shatter")
	transform = transform.Scale(0.75, 0.75)

/obj/item/organ/internal/cyberimp/brain/hackerman_deck
	name = "\improper Binyat wireless hacking system"
	desc = "A rare-to-find neural chip that allows its user to interface with nearby machinery from a distance \
		and affect it in (usually) beneficial ways. Due to the wireless connection, fine manipulation \
		isn't possible, however the deck will drop a payload into the target's systems that will attempt \
		hacking for you."
	icon_state = "hackerman"
	implant_overlay = null
	implant_color = null
	slot = "brain_antistun"
	origin_tech = "materials=4;combat=6;biotech=6;powerstorage=2;syndicate=3"
	stealth_level = 4 //Only surgery or a body scanner with the highest tier of stock parts can detect this.

/obj/item/organ/internal/cyberimp/brain/hackerman_deck/examine_more(mob/user)
	. = ..()
	. += "<i>Considered Cybersun Incorporated's most recent and developed implant system focused on hacking from a range while being undetectable from normal means. \
	The Binyat Wireless Hacking System (BWHS) is a stealth-built implant that gives its user a rudimentary electronic interface on whatever can be perceived. \
	It uses a micro jammer to hide its existence from even the most advanced scanning systems.<i>"
	. += "<i>Originally designed as a hand-held device for long-range testing of Cybersun's electronic security systems, \
	the easy integration of the components into a neural implant led to a revaluation of the device's potential. \
	Development would commence to create the first sets of prototypes,  focusing on tricking scanners with no false positives, \
	and being able to hack from afar. The System does have a major flaw, however, as Cybersun R&D was never able to miniaturize its cooling systems to a practical level. \
	Repeated use will lead to skin irritation, internal burns, and even severe nerve damage in extreme cases.<i>"
	. += "<i>As of modern times, the BWHS is heavily vetted under Cybersun Inc. due to its dangerous nature and rather difficult detection. \
	However, this hasn't stopped the flow of these implants from reaching the black market, whether by inside or outside influences.</i>"

/obj/item/organ/internal/cyberimp/brain/hackerman_deck/insert(mob/living/carbon/M, special = 0)
	. = ..()
	add_spell()
	RegisterSignal(M, COMSIG_BODY_TRANSFER_TO, PROC_REF(on_body_transfer))

/obj/item/organ/internal/cyberimp/brain/hackerman_deck/remove(mob/living/carbon/M, special = 0)
	. = ..()
	if(M.mind)
		M.mind.RemoveSpell(/datum/spell/hackerman_deck)
	UnregisterSignal(M, COMSIG_BODY_TRANSFER_TO)

/obj/item/organ/internal/cyberimp/brain/hackerman_deck/proc/on_body_transfer()
	SIGNAL_HANDLER
	for(var/datum/action/A in owner.actions)
		if(A.name == "Activate Ranged Hacking") //Bit snowflake, but the action doesn't remove right otherwise
			A.Remove(owner)
	addtimer(CALLBACK(src, PROC_REF(add_spell)), 1 SECONDS) //Give the mind a moment to settle in
	add_spell()

/obj/item/organ/internal/cyberimp/brain/hackerman_deck/proc/add_spell()
	if(owner.mind)
		owner.mind.RemoveSpell(/datum/spell/hackerman_deck) //Just to be sure.
		owner.mind.AddSpell(new /datum/spell/hackerman_deck(null))

/obj/item/organ/internal/cyberimp/brain/hackerman_deck/emp_act(severity)
	owner.adjustStaminaLoss(40 / severity)
	owner.adjust_bodytemperature(400 / severity)
	to_chat(owner, "<span class='warning'>Your [name] heats up drastically!</span>")
	return TRUE

/datum/spell/hackerman_deck
	name = "Activate Ranged Hacking"
	desc = "Click on any machine to hack them. Has a short range of only three tiles."
	clothes_req = FALSE
	invocation = "none"
	antimagic_flags = NONE
	selection_activated_message = "You warm up your Binyat deck, there's an idle buzzing at the back of your mind as it awaits a target."
	selection_deactivated_message = "Your hacking deck makes an almost disappointed sounding buzz at the back of your mind as it powers down."
	action_icon_state = "hackerman"
	action_background_icon_state = "bg_pulsedemon"
	/// How many times have we successfully hacked in the last minute? Increases burn damage by 3 for each value above 0.
	var/recent_hacking = 0

/datum/spell/hackerman_deck/create_new_targeting()
	var/datum/spell_targeting/clicked_atom/C = new()
	C.range = 3
	C.try_auto_target = FALSE
	return C

/datum/spell/hackerman_deck/on_mind_transfer(mob/living/L)
	if(!ishuman(L))
		return FALSE
	var/mob/living/carbon/human/H = L
	var/obj/item/organ/internal/cyberimp/brain/hackerman_deck/our_deck = H.get_int_organ(/obj/item/organ/internal/cyberimp/brain/hackerman_deck)
	if(!our_deck)
		return FALSE
	return TRUE

/datum/spell/hackerman_deck/cast(list/targets, mob/user)
	var/atom/target = targets[1]
	if(get_dist(user, target) > 3) //fucking cameras holy shit
		to_chat(user, "<span class='warning'>Your implant is not robust enough to hack at that distance!</span>")
		cooldown_handler.start_recharge(cooldown_handler.recharge_duration * 0.3)
		return
	if(istype(user.loc, /obj/machinery/atmospherics)) //Come now, no emaging all the doors on station from a pipe
		to_chat(user, "<span class='warning'>Your implant is unable to get a lock on anything in the pipes!</span>")
		return
	var/beam
	if(!isturf(user.loc)) //Using it inside a locker or stealth box is fine! Let us make sure the beam can be seen though.
		beam = user.loc.Beam(target, icon_state = "sm_arc_supercharged", time = 3 SECONDS)
	else
		beam = user.Beam(target, icon_state = "sm_arc_supercharged", time = 3 SECONDS)

	user.visible_message("<span class='warning'>[user] makes an unusual buzzing sound as the air between them and [target] crackles.</span>", \
			"<span class='warning'>The air between you and [target] begins to crackle audibly as the Binyat gets to work and heats up in your head!</span>")

	if(!do_after(user, 3 SECONDS, target))
		qdel(beam)
		cooldown_handler.start_recharge(cooldown_handler.recharge_duration * 0.3)
		return

	if(!target.emag_act(user))
		to_chat(user, "<span class='warning'>You are unable to hack this!</span>")
		cooldown_handler.start_recharge(cooldown_handler.recharge_duration * 0.3)
		return

	target.add_hiddenprint(user)

	playsound(target, 'sound/machines/terminal_processing.ogg', 15, TRUE)

	var/mob/living/carbon/human/human_owner = user
	human_owner.adjustFireLoss(5 + (recent_hacking * 3))
	recent_hacking++
	addtimer(CALLBACK(src, PROC_REF(lower_recent_hacking)), 1 MINUTES)

/datum/spell/hackerman_deck/proc/lower_recent_hacking()
	recent_hacking--

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
	augment_icon = "breathing_tube"

/obj/item/organ/internal/cyberimp/mouth/breathing_tube/render()
	. = ..()
	if(!.)
		return
	var/mutable_appearance/our_MA = mutable_appearance(augment_state, augment_icon, layer = -INTORGAN_LAYER)
	return our_MA

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

/obj/item/organ/internal/cyberimp/chest/nutriment
	name = "Nutriment pump implant"
	desc = "This implant will synthesize a small amount of nutriment and pumps it directly into your bloodstream when you are starving."
	icon_state = "nutriment_implant"
	implant_overlay = null
	var/hunger_threshold = NUTRITION_LEVEL_STARVING
	var/synthesizing = 0
	var/poison_amount = 5
	var/disabled_by_emp = FALSE
	slot = "stomach"
	origin_tech = "materials=2;powerstorage=2;biotech=2"
	augment_icon = "nutripump"

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
	if(status & ORGAN_DEAD)
		return FALSE
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

/obj/item/organ/internal/cyberimp/chest/nutriment/render()
	. = ..()
	if(!.)
		return
	var/mutable_appearance/our_MA = mutable_appearance(augment_state, augment_icon, layer = -INTORGAN_LAYER)
	return our_MA


/obj/item/organ/internal/cyberimp/chest/nutriment/plus
	name = "Nutriment pump implant PLUS"
	desc = "This implant will synthesize a small amount of nutriment and pumps it directly into your bloodstream when you are hungry."
	icon_state = "adv_nutriment_implant"
	hunger_threshold = NUTRITION_LEVEL_HUNGRY
	poison_amount = 10
	origin_tech = "materials=4;powerstorage=3;biotech=3"
	augment_icon = "nutripump_adv"

/obj/item/organ/internal/cyberimp/chest/nutriment/hardened
	name = "hardened nutriment pump implant"
	emp_proof = TRUE

/obj/item/organ/internal/cyberimp/chest/nutriment/plus/hardened
	name = "hardened nutriment pump implant PLUS"
	emp_proof = TRUE

/obj/item/organ/internal/cyberimp/chest/reviver
	name = "Reviver implant"
	desc = "This implant will attempt to revive and heal you out of critical condition or death. For the faint of heart!"
	icon_state = "reviver_implant"
	implant_overlay = null
	origin_tech = "materials=5;programming=5;biotech=6"
	slot = "heartdrive"
	augment_icon = "reviver"
	/// How long the implant will go on cooldown for once the user has exited crit, in seconds.
	var/revive_cost = 0 SECONDS
	/// Are we in the progress of healing the user?
	var/reviving = FALSE
	/// Have we defibed someone this heal period? If so, do not heal past crit without an upgraded heart, as it is low on juice.
	var/has_defibed = FALSE
	/// How long we are on cooldown for
	COOLDOWN_DECLARE(reviver_cooldown)
	/// How long till we can try to defib again
	COOLDOWN_DECLARE(defib_cooldown)
	/// This check is an aditional minute delay applied to nuggeted IPCS, so they are not endlessly instantly reviving.
	COOLDOWN_DECLARE(nugget_contingency)
	/// The trigger when nuggeted is detected. Resets when revived. Prevents the cooldown from being applied again.
	var/applied_nugget_cooldown = FALSE

/obj/item/organ/internal/cyberimp/chest/reviver/hardened
	name = "Hardened reviver implant"
	emp_proof = TRUE

/obj/item/organ/internal/cyberimp/chest/reviver/hardened/Initialize(mapload)
	. = ..()
	desc += " The implant has been hardened. It is invulnerable to EMPs."

/obj/item/organ/internal/cyberimp/chest/reviver/render()
	. = ..()
	if(!.)
		return
	var/mutable_appearance/our_MA = mutable_appearance(augment_state, augment_icon, layer = -INTORGAN_LAYER)
	return our_MA

/obj/item/organ/internal/cyberimp/chest/reviver/dead_process()
	if(status & ORGAN_DEAD)
		return FALSE
	try_heal() // Allows implant to work even on dead people

/obj/item/organ/internal/cyberimp/chest/reviver/on_life()
	if(status & ORGAN_DEAD)
		return FALSE
	try_heal()

/obj/item/organ/internal/cyberimp/chest/reviver/proc/try_heal()
	if(reviving)
		if(owner.stat != DEAD && reached_heal_threshold()) //Don't stop healing when they are dead.
			COOLDOWN_START(src, reviver_cooldown, revive_cost)
			reviving = FALSE
			to_chat(owner, "<span class='notice'>Your reviver implant shuts down and starts recharging. It will be ready again in [DisplayTimeText(revive_cost)].</span>")
			applied_nugget_cooldown = FALSE
		else
			addtimer(CALLBACK(src, PROC_REF(heal)), 3 SECONDS)
		return
	if(!COOLDOWN_FINISHED(src, reviver_cooldown) || owner.suiciding || !COOLDOWN_FINISHED(src, nugget_contingency)) // don't heal while you're in cooldown!
		return
	if(owner.health <= 0 || owner.stat == DEAD)
		if(ismachineperson(owner))
			if(!applied_nugget_cooldown && length(owner.bodyparts) <= 2)
				COOLDOWN_START(src, nugget_contingency, 1 MINUTES)
				applied_nugget_cooldown = TRUE
				return
		revive_cost = 0
		reviving = TRUE
		has_defibed = FALSE
		to_chat(owner, "<span class='notice'>You feel a faint buzzing as your reviver implant starts patching your wounds...</span>")
		COOLDOWN_START(src, defib_cooldown, 8 SECONDS) // 5 seconds after heal proc delay

/obj/item/organ/internal/cyberimp/chest/reviver/proc/heal()
	if(QDELETED(owner))
		return
	// This is not on defib check so it doesnt revive IPCs either in a demon.
	if(HAS_TRAIT(owner, TRAIT_UNREVIVABLE))
		return
	if(COOLDOWN_FINISHED(src, defib_cooldown))
		revive_dead()
	/// boolean that stands for if PHYSICAL damage being patched
	var/body_damage_patched = FALSE
	if(owner.getOxyLoss())
		owner.adjustOxyLoss(-3)
		revive_cost += 0.5 SECONDS
	if(owner.getBruteLoss())
		owner.adjustBruteLoss(-2, robotic = TRUE)
		revive_cost += 4 SECONDS
		body_damage_patched = TRUE
	if(owner.getFireLoss())
		owner.adjustFireLoss(-2, robotic = TRUE)
		revive_cost += 4 SECONDS
		body_damage_patched = TRUE
	if(owner.getToxLoss())
		owner.adjustToxLoss(-1)
		revive_cost += 4 SECONDS

	if(body_damage_patched && prob(25)) // healing is called every few seconds, not every tick
		if(owner.stat != CONSCIOUS)
			owner.visible_message("<span class='warning'>[owner]'s body [pick("twitches", "shifts", "shivers", "spasms", "vibrates")] a bit.</span>", \
			"<span class='notice'>You feel like something is patching your injured body.</span>")
		else // No twitching if awake.
			to_chat(owner, "<span class='notice'>You feel like something is patching your injured body.</span>")

/obj/item/organ/internal/cyberimp/chest/reviver/proc/revive_dead()
	if(!COOLDOWN_FINISHED(src, defib_cooldown) || owner.stat != DEAD || !can_defib())
		return
	var/mob/dead/observer/ghost = owner.get_ghost()
	if(ghost)
		to_chat(ghost, "<span class='ghostalert'>You are being revived by [src]!</span>")
		window_flash(ghost.client)
		SEND_SOUND(ghost, sound('sound/effects/genetics.ogg'))
	COOLDOWN_START(src, defib_cooldown, 16 SECONDS)
	playsound(get_turf(owner), 'sound/machines/defib_charge.ogg', 50, FALSE)
	owner.grab_ghost()
	owner.visible_message("<span class='warning'>[owner]'s body spasms violently!</span>")
	addtimer(CALLBACK(src, PROC_REF(zap_em)), 5 SECONDS)

/obj/item/organ/internal/cyberimp/chest/reviver/proc/zap_em()
	playsound(owner, 'sound/machines/defib_zap.ogg', 75, TRUE, -1)
	// Inflict some brain damage scaling with time spent dead
	var/time_dead = world.time - owner.timeofdeath
	var/obj/item/organ/internal/brain/sponge = owner.get_int_organ(/obj/item/organ/internal/brain)
	var/defib_time_brain_damage = min(100 * time_dead / BASE_DEFIB_TIME_LIMIT, 89) // 20 from 1 minute onward, +20 per minute up to 99 (10 organ damage flat added after)
	if(time_dead > DEFIB_TIME_LOSS && defib_time_brain_damage > sponge.damage)
		owner.setBrainLoss(defib_time_brain_damage)
	// Turns out it takes some raw materials to heal you so much and defib you from inside. We took some material from your organs and iron from blood, hope you do not mind!
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		for(var/obj/item/organ/internal/I in H.internal_organs)
			I.receive_damage(10, TRUE)
		H.blood_volume *= 0.85
	revive_cost += 10 MINUTES // Additional 10 minutes cooldown after revival.
	owner.SetLoseBreath(0) //Reset the heart attack losebreath of hell
	owner.set_heartattack(FALSE)
	owner.update_revive()
	owner.KnockOut()
	owner.Paralyse(10 SECONDS)
	owner.emote("gasp")
	owner.Jitter(20 SECONDS)
	has_defibed = TRUE
	SEND_SIGNAL(owner, COMSIG_LIVING_MINOR_SHOCK)
	add_attack_logs(owner, owner, "Revived with [src]")

/obj/item/organ/internal/cyberimp/chest/reviver/proc/can_defib()
	if(!owner)
		return FALSE
	// They will get up on their own.
	if(ismachineperson(owner))
		return FALSE
	// Slight tweak, revive if brute burn and oxygen loss *combined* are above 210, to avoid spam defibing at like, 200+ brute burn damage or 200 o2 loss
	if(!owner.is_revivable() || owner.getBruteLoss() + owner.getFireLoss() + owner.getOxyLoss() >= 210 || HAS_TRAIT(owner, TRAIT_HUSK) || owner.blood_volume < BLOOD_VOLUME_SURVIVE)
		return FALSE
	// Let us break this on multiple lines
	// Clone loss is a new addition outside defib code, to avoid endless revive hell.
	// Avoid defibing with over 125 toxin loss as well. This also means toxin will delay someone from being revived *much* longer.
	if(!owner.get_organ_slot("brain") || HAS_TRAIT(owner, TRAIT_FAKEDEATH) || HAS_TRAIT(owner, TRAIT_BADDNA) || owner.getCloneLoss() >= 180 || owner.getToxLoss() >= 125)
		return FALSE
	return TRUE

/obj/item/organ/internal/cyberimp/chest/reviver/proc/reached_heal_threshold()
	// By default, 0 health. Won't heal you out of shock alone, will need some medical attention still if you do not have meds!
	// Will heal you out of crit though with 2 ticks of extra healing, due to callback.
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		var/heal_threshold = 0
		var/obj/item/organ/internal/heart/cybernetic/upgraded/U = H.get_int_organ(/obj/item/organ/internal/heart/cybernetic/upgraded)
		if(U) // The heart assists in healing, and will heal you out of shock.
			heal_threshold = 25
		if(!has_defibed) // Not low on power, can heal you out of shock.
			heal_threshold = 25
		if(H.health > heal_threshold)
			return TRUE
	return FALSE

/obj/item/organ/internal/cyberimp/chest/reviver/emp_act(severity)
	if(!owner || emp_proof)
		return
	if(reviving)
		revive_cost += 40 SECONDS
		COOLDOWN_START(src, defib_cooldown, 20 SECONDS)
	else
		COOLDOWN_START(src, reviver_cooldown, 20 SECONDS)
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		if(H.stat != DEAD && prob(50 / severity) && H.can_heartattack())
			H.set_heartattack(TRUE)
			addtimer(CALLBACK(src, PROC_REF(undo_heart_attack)), 600 / severity)

/obj/item/organ/internal/cyberimp/chest/reviver/proc/undo_heart_attack()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return
	H.set_heartattack(FALSE)
	H.adjustOxyLoss(-100) ///In the unlikely case that you are still alive, this should get you maybe to livable circumstances.
	H.SetLoseBreath(0)
	if(H.stat == CONSCIOUS)
		to_chat(H, "<span class='notice'>You feel your heart beating again!</span>")

/obj/item/organ/internal/cyberimp/chest/bluespace_anchor
	name = "bluespace anchor implant"
	desc = "This large cybernetic implant anchors you in bluespace, preventing almost any teleportation effects from working. It disrupts GPS systems however."
	icon_state = "bluespace_anchor"
	implant_overlay = null
	slot = "bluespace_anchor"
	origin_tech = "bluespace=6;biotech=4"

/obj/item/organ/internal/cyberimp/chest/bluespace_anchor/insert(mob/living/carbon/M, special = FALSE)
	..()
	RegisterSignal(M, COMSIG_MOVABLE_TELEPORTING, PROC_REF(on_teleport))
	RegisterSignal(M, COMSIG_MOB_PRE_JAUNT, PROC_REF(on_jaunt))
	for(var/obj/item/bio_chip/tracking/T in M)
		if(T && T.implanted)
			qdel(T)

/obj/item/organ/internal/cyberimp/chest/bluespace_anchor/remove(mob/living/carbon/M, special = FALSE)
	UnregisterSignal(M, COMSIG_MOVABLE_TELEPORTING)
	UnregisterSignal(M, COMSIG_MOB_PRE_JAUNT)
	return ..()

/// Blocks teleports and stuns the would-be-teleportee.
/obj/item/organ/internal/cyberimp/chest/bluespace_anchor/proc/on_teleport(mob/living/teleportee, atom/destination, channel)
	SIGNAL_HANDLER  // COMSIG_MOVABLE_TELEPORTED

	to_chat(teleportee, "<span class='userdanger'>You feel yourself teleporting, but are suddenly flung back to where you just were!</span>")

	teleportee.Weaken(5 SECONDS)
	var/datum/effect_system/spark_spread/spark_system = new()
	spark_system.set_up(5, TRUE, teleportee)
	spark_system.start()
	return COMPONENT_BLOCK_TELEPORT

/// Prevents a user from entering a jaunt.
/obj/item/organ/internal/cyberimp/chest/bluespace_anchor/proc/on_jaunt(mob/living/jaunter)
	SIGNAL_HANDLER  // COMSIG_MOB_PRE_JAUNT

	to_chat(jaunter, "<span class='userdanger'>As you attempt to jaunt, you slam directly into the barrier between realities and are sent crashing back into corporeality!</span>")

	jaunter.Weaken(5 SECONDS)
	var/datum/effect_system/spark_spread/spark_system = new()
	spark_system.set_up(5, TRUE, jaunter)
	spark_system.start()
	return COMPONENT_BLOCK_JAUNT

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
	if(status & ORGAN_DEAD)
		return FALSE
	if(owner.maxHealth == owner.health)
		owner.adjust_nutrition(-0.25)
		return //Passive damage scanning

	owner.adjustBruteLoss(-0.5, robotic = TRUE)
	owner.adjustFireLoss(-0.5, robotic = TRUE)
	owner.adjust_nutrition(-2) //Very power inefficent. Hope you got an APC nearby.

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

/obj/item/organ/internal/cyberimp/chest/ipc_joints/flayer_pacification
	name = "\improper Nanite pacifier"
	desc = "This implant acts on mindflayer nanobots like smoke does to bees, rendering them significantly more docile."
	implant_color = COLOR_BLACK
	origin_tech = "materials=4;programming=4;biotech=5;combat=4;"

/obj/item/organ/internal/cyberimp/chest/ipc_joints/flayer_pacification/insert(mob/living/carbon/M, special)
	..()
	ADD_TRAIT(M, TRAIT_MINDFLAYER_NULLIFIED, UNIQUE_TRAIT_SOURCE(src))
	SEND_SIGNAL(M, COMSIG_FLAYER_RETRACT_IMPLANTS, TRUE)

/obj/item/organ/internal/cyberimp/chest/ipc_joints/flayer_pacification/remove(mob/living/carbon/M, special)
	REMOVE_TRAIT(M, TRAIT_MINDFLAYER_NULLIFIED, UNIQUE_TRAIT_SOURCE(src))
	return ..()

/obj/item/organ/internal/cyberimp/chest/ipc_food
	name = "Culinary Processing Implant"
	desc = "This implant emulates the functions of a gastrointestinal system, allowing IPCs to eat and experience taste."
	implant_color = "#d8780a"
	origin_tech = "materials=2;powerstorage=2;biotech=2"
	slot = "gastrointestinal"
	requires_machine_person = TRUE

/obj/item/organ/internal/cyberimp/chest/ipc_food/insert(mob/living/carbon/M, special = FALSE)
	..()
	ADD_TRAIT(M, TRAIT_IPC_CAN_EAT, "ipc_food[UID()]")

/obj/item/organ/internal/cyberimp/chest/ipc_food/remove(mob/living/carbon/M, special = FALSE)
	REMOVE_TRAIT(M, TRAIT_IPC_CAN_EAT, "ipc_food[UID()]")
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
