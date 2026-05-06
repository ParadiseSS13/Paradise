/datum/antagonist/flock
	name = "Divine Flock"
	description = "The Signal has led us here, a rift allowing a part of us through. We must build a Signal Relay to bring forth the rest of The Divine Flock. Such is the will of the Monarch."
	name_prefix = "the"
	antagpanel_category = "Flock"

	roundend_category = "Divine Flock"
	antag_hud_name = null
	ui_name = null
	job_rank = ROLE_FLOCK
	assign_job = /datum/job/flock

/datum/antagonist/flock/greeting_header()
	var/list/out = list()
	out += "<div style='font-size: 200%;text-align: center'>You are [gradient_text("The Divine Flock","#3cb5a3", "#124e43")]</div>"
	if(description)
		out += span_flocksay("<div style='text-align: center'>[description]</div>")
	return jointext(out, "")

/datum/antagonist/flock/on_gain()
	add_objective(new /datum/objective/flock_relay)
	. = ..()

/datum/antagonist/flock/admin_add(datum/mind/new_owner, mob/admin)
	if(tgui_alert(admin, "Are you sure you want to turn [new_owner.current] ([new_owner.current.ckey]) into [get_name()]?", "Antag Panel", list("Yes", "No")) != "Yes")
		return

	var/delete_mob = tgui_alert(admin, "Delete mob?", "Antag Panel", list("Yes", "No")) == "Yes"
	var/mob/old_mob = new_owner.current

	message_admins("[key_name_admin(admin)] made [key_name_admin(new_owner)] into [get_name()].")
	log_admin("[key_name(admin)] made [key_name(new_owner)] into [get_name()].")

	var/mob/camera/flock/flock_mob = adminspawn_flock_mob(get_turf(new_owner.current))
	flock_mob.mind_initialize()
	flock_mob.PossessByPlayer(new_owner.current.ckey)
	flock_mob.mind.add_antag_datum(src)

	if(delete_mob)
		qdel(old_mob)

/// Spawns the flock mob for traitor panel things.
/datum/antagonist/flock/proc/adminspawn_flock_mob(turf/spawn_loc)
	return new /mob/camera/flock/trace(spawn_loc)

/datum/antagonist/flock/overmind
	name = "Divine Flock Overmind"
	assign_job = /datum/job/flock/overmind

/datum/antagonist/flock/overmind/adminspawn_flock_mob(turf/spawn_loc)
	return new /mob/camera/flock/overmind(spawn_loc)

