// Hellhound
/mob/living/simple_animal/hostile/hellhound
	// Sprites by FoS: http://nanotrasen.se/phpBB3/memberlist.php?mode=viewprofile&u=386
	name = "Lesser Hellhound"
	desc = "A demonic-looking black canine monster with glowing red eyes and sharp teeth. A firey, lava-like substance drips from it."
	icon_state = "hellhound"
	icon_living = "hellhound"
	icon_dead = "hellhound_dead"
	icon_resting = "hellhound_rest"
	mutations = list(BREATHLESS)
	gold_core_spawnable = CHEM_MOB_SPAWN_HOSTILE
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	melee_damage_lower = 10 // slightly higher than araneus
	melee_damage_upper = 30
	a_intent = INTENT_HARM
	environment_smash = 1
	speak_chance = 0
	speed = 0
	maxHealth = 250 // same as sgt araneus
	health = 250
	obj_damage = 50
	robust_searching = 1
	stat_attack = 1
	attacktext = "savages"
	attack_sound = 'sound/effects/bite.ogg'
	speak_emote = list("growls")
	see_in_dark = 9
	universal_understand = 1
	wander = 0
	var/life_regen_cycles = 0
	var/life_regen_cycle_trigger = 10 // heal once for every X number of cycles spent resting
	var/life_regen_amount = -10 // negative, because negative = healing
	var/smoke_lastuse = 0
	var/smoke_freq = 300 // 30 seconds
	var/datum/action/innate/demon/whisper/whisper_action

/mob/living/simple_animal/hostile/hellhound/New()
	. = ..()
	whisper_action = new()
	whisper_action.Grant(src)

/mob/living/simple_animal/hostile/hellhound/handle_automated_action()
	. = ..()
	if(resting)
		if(!wants_to_rest())
			custom_emote(1, "growls, and gets up.")
			playsound(get_turf(src), 'sound/hallucinations/growl2.ogg', 50, 1)
			icon_state = "[icon_living]"
			resting = 0
			update_canmove()
	else if(wants_to_rest())
		custom_emote(1, "lays down, and starts to lick their wounds.")
		icon_state = "[icon_resting]"
		resting = 1
		update_canmove()

/mob/living/simple_animal/hostile/hellhound/examine(mob/user)
	. = ..()
	if(stat != DEAD)
		var/list/msgs = list()
		if(key)
			msgs += "<span class='warning'>Its eyes have the spark of intelligence.</span>"
		if(health > (maxHealth*0.95))
			msgs += "<span class='notice'>It appears to be in excellent health.</span>"
		else if(health > (maxHealth*0.75))
			msgs += "<span class='notice'>It has a few injuries.</span>"
		else if(health > (maxHealth*0.55))
			msgs += "<span class='warning'>It has many injuries.</span>"
		else if(health > (maxHealth*0.25))
			msgs += "<span class='warning'>It is covered in wounds!</span>"
		if(resting)
			if(getBruteLoss() || getFireLoss())
				msgs += "<span class='warning'>It is currently licking its wounds, regenerating the damage to its body!</span>"
			else
				msgs += "<span class='notice'>It is currently resting.</span>"
		to_chat(usr,msgs.Join("<BR>"))

/mob/living/simple_animal/hostile/hellhound/Life(seconds, times_fired)
	. = ..()
	if(stat != DEAD && resting && (getBruteLoss() || getFireLoss()))
		if(life_regen_cycles >= life_regen_cycle_trigger)
			life_regen_cycles = 0
			to_chat(src, "<span class='notice'>You lick your wounds, helping them close.</span>")
			adjustBruteLoss(life_regen_amount)
			adjustFireLoss(life_regen_amount)
		else
			life_regen_cycles++

/mob/living/simple_animal/hostile/hellhound/proc/wants_to_rest()
	if(target)
		return FALSE
	if(getBruteLoss() || getFireLoss())
		return TRUE
	return FALSE

/mob/living/simple_animal/hostile/hellhound/AttackingTarget()
	. = ..()
	if(ishuman(target) && (!client || a_intent == INTENT_HARM))
		special_aoe()

/mob/living/simple_animal/hostile/hellhound/attackby(obj/item/C, mob/user, params)
	. = ..()
	if(target && isliving(target))
		var/mob/living/L = target
		if(L.stat != CONSCIOUS)
			target = user

/mob/living/simple_animal/hostile/hellhound/proc/special_aoe()
	if(world.time < (smoke_lastuse + smoke_freq))
		return
	smoke_lastuse = world.time
	var/datum/effect_system/smoke_spread/sleeping/smoke = new
	smoke.set_up(10, 0, loc)
	smoke.start()

/mob/living/simple_animal/hostile/hellhound/greater
	name = "Greater Hellhound"
	desc = "A demonic-looking black canine monster with glowing red eyes and sharp teeth. Greater hounds are far stronger than their lesser kin, and typically employed by powerful bluespace entities."
	icon_state = "hellhoundgreater"
	icon_living = "hellhoundgreater"
	icon_resting = "hellhoundgreater_sit"
	maxHealth = 400
	health = 400
	force_threshold = 5 // no punching
	smoke_freq = 200
	life_regen_cycle_trigger = 5
	melee_damage_lower = 20
	melee_damage_upper = 30
	environment_smash = 2
	gold_core_spawnable = CHEM_MOB_SPAWN_INVALID
