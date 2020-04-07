/mob/living/simple_animal/hostile/tree
	name = "pine tree"
	desc = "A pissed off tree-like alien. It seems annoyed with the festivities..."
	icon = 'icons/obj/flora/pinetrees.dmi'
	icon_state = "pine_1"
	icon_living = "pine_1"
	icon_dead = "pine_1"
	icon_gib = "pine_1"
	speak_chance = 0
	turns_per_move = 5
	response_help = "brushes the"
	response_disarm = "pushes the"
	response_harm = "hits the"
	speed = 1
	maxHealth = 250
	health = 250
	mob_size = MOB_SIZE_LARGE

	pixel_x = -16

	harm_intent_damage = 5
	melee_damage_lower = 8
	melee_damage_upper = 12
	attacktext = "bites"
	attack_sound = 'sound/weapons/bite.ogg'
	speak_emote = list("pines")
	emote_taunt = list("growls")
	taunt_chance = 20

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0

	faction = list("hostile", "winter")
	loot = list(/obj/item/stack/sheet/wood)
	gold_core_spawnable = HOSTILE_SPAWN
	deathmessage = "is hacked into pieces!"
	del_on_death = 1

/mob/living/simple_animal/hostile/tree/AttackingTarget()
	. = ..()
	if(. && iscarbon(target))
		var/mob/living/carbon/C = target
		if(prob(15))
			C.Weaken(3)
			C.visible_message("<span class='danger'>\the [src] knocks down \the [C]!</span>")
