/datum/action/item_action/ninja_clones
	check_flags = AB_CHECK_CONSCIOUS
	name = "Energy Clones"
	desc = "Creates two clones of the user to confuse enemies in the fight. Also changes your and the clones possition after that. Energy cost: 4000"
	use_itemicon = FALSE
	icon_icon = 'icons/mob/actions/actions_ninja.dmi'
	button_icon_state = "ninja_clones"
	button_icon = 'icons/mob/actions/actions_ninja.dmi'
	background_icon_state = "background_green"
	action_initialisation_text = "Lightweave Illusion Device"

/obj/item/clothing/suit/space/space_ninja/proc/spawn_ninja_clones()
	var/mob/living/carbon/human/ninja = affecting
	if(!ninja)
		return
	if(!ninjacost(400))
		playsound(ninja, 'sound/effects/clone_jutsu.ogg', 50, TRUE)
		s_coold = 4 SECONDS
		sleep(15)
		do_sparks(3, FALSE, ninja)
		add_attack_logs(ninja, null, "Activated Energy Clones")
		for(var/i=0, i<2, i++)
			var/mob/living/simple_animal/hostile/illusion/ninja_clone = new(ninja.loc)
			ninja_clone.faction = list(ROLE_NINJA)
			ninja_clone.Copy_Parent(ninja, 200, 20, 5)
			do_teleport(ninja_clone, get_turf(ninja), 2)
		do_teleport(ninja, get_turf(ninja), 2, asoundin = 'sound/effects/phasein.ogg')

