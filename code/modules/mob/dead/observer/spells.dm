GLOBAL_LIST_INIT(boo_phrases, list(
	"You feel a chill run down your spine.",
	"You think you see a figure in your peripheral vision.",
	"What was that?",
	"The hairs stand up on the back of your neck.",
	"You are filled with a great sadness.",
	"Something doesn't feel right...",
	"You feel a presence in the room.",
	"It feels like someone's standing behind you.",
))

/obj/effect/proc_holder/spell/boo
	name = "Boo!"
	desc = "Fuck with the living."
	selection_deactivated_message	= "<span class='notice'>Your presence will not be known. For now.</span>"
	selection_activated_message		= "<span class='notice'>You prepare to reach across the veil. <b>Left-click to influence a target!</b></span>"

	ghost = TRUE

	action_icon_state = "boo"
	school = "transmutation"
	base_cooldown = 2 MINUTES
	starts_charged = FALSE
	clothes_req = FALSE
	stat_allowed = UNCONSCIOUS
	invocation = ""
	invocation_type = "none"
	// no need to spam admins regarding boo casts
	create_attack_logs = FALSE


/obj/effect/proc_holder/spell/boo/create_new_targeting()
	var/datum/spell_targeting/click/T = new()
	T.allowed_type = /atom
	T.try_auto_target = FALSE
	return T

/obj/effect/proc_holder/spell/boo/cast(list/targets, mob/user = usr)
	var/atom/target = targets[1]
	ASSERT(istype(target))

	if(target.get_spooked())
		var/area/spook_zone = get_area(target)
		if(spook_zone.is_haunted == TRUE)
			to_chat(usr, "<span class='notice'>The veil is weak in [spook_zone], it took less effort to influence [target].</span>")
			cooldown_handler.start_recharge(cooldown_handler.recharge_duration / 2)
		return

	cooldown_handler.start_recharge(cooldown_handler.recharge_duration * 0.1)
