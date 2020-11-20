/mob/living/simple_animal/turkey/space_turkey
	name = "space turkey"
	real_name = "space turkey"
	desc = "Flightful, untamable, unpardonable."
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
	gold_core_spawnable = NO_SPAWN
	universal_speak = 0

	var/playstyle_string = "<b><font size=3 color='red'>It's a productive shift on the station,<br> \
							and you are a terrible turkey.</font></b><br> \
							<b>Objective #1:</b> Hatch as many turkeys as possible.<br> \
							<b>Objective #2:</b> Annoy the crew. Incessantly.<br> \
							<b>Objective #3:</b> Don't harm anyone unless you're cornered. <i>(Hint: The Flying Tackle doesn't hurt people.)</i>"

	var/egg_type = /obj/item/reagent_containers/food/snacks/egg/turkey

/mob/living/simple_animal/turkey/space_turkey/proc/ghost_call()
	notify_ghosts("A space turkey has been created at [get_area(src)]!", enter_link = "<a href=?src=[UID()];ghostjoin=1>(Click to enter)</a>", source = src, action = NOTIFY_ATTACK)

/mob/living/simple_animal/turkey/space_turkey/New(Loc, CallGhosts = TRUE)
	. = ..()

	pass_flags &= ~PASSMOB
	add_language("Vox-pidgin", 1)
	AddSpell(new /obj/effect/proc_holder/spell/targeted/lay_turkey_egg(null))
	AddSpell(new /obj/effect/proc_holder/spell/targeted/gobble(null))
	AddSpell(new /obj/effect/proc_holder/spell/targeted/turkey_tackle(null))
	if(CallGhosts)
		ghost_call()

/mob/living/simple_animal/turkey/space_turkey/Topic(href, href_list, hsrc)
	if(href_list["ghostjoin"])
		var/mob/dead/observer/ghost = usr
		if(istype(ghost))
			attack_ghost(ghost)

/obj/item/reagent_containers/food/snacks/egg/turkey
	name = "egg" //Originally had a snarky turkey egg description; removed to hide eggs with other eggs.
	desc = "An egg!"

#define TURKEY_HATCH_SPEED 30*4 //30 x # of minutes

/obj/item/reagent_containers/food/snacks/egg/turkey/New()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/reagent_containers/food/snacks/egg/turkey/process()
	if(isturf(loc)) //Currently quits growing if picked up; hope to fix later.
		amount_grown += 1
		if(amount_grown >= TURKEY_HATCH_SPEED)
			notify_ghosts("A space turkey is ready to hatch in [get_area(src)]!", enter_link = "<a href=?src=[UID()];ghostjoin=1>(Click to enter)</a>", source = src, action = NOTIFY_ATTACK)
			STOP_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj, src)

/obj/item/reagent_containers/food/snacks/egg/turkey/Topic(href, href_list, hsrc)
	if(href_list["ghostjoin"])
		var/mob/dead/observer/ghost = usr
		if(istype(ghost))
			attack_ghost(ghost)

/obj/item/reagent_containers/food/snacks/egg/turkey/attack_ghost(mob/user)
	if(src.amount_grown < TURKEY_HATCH_SPEED)
		to_chat(user, "<span class='boldnotice'>This egg is not ready to hatch yet!</span>")
		return
	if(!src || QDELETED(src))
		to_chat(user, "<span class='boldnotice'>Someone is already controlling this turkey.</span>")
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
	if(be_turkey == "No")
		return
	if(cannotPossess(user))
		to_chat(user, "<span class='boldnotice'>Upon using the antagHUD you forfeited the ability to join the round.</span>")
		return
	if(!src || QDELETED(src))
		to_chat(user, "<span class='boldnotice'>Someone is already controlling this turkey.</span>")
		return
	visible_message("[src] hatches with a quiet cracking sound.")
	var/mob/living/simple_animal/turkey/space_turkey/T = new(get_turf(src), FALSE)
	to_chat(user, T.playstyle_string)
	T.key = user.key
	qdel(src)

/mob/living/simple_animal/turkey/space_turkey/attack_ghost(mob/user)
	if(key)
		to_chat(user, "<span class='boldnotice'>Someone is already controlling this turkey.</span>")
		return
	if(cannotPossess(user))
		to_chat(user, "<span class='boldnotice'>Upon using the antagHUD you forfeited the ability to join the round.</span>")
		return
	if(jobban_isbanned(user, "Syndicate"))
		to_chat(user, "<span class='warning'>You are banned from antagonists!</span>")
		return
	if(stat == DEAD)
		to_chat(user, "<span class='boldnotice'>The turkey is dead.</span>")
		return
	if(!src || QDELETED(src))
		return
	var/be_turkey = alert("Become a space turkey? (Warning, You can no longer be cloned!)",,"Yes","No")
	if(be_turkey == "No" || !src || QDELETED(src))
		return
	if(cannotPossess(user))
		to_chat(user, "<span class='boldnotice'>Upon using the antagHUD you forfeited the ability to join the round.</span>")
		return
	if(stat == DEAD)
		to_chat(user, "<span class='boldnotice'>The turkey is dead.</span>")
		return
	if(key)
		to_chat(user, "<span class='boldnotice'>Someone is already controlling this turkey.</span>")
		return
	to_chat(user, playstyle_string)
	key = user.key
