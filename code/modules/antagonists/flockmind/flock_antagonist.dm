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
	out += SPAN_FLOCKSAY("<div style='text-align: center'>You live through your drones - should all your drones perish, all hope of constructing the relay is lost! Do not allow all your drones to die, lest you yourself fade!</div>")
	out += SPAN_FLOCKSAY("<div style='text-align: center'>Capturing living mobs allows your flock to spread, using their living bodies as conduits to create new drones and bits.</div>")
	out += SPAN_FLOCKSAY("<div style='text-align: center'>Drones can create new drones by consuming matter. Likewise, they use that matter to build structures you designate! All structures require Compute, which can only be gotten by converting computer terminals.</div>")
	return jointext(out, "")

/datum/antagonist/flock/on_gain()
	add_antag_objective(new /datum/objective/flock_relay)
	. = ..()
