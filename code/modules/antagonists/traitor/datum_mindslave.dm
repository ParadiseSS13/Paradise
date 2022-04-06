
// For Mindslaves and Zealots
/datum/antagonist/mindslave
	name = "Mindslave"
	roundend_category = "mindslaves"
	job_rank = SPECIAL_ROLE_TRAITOR
	special_role = SPECIAL_ROLE_TRAITOR
	antag_hud_type = ANTAG_HUD_TRAITOR
	antag_hud_name = "mindslave" // This isn't named "hudmindslave" because `add_serve_hud()` adds "hud" to the beginning.
	clown_gain_text = "Your syndicate training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself."
	clown_removal_text = "You lose your syndicate training and return to your own clumsy, clownish self."
	/// A reference to the mind who minslaved us.
	var/datum/mind/master
	/// Custom greeting text if you don't want to use the basic greeting. Specify this when making a new mindslave datum with `New()`.
	var/greet_text

/datum/antagonist/mindslave/New(datum/mind/_master, _greet_text)
	if(!_master)
		stack_trace("[type] created without a \"_master\" argument.")
		qdel(src)
		return
	master = _master
	greet_text = _greet_text
	return ..()

/datum/antagonist/mindslave/Destroy()
	master = null
	return ..()

/datum/antagonist/mindslave/on_gain()
	SSticker.mode.implanted[owner] = master

	var/datum/mindslaves/slaved = master.som
	if(!slaved) // If the master didn't already have this, we need to make a new mindslaves datum.
		slaved = new
		slaved.masters += master
		master.som = slaved

	// Update our master's HUD to give him the "M" icon.
	// Basically a copy and paste of what's in [/datum/antagonist/proc/add_antag_hud] in case the master doesn't have a traitor datum.
	var/datum/atom_hud/antag/hud = GLOB.huds[antag_hud_type]
	hud.join_hud(master.current)
	set_antag_hud(master.current, "hudmaster")
	slaved.add_serv_hud(master, "master")

	// Add an obey and protect objective.
	var/datum/objective/protect/serve_objective = new
	serve_objective.target = master
	serve_objective.owner = owner
	var/role = master.assigned_role ? master.assigned_role : master.special_role
	serve_objective.explanation_text = "Obey every order from and protect [master.current.real_name], the [role]."
	objectives += serve_objective
	return ..()

/datum/antagonist/mindslave/on_removal()
	if(owner.som)
		var/datum/mindslaves/slaved = owner.som
		slaved.serv -= owner
		slaved.leave_serv_hud(owner)
	return ..()

/datum/antagonist/mindslave/greet()
	var/mob/living/carbon/human/mindslave = owner.current
	// Show them the custom greeting text if it exists.
	if(greet_text)
		to_chat(mindslave, "<span class='biggerdanger'>[greet_text]</span>")
	else // Default greeting text if nothing is given.
		to_chat(mindslave, "<span class='biggerdanger'><B>You are now completely loyal to [master.current.name]!</B> \
							You must lay down your life to protect [master.current.p_them()] and assist in [master.current.p_their()] goals at any cost.</span>")

/datum/antagonist/mindslave/farewell()
	to_chat(owner.current, "<span class='biggerdanger'>You are no longer a mindslave of [master.current]!</span>")

/datum/antagonist/mindslave/add_antag_hud(mob/living/antag_mob)
	. = ..()
	// Make the mindslave hud icon show to the mindslave.
	var/datum/mindslaves/slaved = master.som
	owner.som = slaved
	slaved.serv += owner
	slaved.add_serv_hud(owner, antag_hud_name)

/datum/antagonist/mindslave/remove_antag_hud(mob/living/antag_mob)
	. = ..()
	// Remove the mindslave antag hud from the mindslave.
	var/datum/mindslaves/slaved = owner.som
	slaved.serv -= owner
	slaved.leave_serv_hud(owner)
	owner.som = null

// Helper proc that determines if a mob is a mindslave.
/proc/ismindslave(mob/living/carbon/human/H)
	return istype(H) && H.mind.has_antag_datum(/datum/antagonist/mindslave, FALSE)
