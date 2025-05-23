/mob/living/basic/netherworld/hellhound
	// Sprites by FoS: https://www.paradisestation.org/forum/profile/335-fos
	name = "lesser hellhound"
	desc = "A demonic-looking black canine monster with glowing red eyes and sharp teeth. A firey, lava-like substance drips from it."
	icon_state = "hellhound"
	icon_living = "hellhound"
	icon_dead = "hellhound_dead"
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	melee_damage_lower = 10 // slightly higher than araneus
	melee_damage_upper = 30
	a_intent = INTENT_HARM
	speed = 0
	maxHealth = 250 // same as sgt araneus
	health = 250
	obj_damage = 50
	attack_verb_continuous = "savages"
	attack_verb_simple = "savage"
	attack_sound = 'sound/effects/bite.ogg'
	speak_emote = list("growls")
	see_in_dark = 9
	universal_understand = TRUE
	ai_controller = /datum/ai_controller/basic_controller/simple/simple_hostile_obstacles
	step_type = FOOTSTEP_MOB_CLAW
	/// The hellhound's icon when resting
	var/icon_resting = "hellhound_rest"
	/// How many cycles has the hellhound rested
	var/life_regen_cycles = 0
	/// Trigger number for health regen
	var/life_regen_cycle_trigger = 10
	/// How much is healed when regenerating
	var/life_regen_amount = -10 // negative, because negative = healing
	/// When did the hellhound last use smoke
	var/smoke_lastuse = 0
	/// How often can the hellhound use smoke
	var/smoke_freq = 30 SECONDS

/mob/living/basic/netherworld/hellhound/examine(mob/user)
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

/mob/living/basic/netherworld/hellhound/Life(seconds, times_fired)
	. = ..()
	if(stat != DEAD && IS_HORIZONTAL(src) && (getBruteLoss() || getFireLoss()))
		if(life_regen_cycles >= life_regen_cycle_trigger)
			life_regen_cycles = 0
			to_chat(src, "<span class='notice'>You lick your wounds, helping them close.</span>")
			adjustBruteLoss(life_regen_amount)
			adjustFireLoss(life_regen_amount)
		else
			life_regen_cycles++

// TODO: Bug Warriorstar about this
// /mob/living/basic/netherworld/hellhound/proc/wants_to_rest()
// 	if(target)
// 		return FALSE
// 	if(getBruteLoss() || getFireLoss())
// 		return TRUE
// 	return FALSE

/mob/living/basic/netherworld/hellhound/greater
	name = "greater hellhound"
	desc = "A demonic-looking black canine monster with glowing red eyes and sharp teeth. Greater hounds are far stronger than their lesser kin, and should be engaged with extreme caution."
	icon_state = "hellhoundgreater"
	icon_living = "hellhoundgreater"
	icon_resting = "hellhoundgreater_sit"
	maxHealth = 400
	health = 400
	force_threshold = 5 // no punching
	universal_speak = TRUE
	smoke_freq = 20 SECONDS
	life_regen_cycle_trigger = 5
	melee_damage_lower = 20
	melee_damage_upper = 30

/mob/living/basic/netherworld/hellhound/greater/Initialize(mapload)
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

/mob/living/basic/netherworld/hellhound/greater/melee_attack(atom/target, list/modifiers, ignore_cooldown)
	. = ..()
	if(. && ishuman(target) && (!client || a_intent == INTENT_HARM))
		special_aoe()

/mob/living/basic/netherworld/hellhound/greater/proc/special_aoe()
	if(world.time < (smoke_lastuse + smoke_freq))
		return
	smoke_lastuse = world.time
	var/datum/effect_system/smoke_spread/sleeping/smoke = new
	smoke.set_up(10, FALSE, loc)
	smoke.start()

/mob/living/basic/netherworld/hellhound/greater/tear
	name = "frenzied hellhound"
	maxHealth = 300
	health = 300
	melee_damage_lower = 30
	melee_damage_upper = 50
