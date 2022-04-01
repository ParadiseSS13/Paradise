/// If used, an implant will trigger when an emote is intentionally used.
#define IMPLANT_EMOTE_TRIGGER_INTENTIONAL (1<<0)
/// If used, an implant will trigger when an emote is forced/unintentionally used.
#define IMPLANT_EMOTE_TRIGGER_UNINTENTIONAL (1<<1)
/// If used, an implant will always trigger when the user makes an emote.
#define IMPLANT_EMOTE_TRIGGER_ALWAYS (IMPLANT_EMOTE_TRIGGER_UNINTENTIONAL | IMPLANT_EMOTE_TRIGGER_INTENTIONAL)

/obj/item/implant
	name = "implant"
	icon = 'icons/obj/implants.dmi'
	icon_state = "generic" //Shows up as the action button icon
	origin_tech = "materials=2;biotech=3;programming=2"

	actions_types = list(/datum/action/item_action/hands_free/activate)
	var/activated = 1 //1 for implant types that can be activated, 0 for ones that are "always on" like mindshield implants
	var/implanted = null
	var/mob/living/imp_in = null
	item_color = "b"
	var/allow_multiple = 0
	var/uses = -1
	flags = DROPDEL

	/// Emotes that activate this implant when used.
	var/trigger_emotes
	/// What type of emote (intentional, unintentional, or both) will trigger the implant.
	var/trigger_causes = IMPLANT_EMOTE_TRIGGER_UNINTENTIONAL

/obj/item/implant/proc/unregister_emotes()
	if(imp_in && LAZYLEN(trigger_emotes))
		for(var/emote in trigger_emotes)
			UnregisterSignal(imp_in, COMSIG_MOB_EMOTED(emote))

/**
 * Set the emote that will trigger the implant.
 * * user: User who is trying to associate the implant to themselves.
 * * emote_key: Key of the emote that should trigger the implant.
 */
/obj/item/implant/proc/set_trigger(mob/user, emote_key, on_implant = FALSE)

	if(imp_in != user)
		return FALSE

	if(!emote_key)
		return FALSE

	if(LAZYIN(trigger_emotes, emote_key) && !on_implant)
		to_chat(user, "<span class='warning'> You've already registered [emote_key]!")
		return FALSE

	if(emote_key == "me" || emote_key == "custom")
		to_chat(user, "<span class='warning'> You can't trigger [src] with a custom emote.")
		return FALSE


	if(!(emote_key in user.usable_emote_keys(trigger_causes & IMPLANT_EMOTE_TRIGGER_INTENTIONAL)))
		to_chat(user, "<span class='warning'> You can't trigger [src] with that emote! Try *help to see emotes you can use.</span>")
		return FALSE

	if(!(emote_key in user.usable_emote_keys(trigger_causes & IMPLANT_EMOTE_TRIGGER_UNINTENTIONAL)))
		CRASH("User was given an implant for an unintentional emote that they can't use.")

	LAZYADD(trigger_emotes, emote_key)
	RegisterSignal(user, COMSIG_MOB_EMOTED(emote_key), .proc/on_emote)

/obj/item/implant/proc/on_emote(mob/living/user, /datum/emote/emote, key, emote_type, message, intentional)
	SIGNAL_HANDLER

	if(!implanted || !imp_in)
		return

	if(intentional && (trigger_causes & IMPLANT_EMOTE_TRIGGER_INTENTIONAL) || (!intentional && (trigger_causes & IMPLANT_EMOTE_TRIGGER_UNINTENTIONAL)))
		return

	trigger(key, user, intentional)


/obj/item/implant/proc/trigger(emote, mob/source, force)
	return

/obj/item/implant/proc/activate()
	return

/obj/item/implant/ui_action_click()
	activate("action_button")


//What does the implant do upon injection?
//return 1 if the implant injects
//return -1 if the implant fails to inject
//return 0 if there is no room for implant
/obj/item/implant/proc/implant(mob/source, mob/user)
	var/obj/item/implant/imp_e = locate(src.type) in source
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


	src.loc = source
	imp_in = source
	implanted = 1
	if(activated)
		if(trigger_emotes)
			for(var/emote in trigger_emotes)
				set_trigger(source, emote, TRUE)
		for(var/X in actions)
			var/datum/action/A = X
			A.Grant(source)
	if(ishuman(source))
		var/mob/living/carbon/human/H = source
		H.sec_hud_set_implants()

	if(user)
		add_attack_logs(user, source, "Implanted with [src]")

	return 1

/obj/item/implant/proc/removed(mob/source)
	src.loc = null
	imp_in = null
	implanted = 0

	for(var/X in actions)
		var/datum/action/A = X
		A.Grant(source)

	if(ishuman(source))
		var/mob/living/carbon/human/H = source
		H.sec_hud_set_implants()

	unregister_emotes()

	return 1

/obj/item/implant/Destroy()
	if(imp_in)
		removed(imp_in)
	return ..()


/obj/item/implant/proc/get_data()
	return "No information available"

/obj/item/implant/dropped(mob/user)
	. = 1
	..()
