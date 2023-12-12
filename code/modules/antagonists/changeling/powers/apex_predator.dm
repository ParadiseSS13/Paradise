/datum/action/changeling/apex_predator
	name = "Apex Predator"
	desc = "We evolve a keen intuition, allowing us to detect the anxieties of nearby lifeforms."
	helptext = "We will be able to detect the direction and room our prey is in, as well as if they have any injuries."
	button_icon_state = "predator"
	dna_cost = 1
	power_type = CHANGELING_PURCHASABLE_POWER
	menu_location = CLING_MENU_UTILITY

/datum/action/changeling/apex_predator/sting_action(mob/user)
	var/target_by_name = list()
	for(var/mob/living/carbon/human/H in GLOB.human_list)
		if((H.z != user.z) || !H.mind)
			continue
		target_by_name[H.real_name] = H

	var/target_name = tgui_input_list(user, "Person to Locate", "Prey", target_by_name)
	if(!target_name)
		return
	var/mob/living/carbon/human/target = target_by_name[target_name]
	var/message = "[target_name] is in [get_area(target)], [dir2text(get_dir(user, target))] of us."
	if(target.get_damage_amount() >= 40 || target.bleed_rate)
		message += " <i>They are wounded...</i>"
	to_chat(user, "<span class='changeling'>[message]</span>")
