#define LIGHT_DAM_THRESHOLD 4
#define LIGHT_HEAL_THRESHOLD 2
#define LIGHT_DAMAGE_TAKEN 7

/*

SHADOWLING: A gamemode based on previously-run events

Aliens called shadowlings are on the station.
These shadowlings can 'enthrall' crew members and enslave them.
They also burn in the light but heal rapidly whilst in the dark.
The game will end under two conditions:
	1. The shadowlings die
	2. The emergency shuttle docks at CentCom

Shadowling strengths:
	- The dark
	- Hard vacuum (They are not affected by it)
	- Their thralls who are not harmed by the light
	- Stealth

Shadowling weaknesses:
	- The light
	- Fire
	- Enemy numbers
	- Lasers (Lasers are concentrated light and do more damage)
	- Flashbangs (High stun and high burn damage; if the light stuns humans, you bet your ass it'll hurt the shadowling very much!)

Shadowlings start off disguised as normal crew members, and they only have two abilities: Hatch and Enthrall.
They can still enthrall and perhaps complete their objectives in this form.
Hatch will, after a short time, cast off the human disguise and assume the shadowling's true identity.
They will then assume the normal shadowling form and gain their abilities.

The shadowling will seem OP, and that's because it kinda is. Being restricted to the dark while being alone most of the time is extremely difficult and as such the shadowling needs powerful abilities.
Made by Xhuis

*/



/*
	GAMEMODE
*/


/datum/game_mode
	var/list/datum/mind/shadows = list()
	var/list/datum/mind/shadowling_thralls = list()
	var/list/shadow_objectives = list()
	var/required_thralls = 15 //How many thralls are needed (hardcoded for now)
	var/shadowling_ascended = 0 //If at least one shadowling has ascended
	var/shadowling_dead = 0 //is shadowling kill
	var/objective_explanation


/proc/is_thrall(var/mob/living/M)
	return istype(M) && M.mind && ticker && ticker.mode && (M.mind in ticker.mode.shadowling_thralls)


/proc/is_shadow_or_thrall(var/mob/living/M)
	return istype(M) && M.mind && ticker && ticker.mode && ((M.mind in ticker.mode.shadowling_thralls) || (M.mind in ticker.mode.shadows))


/proc/is_shadow(var/mob/living/M)
	return istype(M) && M.mind && ticker && ticker.mode && (M.mind in ticker.mode.shadows)


/datum/game_mode/shadowling
	name = "shadowling"
	config_tag = "shadowling"
	required_players = 30
	required_enemies = 2
	recommended_enemies = 2
	restricted_jobs = list("AI", "Cyborg")
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Blueshield", "Nanotrasen Representative", "Security Pod Pilot", "Magistrate", "Brig Physician", "Internal Affairs Agent", "Nanotrasen Navy Officer", "Special Operations Officer")

/datum/game_mode/shadowling/announce()
	to_chat(world, "<b>The current game mode is - Shadowling!</b>")
	to_chat(world, "<b>There are alien <span class='deadsay'>shadowlings</span> on the station. Crew: Kill the shadowlings before they can eat or enthrall the crew. Shadowlings: Enthrall the crew while remaining in hiding.</b>")

/datum/game_mode/shadowling/pre_setup()
	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	var/list/datum/mind/possible_shadowlings = get_players_for_role(ROLE_SHADOWLING)

	if(!possible_shadowlings.len)
		return 0

	var/shadowlings = max(3, round(num_players()/14))

	while(shadowlings)
		var/datum/mind/shadow = pick(possible_shadowlings)
		shadows += shadow
		possible_shadowlings -= shadow
		modePlayer += shadow
		shadow.special_role = SPECIAL_ROLE_SHADOWLING
		shadow.restricted_roles = restricted_jobs
		shadowlings--
	return 1


/datum/game_mode/shadowling/post_setup()
	for(var/datum/mind/shadow in shadows)
		log_game("[shadow.key] (ckey) has been selected as a Shadowling.")
		sleep(10)
		to_chat(shadow.current, "<br>")
		to_chat(shadow.current, "<span class='deadsay'><b><font size=3>You are a shadowling!</font></b></span>")
		greet_shadow(shadow)
		finalize_shadowling(shadow)
		process_shadow_objectives(shadow)
		//give_shadowling_abilities(shadow)
	..()

/datum/game_mode/proc/greet_shadow(var/datum/mind/shadow)
	to_chat(shadow.current, "<b>Currently, you are disguised as an employee aboard [world.name].</b>")
	to_chat(shadow.current, "<b>In your limited state, you have two abilities: Hatch and Shadowling Hivemind (:8).</b>")
	to_chat(shadow.current, "<b>Any other shadowlings are your allies. You must assist them as they shall assist you.</b>")
	to_chat(shadow.current, "<b>If you are new to shadowling, or want to read about abilities, check the wiki page at http://nanotrasen.se/wiki/index.php/Shadowling</b><br>")



/datum/game_mode/proc/process_shadow_objectives(var/datum/mind/shadow_mind)
	var/objective = "enthrall" //may be devour later, but for now it seems murderbone-y

	if(objective == "enthrall")
		objective_explanation = "Ascend to your true form by use of the Ascendance ability. This may only be used with [required_thralls] collective thralls, while hatched, and is unlocked with the Collective Mind ability."
		shadow_objectives += "enthrall"
		shadow_mind.memory += "<b>Objective #1</b>: [objective_explanation]"
		to_chat(shadow_mind.current, "<b>Objective #1</b>: [objective_explanation]<br>")


/datum/game_mode/proc/finalize_shadowling(var/datum/mind/shadow_mind)
	var/mob/living/carbon/human/S = shadow_mind.current
	shadow_mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/shadowling_hatch(null))
	spawn(0)
		shadow_mind.current.add_language("Shadowling Hivemind")
		update_shadow_icons_added(shadow_mind)
		if(shadow_mind.assigned_role == "Clown")
			to_chat(S, "<span class='notice'>Your alien nature has allowed you to overcome your clownishness.</span>")
			S.mutations.Remove(CLUMSY)

/datum/game_mode/proc/add_thrall(datum/mind/new_thrall_mind)
	if(!istype(new_thrall_mind))
		return 0
	if(!(new_thrall_mind in shadowling_thralls))
		shadowling_thralls += new_thrall_mind
		new_thrall_mind.special_role = SPECIAL_ROLE_SHADOWLING_THRALL
		update_shadow_icons_added(new_thrall_mind)
		new_thrall_mind.current.attack_log += "\[[time_stamp()]\] <span class='danger'>Became a thrall</span>"
		new_thrall_mind.current.add_language("Shadowling Hivemind")
		new_thrall_mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/lesser_glare(null))
		new_thrall_mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/lesser_shadow_walk(null))
		new_thrall_mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/shadow_vision/thrall(null))
		to_chat(new_thrall_mind.current, "<span class='shadowling'><b>You see the truth. Reality has been torn away and you realize what a fool you've been.</b></span>")
		to_chat(new_thrall_mind.current, "<span class='shadowling'><b>The shadowlings are your masters.</b> Serve them above all else and ensure they complete their goals.</span>")
		to_chat(new_thrall_mind.current, "<span class='shadowling'>You may not harm other thralls or the shadowlings. However, you do not need to obey other thralls.</span>")
		to_chat(new_thrall_mind.current, "<span class='shadowling'>Your body has been irreversibly altered. The attentive can see this - you may conceal it by wearing a mask.</span>")
		to_chat(new_thrall_mind.current, "<span class='shadowling'>Though not nearly as powerful as your masters, you possess some weak powers. These can be found in the Thrall Abilities tab.</span>")
		to_chat(new_thrall_mind.current, "<span class='shadowling'>You may communicate with your allies by speaking in the Shadowling Hivemind (:8).</span>")
		if(jobban_isbanned(new_thrall_mind.current, ROLE_SHADOWLING))
			replace_jobbaned_player(new_thrall_mind.current, ROLE_SHADOWLING)

		return 1

/datum/game_mode/proc/remove_thrall(datum/mind/thrall_mind, var/kill = 0)
	if(!istype(thrall_mind) || !(thrall_mind in shadowling_thralls) || !isliving(thrall_mind.current))
		return 0 //If there is no mind, the mind isn't a thrall, or the mind's mob isn't alive, return
	shadowling_thralls.Remove(thrall_mind)
	thrall_mind.current.attack_log += "\[[time_stamp()]\] <span class='danger'>Dethralled</span>"
	thrall_mind.special_role = null
	update_shadow_icons_removed(thrall_mind)
	for(var/obj/effect/proc_holder/spell/S in thrall_mind.spell_list)
		thrall_mind.RemoveSpell(S)
	thrall_mind.current.remove_language("Shadowling Hivemind")
	if(kill && ishuman(thrall_mind.current)) //If dethrallization surgery fails, kill the mob as well as dethralling them
		var/mob/living/carbon/human/H = thrall_mind.current
		H.visible_message("<span class='warning'>[H] jerks violently and falls still.</span>", \
							"<span class='userdanger'>A piercing white light floods your mind, banishing your memories as a thrall and--</span>")
		H.death()
		return 1
	var/mob/living/M = thrall_mind.current
	if(issilicon(M))
		M.audible_message("<span class='notice'>[M] lets out a short blip.</span>", \
							"<span class='userdanger'>You have been turned into a robot! You are no longer a thrall! Though you try, you cannot remember anything about your servitude...</span>")
	else
		M.visible_message("<span class='big'>[M] looks like their mind is their own again!</span>", \
						"<span class='userdanger'>A piercing white light floods your eyes. Your mind is your own again! Though you try, you cannot remember anything about the shadowlings or your time \
							under their command...</span>")
	return 1


/*
	GAME FINISH CHECKS
*/

/datum/game_mode/shadowling/check_finished()
	var/shadows_alive = 0 //and then shadowling was kill
	for(var/datum/mind/shadow in shadows) //but what if shadowling was not kill?
		if(!istype(shadow.current,/mob/living/carbon/human) && !istype(shadow.current,/mob/living/simple_animal/ascendant_shadowling))
			continue
		if(shadow.current.stat == DEAD)
			continue
		shadows_alive++
	if(shadows_alive)
		return ..()
	else
		shadowling_dead = 1 //but shadowling was kill :(
		return 1

/datum/game_mode/proc/remove_shadowling(datum/mind/ling_mind)
	if(!istype(ling_mind) || !(ling_mind in shadows)) return 0
	update_shadow_icons_removed(ling_mind)
	shadows.Remove(ling_mind)
	ling_mind.current.attack_log += "\[[time_stamp()]\] <span class='danger'>Deshadowlinged</span>"
	ling_mind.special_role = null
	for(var/obj/effect/proc_holder/spell/S in ling_mind.spell_list)
		ling_mind.RemoveSpell(S)
	var/mob/living/M = ling_mind.current
	if(issilicon(M))
		M.audible_message("<span class='notice'>[M] lets out a short blip.</span>", \
						  "<span class='userdanger'>You have been turned into a robot! You are no longer a shadowling! Though you try, you cannot remember anything about your time as one...</span>")
	else
		M.visible_message("<span class='big'>[M] screams and contorts!</span>", \
						  "<span class='userdanger'>THE LIGHT-- YOUR MIND-- <i>BURNS--</i></span>")
		spawn(30)
			if(!M || qdeleted(M))
				return
			M.visible_message("<span class='warning'>[M] suddenly bloats and explodes!</span>", \
							  "<span class='warning'><b>AAAAAAAAA<font size=3>AAAAAAAAAAAAA</font><font size=4>AAAAAAAAAAAA----</font></span>")
			playsound(M, 'sound/magic/Disintegrate.ogg', 100, 1)
			M.gib()

/datum/game_mode/shadowling/proc/check_shadow_victory()
	var/success = 0 //Did they win?
	if(shadow_objectives.Find("enthrall"))
		success = shadowling_ascended
	return success


/datum/game_mode/shadowling/declare_completion()
	if(check_shadow_victory() && shuttle_master.emergency.mode >= SHUTTLE_ESCAPE) //Doesn't end instantly - this is hacky and I don't know of a better way ~X
		to_chat(world, "<span class='greentext'><b>The shadowlings have ascended and taken over the station!</b></span>")
	else if(shadowling_dead && !check_shadow_victory()) //If the shadowlings have ascended, they can not lose the round
		to_chat(world, "<span class='redtext'><b>The shadowlings have been killed by the crew!</b></span>")
	else if(!check_shadow_victory() && shuttle_master.emergency.mode >= SHUTTLE_ESCAPE)
		to_chat(world, "<span class='redtext'><b>The crew escaped the station before the shadowlings could ascend!</b></span>")
	else
		to_chat(world, "<span class='redtext'><b>The shadowlings have failed!</b></span>")
	..()
	return 1


/datum/game_mode/proc/auto_declare_completion_shadowling()
	var/text = ""
	if(shadows.len)
		text += "<br><span class='big'><b>The shadowlings were:</b></span>"
		for(var/datum/mind/shadow in shadows)
			text += "<br>[shadow.key] was [shadow.name] ("
			if(shadow.current)
				if(shadow.current.stat == DEAD)
					text += "died"
				else
					text += "survived"
				if(shadow.current.real_name != shadow.name)
					text += " as <b>[shadow.current.real_name]</b>"
			else
				text += "body destroyed"
			text += ")"
		text += "<br>"
		if(shadowling_thralls.len)
			text += "<br><span class='big'><b>The thralls were:</b></span>"
			for(var/datum/mind/thrall in shadowling_thralls)
				text += "<br>[thrall.key] was [thrall.name] ("
				if(thrall.current)
					if(thrall.current.stat == DEAD)
						text += "died"
					else
						text += "survived"
					if(thrall.current.real_name != thrall.name)
						text += " as <b>[thrall.current.real_name]</b>"
				else
					text += "body destroyed"
				text += ")"
	text += "<br>"
	to_chat(world, text)


/*
	MISCELLANEOUS
*/


/datum/species/shadow/ling
	//Normal shadowpeople but with enhanced effects
	name = "Shadowling"

	icobase = 'icons/mob/human_races/r_shadowling.dmi'
	deform = 'icons/mob/human_races/r_shadowling.dmi'

	blood_color = "#555555"
	flesh_color = "#222222"

	flags = NO_BLOOD | NO_BREATHE | RADIMMUNE | NOGUNS //Can't use guns due to muzzle flash
	burn_mod = 1.5 //1.5x burn damage, 2x is excessive
	hot_env_multiplier = 1.5

	silent_steps = 1

/datum/species/shadow/ling/handle_life(var/mob/living/carbon/human/H)
	if(!H.weakeyes)
		H.weakeyes = 1 //Makes them more vulnerable to flashes and flashbangs
	var/light_amount = 0
	H.nutrition = 450 //i aint never get hongry
	if(isturf(H.loc))
		var/turf/T = H.loc
		light_amount = T.get_lumcount() * 10
		if(light_amount > LIGHT_DAM_THRESHOLD && !H.incorporeal_move) //Can survive in very small light levels. Also doesn't take damage while incorporeal, for shadow walk purposes
			H.take_overall_damage(0, LIGHT_DAMAGE_TAKEN)
			if(H.stat != DEAD)
				to_chat(H, "<span class='userdanger'>The light burns you!</span>")//Message spam to say "GET THE FUCK OUT"
				H << 'sound/weapons/sear.ogg'
		else if(light_amount < LIGHT_HEAL_THRESHOLD)
			H.heal_overall_damage(5, 5)
			H.adjustToxLoss(-5)
			H.adjustBrainLoss(-25) //Shad O. Ling gibbers, "CAN U BE MY THRALL?!!"
			H.adjustCloneLoss(-1)
			H.SetWeakened(0)
			H.SetStunned(0)


/datum/species/shadow/ling/lesser //Empowered thralls. Obvious, but powerful
	name = "Lesser Shadowling"

	icobase = 'icons/mob/human_races/r_lshadowling.dmi'
	deform = 'icons/mob/human_races/r_lshadowling.dmi'

	blood_color = "#CCCCCC"
	flesh_color = "#AAAAAA"

	flags = NO_BLOOD | NO_BREATHE | RADIMMUNE
	burn_mod = 1.1
	hot_env_multiplier = 1.1

/datum/species/shadow/ling/lesser/handle_life(var/mob/living/carbon/human/H)
	if(!H.weakeyes)
		H.weakeyes = 1 //Makes them more vulnerable to flashes and flashbangs
	var/light_amount = 0
	H.nutrition = 450 //i aint never get hongry
	if(isturf(H.loc))
		var/turf/T = H.loc
		light_amount = T.get_lumcount() * 10
		if(light_amount > LIGHT_DAM_THRESHOLD && !H.incorporeal_move)
			H.take_overall_damage(0, LIGHT_DAMAGE_TAKEN/2)
		else if(light_amount < LIGHT_HEAL_THRESHOLD)
			H.heal_overall_damage(2,2)
			H.adjustToxLoss(-5)
			H.adjustBrainLoss(-25)
			H.adjustCloneLoss(-1)

/datum/game_mode/proc/update_shadow_icons_added(datum/mind/shadow_mind)
	var/datum/atom_hud/antag/shadow_hud = huds[ANTAG_HUD_SHADOW]
	shadow_hud.join_hud(shadow_mind.current)
	set_antag_hud(shadow_mind.current, ((shadow_mind in shadows) ? "hudshadowling" : "hudshadowlingthrall"))


/datum/game_mode/proc/update_shadow_icons_removed(datum/mind/shadow_mind) //This should never actually occur, but it's here anyway.
	var/datum/atom_hud/antag/shadow_hud = huds[ANTAG_HUD_SHADOW]
	shadow_hud.leave_hud(shadow_mind.current)
	set_antag_hud(shadow_mind.current, null)