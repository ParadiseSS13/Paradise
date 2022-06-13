/// If used, an implant will trigger when an emote is intentionally used.
#define IMPLANT_EMOTE_TRIGGER_INTENTIONAL (1<<0)
/// If used, an implant will trigger when an emote is forced/unintentionally used.
#define IMPLANT_EMOTE_TRIGGER_UNINTENTIONAL (1<<1)
/// If used, an implant will always trigger when the user makes an emote.
#define IMPLANT_EMOTE_TRIGGER_ALWAYS (IMPLANT_EMOTE_TRIGGER_UNINTENTIONAL | IMPLANT_EMOTE_TRIGGER_INTENTIONAL)
/// If used, an implant will trigger on the user's first death.
#define IMPLANT_TRIGGER_DEATH_ONCE (1<<2)
/// If used, an implant will trigger any time a user dies.
#define IMPLANT_TRIGGER_DEATH_ANY (1<<3)
/// If used, an implant will NOT trigger on death when a user is gibbed.
#define IMPLANT_TRIGGER_NOT_WHEN_GIBBED (1<<4)

// Defines related to the way that the implant is activated. This is the value for implant.activated
/// The implant is passively active (like a mindshield)
#define IMPLANT_ACTIVATED_PASSIVE 0
/// The implant is activated manually by a trigger
#define IMPLANT_ACTIVATED_ACTIVE 1

/**
 * # Implants
 *
 * Code for implants that can be inserted into a person and have some sort of passive or triggered action.
 *
 */
/obj/item/implant
	name = "implant"
	icon = 'icons/obj/implants.dmi'
	icon_state = "generic" //Shows up as the action button icon
	origin_tech = "materials=2;biotech=3;programming=2"

	actions_types = list(/datum/action/item_action/hands_free/activate)
	/// How the implant is activated.
	var/activated = IMPLANT_ACTIVATED_ACTIVE
	/// Whether the implant is implanted. Null if it's never been inserted, TRUE if it's currently inside someone, or FALSE if it's been removed.
	var/implanted = null
	/// Who the implant is inside of.
	var/mob/living/imp_in = null
	item_color = "b"
	/// Whether multiple implants of this same type can be inserted into someone.
	var/allow_multiple = FALSE
	/// Amount of times that the implant can be triggered by the user. If the implant can't be used, it can't be inserted.
	var/uses = -1
	flags = DROPDEL  // By default, don't let implants be harvestable.

	/// List of emote keys that activate this implant when used.
	var/list/trigger_emotes
	/// What type of action will trigger this emote. Bitfield of IMPLANT_EMOTE_* defines.
	var/trigger_causes
	/// Whether this implant has already triggered on death or not, to prevent it firing multiple times.
	var/has_triggered_on_death = FALSE

/obj/item/implant/proc/unregister_emotes()
	if(imp_in && LAZYLEN(trigger_emotes))
		for(var/emote in trigger_emotes)
			UnregisterSignal(imp_in, COMSIG_MOB_EMOTED(emote))

/**
 * Set the emote that will trigger the implant.
 * * user - User who is trying to associate the implant to themselves.
 * * emote_key - Key of the emote that should trigger the implant.
 * * on_implant - Whether this proc is being called during the implantation of the implant.
 * * silent - If true, the user won't get any to_chat messages if an implantation fails.
 */
/obj/item/implant/proc/set_trigger(mob/user, emote_key, on_implant = FALSE, silent = TRUE)
	if(imp_in != user)
		return FALSE

	if(!emote_key)
		return FALSE

	if(LAZYIN(trigger_emotes, emote_key) && !on_implant)
		if(!silent)
			to_chat(user, "<span class='warning'> You've already registered [emote_key]!")
		return FALSE

	if(emote_key == "me" || emote_key == "custom")
		if(!silent)
			to_chat(user, "<span class='warning'> You can't trigger [src] with a custom emote.")
		return FALSE

	if(!(emote_key in user.usable_emote_keys(trigger_causes & IMPLANT_EMOTE_TRIGGER_INTENTIONAL)))
		if(!silent)
			to_chat(user, "<span class='warning'> You can't trigger [src] with that emote! Try *help to see emotes you can use.</span>")
		return FALSE

	if(!(emote_key in user.usable_emote_keys(trigger_causes & IMPLANT_EMOTE_TRIGGER_UNINTENTIONAL)))
		CRASH("User was given an implant for an unintentional emote that they can't use.")

	LAZYADD(trigger_emotes, emote_key)
	RegisterSignal(user, COMSIG_MOB_EMOTED(emote_key), .proc/on_emote)

/obj/item/implant/proc/on_emote(mob/living/user, datum/emote/fired_emote, key, emote_type, message, intentional)
	SIGNAL_HANDLER

	if(!implanted || !imp_in)
		return

	if(!(intentional && (trigger_causes & IMPLANT_EMOTE_TRIGGER_INTENTIONAL)) && !(!intentional && (trigger_causes & IMPLANT_EMOTE_TRIGGER_UNINTENTIONAL)))
		return

	add_attack_logs(user, user, "[intentional ? "intentionally" : "unintentionally"] [src] was [intentional ? "intentionally" : "unintentionally"] triggered with the emote [fired_emote].")
	emote_trigger(key, user, intentional)

/obj/item/implant/proc/on_death(mob/source, gibbed)
	SIGNAL_HANDLER

	if(!implanted || !imp_in)
		return

	if(gibbed && (trigger_causes & IMPLANT_TRIGGER_NOT_WHEN_GIBBED))
		return

	// This should help avoid infinite recursion for things like dust that call death()
	if(has_triggered_on_death && (trigger_causes & IMPLANT_TRIGGER_DEATH_ONCE))
		return

	has_triggered_on_death = TRUE

	add_attack_logs(source, source, "had their [src] implant triggered on [gibbed ? "gib" : "death"].")
	death_trigger(source, gibbed)

/obj/item/implant/proc/emote_trigger(emote, mob/source, force)
	return

/obj/item/implant/proc/death_trigger(mob/source, gibbed)
	return

/obj/item/implant/proc/activate(cause)
	return

/obj/item/implant/ui_action_click()
	activate("action_button")

/**
 * Try to implant ourselves into a mob.
 *
 * * source - The person the implant is being administered to.
 * * user - The person who is doing the implanting.
 *
 * Returns
 * 	1 if the implant injects successfully
 *  -1 if the implant fails to inject
 * 	0 if there's no room for the implant.
 */
/obj/item/implant/proc/implant(mob/source, mob/user)
	var/obj/item/implant/imp_e = locate(type) in source
	if(!allow_multiple && imp_e && imp_e != src)
		if(imp_e.uses < initial(imp_e.uses)*2)
			if(uses == -1)
				imp_e.uses = -1
			else
				imp_e.uses = min(imp_e.uses + uses, initial(imp_e.uses)*2)
			qdel(src)
			return 1
		else
			return 0


	loc = source
	imp_in = source
	implanted = TRUE
	if(trigger_emotes)
		if(!(trigger_causes & IMPLANT_EMOTE_TRIGGER_INTENTIONAL | IMPLANT_EMOTE_TRIGGER_UNINTENTIONAL))
			CRASH("Implant [src] has trigger emotes defined but no trigger cause with which to use them!")
		if(!activated && (trigger_causes & IMPLANT_EMOTE_TRIGGER_INTENTIONAL))
			CRASH("Implant [src] has intentional emote triggers on a passive implant")
		// If you can't activate the implant manually, you shouldn't be able to deliberately activate it with an emote
		for(var/emote in trigger_emotes)
			set_trigger(source, emote, TRUE, TRUE)
	if(activated)
		for(var/X in actions)
			var/datum/action/A = X
			A.Grant(source)
	if(trigger_causes & (IMPLANT_TRIGGER_DEATH_ONCE | IMPLANT_TRIGGER_DEATH_ANY))
		RegisterSignal(source, COMSIG_MOB_DEATH, .proc/on_death)
	if(ishuman(source))
		var/mob/living/carbon/human/H = source
		H.sec_hud_set_implants()

	if(user)
		add_attack_logs(user, source, "Implanted with [src]")

	return 1

/**
 * Clean up when an implant is removed.
 * * source - the user who the implant was removed from.
 */
/obj/item/implant/proc/removed(mob/source)
	loc = null
	imp_in = null
	implanted = FALSE

	for(var/X in actions)
		var/datum/action/A = X
		A.Grant(source)

	if(ishuman(source))
		var/mob/living/carbon/human/H = source
		H.sec_hud_set_implants()

	if(trigger_causes & (IMPLANT_TRIGGER_DEATH_ONCE | IMPLANT_TRIGGER_DEATH_ANY))
		UnregisterSignal(source, COMSIG_MOB_DEATH)

	unregister_emotes()

	return TRUE

/obj/item/implant/Destroy()
	if(imp_in)
		removed(imp_in)
	return ..()


/obj/item/implant/proc/get_data()
	return "No information available"

/obj/item/implant/dropped(mob/user)
	. = TRUE
	..()
