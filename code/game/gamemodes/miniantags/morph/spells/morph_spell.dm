/datum/spell/morph_spell
	action_background_icon_state = "bg_morph"
	clothes_req = FALSE
	/// How much food it costs the morph to use this
	var/hunger_cost = 0

/datum/spell/morph_spell/New()
	..()
	if(hunger_cost)
		name = "[name] ([hunger_cost])"
		action.name = name
		action.desc = desc
		action.build_all_button_icons()

/datum/spell/morph_spell/create_new_handler()
	var/datum/spell_handler/morph/H = new
	H.hunger_cost = hunger_cost
	return H
