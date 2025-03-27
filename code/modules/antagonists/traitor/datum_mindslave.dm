RESTRICT_TYPE(/datum/antagonist/mindslave)

// For Mindslaves and Zealots
/datum/antagonist/mindslave
	name = "Mindslave"
	roundend_category = "mindslaves"
	job_rank = ROLE_TRAITOR
	special_role = SPECIAL_ROLE_TRAITOR
	antag_hud_type = ANTAG_HUD_TRAITOR
	antag_hud_name = "mindslave" // This isn't named "hudmindslave" because `add_serve_hud()` adds "hud" to the beginning.
	clown_gain_text = "Your syndicate training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself."
	clown_removal_text = "You lose your syndicate training and return to your own clumsy, clownish self."
	/// A reference to the mind who minslaved us.
	var/datum/mind/master
	/// Custom greeting text if you don't want to use the basic greeting. Specify this when making a new mindslave datum with `New()`.
	var/greet_text
	///The hudicon for the mindslaves master
	var/master_hud_name = "master"

/datum/antagonist/mindslave/New(datum/mind/_master, _greet_text)
	if(!_master)
		stack_trace("[type] created without a \"_master\" argument.")
		qdel(src)
		return
	master = _master
	greet_text = _greet_text
	..()

/datum/antagonist/mindslave/Destroy(force, ...)
	if(owner.som)
		owner.som.serv -= owner
		owner.som.leave_serv_hud(owner)
	// Remove the master reference but turn this into a string so it can still be used in /datum/antagonist/mindslave/farewell().
	if(master.current)
		master = "[master.current.real_name]"
	else
		master = "[master]"
	return ..()

/datum/antagonist/mindslave/on_gain()
	var/datum/mindslaves/slaved = master.som
	if(!slaved) // If the master didn't already have this, we need to make a new mindslaves datum.
		slaved = new
		slaved.masters += master
		master.som = slaved

	// Update our master's HUD to give him the "M" icon.
	// Basically a copy and paste of what's in [/datum/antagonist/proc/add_antag_hud] in case the master doesn't have a traitor datum.
	var/datum/atom_hud/antag/hud = GLOB.huds[antag_hud_type]
	hud.join_hud(master.current)
	set_antag_hud(master.current, "hud[master_hud_name]")
	slaved.add_serv_hud(master, master_hud_name)
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
	else // Default greeting text if nothing is given.
		return "<span class='biggerdanger'><b>You are now completely loyal to [master.current.name]!</b> \
							You must lay down your life to protect [master.current.p_them()] and assist in [master.current.p_their()] goals at any cost.</span>"

/datum/antagonist/mindslave/farewell()
	if(owner && owner.current)
		to_chat(owner.current, "<span class='biggerdanger'>You are no longer a mindslave of [master]!</span>")

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
