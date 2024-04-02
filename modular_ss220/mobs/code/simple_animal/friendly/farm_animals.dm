/mob/living/simple_animal/hostile/retaliate/goat
	attacktext = "бодает"
	death_sound = 'modular_ss220/mobs/sound/creatures/goat_death.ogg'

/mob/living/simple_animal/cow
	attacktext = "бодает"
	death_sound = 'modular_ss220/mobs/sound/creatures/cow_death.ogg'
	damaged_sound = list('modular_ss220/mobs/sound/creatures/cow_damaged.ogg')
	talk_sound = list('modular_ss220/mobs/sound/creatures/cow_talk1.ogg', 'modular_ss220/mobs/sound/creatures/cow_talk2.ogg')

/mob/living/simple_animal/chicken
	name = "курица"
	desc = "Гордая несушка. Яички должны быть хороши!"
	death_sound = 'modular_ss220/mobs/sound/creatures/chicken_death.ogg'
	damaged_sound = list('modular_ss220/mobs/sound/creatures/chicken_damaged1.ogg', 'modular_ss220/mobs/sound/creatures/chicken_damaged2.ogg')
	talk_sound = list('modular_ss220/mobs/sound/creatures/chicken_talk.ogg')
	holder_type = /obj/item/holder/chicken

/mob/living/simple_animal/chick
	name = "цыпленок"
	desc = "Маленькая прелесть! Но пока что маловата..."
	attacktext = "клюёт"
	death_sound = 'modular_ss220/mobs/sound/creatures/mouse_squeak.ogg'
	holder_type = /obj/item/holder/chick

/mob/living/simple_animal/chick/Life(seconds, times_fired)
	if(amount_grown >= 100 && prob(20))
		var/mob/living/simple_animal/C = new /mob/living/simple_animal/cock(loc)
		if(mind)
			mind.transfer_to(C)
		qdel(src)
	. = ..()

/mob/living/simple_animal/cock
	name = "петух"
	desc = "Гордый и важный вид."
	gender = MALE
	icon = 'modular_ss220/mobs/icons/mob/animal.dmi'
	icon_state = "cock"
	icon_living = "cock"
	icon_dead = "cock_dead"
	speak = list("Cluck!","BWAAAAARK BWAK BWAK BWAK!","Bwaak bwak.")
	speak_emote = list("clucks","croons")
	emote_hear = list("clucks")
	emote_see = list("pecks at the ground","flaps its wings viciously")
	density = 0
	speak_chance = 2
	turns_per_move = 3
	butcher_results = list(/obj/item/food/snacks/meat = 4)
	response_help  = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm   = "kicks the"
	melee_damage_type = STAMINA
	melee_damage_lower = 2
	melee_damage_upper = 6
	attacktext = "клюёт"
	death_sound = 'modular_ss220/mobs/sound/creatures/chicken_death.ogg'
	damaged_sound = list('modular_ss220/mobs/sound/creatures/chicken_damaged1.ogg', 'modular_ss220/mobs/sound/creatures/chicken_damaged2.ogg')
	talk_sound = list('modular_ss220/mobs/sound/creatures/chicken_talk.ogg')
	health = 30
	maxHealth = 30
	ventcrawler = 2
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	can_hide = 1
	can_collar = 1
	gold_core_spawnable = FRIENDLY_SPAWN
	footstep_type = FOOTSTEP_MOB_CLAW
	holder_type = /obj/item/holder/cock

/mob/living/simple_animal/cock/npc_safe(mob/user)
	return TRUE

/mob/living/simple_animal/pig
	name = "свинья"
	attacktext = "лягает"
	death_sound = 'modular_ss220/mobs/sound/creatures/pig_death.ogg'
	talk_sound = list('modular_ss220/mobs/sound/creatures/pig_talk1.ogg', 'modular_ss220/mobs/sound/creatures/pig_talk2.ogg')
	damaged_sound = list()

/mob/living/simple_animal/pig/npc_safe(mob/user)
	return TRUE

/mob/living/simple_animal/turkey
	name = "индюшка"
	desc = "И не благодари."
	death_sound = 'modular_ss220/mobs/sound/creatures/duck_quak1.ogg'


/mob/living/simple_animal/goose
	name = "гусь"
	desc = "Прекрасная птица для набива подушек и страха детишек."
	icon_resting = "goose_rest"
	melee_damage_type = STAMINA
	melee_damage_lower = 2
	melee_damage_upper = 8
	attacktext = "щипает"
	death_sound = 'modular_ss220/mobs/sound/creatures/duck_quak1.ogg'
	talk_sound = list('modular_ss220/mobs/sound/creatures/duck_talk1.ogg', 'modular_ss220/mobs/sound/creatures/duck_talk2.ogg', 'modular_ss220/mobs/sound/creatures/duck_talk3.ogg', 'modular_ss220/mobs/sound/creatures/duck_quak1.ogg', 'modular_ss220/mobs/sound/creatures/duck_quak2.ogg', 'modular_ss220/mobs/sound/creatures/duck_quak3.ogg')
	damaged_sound = list('modular_ss220/mobs/sound/creatures/duck_aggro1.ogg', 'modular_ss220/mobs/sound/creatures/duck_aggro2.ogg')

/mob/living/simple_animal/goose/npc_safe(mob/user)
	return TRUE

/mob/living/simple_animal/goose/gosling
	name = "гусенок"
	desc = "Симпатичный гусенок. Скоро он станей грозой всей станции."
	icon = 'modular_ss220/mobs/icons/mob/animal.dmi'
	icon_state = "gosling"
	icon_living = "gosling"
	icon_dead = "gosling_dead"
	icon_resting = "gosling_rest"
	butcher_results = list(/obj/item/food/snacks/meat = 3)
	melee_damage_lower = 0
	melee_damage_upper = 0
	health = 20
	maxHealth = 20

/mob/living/simple_animal/seal
	death_sound = 'modular_ss220/mobs/sound/creatures/seal_death.ogg'
