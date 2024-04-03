/datum/spell/alien_spell/whisper
	name = "Whisper"
	desc = "Whisper into a target's mind."
	plasma_cost = 10
	action_icon_state = "alien_whisper"
	var/target

/datum/spell/alien_spell/whisper/create_new_targeting() // Yeah this is copy and pasted code from cryoken and it's good enough
	var/datum/spell_targeting/click/T = new()
	T.allowed_type = /mob/living
	T.click_radius = 0
	T.try_auto_target = FALSE
	T.selection_type = SPELL_SELECTION_RANGE
	T.include_user = TRUE
	return T

/datum/spell/alien_spell/whisper/cast(list/targets, mob/living/carbon/user)
	var/mob/living/target = targets[1]

	var/msg = tgui_input_text(user, "Message:", "Alien Whisper")
	if(!msg)
		revert_cast(user)
		return
	log_say("(AWHISPER to [key_name(target)]) [msg]", user)
	to_chat(target, "<span class='noticealien'>You hear a strange, alien voice in your head...<span class='noticealien'> [msg]")
	to_chat(user, "<span class='noticealien'>You said: [msg] to [target]</span>")
	for(var/mob/dead/observer/ghosts in GLOB.player_list)
		ghosts.show_message("<i>Alien message from <b>[user]</b> ([ghost_follow_link(user, ghost=ghosts)]) to <b>[target]</b> ([ghost_follow_link(target, ghost=ghosts)]): [msg]</i>")
