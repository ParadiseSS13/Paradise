/datum/action/changeling/stalking_presence
	name = "Stalking Presence"
	desc = "We evolve a keen intution, able to detect the anxieties of nearby lifeforms."
	helptext = "We will be able to detect the room, and direction of our prey as well as if they are injured."
	button_icon_state = "stalking"
	dna_cost = 1
	power_type = CHANGELING_PURCHASABLE_POWER
	menu_location = CLING_MENU_UTILITY


/datum/action/changeling/stalking_presence/proc/valid_target(mob/target, mob/user)
	return target.z == user.z && target.mind

/datum/action/changeling/stalking_presence/sting_action(mob/user)
	var/targets_by_name = list()
	for(var/mob/living/carbon/human/H in GLOB.human_list)
		if(!valid_target(H, user))
			continue
		targets_by_name[H.real_name] = H

	var/target_name = input(user, "Person to Locate", "Fear") in targets_by_name
	if(!target_name)
		return
	var/mob/living/carbon/human/target = targets_by_name[target_name]
	var/message = "[target_name] is in [get_area(target)], [dir2text(get_dir(user, target))] from you."
	if(target.get_damage_amount() >= 40 || target.bleed_rate)
		message += "<i> They are wounded...</i>"
	to_chat(user, "<span class='changeling'>[message]</span>")
