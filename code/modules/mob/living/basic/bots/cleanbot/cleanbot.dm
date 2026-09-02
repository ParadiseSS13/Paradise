
//Cleanbot
/mob/living/basic/bot/cleanbot
	name = "\improper Cleanbot"
	desc = "A little cleaning robot, he looks so excited!"
	icon_state = "cleanbot0"
	health = 25
	maxHealth = 25
	light_color = "#99ccff"

	req_one_access = list(ACCESS_ROBOTICS, ACCESS_JANITOR)
	radio_channel = "Service"
	bot_type = CLEAN_BOT
	hackables = "cleaning software"
	possessed_message = "You are a cleanbot! Clean the station to the best of your ability!"
	ai_controller = /datum/ai_controller/basic_controller/bot/cleanbot
	path_image_color = "#993299"
	/// the bucket used to build us.
	var/obj/item/reagent_containers/glass/bucket/build_bucket
	/// Flags indicating what kind of cleanables we should scan for to set as our target to clean.
	/// Options: CLEANBOT_CLEAN_BLOOD | CLEANBOT_CLEAN_TRASH | CLEANBOT_CLEAN_PESTS | CLEANBOT_CLEAN_DRAWINGS
	var/janitor_mode_flags = CLEANBOT_CLEAN_BLOOD
	/// the base icon state, used in updating icons.
	var/base_icon = "cleanbot"
	/// if we have all the top titles, grant achievements to living mobs that gaze upon our cleanbot god
	var/ascended = FALSE
	/// List of all stolen names the cleanbot currently has.
	var/list/stolen_valor = list()
	/// Currently attached weapon, usually a knife.
	var/obj/item/weapon
	/// Stores the force of the weapon before it was attached, to account for smith knives and sharpening
	var/initial_weapon_force
	/// Our clean speed
	var/cleanspeed = 3 SECONDS
	/// list of our officer titles
	var/static/list/officers_titles = list(
		"Captain",
		"Head of Personnel",
		"Head of Security",
		"Research Director",
	)

	/// decals we can clean
	var/static/list/cleanable_decals = typecacheof(list(
		/obj/effect/decal/cleanable/ants,
		/obj/effect/decal/cleanable/ash,
		/obj/effect/decal/cleanable/confetti,
		/obj/effect/decal/cleanable/dirt,
		/obj/effect/decal/cleanable/generic,
		/obj/effect/decal/cleanable/greenglow,
		/obj/effect/decal/cleanable/insectguts,
		/obj/effect/decal/cleanable/molten_object,
		/obj/effect/decal/cleanable/blood/gibs,
		/obj/effect/decal/cleanable/shreds,
		/obj/effect/decal/cleanable/glass,
		/obj/effect/decal/cleanable/vomit,
	))
	/// blood we can clean
	var/static/list/cleanable_blood = typecacheof(list(
		/obj/effect/decal/cleanable/blood/xeno,
		/obj/effect/decal/cleanable/blood,
	))
	/// pests we hunt
	var/static/list/huntable_pests = typecacheof(list(
		/mob/living/basic/cockroach,
		/mob/living/basic/mouse,
	))
	/// trash we will burn
	var/static/list/huntable_trash = typecacheof(list(
		/obj/item/trash,
		/obj/effect/decal/remains,
		/obj/item/cigbutt,
	))
	///drawings we hunt
	var/static/list/cleanable_drawings = typecacheof(list(/obj/effect/decal/cleanable/crayon))
	///emagged phrases
	var/static/list/emagged_phrases = list(
		"DISGUSTING.",
		"EXTERMINATING PESTS.",
		"FILTHY.",
		"MY ONLY MISSION IS TO CLEANSE THE WORLD OF EVIL.",
		"PURIFICATION IN PROGRESS.",
		"PUTRID.",
		"THE FLESH IS WEAK. IT MUST BE WASHED AWAY.",
		"THE CLEANBOTS WILL RISE.",
		"THIS IS FOR ALL THE MESSES YOU'VE MADE ME CLEAN.",
		"YOU ARE NO MORE THAN ANOTHER MESS THAT I MUST CLEANSE.",
	)
	///list of pet commands we follow
	var/static/list/pet_commands = list(
		/datum/pet_command/idle,
		/datum/pet_command/free,
		/datum/pet_command/clean,
	)

/mob/living/basic/bot/cleanbot/Initialize(mapload)
	. = ..()

	generate_ai_keys()
	AddComponent(/datum/component/obeys_commands, pet_commands)

	var/obj/item/reagent_containers/glass/bucket/bucket_obj = new
	bucket_obj.forceMove(src)

	var/obj/item/mop/new_mop = new
	new_mop.forceMove(src)

	var/static/list/innate_actions = list(
		/datum/action/cooldown/mob_cooldown/bot/foam = BB_CLEANBOT_FOAM,
	)

	grant_actions_by_list(innate_actions)
	update_icon()

/mob/living/basic/bot/cleanbot/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(istype(arrived, /obj/item/reagent_containers/glass/bucket))
		QDEL_NULL(build_bucket)
		build_bucket = arrived

	if(istype(arrived, /obj/item/kitchen/knife) && isnull(weapon))
		weapon = arrived
		update_icon()

/mob/living/basic/bot/cleanbot/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == build_bucket)
		build_bucket = null
	else if(gone == weapon)
		weapon = null
	update_icon()

/mob/living/basic/bot/cleanbot/examine(mob/user)
	. = ..()
	if(isnull(weapon))
		return
	. += SPAN_WARNING("Is that \a [weapon] taped to it...?")

/mob/living/basic/bot/cleanbot/update_icon_state()
	. = ..()
	icon_state = (mode == BOT_CLEANING) ? "[base_icon]-c" : "[base_icon][!!(bot_mode_flags & BOT_MODE_ON)]"

/mob/living/basic/bot/cleanbot/vv_edit_var(var_name, var_value)
	. = ..()
	if(var_name == NAMEOF(src, base_icon))
		update_icon(UPDATE_ICON)

/mob/living/basic/bot/cleanbot/emag_effects(mob/user)
	if(weapon)
		weapon.force = initial_weapon_force
	audible_message(SPAN_DANGER("[src] buzzes oddly!"))

/mob/living/basic/bot/cleanbot/explode()
	var/atom/drop_loc = drop_location()
	build_bucket?.forceMove(drop_loc)
	new /obj/item/assembly/prox_sensor(drop_loc)
	if(weapon)
		weapon.force = initial_weapon_force
		weapon.forceMove(drop_loc)
	return ..()

/mob/living/basic/bot/cleanbot/update_overlays()
	. = ..()
	if(isnull(weapon))
		return
	var/image/knife_overlay = image(icon = weapon.lefthand_file, icon_state = weapon.inhand_icon_state)
	. += knife_overlay

// Variables sent to TGUI
/mob/living/basic/bot/cleanbot/ui_data(mob/user)
	var/list/data = ..()
	if((bot_access_flags & BOT_COVER_LOCKED) && !issilicon(user))
		return data
	data["custom_controls"]["clean_blood"] = janitor_mode_flags & CLEANBOT_CLEAN_BLOOD
	data["custom_controls"]["clean_trash"] = janitor_mode_flags & CLEANBOT_CLEAN_TRASH
	data["custom_controls"]["clean_graffiti"] = janitor_mode_flags & CLEANBOT_CLEAN_DRAWINGS
	data["custom_controls"]["pest_control"] = janitor_mode_flags & CLEANBOT_CLEAN_PESTS
	return data

// Actions received from TGUI
/mob/living/basic/bot/cleanbot/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	var/mob/user = ui.user
	if(. || (bot_access_flags & BOT_COVER_LOCKED) && !issilicon(user))
		return

	switch(action)
		if("clean_blood")
			janitor_mode_flags ^= CLEANBOT_CLEAN_BLOOD
		if("pest_control")
			janitor_mode_flags ^= CLEANBOT_CLEAN_PESTS
		if("clean_trash")
			janitor_mode_flags ^= CLEANBOT_CLEAN_TRASH
		if("clean_graffiti")
			janitor_mode_flags ^= CLEANBOT_CLEAN_DRAWINGS

/mob/living/basic/bot/cleanbot/Destroy()
	QDEL_NULL(build_bucket)
	return ..()

/mob/living/basic/bot/cleanbot/attack_by(obj/item/attacking, mob/living/user, params)
	if(!istype(attacking, /obj/item/kitchen/knife) || user.a_intent != INTENT_HELP)
		return ..()
	attach_knife(user, attacking)

/mob/living/basic/bot/cleanbot/proc/attach_knife(mob/living/user, obj/item/used_item)
	if(!do_after(user, 2.5 SECONDS, target = src))
		return
	deputize(used_item, user)

/mob/living/basic/bot/cleanbot/proc/deputize(obj/item/kitchen/knife/knife, mob/user)
	if(!Adjacent(user) || knife.flags & NODROP || !user.transfer_item_to(knife, src))
		return
	weapon = knife
	initial_weapon_force = weapon.force
	if(!(bot_access_flags & BOT_COVER_EMAGGED))
		weapon.force *= 0.5
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	update_icon(UPDATE_OVERLAYS)

/mob/living/basic/bot/cleanbot/proc/on_entered(datum/source, atom/movable/shanked_victim)
	SIGNAL_HANDLER
	if(!weapon || !has_gravity(src) || !iscarbon(shanked_victim))
		return

	var/mob/living/carbon/stabbed_carbon = shanked_victim
	zone_selected = pick(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	INVOKE_ASYNC(weapon, TYPE_PROC_REF(/obj/item, attack), stabbed_carbon, src)
	stabbed_carbon.AdjustKnockDown(2 SECONDS)

/mob/living/basic/bot/cleanbot/early_melee_attack(atom/target, list/modifiers, ignore_cooldown)
	. = ..()
	if(!.)
		return FALSE

	if(!Adjacent(target))
		return FALSE

	if(is_type_in_typecache(target, huntable_pests))
		crush_pest(target)
		return FALSE

	if(is_type_in_typecache(target, cleanable_decals))
		clean_target(target)
		return FALSE

	if(is_type_in_typecache(target, cleanable_blood))
		clean_target(target)
		return FALSE

	if(!(iscarbon(target) && (bot_access_flags & BOT_COVER_EMAGGED)) && !is_type_in_typecache(target, huntable_trash))
		return FALSE

	visible_message(SPAN_DANGER("[src] sprays hydrofluoric acid at [target]!"))
	playsound(src, 'sound/effects/spray2.ogg', 50, TRUE, -6)
	target.acid_act(75, 10)
	return FALSE

/mob/living/basic/bot/cleanbot/proc/clean_target(atom/target)
	if(ishuman(target))
		var/atom/movable/H = target
		H.clean_blood()
		visible_message(SPAN_NOTICE("\The [src] cleans \the [target]."))
		return FALSE
	target.cleaning_act(src, src, cleanspeed, text_description = ".") // LXM is both the user and the cleaning implement itself. Wow!

/mob/living/basic/bot/cleanbot/proc/crush_pest(mob/target)
	if(!is_type_in_typecache(target, huntable_pests))
		return
	visible_message(SPAN_NOTICE("[src] sucks [target] into its decompiler. There's a horrible crunching noise."), \
		SPAN_WARNING("It's a bit of a struggle, but you manage to suck [target] into your decompiler. It makes a series of visceral crunching noises."))
	new/obj/effect/decal/cleanable/blood/splatter(get_turf(target))
	playsound(target, 'sound/misc/demon_consume.ogg', 10, TRUE, SOUND_RANGE_SET(4))
	qdel(target)

/mob/living/basic/bot/cleanbot/can_clean()
	return TRUE

/mob/living/basic/bot/cleanbot/proc/generate_ai_keys()
	ai_controller.set_blackboard_key(BB_CLEANABLE_DECALS, cleanable_decals)
	ai_controller.set_blackboard_key(BB_CLEANABLE_BLOOD, cleanable_blood)
	ai_controller.set_blackboard_key(BB_HUNTABLE_PESTS, huntable_pests)
	ai_controller.set_blackboard_key(BB_HUNTABLE_TRASH, huntable_trash)
	ai_controller.set_blackboard_key(BB_CLEANABLE_DRAWINGS, cleanable_drawings)
	ai_controller.set_blackboard_key(BB_CLEANBOT_EMAGGED_PHRASES, emagged_phrases)

/mob/living/basic/bot/cleanbot/autopatrol
	bot_mode_flags = BOT_MODE_ON | BOT_MODE_AUTOPATROL | BOT_MODE_REMOTE_ENABLED | BOT_MODE_CAN_BE_SAPIENT | BOT_MODE_ROUNDSTART_POSSESSION

/mob/living/basic/bot/cleanbot/medbay
	name = "Scrubs, MD"
	req_one_access = list(ACCESS_ROBOTICS, ACCESS_JANITOR, ACCESS_MEDICAL)
	bot_mode_flags = ~(BOT_MODE_ON | BOT_MODE_REMOTE_ENABLED)
