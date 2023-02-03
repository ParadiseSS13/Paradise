/datum/action/item_action/advanced/ninja/ninja_clones
	name = "Energy Clones"
	desc = "Creates two clones of the user to confuse enemies in the fight. Also changes your and the clones possition after that. Energy cost: 4000"
	check_flags = AB_CHECK_CONSCIOUS
	charge_type = ADV_ACTION_TYPE_RECHARGE
	charge_max = 8 SECONDS
	use_itemicon = FALSE
	icon_icon = 'icons/mob/actions/actions_ninja.dmi'
	button_icon_state = "ninja_clones"
	button_icon = 'icons/mob/actions/actions_ninja.dmi'
	background_icon_state = "background_green"
	action_initialisation_text = "Lightweave Illusion Device"

/obj/item/clothing/suit/space/space_ninja/proc/start_ninja_clones()
	var/mob/living/carbon/human/ninja = affecting
	if(!ninja)
		return
	if(!ninjacost(4000))
		playsound(ninja, 'sound/effects/clone_jutsu.ogg', 50, TRUE)
		for(var/datum/action/item_action/advanced/ninja/ninja_clones/ninja_action in actions)
			ninja_action.use_action()
			break
		addtimer(CALLBACK(src, .proc/spawn_ninja_clones, ninja), 15)


/obj/item/clothing/suit/space/space_ninja/proc/spawn_ninja_clones(mob/living/carbon/human/ninja)
	if(auto_smoke)
		if(locate(/datum/action/item_action/advanced/ninja/ninja_smoke_bomb) in actions)
			prime_smoke(lowcost = TRUE)
	do_sparks(3, FALSE, ninja)
	add_attack_logs(ninja, null, "Activated Energy Clones")
	for(var/i=0, i<2, i++)
		var/mob/living/simple_animal/hostile/illusion/ninja_clone = new(ninja.loc)
		ninja_clone.faction = list(ROLE_NINJA)
		ninja_clone.Copy_Parent(ninja, 20 SECONDS, 20, 10, 50)
		do_teleport(ninja_clone, get_turf(ninja), 2)
		// Check mobs in a small radius from the cast position for mindshield
		// And make the closest to be targeted by clones
		var/list/mobs_in_range = viewers(5, get_turf(src))
		for(var/mob/living/in_turf_mob in mobs_in_range)
			if(ismindshielded(in_turf_mob))
				ninja_clone.GiveTarget(in_turf_mob)
				break
	do_teleport(ninja, get_turf(ninja), 2, asoundin = 'sound/effects/phasein.ogg')
