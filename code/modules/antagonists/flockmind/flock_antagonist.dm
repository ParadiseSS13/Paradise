/datum/antagonist/flock
	name = "Divine Flock"
	roundend_category = "Flock"
	roundend_category = "Divine Flock"
	wiki_page_name = "Divine Flock"
	antag_hud_name = null
	job_rank = ROLE_FLOCK
	special_role = SPECIAL_ROLE_FLOCK
	blurb_g = 128
	blurb_b = 128
	blurb_a = 0.75

/datum/antagonist/flock/greet()
	var/list/out = list()
	out += "<div style='font-size: 200%;text-align: center'>You are [gradient_text("The Divine Flock","#3cb5a3", "#124e43")]</div>"
	out += SPAN_FLOCKSAY("<div style='text-align: center'>["The Signal has led us here, a rift allowing a part of us through. We must build a Signal Relay to bring forth the rest of The Divine Flock. Such is the will of the Monarch."]</div>")
	return jointext(out, "")

/datum/antagonist/flock/on_gain()
	add_antag_objective(new /datum/objective/flock_relay)
	. = ..()
