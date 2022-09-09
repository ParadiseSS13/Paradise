/datum/action/item_action/ninja_sword_recall
	name = "Recall Energy Katana"
	desc = "Teleports the Energy Katana linked to this suit to its wearer. Energy cost: 200"
	use_itemicon = FALSE
	check_flags = FALSE
	button_icon_state = "energy_katana_green"
	icon_icon = 'icons/obj/ninjaobjects.dmi'
	button_icon = 'icons/mob/actions/actions_ninja.dmi'
	background_icon_state = "background_green"
	action_initialisation_text = "Katana Recall System"

/**
 * Proc called to recall the ninja's sword.
 *
 * Called to summon the ninja's katana back to them
 * If the katana can see the ninja, it will throw itself towards them.
 * If not, the katana will teleport itself to the ninja.
 */
/obj/item/clothing/suit/space/space_ninja/proc/ninja_sword_recall()
	var/mob/living/carbon/human/ninja = affecting
	var/inview = TRUE

	if(!energyKatana)
		to_chat(ninja, span_warning("Could not locate your Energy Katana!"))
		return

	if(energyKatana in ninja)
		return

	var/distance = get_dist(ninja,energyKatana)

	if(!(energyKatana in view(ninja)))
		inview = FALSE

	if(!ninjacost(20))	//Статичная цена в 200 энергии
		s_coold = 0.5 SECONDS	//0.5 секунд задержки, чтобы избежать спама возврата
		if(iscarbon(energyKatana.loc))
			var/mob/living/carbon/sword_holder = energyKatana.loc
			sword_holder.unEquip(energyKatana, TRUE)
		else
			energyKatana.forceMove(get_turf(energyKatana))

		if(inview) //If we can see the katana, throw it towards ourselves, damaging people as we go.
			if(energyKatana.loc == ninja.loc)	//При нажатии катана уже была на той же клетке, что и мы? Подбираем её
				energyKatana.returnToOwner(ninja, 1)
				return
			energyKatana.spark_system.start()
			playsound(ninja, "sparks", 50, TRUE, -9)
			ninja.visible_message(span_danger("\the [energyKatana] flies towards [ninja]!"),span_warning("You hold out your hand and \the [energyKatana] flies towards you!"))
			energyKatana.throw_at(ninja, distance+1, energyKatana.throw_speed)

		else //Else just TP it to us.
			energyKatana.returnToOwner(ninja, 1)
