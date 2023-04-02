/datum/action/item_action/advanced/ninja/ninjaheal
	name = "Restorative Cocktail"
	desc = "Injects an experimental chemical that will heal most of the user's injuries, purges other reagents, cures internal damage, regrows limbs and bones. \
			It operates by rewinding your bodyparts to their perfect state in the past. Cause of that healing comes with a price of rare time paradox occuring! \
			DO NOT overdose it! Overdose threshold: 30"
	check_flags = NONE
	charge_type = ADV_ACTION_TYPE_CHARGES
	charge_max = 3
	use_itemicon = FALSE
	button_icon_state = "chem_injector"
	icon_icon = 'icons/mob/actions/actions_ninja.dmi'
	button_icon = 'icons/mob/actions/actions_ninja.dmi'
	background_icon_state = "background_green_active"
	action_initialisation_text = "Integrated Restorative Cocktail Mixer"

/obj/item/clothing/suit/space/space_ninja/proc/ninjaheal()
	if(ninjacost(0,N_HEAL))
		return
	var/mob/living/carbon/human/ninja = affecting
	ninja.reagents.add_reagent("chiyurizine", 25)	//The 25 dose is important. Reagent won't work if you add less. And it will overdose if you add 30 or more
	to_chat(ninja, span_notice("Реагенты успешно введены в пользователя."))
	atom_say("Spider-OS напоминает вам, вы можете отслеживать количество реагента в крови с помощью встроенных сканеров.")
	add_attack_logs(ninja, null, "Activated healing chems.")
	for(var/datum/action/item_action/advanced/ninja/ninjaheal/ninja_action in actions)
		ninja_action.use_action()
		if(!ninja_action.charge_counter)
			ninja_action.action_ready = FALSE
			ninja_action.toggle_button_on_off()
		break

// A reality rift designated to contain our ninja inside it.
// Created via the "chiyurizine" reagent.
/obj/effect/temp_visual/ninja_rend
	name = "A somewhat stable rend in reality"
	desc = "Incredible... yet absurd thing. Who's gonna come out of it?"
	icon = 'icons/obj/ninjaobjects.dmi'
	icon_state = "green_rift"
	anchored = TRUE
	var/mob/living/carbon/human/occupant	//mob holder
	duration = 1 MINUTES
	var/duration_min = 5 SECONDS
	var/duration_max = 20 SECONDS
	randomdir = FALSE
	light_power = 5
	light_range = 3
	light_color = "#55ff63"

/obj/effect/temp_visual/ninja_rend/Initialize(mapload)
	for(var/obj/effect/temp_visual/ninja_rend/other_rend in src.loc.contents)
		if(other_rend!=src)
			qdel(other_rend)	//Only one on a turf!
	duration = rand(duration_min, duration_max)
	. = ..()

/obj/effect/temp_visual/ninja_rend/Destroy()
	if(occupant)
		occupant.forceMove(get_turf(src))
		occupant.SetSleeping(0)
		occupant = null
	. = ..()

/obj/effect/temp_visual/ninja_rend/proc/GetOccupant(mob/living/carbon/human/rend_occupant)
	if(!istype(rend_occupant))
		return
	occupant = rend_occupant
	//Check below gets them out of most machines safelly
	if(isobj(rend_occupant.loc))
		var/obj/O = rend_occupant.loc
		O.force_eject_occupant(rend_occupant)
	occupant.forceMove(src)
	occupant.SetSleeping(duration)
	to_chat(occupant, span_danger("Вы попали в пространственно временной парадокс... "))
