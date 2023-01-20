/datum/action/item_action/advanced/ninja/ninja_emergency_blink
	name = "Emergency Blink"
	desc = "Teleports user to a random nearby location. Consumes a big amount of energy. Use wisely. Energy cost: 1500"
	check_flags = NONE
	charge_type = ADV_ACTION_TYPE_RECHARGE
	charge_max = 3 SECONDS
	use_itemicon = FALSE
	button_icon_state = "emergency_blink"
	icon_icon = 'icons/mob/actions/actions_ninja.dmi'
	button_icon = 'icons/mob/actions/actions_ninja.dmi'
	background_icon_state = "background_green"
	action_initialisation_text = "Void-Shift - Emergency Blink System"

//Наглейший копипаст из кода блюспейс кристаллов ^v^
/obj/item/clothing/suit/space/space_ninja/proc/emergency_blink()
	var/mob/living/carbon/human/ninja = affecting
	if(!is_teleport_allowed(ninja.z))
		src.visible_message(span_warning("[src] begins to glow... But then stops!"))
		return
	if(!ninjacost(1500))
		var/turf/T = get_turf(ninja)
		if(auto_smoke)
			if(locate(/datum/action/item_action/advanced/ninja/ninja_smoke_bomb) in actions)
				prime_smoke(lowcost = TRUE)
		do_teleport(ninja, T, 8, asoundin = 'sound/effects/phasein.ogg')
		add_attack_logs(ninja, null, "Emergency blinked from [COORD(T)] to [COORD(ninja)].")
		investigate_log("[key_name_log(ninja)] Emergency blinked from [COORD(T)] to [COORD(ninja)].", INVESTIGATE_TELEPORTATION)
		for(var/datum/action/item_action/advanced/ninja/ninja_emergency_blink/ninja_action in actions)
			ninja_action.use_action()
			break
