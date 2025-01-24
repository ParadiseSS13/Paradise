// Hellhound
/mob/living/simple_animal/hostile/hellhound
	// Sprites by FoS: https://www.paradisestation.org/forum/profile/335-fos
	name = "lesser hellhound"
	desc = "A demonic-looking black canine monster with glowing red eyes and sharp teeth. A firey, lava-like substance drips from it."
	icon_state = "hellhound"
	icon_living = "hellhound"
	icon_dead = "hellhound_dead"
	icon_resting = "hellhound_rest"
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
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
	robust_searching = TRUE
	stat_attack = UNCONSCIOUS
	attacktext = "savages"
	attack_sound = 'sound/effects/bite.ogg'
	speak_emote = list("growls")
	see_in_dark = 9
	universal_understand = TRUE
	wander = FALSE
	var/life_regen_cycles = 0
	var/life_regen_cycle_trigger = 10 // heal once for every X number of cycles spent resting
	var/life_regen_amount = -10 // negative, because negative = healing
	var/smoke_lastuse = 0
	var/smoke_freq = 300 // 30 seconds
	footstep_type = FOOTSTEP_MOB_CLAW

/mob/living/simple_animal/hostile/hellhound/Initialize(mapload)
	. = ..()
	var/datum/action/innate/demon_whisper/whisper_action = new
	whisper_action.Grant(src)
	ADD_TRAIT(src, TRAIT_NOBREATH, SPECIES_TRAIT)

/mob/living/simple_animal/hostile/hellhound/handle_automated_action()
	if(!..())
		return
	if(IS_HORIZONTAL(src))
		if(!wants_to_rest())
			custom_emote(EMOTE_VISIBLE, "growls, and gets up.")
			playsound(get_turf(src), 'sound/hallucinations/growl2.ogg', 50, 1)
			stand_up()
	else if(wants_to_rest())
		custom_emote(EMOTE_VISIBLE, "lays down, and starts to lick their wounds.")
		lay_down()

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
		if(IS_HORIZONTAL(src))
			if(getBruteLoss() || getFireLoss())
				msgs += "<span class='warning'>It is currently licking its wounds, regenerating the damage to its body!</span>"
			else
				msgs += "<span class='notice'>It is currently resting.</span>"
		. += msgs.Join("<BR>")

/mob/living/simple_animal/hostile/hellhound/Life(seconds, times_fired)
	. = ..()
	if(stat != DEAD && IS_HORIZONTAL(src) && (getBruteLoss() || getFireLoss()))
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

/mob/living/simple_animal/hostile/hellhound/attackby__legacy__attackchain(obj/item/C, mob/user, params)
	. = ..()
	if(target && isliving(target))
		var/mob/living/L = target
		if(L.stat != CONSCIOUS)
			target = user

/mob/living/simple_animal/hostile/hellhound/greater
	name = "greater hellhound"
	desc = "A demonic-looking black canine monster with glowing red eyes and sharp teeth. Greater hounds are far stronger than their lesser kin, and should be engaged with extreme caution."
	icon_state = "hellhoundgreater"
	icon_living = "hellhoundgreater"
	icon_resting = "hellhoundgreater_sit"
	maxHealth = 400
	health = 400
	force_threshold = 5 // no punching
	universal_speak = TRUE
	smoke_freq = 200
	life_regen_cycle_trigger = 5
	melee_damage_lower = 20
	melee_damage_upper = 30
	environment_smash = 2

/mob/living/simple_animal/hostile/hellhound/greater/Initialize(mapload)
	. = ..()
	// Movement
	AddSpell(new /datum/spell/ethereal_jaunt/shift)
	var/datum/spell/area_teleport/teleport/telespell = new
	telespell.clothes_req = FALSE
	telespell.invocation_type = "none"
	AddSpell(telespell)
	var/datum/spell/aoe/knock/knockspell = new
	knockspell.invocation_type = "none"
	AddSpell(knockspell)
	// Defense
	var/datum/spell/forcewall/wallspell = new
	wallspell.clothes_req = FALSE
	wallspell.invocation_type = "none"
	AddSpell(wallspell)
	// Offense
	var/datum/spell/aoe/conjure/creature/summonspell = new
	summonspell.base_cooldown = 1
	summonspell.invocation_type = "none"
	summonspell.summon_type = list(/mob/living/simple_animal/hostile/hellhound)
	summonspell.summon_amt = 1
	AddSpell(summonspell)

/mob/living/simple_animal/hostile/hellhound/greater/AttackingTarget()
	. = ..()
	if(. && ishuman(target) && (!client || a_intent == INTENT_HARM))
		special_aoe()

/mob/living/simple_animal/hostile/hellhound/greater/proc/special_aoe()
	if(world.time < (smoke_lastuse + smoke_freq))
		return
	smoke_lastuse = world.time
	var/datum/effect_system/smoke_spread/sleeping/smoke = new
	smoke.set_up(10, FALSE, loc)
	smoke.start()

/mob/living/simple_animal/hostile/hellhound/tear
	name = "frenzied hellhound"
	maxHealth = 300
	health = 300
	melee_damage_lower = 30
	melee_damage_upper = 50
	faction = list("rift")
