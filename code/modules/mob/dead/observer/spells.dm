GLOBAL_LIST_INIT(boo_phrases, list(
	"You feel a chill run down your spine.",
	"You think you see a figure in your peripheral vision.",
	"What was that?",
	"The hairs stand up on the back of your neck.",
	"You are filled with a great sadness.",
	"Something doesn't feel right...",
	"You feel a presence in the room.",
	"It feels like someone's standing behind you.",
))

/obj/effect/proc_holder/spell/aoe_turf/boo
	name = "Boo!"
	desc = "Fuck with the living."

	ghost = TRUE

	action_icon_state = "boo"
	school = "transmutation"
	charge_max = 600
	starts_charged = FALSE
	clothes_req = 0
	stat_allowed = 1
	invocation = ""
	invocation_type = "none"
	range = 1 // Or maybe 3?

/obj/effect/proc_holder/spell/aoe_turf/boo/cast(list/targets, mob/user = usr)
	for(var/turf/T in targets)
		T.get_spooked()
