//This is the gamemode file for the ported goon gamemode vampires.
//They get a traitor objective and a blood sucking objective
/datum/game_mode
	var/list/datum/mind/vampires = list()
	var/list/datum/mind/vampire_enthralled = list() //those controlled by a vampire
	var/list/vampire_thralls = list() //vammpires controlling somebody

/datum/game_mode/vampire
	name = "vampire"
	config_tag = "vampire"
	restricted_jobs = list("AI", "Cyborg")
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Blueshield", "Nanotrasen Representative", "Security Pod Pilot", "Magistrate", "Chaplain", "Brig Physician", "Internal Affairs Agent", "Nanotrasen Navy Officer", "Special Operations Officer", "Syndicate Officer")
	protected_species = list("Machine")
	required_players = 15
	required_enemies = 1
	recommended_enemies = 4

	var/const/prob_int_murder_target = 50 // intercept names the assassination target half the time
	var/const/prob_right_murder_target_l = 25 // lower bound on probability of naming right assassination target
	var/const/prob_right_murder_target_h = 50 // upper bound on probability of naimg the right assassination target

	var/const/prob_int_item = 50 // intercept names the theft target half the time
	var/const/prob_right_item_l = 25 // lower bound on probability of naming right theft target
	var/const/prob_right_item_h = 50 // upper bound on probability of naming the right theft target

	var/const/prob_int_sab_target = 50 // intercept names the sabotage target half the time
	var/const/prob_right_sab_target_l = 25 // lower bound on probability of naming right sabotage target
	var/const/prob_right_sab_target_h = 50 // upper bound on probability of naming right sabotage target

	var/const/prob_right_killer_l = 25 //lower bound on probability of naming the right operative
	var/const/prob_right_killer_h = 50 //upper bound on probability of naming the right operative
	var/const/prob_right_objective_l = 25 //lower bound on probability of determining the objective correctly
	var/const/prob_right_objective_h = 50 //upper bound on probability of determining the objective correctly

	var/vampire_amount = 4

/datum/game_mode/vampire/announce()
	to_chat(world, "<B>The current game mode is - Vampires!</B>")
	to_chat(world, "<B>There are Vampires from Space Transylvania on the station, keep your blood close and neck safe!</B>")

/datum/game_mode/vampire/pre_setup()

	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	var/list/datum/mind/possible_vampires = get_players_for_role(ROLE_VAMPIRE)

	vampire_amount = 1 + round(num_players() / 10)

	if(possible_vampires.len>0)
		for(var/i = 0, i < vampire_amount, i++)
			if(!possible_vampires.len) break
			var/datum/mind/vampire = pick(possible_vampires)
			possible_vampires -= vampire
			vampires += vampire
			vampire.restricted_roles = restricted_jobs
			modePlayer += vampires
			var/datum/mindslaves/slaved = new()
			slaved.masters += vampire
			vampire.som = slaved //we MIGT want to mindslave someone
			vampire.special_role = SPECIAL_ROLE_VAMPIRE
		..()
		return 1
	else
		return 0

/datum/game_mode/vampire/post_setup()
	for(var/datum/mind/vampire in vampires)
		grant_vampire_powers(vampire.current)
		forge_vampire_objectives(vampire)
		greet_vampire(vampire)
		update_vampire_icons_added(vampire)
	..()

/datum/game_mode/proc/auto_declare_completion_vampire()
	if(vampires.len)
		var/text = "<FONT size = 2><B>The vampires were:</B></FONT>"
		for(var/datum/mind/vampire in vampires)
			var/traitorwin = 1

			text += "<br>[vampire.key] was [vampire.name] ("
			if(vampire.current)
				if(vampire.current.stat == DEAD)
					text += "died"
				else
					text += "survived"
				if(vampire.current.real_name != vampire.name)
					text += " as [vampire.current.real_name]"
			else
				text += "body destroyed"
			text += ")"

			if(vampire.objectives.len)//If the traitor had no objectives, don't need to process this.
				var/count = 1
				for(var/datum/objective/objective in vampire.objectives)
					if(objective.check_completion())
						text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='green'><B>Success!</B></font>"
						feedback_add_details("traitor_objective","[objective.type]|SUCCESS")
					else
						text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='red'>Fail.</font>"
						feedback_add_details("traitor_objective","[objective.type]|FAIL")
						traitorwin = 0
					count++

			var/special_role_text
			if(vampire.special_role)
				special_role_text = lowertext(vampire.special_role)
			else
				special_role_text = "antagonist"

			if(traitorwin)
				text += "<br><font color='green'><B>The [special_role_text] was successful!</B></font>"
				feedback_add_details("traitor_success","SUCCESS")
			else
				text += "<br><font color='red'><B>The [special_role_text] has failed!</B></font>"
				feedback_add_details("traitor_success","FAIL")
		to_chat(world, text)
	return 1

/datum/game_mode/proc/auto_declare_completion_enthralled()
	if(vampire_enthralled.len)
		var/text = "<FONT size = 2><B>The Enthralled were:</B></FONT>"
		for(var/datum/mind/Mind in vampire_enthralled)
			text += "<br>[Mind.key] was [Mind.name] ("
			if(Mind.current)
				if(Mind.current.stat == DEAD)
					text += "died"
				else
					text += "survived"
				if(Mind.current.real_name != Mind.name)
					text += " as [Mind.current.real_name]"
			else
				text += "body destroyed"
			text += ")"
		to_chat(world, text)
	return 1

/datum/game_mode/proc/forge_vampire_objectives(var/datum/mind/vampire)
	//Objectives are traitor objectives plus blood objectives

	var/datum/objective/blood/blood_objective = new
	blood_objective.owner = vampire
	blood_objective.gen_amount_goal(150, 400)
	vampire.objectives += blood_objective

	var/datum/objective/assassinate/kill_objective = new
	kill_objective.owner = vampire
	kill_objective.find_target()
	vampire.objectives += kill_objective

	var/datum/objective/steal/steal_objective = new
	steal_objective.owner = vampire
	steal_objective.find_target()
	vampire.objectives += steal_objective


	switch(rand(1,100))
		if(1 to 80)
			if(!(locate(/datum/objective/escape) in vampire.objectives))
				var/datum/objective/escape/escape_objective = new
				escape_objective.owner = vampire
				vampire.objectives += escape_objective
		else
			if(!(locate(/datum/objective/survive) in vampire.objectives))
				var/datum/objective/survive/survive_objective = new
				survive_objective.owner = vampire
				vampire.objectives += survive_objective
	return

/datum/game_mode/proc/grant_vampire_powers(mob/living/carbon/vampire_mob)
	if(!istype(vampire_mob))
		return
	vampire_mob.make_vampire()

/datum/game_mode/proc/greet_vampire(var/datum/mind/vampire, var/you_are=1)
	var/dat
	if(you_are)
		SEND_SOUND(vampire.current, 'sound/ambience/antag/vampalert.ogg')
		dat = "<span class='danger'>You are a Vampire!</span><br>"
	dat += {"To bite someone, target the head and use harm intent with an empty hand. Drink blood to gain new powers.
You are weak to holy things and starlight. Don't go into space and avoid the Chaplain, the chapel and especially Holy Water."}
	to_chat(vampire.current, dat)
	to_chat(vampire.current, "<B>You must complete the following tasks:</B>")

	if(vampire.current.mind)
		if(vampire.current.mind.assigned_role == "Clown")
			to_chat(vampire.current, "Your lust for blood has allowed you to overcome your clumsy nature allowing you to wield weapons without harming yourself.")
			vampire.current.mutations.Remove(CLUMSY)
			var/datum/action/innate/toggle_clumsy/A = new
			A.Grant(vampire.current)
	var/obj_count = 1
	for(var/datum/objective/objective in vampire.objectives)
		to_chat(vampire.current, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
		obj_count++
	return

/datum/vampire
	var/bloodtotal = 0 // CHANGE TO ZERO WHEN PLAYTESTING HAPPENS
	var/bloodusable = 0 // CHANGE TO ZERO WHEN PLAYTESTING HAPPENS
	var/mob/living/owner = null
	var/gender = FEMALE
	var/iscloaking = 0 // handles the vampire cloak toggle
	var/list/powers = list() // list of available powers and passives
	var/mob/living/carbon/human/draining // who the vampire is draining of blood
	var/nullified = 0 //Nullrod makes them useless for a short while.
	var/list/upgrade_tiers = list(
		/obj/effect/proc_holder/spell/vampire/self/rejuvenate = 0,
		/obj/effect/proc_holder/spell/vampire/targetted/hypnotise = 0,
		/obj/effect/proc_holder/spell/vampire/mob_aoe/glare = 0,
		/datum/vampire_passive/vision = 100,
		/obj/effect/proc_holder/spell/vampire/self/shapeshift = 100,
		/obj/effect/proc_holder/spell/vampire/self/cloak = 150,
		/obj/effect/proc_holder/spell/vampire/targetted/disease = 150,
		/obj/effect/proc_holder/spell/vampire/bats = 200,
		/obj/effect/proc_holder/spell/vampire/self/screech = 200,
		/datum/vampire_passive/regen = 200,
		/obj/effect/proc_holder/spell/vampire/shadowstep = 250,
		/obj/effect/proc_holder/spell/vampire/self/jaunt = 300,
		/obj/effect/proc_holder/spell/vampire/targetted/enthrall = 300,
		/datum/vampire_passive/full = 500)

/datum/vampire/New(gend = FEMALE)
	gender = gend

/datum/vampire/proc/force_add_ability(path)
	var/spell = new path(owner)
	if(istype(spell, /obj/effect/proc_holder/spell))
		owner.mind.AddSpell(spell)
	powers += spell

/datum/vampire/proc/get_ability(path)
	for(var/P in powers)
		var/datum/power = P
		if(power.type == path)
			return power
	return null

/datum/vampire/proc/add_ability(path)
	if(!get_ability(path))
		force_add_ability(path)

/datum/vampire/proc/remove_ability(ability)
	if(ability && (ability in powers))
		powers -= ability
		owner.mind.spell_list.Remove(ability)
		qdel(ability)

/datum/vampire/proc/update_owner(var/mob/living/carbon/human/current) //Called when a vampire gets cloned. This updates vampire.owner to the new body.
	if(current.mind && current.mind.vampire && current.mind.vampire.owner && (current.mind.vampire.owner != current))
		current.mind.vampire.owner = current

/mob/proc/make_vampire()
	if(!mind)
		return
	var/datum/vampire/vamp
	if(!mind.vampire)
		vamp = new /datum/vampire(gender)
		vamp.owner = src
		mind.vampire = vamp
	else
		vamp = mind.vampire
		vamp.powers.Cut()

	vamp.check_vampire_upgrade(0)

/datum/vampire/proc/remove_vampire_powers()
	for(var/P in powers)
		remove_ability(P)
	if(owner.hud_used)
		var/datum/hud/hud = owner.hud_used
		if(hud.vampire_blood_display)
			hud.remove_vampire_hud()
	owner.alpha = 255

/datum/vampire/proc/handle_bloodsucking(mob/living/carbon/human/H)
	draining = H
	var/blood = 0
	var/old_bloodtotal = 0 //used to see if we increased our blood total
	var/old_bloodusable = 0 //used to see if we increased our blood usable
	if(owner.is_muzzled())
		to_chat(owner, "<span class='warning'>[owner.wear_mask] prevents you from biting [H]!</span>")
		draining = null
		return
	add_attack_logs(owner, H, "vampirebit & is draining their blood.", ATKLOG_ALMOSTALL)
	owner.visible_message("<span class='danger'>[owner] grabs [H]'s neck harshly and sinks in [owner.p_their()] fangs!</span>", "<span class='danger'>You sink your fangs into [H] and begin to drain [owner.p_their()] blood.</span>", "<span class='notice'>You hear a soft puncture and a wet sucking noise.</span>")
	if(!iscarbon(owner))
		H.LAssailant = null
	else
		H.LAssailant = owner
	while(do_mob(owner, H, 50))
		if(!(owner.mind in ticker.mode.vampires))
			to_chat(owner, "<span class='warning'>Your fangs have disappeared!</span>")
			return
		old_bloodtotal = bloodtotal
		old_bloodusable = bloodusable
		if(!H.blood_volume)
			to_chat(owner, "<span class='warning'>They've got no blood left to give.</span>")
			break
		if(H.stat < DEAD)
			blood = min(20, H.blood_volume)	// if they have less than 20 blood, give them the remnant else they get 20 blood
			bloodtotal += blood / 2	//divide by 2 to counted the double suction since removing cloneloss -Melandor0
			bloodusable += blood / 2
		else
			blood = min(5, H.blood_volume)	// The dead only give 5 blood
			bloodtotal += blood
		if(old_bloodtotal != bloodtotal)
			to_chat(owner, "<span class='notice'><b>You have accumulated [bloodtotal] [bloodtotal > 1 ? "units" : "unit"] of blood[bloodusable != old_bloodusable ? ", and have [bloodusable] left to use" : ""].</b></span>")
		check_vampire_upgrade()
		H.blood_volume = max(H.blood_volume - 25, 0)
		if(ishuman(owner))
			var/mob/living/carbon/human/V = owner
			V.nutrition = min(NUTRITION_LEVEL_WELL_FED, V.nutrition + (blood / 2))

	draining = null
	to_chat(owner, "<span class='notice'>You stop draining [H.name] of blood.</span>")

/datum/vampire/proc/check_vampire_upgrade(announce = 1)
	var/list/old_powers = powers.Copy()

	for(var/ptype in upgrade_tiers)
		var/level = upgrade_tiers[ptype]
		if(bloodtotal >= level)
			add_ability(ptype)

	if(announce)
		announce_new_power(old_powers)

/datum/vampire/proc/announce_new_power(list/old_powers)
	for(var/p in powers)
		if(!(p in old_powers))
			if(istype(p, /obj/effect/proc_holder/spell/vampire))
				var/obj/effect/proc_holder/spell/vampire/power = p
				to_chat(owner, "<span class='notice'>[power.gain_desc]</span>")
			else if(istype(p, /datum/vampire_passive))
				var/datum/vampire_passive/power = p
				to_chat(owner, "<span class='notice'>[power.gain_desc]</span>")

/datum/game_mode/proc/remove_vampire(datum/mind/vampire_mind)
	if(vampire_mind in vampires)
		ticker.mode.vampires -= vampire_mind
		vampire_mind.special_role = null
		vampire_mind.current.create_attack_log("<span class='danger'>De-vampired</span>")
		if(vampire_mind.vampire)
			vampire_mind.vampire.remove_vampire_powers()
			QDEL_NULL(vampire_mind.vampire)
		if(issilicon(vampire_mind.current))
			to_chat(vampire_mind.current, "<span class='userdanger'>You have been turned into a robot! You can feel your powers fading away...</span>")
		else
			to_chat(vampire_mind.current, "<span class='userdanger'>You have been brainwashed! You are no longer a vampire.</span>")
		ticker.mode.update_vampire_icons_removed(vampire_mind)

//prepare for copypaste
/datum/game_mode/proc/update_vampire_icons_added(datum/mind/vampire_mind)
	var/datum/atom_hud/antag/vamp_hud = huds[ANTAG_HUD_VAMPIRE]
	vamp_hud.join_hud(vampire_mind.current)
	set_antag_hud(vampire_mind.current, ((vampire_mind in vampires) ? "hudvampire" : "hudvampirethrall"))

/datum/game_mode/proc/update_vampire_icons_removed(datum/mind/vampire_mind)
	var/datum/atom_hud/antag/vampire_hud = huds[ANTAG_HUD_VAMPIRE]
	vampire_hud.leave_hud(vampire_mind.current)
	set_antag_hud(vampire_mind.current, null)

/datum/game_mode/proc/remove_vampire_mind(datum/mind/vampire_mind, datum/mind/head)
	//var/list/removal
	if(!istype(head))
		head = vampire_mind //workaround for removing a thrall's control over the enthralled
	var/ref = "\ref[head]"
	if(ref in vampire_thralls)
		vampire_thralls[ref] -= vampire_mind
	vampire_enthralled -= vampire_mind
	vampire_mind.special_role = null
	var/datum/mindslaves/slaved = vampire_mind.som
	slaved.serv -= vampire_mind
	vampire_mind.som = null
	slaved.leave_serv_hud(vampire_mind)
	update_vampire_icons_removed(vampire_mind)
	vampire_mind.current.visible_message("<span class='userdanger'>[vampire_mind.current] looks as though a burden has been lifted!</span>", "<span class='userdanger'>The dark fog in your mind clears as you regain control of your own faculties, you are no longer a vampire thrall!</span>")
	if(vampire_mind.current.hud_used)
		vampire_mind.current.hud_used.remove_vampire_hud()


/datum/vampire/proc/check_sun()
	var/ax = owner.x
	var/ay = owner.y

	for(var/i = 1 to 20)
		ax += SSsun.dx
		ay += SSsun.dy

		var/turf/T = locate(round(ax, 0.5), round(ay, 0.5), owner.z)

		if(T.x == 1 || T.x == world.maxx || T.y == 1 || T.y == world.maxy)
			break

		if(T.density)
			return
	vamp_burn(1)

/datum/vampire/proc/handle_vampire()
	if(owner.hud_used)
		var/datum/hud/hud = owner.hud_used
		if(!hud.vampire_blood_display)
			hud.vampire_blood_display = new /obj/screen()
			hud.vampire_blood_display.name = "Usable Blood"
			hud.vampire_blood_display.icon_state = "power_display"
			hud.vampire_blood_display.screen_loc = "WEST:6,CENTER-1:15"
			hud.static_inventory += hud.vampire_blood_display
			hud.show_hud(hud.hud_version)
		hud.vampire_blood_display.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#dd66dd'>[bloodusable]</font></div>"
	handle_vampire_cloak()
	if(istype(owner.loc, /turf/space))
		check_sun()
	if(istype(owner.loc.loc, /area/chapel) && !get_ability(/datum/vampire_passive/full))
		vamp_burn(0)
	nullified = max(0, nullified - 1)

/datum/vampire/proc/handle_vampire_cloak()
	if(!ishuman(owner))
		owner.alpha = 255
		return
	var/turf/simulated/T = get_turf(owner)
	var/light_available = T.get_lumcount(0.5) * 10

	if(!istype(T))
		return 0

	if(!iscloaking)
		owner.alpha = 255
		return 0

	if(light_available <= 2)
		owner.alpha = round((255 * 0.15))
		return 1
	else
		owner.alpha = round((255 * 0.80))

/datum/vampire/proc/vamp_burn(severe_burn)
	var/burn_chance = severe_burn ? 35 : 8
	if(prob(burn_chance) && owner.health >= 50)
		switch(owner.health)
			if(75 to 100)
				to_chat(owner, "<span class='warning'>Your skin flakes away...</span>")
			if(50 to 75)
				to_chat(owner, "<span class='warning'>Your skin sizzles!</span>")
		owner.adjustFireLoss(3)
	else if(owner.health < 50)
		if(!owner.on_fire)
			to_chat(owner, "<span class='danger'>Your skin catches fire!</span>")
			owner.emote("scream")
		else
			to_chat(owner, "<span class='danger'>You continue to burn!</span>")
		owner.adjust_fire_stacks(5)
		owner.IgniteMob()
	return

/datum/hud/proc/remove_vampire_hud()
	if(!vampire_blood_display)
		return

	static_inventory -= vampire_blood_display
	QDEL_NULL(vampire_blood_display)
	show_hud(hud_version)
