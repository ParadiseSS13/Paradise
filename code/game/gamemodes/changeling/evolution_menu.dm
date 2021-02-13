/// The evolution menu will be shown in the compact mode, with only powers and costs being displayed.
#define COMPACT_MODE	0
/// The evolution menu will be shown in the expanded mode, with powers, costs, and ability descriptions being displayed.
#define EXPANDED_MODE	1

/datum/action/changeling/evolution_menu
	name = "-Evolution Menu-" //Dashes are so it's listed before all the other abilities.
	desc = "Choose our method of subjugation."
	button_icon_state = "changelingsting"
	dna_cost = 0
	/// Which UI view will be displayed. Compact mode will show only ability names, and will leave out their descriptions and helptext.
	var/view_mode = EXPANDED_MODE
	/// A list containing the names of bought changeling abilities. For use with the UI.
	var/list/purchased_abilities = list()
	/// A list containing every purchasable changeling ability. Includes its name, description, helptext and cost.
	var/static/list/ability_list = list()

/datum/action/changeling/evolution_menu/Grant(mob/M)
	. = ..()
	if(length(ability_list))
		return // List is already populated.

	for(var/action in subtypesof(/datum/action/changeling))
		var/datum/action/changeling/C = action
		if(initial(C.dna_cost) <= 0) // Filter out innate abilities like DNA sting, Evolution menu, etc.
			continue
		ability_list += list(list(
			"name" = initial(C.name),
			"description" = initial(C.desc),
			"helptext" = initial(C.helptext),
			"cost" = initial(C.dna_cost)
		))

/datum/action/changeling/evolution_menu/try_to_sting(mob/user, mob/target)
	ui_interact(user)

/datum/action/changeling/evolution_menu/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.always_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "EvolutionMenu", "Evolution Menu", 480, 574, master_ui, state)
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/action/changeling/evolution_menu/ui_data(mob/user)
	var/datum/changeling/cling = owner.mind.changeling
	var/list/data = list(
		"can_respec" = cling.canrespec,
		"evo_points" = cling.geneticpoints,
		"purchsed_abilities" = purchased_abilities,
		"view_mode" = view_mode
	)
	return data

/datum/action/changeling/evolution_menu/ui_static_data(mob/user)
	var/list/data = list(
		"ability_list" = ability_list
	)
	return data

/datum/action/changeling/evolution_menu/ui_act(action, list/params)
	if(..())
		return

	var/datum/changeling/cling = owner.mind.changeling

	switch(action)
		if("readapt")
			if(!cling.lingRespec(owner))
				return FALSE
			purchased_abilities.Cut()
			return TRUE

		if("purchase")
			var/power_name = params["power_name"]
			if(!cling.purchasePower(owner, power_name))
				return FALSE
			purchased_abilities |= power_name
			return TRUE

		if("set_view_mode")
			var/new_view_mode = text2num(params["mode"])
			if(!(new_view_mode in list(COMPACT_MODE, EXPANDED_MODE)))
				return FALSE
			view_mode = new_view_mode
			return TRUE

/datum/changeling/proc/purchasePower(var/mob/living/carbon/user, var/sting_name)
	var/datum/action/changeling/thepower = null
	var/list/all_powers = init_subtypes(/datum/action/changeling)

	for(var/datum/action/changeling/cling_sting in all_powers)
		if(cling_sting.name == sting_name)
			thepower = cling_sting

	if(thepower == null)
		to_chat(user, "This is awkward. Changeling power purchase failed, please report this bug to a coder!")
		return FALSE

	if(absorbedcount < thepower.req_dna)
		to_chat(user, "We lack the energy to evolve this ability!")
		return FALSE

	if(has_sting(thepower))
		to_chat(user, "We have already evolved this ability!")
		return FALSE

	if(thepower.dna_cost < 0)
		to_chat(user, "We cannot evolve this ability.")
		return FALSE

	if(geneticpoints < thepower.dna_cost)
		to_chat(user, "We have reached our capacity for abilities.")
		return FALSE

	if(user.status_flags & FAKEDEATH)//To avoid potential exploits by buying new powers while in stasis, which clears your verblist.
		to_chat(user, "We lack the energy to evolve new abilities right now.")
		return FALSE

	geneticpoints -= thepower.dna_cost
	purchasedpowers += thepower
	thepower.on_purchase(user)
	return TRUE

//Reselect powers
/datum/changeling/proc/lingRespec(var/mob/user)
	if(!ishuman(user) || issmall(user))
		to_chat(user, "<span class='danger'>We can't remove our evolutions in this form!</span>")
		return FALSE
	if(canrespec)
		to_chat(user, "<span class='notice'>We have removed our evolutions from this form, and are now ready to readapt.</span>")
		user.remove_changeling_powers(1)
		canrespec = 0
		user.make_changeling(FALSE)
		return TRUE
	else
		to_chat(user, "<span class='danger'>You lack the power to readapt your evolutions!</span>")
		return FALSE

/mob/proc/make_changeling(var/get_free_powers = TRUE)
	if(!mind)
		return
	if(!ishuman(src))
		return
	if(!mind.changeling)
		mind.changeling = new /datum/changeling(gender)
	if(mind.changeling.purchasedpowers)
		remove_changeling_powers(1)

	add_language("Changeling")

	for(var/language in languages)
		mind.changeling.absorbed_languages |= language

	if(get_free_powers)
		var/list/all_powers = init_subtypes(/datum/action/changeling)
		for(var/datum/action/changeling/path in all_powers) // purchase free powers.
			if(!path.dna_cost)
				if(!mind.changeling.has_sting(path))
					mind.changeling.purchasedpowers += path
				path.on_purchase(src)
	else //for respec
		var/datum/action/changeling/hivemind_pick/S1 = new
		if(!mind.changeling.has_sting(S1))
			mind.changeling.purchasedpowers+=S1
			S1.Grant(src)

	var/mob/living/carbon/C = src		//only carbons have dna now, so we have to typecaste
	mind.changeling.absorbed_dna |= C.dna.Clone()
	mind.changeling.trim_dna()
	return 1

//Used to dump the languages from the changeling datum into the actual mob.
/mob/proc/changeling_update_languages(var/updated_languages)

	for(var/datum/language/L in updated_languages)
		add_language("L.name")

	//This isn't strictly necessary but just to be safe...
	add_language("Changeling")

	return

/datum/changeling/proc/reset()
	chosen_sting = null
	geneticpoints = initial(geneticpoints)
	sting_range = initial(sting_range)
	chem_storage = initial(chem_storage)
	chem_recharge_rate = initial(chem_recharge_rate)
	chem_charges = min(chem_charges, chem_storage)
	chem_recharge_slowdown = initial(chem_recharge_slowdown)
	mimicing = ""

/mob/proc/remove_changeling_powers(var/keep_free_powers=0)
	if(ishuman(src))
		if(mind && mind.changeling)
			digitalcamo = 0
			mind.changeling.changeling_speak = 0
			mind.changeling.reset()
			for(var/datum/action/changeling/p in mind.changeling.purchasedpowers)
				if((p.dna_cost == 0 && keep_free_powers) || p.always_keep)
					continue
				mind.changeling.purchasedpowers -= p
				p.Remove(src)
			remove_language("Changeling")
		if(hud_used)
			hud_used.lingstingdisplay.icon_state = null
			hud_used.lingstingdisplay.invisibility = 101

/datum/changeling/proc/has_sting(datum/action/power)
	for(var/datum/action/P in purchasedpowers)
		if(power.name == P.name)
			return 1
	return 0
