/datum/game_mode/wizard/raginmages
	name = "ragin' mages"
	config_tag = "raginmages"
	required_players = 20

	use_huds = TRUE
	players_per_mage = 6
	multi_wizard_drifting = TRUE

/datum/game_mode/wizard/raginmages/announce()
	to_chat(world, "<B>The current game mode is - Ragin' Mages!</B>")
	to_chat(world, "<B>The <font color='red'>Space Wizard Federation</font> is pissed, help defeat all the space wizards!</B>")

/datum/game_mode/wizard/raginmages/greet_wizard(var/datum/mind/wizard, var/you_are=1)
	if(you_are)
		to_chat(wizard.current, "<span class='danger'>You are the Space Wizard!</span>")
	to_chat(wizard.current, "<B>The Space Wizards Federation has given you the following tasks:</B>")

	var/obj_count = 1
	for(var/datum/objective/objective in wizard.objectives)
		to_chat(wizard.current, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
		obj_count++
	to_chat(wizard.current, "<b>Objective Alpha</b>: Make sure the station pays for its actions against our diplomats")
	return

/datum/game_mode/wizard/raginmages/declare_completion()
	if(finished)
		feedback_set_details("round_end_result","raging wizard loss - wizards killed")
		to_chat(world, "<span class='warning'><FONT size = 3><B> The crew has managed to hold off the wizard attack! The Space Wizard Federation has been taught a lesson they will not soon forget!</B></FONT></span>")
	..(1)
