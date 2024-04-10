/datum/spell/chef/expert_chef/create_new_targeting()
	return new /datum/spell_targeting/self

/datum/spell/chef/expert_chef
	name = "Expert Chef Knowledge"
	desc = "Find things you can cook with the items in reach."
	school = "chef"
	panel = "Chef"
	clothes_req = FALSE
	base_cooldown = 5 SECONDS
	human_req = TRUE
	action_icon_state = "chef"
	action_background_icon_state = "bg_default"
	still_recharging_msg = "All this thinking makes your head hurt, wait a bit longer."

/datum/spell/chef/expert_chef/cast(list/targets, mob/user = usr)
	for(var/mob/living/carbon/human/H in targets)
		H.expert_chef_knowledge()
