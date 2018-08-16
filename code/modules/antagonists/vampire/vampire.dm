/datum/antagonist/vampire
	name = "Vampire"
	roundend_category  = "vampires"
	job_rank = ROLE_VAMPIRE


	var/bloodusable = 0
	var/bloodtotal = 0
	var/fullpower = FALSE
	var/draining
	var/list/objectives_given

	var/iscloaking = FALSE

	var/nullified = 0

	var/list/powers = list()// list of current powers

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

/datum/antagonist/vampire/on_gain()
	give_objectives()
	check_vampire_upgrade()
	ticker.mode.vampires += owner
	owner.special_role = "vampire"
	owner.current.faction += "vampire"
	ticker.mode.update_vampire_icons_added(owner)
	..()

/datum/antagonist/vampire/on_removal()
	remove_vampire_powers()
	owner.current.faction -= "vampire"
	ticker.mode.vampires -= owner
	owner.special_role = null
	owner.current.create_attack_log("<span class='danger'>De-vampired</span>")
	if(ishuman(owner.current))
		var/mob/living/carbon/human/H = owner.current
		var/datum/hud/hud = H.hud_used
		if(hud.vampire_blood_display)
			hud.remove_vampire_hud()
	ticker.mode.update_vampire_icons_removed(owner)
	for(var/O in objectives_given)
		owner.objectives -= O
	LAZYCLEARLIST(objectives_given)
	if(owner.current)
		if(issilicon(owner.current))
			to_chat(owner.current, "<span class='userdanger'>You have been turned into a robot! You can feel your powers fading away...</span>")
		else
			to_chat(owner.current,"<span class='userdanger'>Your powers have been quenched! You are no longer a vampire</span>")
	owner.special_role = null
	..()

/datum/antagonist/vampire/greet()
	to_chat(owner.current, "<span class='userdanger'>You are a Vampire!</span>")
	to_chat(owner.current, "<span class='danger'>To bite someone, target the head and use harm intent with an empty hand. Drink blood to gain new powers.</span>")
	to_chat(owner.current, "<span class='danger'>You are weak to holy things and starlight. Don't go into space and avoid the Chaplain, the chapel and especially Holy Water.</span>")
	if(owner.current.mind.assigned_role == "Clown")
		to_chat(owner.current, "Your lust for blood has allowed you to overcome your clumsy nature allowing you to wield weapons without harming yourself.")
		owner.current.mutations.Remove(CLUMSY)

	if(LAZYLEN(objectives_given))
		owner.announce_objectives()

/datum/antagonist/vampire/proc/give_objectives()
	var/datum/objective/blood/blood_objective = new
	blood_objective.owner = owner
	blood_objective.gen_amount_goal(150, 400)
	add_objective(blood_objective)

	var/datum/objective/assassinate/kill_objective = new
	kill_objective.owner = owner
	kill_objective.find_target()
	add_objective(kill_objective)

	var/datum/objective/steal/steal_objective = new
	steal_objective.owner = owner
	steal_objective.find_target()
	add_objective(steal_objective)



	if(prob(80))
		if(!(locate(/datum/objective/escape) in owner.objectives))
			var/datum/objective/escape/escape_objective = new
			escape_objective.owner = owner
			add_objective(escape_objective)
	else
		if(!(locate(/datum/objective/survive) in owner.objectives))
			var/datum/objective/survive/survive_objective = new
			survive_objective.owner = owner
			add_objective(survive_objective)
	return

/datum/antagonist/vampire/proc/add_objective(var/datum/objective/O)
	LAZYADD(owner.objectives, O)
	LAZYADD(objectives_given, O)


/datum/antagonist/vampire/proc/vamp_burn(var/severe_burn = FALSE)
	var/mob/living/L = owner.current
	if(!L)
		return
	var/burn_chance = severe_burn ? 35 : 8
	if(prob(burn_chance) && L.health >= 50)
		switch(L.health)
			if(75 to 100)
				to_chat(L, "<span class='warning'>Your skin flakes away...</span>")
			if(50 to 75)
				to_chat(L, "<span class='warning'>Your skin sizzles!</span>")
		L.adjustFireLoss(3)
	else if(L.health < 50)
		if(!L.on_fire)
			to_chat(L, "<span class='danger'>Your skin catches fire!</span>")
			L.emote("scream")
		else
			to_chat(L, "<span class='danger'>You continue to burn!</span>")
		L.adjust_fire_stacks(5)
		L.IgniteMob()
	return

/datum/antagonist/vampire/proc/check_sun()
	var/mob/living/carbon/C = owner.current
	var/ax = C.x
	var/ay = C.y

	for(var/i = 1 to 20)
		ax += SSsun.dx
		ay += SSsun.dy

		var/turf/T = locate(round(ax, 0.5), round(ay, 0.5), C.z)

		if(T.x == 1 || T.x == world.maxx || T.y == 1 || T.y == world.maxy)
			break

		if(T.density)
			return
	vamp_burn(TRUE)

/datum/antagonist/vampire/handle_stat()
	stat("Total Blood",  bloodtotal)
	stat("Usable Blood", bloodusable)

/datum/antagonist/vampire/antag_life()
	var/mob/living/carbon/C = owner.current
	if(!C)
		return
	if(C.hud_used)
		var/datum/hud/hud = C.hud_used
		if(!hud.vampire_blood_display)
			hud.vampire_blood_display = new /obj/screen()
			hud.vampire_blood_display.name = "Usable Blood"
			hud.vampire_blood_display.icon_state = "power_display"
			hud.vampire_blood_display.screen_loc = "WEST:6,CENTER-1:15"
			hud.static_inventory += hud.vampire_blood_display
			hud.show_hud(hud.hud_version)
		hud.vampire_blood_display.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#dd66dd'>[bloodusable]</font></div>"
	handle_vampire_cloak()
	if(istype(C.loc, /turf/space))
		check_sun()
	if(istype(get_area(C), /area/chapel) && !get_ability(/datum/vampire_passive/full))
		vamp_burn()
	nullified = max(0, nullified - 1)



/datum/antagonist/vampire/proc/handle_bloodsucking(mob/living/carbon/human/H)
	draining = H
	var/mob/living/carbon/human/O = owner.current
	var/blood = 0
	var/old_bloodtotal = 0 //used to see if we increased our blood total
	var/old_bloodusable = 0 //used to see if we increased our blood usable
	if(O.is_muzzled())
		to_chat(owner, "<span class='warning'>[O.wear_mask] prevents you from biting [H]!</span>")
		draining = null
		return FALSE
	add_attack_logs(owner, H, "vampirebit & is draining their blood.", ATKLOG_ALMOSTALL)
	O.visible_message("<span class='danger'>[owner] grabs [H]'s neck harshly and sinks in [owner.p_their()] fangs!</span>", "<span class='danger'>You sink your fangs into [H] and begin to drain [owner.p_their()] blood.</span>", "<span class='notice'>You hear a soft puncture and a wet sucking noise.</span>")
	if(!iscarbon(owner))
		H.LAssailant = null
	else
		H.LAssailant = O
	playsound(O.loc, 'sound/weapons/bite.ogg', 50, 1)
	while(do_mob(O, H, 50))
		if(!is_vampire(O))
			to_chat(owner, "<span class='warning'>Your fangs have disappeared!</span>")
			return
		old_bloodtotal = bloodtotal
		old_bloodusable = bloodusable
		if(!H.blood_volume)
			to_chat(O, "<span class='warning'>They've got no blood left to give.</span>")
			break
		if(H.stat < DEAD)
			blood = min(20, H.blood_volume)	// if they have less than 20 blood, give them the remnant else they get 20 blood
			bloodtotal += blood / 2	//divide by 2 to counted the double suction since removing cloneloss -Melandor0
			bloodusable += blood / 2
		else
			blood = min(5, H.blood_volume)	// The dead only give 5 blood
			bloodtotal += blood
		if(old_bloodtotal != bloodtotal)
			to_chat(O, "<span class='notice'><b>You have accumulated [bloodtotal] [bloodtotal > 1 ? "units" : "unit"] of blood[bloodusable != old_bloodusable ? ", and have [bloodusable] left to use" : ""].</b></span>")
		check_vampire_upgrade()
		H.blood_volume = max(H.blood_volume - 25, 0)
		if(ishuman(O))
			O.nutrition = min(NUTRITION_LEVEL_WELL_FED, O.nutrition + (blood / 2))
		playsound(O.loc, 'sound/items/drink.ogg', 40, 1)

	draining = null
	to_chat(O, "<span class='notice'>You stop draining [H.name] of blood.</span>")

/datum/antagonist/vampire/proc/force_add_ability(path)
	var/spell = new path(owner)
	var/mob/living/carbon/human/O = owner.current
	if(istype(spell, /obj/effect/proc_holder/spell))
		owner.AddSpell(spell)
	else if(istype(spell, /datum/status_effect))
		O.apply_status_effect(spell)
	LAZYADD(powers, spell)

/datum/antagonist/vampire/proc/get_ability(path)
	LAZYINITLIST(powers)
	for(var/P in powers)
		var/datum/power = P
		if(power.type == path)
			return power
	return null

/datum/antagonist/vampire/proc/add_ability(path)
	if(!get_ability(path))
		force_add_ability(path)

/datum/antagonist/vampire/proc/remove_ability(ability)
	if(ability && (ability in powers))
		powers -= ability
		owner.spell_list.Remove(ability)
		qdel(ability)


/datum/antagonist/vampire/proc/remove_vampire_powers()
	for(var/P in powers)
		remove_ability(P)
	owner.current.alpha = 255

/datum/antagonist/vampire/proc/check_vampire_upgrade(var/announce = TRUE)
	var/list/old_powers = powers.Copy()
	for(var/ptype in upgrade_tiers)
		var/level = upgrade_tiers[ptype]
		if(bloodtotal >= level)
			add_ability(ptype)
	if(announce)
		announce_new_power(old_powers)
	owner.current.update_sight() //deal with sight abilities

/datum/antagonist/vampire/proc/announce_new_power(list/old_powers)
	for(var/p in powers)
		if(!(p in old_powers))
			if(istype(p, /obj/effect/proc_holder/spell/vampire))
				var/obj/effect/proc_holder/spell/vampire/power = p
				to_chat(owner.current, "<span class='notice'>[power.gain_desc]</span>")
			else if(istype(p, /datum/vampire_passive))
				var/datum/vampire_passive/power = p
				to_chat(owner.current, "<span class='notice'>[power.gain_desc]</span>")


/datum/antagonist/vampire/proc/handle_vampire_cloak()
	if(!ishuman(owner.current))
		owner.current.alpha = 255
		return
	var/mob/living/carbon/human/H = owner.current
	var/turf/T = get_turf(H)
	var/light_available = T.get_lumcount()

	if(!istype(T))
		return 0

	if(!iscloaking)
		H.alpha = 255
		return 0

	if(light_available <= 0.25)
		H.alpha = round((255 * 0.15))
		return 1
	else
		H.alpha = round((255 * 0.80))