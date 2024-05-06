RESTRICT_TYPE(/datum/antagonist/mindslave)

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
	..()

/datum/antagonist/mindslave/Destroy(force, ...)
	owner.mindslave_slave.remove_servant(owner)
	// Remove the master reference but turn this into a string so it can still be used in /datum/antagonist/mindslave/farewell().
	if(master.current)
		master = "[master.current.real_name]"
	else
		master = "[master]"
	return ..()

/datum/antagonist/mindslave/on_gain()
	var/datum/mindslaves/slaved = master.mindslave_master
	if(!slaved) // If the master didn't already have this, we need to make a new mindslaves datum.
		// if your master is a vampire and shit got here, this will probably be weird.
		slaved = new
		slaved.add_master(master)

	slaved.add_servant(owner, antag_hud_name)
	return ..()

/datum/antagonist/mindslave/add_owner_to_gamemode()
	SSticker.mode.implanted[owner] = master

/datum/antagonist/mindslave/remove_owner_from_gamemode()
	SSticker.mode.implanted[owner] = null
	SSticker.mode.implanted -= owner

/datum/antagonist/mindslave/give_objectives()
	var/explanation_text = "Obey every order from and protect [master.current.real_name], the [master.assigned_role ? master.assigned_role : master.special_role]."
	add_antag_objective(/datum/objective/protect/mindslave, explanation_text, master)

/datum/antagonist/mindslave/greet()
	// Show them the custom greeting text if it exists.
	if(greet_text)
		return "<span class='biggerdanger'>[greet_text]</span>"
	// Default greeting text if nothing is given.
	return "<span class='biggerdanger'><b>You are now completely loyal to [master.current.name]!</b> \
			You must lay down your life to protect [master.current.p_them()] and assist in [master.current.p_their()] goals at any cost.</span>"

/datum/antagonist/mindslave/farewell()
	if(owner && owner.current)
		to_chat(owner.current, "<span class='biggerdanger'>You are no longer a mindslave of [master]!</span>")

// /datum/antagonist/mindslave/add_antag_hud(mob/living/antag_mob)
// 	. = ..()
// 	// Make the mindslave hud icon show to the mindslave.
// 	master.mindslave_master.add_servant(owner)

// /datum/antagonist/mindslave/remove_antag_hud(mob/living/antag_mob)
// 	. = ..()
// 	// Remove the mindslave antag hud from the mindslave.
// 	owner.mindslave_slave.remove_servant(owner)
