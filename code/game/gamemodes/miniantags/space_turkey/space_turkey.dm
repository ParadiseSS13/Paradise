/mob/living/simple_animal/hostile/space_turkey
	name = "space turkey"
	real_name = "space turkey"
	desc = "Flightful, untamable, unpardonable."
	icon_state = "turkey"
	icon_living = "turkey"
	icon_dead = "turkey_dead"
	icon_resting = "turkey_rest"
	speak = list("gobble?","gobble","GOBBLE")
	speak_emote = list("gobbles")
	emote_see = list("struts around")
	speed = -1
	a_intent = INTENT_HARM
	stop_automated_movement = 1
	wander = 0
	status_flags = CANPUSH
	pass_flags = PASSTABLE | PASSMOB //I immediately remove PASSMOB in New(); setting it here because for some reason it lets turkey_tackle turn PASSMOB on/off.
	ventcrawler = VENTCRAWLER_ALWAYS

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)

	maxHealth = 70
	health = 70
	environment_smash = ENVIRONMENT_SMASH_NONE
	obj_damage = 0
	melee_damage_lower = 4
	melee_damage_upper = 7
	see_in_dark = 6
	attacktext = "pecks"
	attack_sound = 'sound/weapons/rapierhit.ogg'
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat = 6)

	var/playstyle_string = "<b><font size=3 color='red'>It's a productive shift on the station,<br> \
							and you are a terrible turkey.</font><br> \
							Lay eggs to hatch more turkeys and fly at crew to knock them down.<br> \
							Objective #1: Hatch as many turkeys as possible.</b> (Lay your eggs in safe spots and protect them from the crew!)<br> \
							<b>Objective #2: Make the crew as miserable as possible.</b> (No killing! The crew can't be miserable if they're dead!)"

	var/egg_type = /obj/item/reagent_containers/food/snacks/egg/turkey

/mob/living/simple_animal/hostile/space_turkey/proc/ghost_call()
	notify_ghosts("A space turkey has been created at [get_area(src)]!", enter_link = "<a href=?src=[UID()];ghostjoin=1>(Click to enter)</a>", source = src, action = NOTIFY_ATTACK)

/mob/living/simple_animal/hostile/space_turkey/New()
	. = ..()

	pass_flags &= ~PASSMOB
	AddSpell(new /obj/effect/proc_holder/spell/targeted/lay_turkey_egg(null))
	AddSpell(new /obj/effect/proc_holder/spell/targeted/gobble(null))
	AddSpell(new /obj/effect/proc_holder/spell/targeted/turkey_tackle(null))

/obj/item/reagent_containers/food/snacks/egg/turkey
	name = "egg" //Originally had a snarky turkey egg description; removed to hide eggs with other eggs.
	desc = "An egg!"

#define TURKEY_HATCH_SPEED 30*7 //30 x # of minutes

/obj/item/reagent_containers/food/snacks/egg/turkey/process()
	if(isturf(loc))
		amount_grown += 1
		if(amount_grown >= TURKEY_HATCH_SPEED)
			notify_ghosts("A space turkey is ready to hatch in [get_area(src)]!", enter_link = "<a href=?src=[UID()];ghostjoin=1>(Click to enter)</a>", source = src, action = NOTIFY_ATTACK)
			STOP_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj, src)

/obj/item/reagent_containers/food/snacks/egg/turkey/attack_ghost(mob/user)
	if(src.amount_grown < TURKEY_HATCH_SPEED)
		to_chat(user, "<span class='boldnotice'>This egg is not ready to hatch yet!</span>")
		return
	if(cannotPossess(user))
		to_chat(user, "<span class='boldnotice'>Upon using the antagHUD you forfeited the ability to join the round.</span>")
		return
	if(jobban_isbanned(user, "Syndicate"))
		to_chat(user, "<span class='warning'>You are banned from antagonists!</span>")
		return
	if(!src || QDELETED(src))
		return
	var/be_turkey = alert("Become a space turkey? (Warning, You can no longer be cloned!)",,"Yes","No")
	if(be_turkey == "No" || !src || QDELETED(src))
		return
	visible_message("[src] hatches with a quiet cracking sound.")
	var/mob/living/simple_animal/hostile/space_turkey/T = new(get_turf(src))
	T.transfer_personality(user.client)
	qdel(src)

/mob/living/simple_animal/hostile/space_turkey/attack_ghost(mob/user)
	if(cannotPossess(user))
		to_chat(user, "<span class='boldnotice'>Upon using the antagHUD you forfeited the ability to join the round.</span>")
		return
	if(jobban_isbanned(user, "Syndicate"))
		to_chat(user, "<span class='warning'>You are banned from antagonists!</span>")
		return
	if(!src || QDELETED(src))
		return
	var/be_turkey = alert("Become a space turkey? (Warning, You can no longer be cloned!)",,"Yes","No")
	if(be_turkey == "No" || !src || QDELETED(src))
		return
	transfer_personality(user.client)

/mob/living/simple_animal/hostile/space_turkey/proc/transfer_personality(var/client/candidate)

	if(!candidate || !candidate.mob)
		return

	if(!QDELETED(candidate) || !QDELETED(candidate.mob))
		var/datum/mind/M = create_turkey_mind(candidate.ckey)
		M.transfer_to(src)
		candidate.mob = src
		ckey = candidate.ckey
		to_chat(src, playstyle_string)

/proc/create_turkey_mind(key)
	var/datum/mind/M = new /datum/mind(key)
	M.assigned_role = "Space Turkey"
	M.special_role = "Space Turkey"
	return M
