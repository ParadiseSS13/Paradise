/mob/living/basic/hellhound
	// Sprites by FoS: https://www.paradisestation.org/forum/profile/335-fos
	name = "lesser hellhound"
	desc = "A demonic-looking black canine monster with glowing red eyes and sharp teeth. A firey, lava-like substance drips from it."
	icon_state = "hellhound"
	icon_living = "hellhound"
	icon_dead = "hellhound_dead"
	icon_resting = "hellhound_rest"
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	melee_damage_lower = 10 // slightly higher than araneus
	melee_damage_upper = 30
	melee_attack_cooldown_min = 1.5 SECONDS
	melee_attack_cooldown_max = 2.5 SECONDS
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
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
	ai_controller = /datum/ai_controller/basic_controller/simple/hellhound
	step_type = FOOTSTEP_MOB_CLAW
	faction = list("nether")
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, STAM = 0, OXY = 1)
	gold_core_spawnable = HOSTILE_SPAWN
	contains_xeno_organ = TRUE
	surgery_container = /datum/xenobiology_surgery_container/hound
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

/mob/living/basic/hellhound/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ai_retaliate)

/mob/living/basic/hellhound/examine(mob/user)
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

/mob/living/basic/hellhound/Move(atom/newloc, direct, glide_size_override, update_dir)
	. = ..()
	if(IS_HORIZONTAL(src))
		stand_up()

/mob/living/basic/hellhound/Life(seconds, times_fired)
	. = ..()
	if(stat != DEAD && (getBruteLoss() || getFireLoss()))
		if(IS_HORIZONTAL(src))
			if(life_regen_cycles >= life_regen_cycle_trigger)
				life_regen_cycles = 0
				to_chat(src, "<span class='notice'>You lick your wounds, helping them close.</span>")
				adjustBruteLoss(life_regen_amount)
				adjustFireLoss(life_regen_amount)
			else
				life_regen_cycles++
	if(ai_controller.blackboard_key_exists(BB_BASIC_MOB_CURRENT_TARGET))
		stand_up()

/mob/living/basic/hellhound/apply_damage(damage, damagetype, def_zone, blocked, sharp, used_weapon, spread_damage)
	. = ..()
	if(stat != DEAD && IS_HORIZONTAL(src))
		stand_up()

/mob/living/basic/hellhound/greater
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
	gold_core_spawnable = NO_SPAWN

/mob/living/basic/hellhound/greater/Initialize(mapload)
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
	summonspell.summon_type = list(/mob/living/basic/hellhound)
	summonspell.summon_amt = 1
	AddSpell(summonspell)

/mob/living/basic/hellhound/greater/melee_attack(atom/target, list/modifiers, ignore_cooldown)
	. = ..()
	if(. && ishuman(target) && (!client || a_intent == INTENT_HARM))
		special_aoe()

/mob/living/basic/hellhound/greater/proc/special_aoe()
	if(world.time < (smoke_lastuse + smoke_freq))
		return
	smoke_lastuse = world.time
	var/datum/effect_system/smoke_spread/sleeping/smoke = new
	smoke.set_up(10, FALSE, loc)
	smoke.start()

/mob/living/basic/hellhound/tear
	name = "frenzied hellhound"
	maxHealth = 300
	health = 300
	melee_damage_lower = 30
	melee_damage_upper = 50
	gold_core_spawnable = NO_SPAWN
