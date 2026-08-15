/mob/living/basic/bot/secbot/ed209
	name = "\improper ED-209 Security Robot"
	desc = "A security robot. He looks less than thrilled."
	icon_state = "ed2090"
	base_icon_state = "ed209"
	light_color = "#f84e4e"
	density = TRUE
	health = 100
	maxHealth = 100
	obj_damage = 60
	environment_smash = ENVIRONMENT_SMASH_WALLS //Walls can't stop THE LAW
	mob_size = MOB_SIZE_LARGE
	ai_controller = /datum/ai_controller/basic_controller/bot/ed209
	bot_type = ADVANCED_SEC_BOT
	hackables = "combat inhibitors"

	projectile_sound = 'sound/weapons/taser2.ogg'
	projectile_type = /obj/projectile/beam/disabler
	/// what projectiles we shoot when emagged
	var/emagged_projectile_type = /obj/projectile/beam
	/// sound of emagged projectile
	var/emagged_projectile_sound = 'sound/weapons/laser.ogg'
	var/datum/action/cooldown/mob_cooldown/ed209_charge/bot_charge
	/// timer till we yell out our war cry again
	COOLDOWN_DECLARE(shoot_cry)


/mob/living/basic/bot/secbot/ed209/Initialize(mapload)
	. = ..()
	set_weapon()
	bot_charge = new(src)
	AddComponent(/datum/component/stun_n_cuff,\
		stun_sound = 'sound/weapons/egloves.ogg',\
		handcuff_type = /obj/item/restraints/handcuffs/cable/zipties,\
	)

/mob/living/basic/bot/secbot/ed209/bot_reset(bypass_ai_reset = FALSE)
	. = ..()
	if(bot_access_flags & BOT_COVER_EMAGGED && isnull(bot_charge.owner))
		bot_charge.Grant(src)
	if(!(bot_access_flags & BOT_COVER_EMAGGED) && !isnull(bot_charge.owner))
		bot_charge.Remove(src)
	set_weapon()

/mob/living/basic/bot/secbot/ed209/emag_act(mob/user, obj/item/card/emag/emag_card)
	. = ..()
	icon_state = "ed209[bot_mode_flags & BOT_MODE_ON]"
	set_weapon()
	to_chat(user, SPAN_WARNING("Safeties disabled!"))
	audible_message(SPAN_BOLDDANGER("[src] buzzes menacingly!"))
	return TRUE

/mob/living/basic/bot/secbot/ed209/proc/set_weapon()
	qdel(GetComponent(/datum/component/ranged_attacks))
	var/projectile = (bot_access_flags & BOT_COVER_EMAGGED) ? emagged_projectile_type : projectile_type
	var/final_projectile_sound = (bot_access_flags & BOT_COVER_EMAGGED) ? emagged_projectile_sound : projectile_sound
	AddComponent(\
		/datum/component/ranged_attacks,\
		projectile_type = projectile,\
		projectile_sound = final_projectile_sound,\
	)

/mob/living/basic/bot/secbot/ed209/ui_data(mob/user)
	var/list/data = ..()
	if(!(bot_access_flags & BOT_COVER_LOCKED) || issilicon(user))
		data["custom_controls"]["handcuff"] = security_mode_flags & SECBOT_HANDCUFF_TARGET
		data["custom_controls"]["check_ids"] = security_mode_flags & SECBOT_CHECK_IDS
		data["custom_controls"]["check_records"] = security_mode_flags & SECBOT_CHECK_RECORDS
	return data

/mob/living/basic/bot/secbot/ed209/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	var/mob/user = ui.user
	if(. || !isliving(user) || (bot_access_flags & BOT_COVER_LOCKED) && !issilicon(user))
		return
	switch(action)
		if("handcuff")
			security_mode_flags ^= SECBOT_HANDCUFF_TARGET
		if("check_ids")
			security_mode_flags ^= SECBOT_CHECK_IDS
		if("check_records")
			security_mode_flags ^= SECBOT_CHECK_RECORDS

/mob/living/basic/bot/secbot/ed209/retrieve_secbot_drops(atom/drop_location)
	var/obj/item/bot_assembly/ed209/ed_assembly = new(drop_location)
	ed_assembly.build_step = ASSEMBLY_FIRST_STEP
	ed_assembly.add_overlay("hs_hole")
	ed_assembly.created_name = name
	new /obj/item/assembly/prox_sensor(drop_location)
	var/obj/item/gun/energy/disabler/disabler_gun = new(drop_location)
	disabler_gun.cell.charge = 0
	disabler_gun.update_appearance()
	if(prob(50))
		new /obj/item/robot_parts/l_leg(drop_location)
		if(prob(25))
			new /obj/item/robot_parts/r_leg(drop_location)
	if(prob(75))
		return
	if(prob(50)) // either helmet or vest
		new /obj/item/clothing/head/helmet(drop_location)
	else
		new /obj/item/clothing/suit/armor/vest(drop_location)

/mob/living/basic/bot/secbot/ed209/Destroy()
	. = ..()
	QDEL_NULL(bot_charge)

/mob/living/basic/bot/secbot/ed209/syndicate
	name = "Syndicate Sentry Bot"
	desc = "A syndicate security bot."
	icon = 'icons/mecha/mecha.dmi'
	icon_state = "darkgygax"
	radio_channel = "Syndicate"
	health = 300
	maxHealth = 300
	faction = list("syndicate")
	light_color = "#5c0909"
	req_one_access = list(ACCESS_SYNDICATE)
	bot_mode_flags = parent_type::bot_mode_flags & ~BOT_MODE_REMOTE_ENABLED
	radio_channel = "Syndicate"
	ai_controller = /datum/ai_controller/basic_controller/bot/ed209/syndicate
	projectile_sound = 'sound/weapons/wave.ogg'
	projectile_type = /obj/projectile/bullet/a40mm
	emagged_projectile_sound = 'sound/weapons/wave.ogg'
	emagged_projectile_type = /obj/projectile/bullet/a40mm
	/// Step sound
	var/stepsound = 'sound/mecha/mechstep.ogg'
	var/area/syndicate_depot/core/depotarea
	var/raised_alert = FALSE
	var/pathing_failed = FALSE

/mob/living/basic/bot/secbot/ed209/syndicate/emag_act(mob/user)
	to_chat(user, SPAN_WARNING("[src] has no card reader slot!"))

/mob/living/basic/bot/secbot/ed209/syndicate/explode()
	if(!QDELETED(src))
		if(depotarea)
			depotarea.list_remove(src, depotarea.guard_list)
		visible_message(SPAN_USERDANGER("[src] blows apart!"))
		do_sparks(3, 1, src)
		new /obj/effect/decal/cleanable/blood/oil(loc)
		var/obj/structure/mecha_wreckage/gygax/dark/wreck = new /obj/structure/mecha_wreckage/gygax/dark(loc)
		wreck.name = "sentry bot wreckage"

		raise_alert("[src] destroyed.")

/mob/living/basic/bot/secbot/ed209/syndicate/proc/raise_alert(reason)
	if(raised_alert)
		return
	raised_alert = TRUE
	if(depotarea)
		depotarea.increase_alert(reason)
