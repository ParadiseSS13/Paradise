/mob/living/simple_animal
	response_help   = "тычет"
	response_disarm = "толкает"
	response_harm   = "пихает"
	attacktext = "атакует"
	attack_sound = null
	friendly = "утыкается в" //If the mob does no damage with it's attack
	var/list/damaged_sound = null // The sound played when player hits animal
	var/list/talk_sound = null // The sound played when talk


/mob/living/simple_animal/say(message, verb, sanitize, ignore_speech_problems, ignore_atmospherics)
	. = ..()
	if(. && length(src.talk_sound))
		playsound(src, pick(src.talk_sound), 75, TRUE)

/mob/living/simple_animal/attacked_by(obj/item/I, mob/living/user)
	. = ..()
	if(. && length(src.damaged_sound) && src.stat != DEAD)
		playsound(src, pick(src.damaged_sound), 40, 1)

/mob/living/simple_animal/attack_hand(mob/living/carbon/human/M)
	. = ..()
	if(. && length(src.damaged_sound) && src.stat != DEAD)
		playsound(src, pick(src.damaged_sound), 40, 1)

/mob/living/simple_animal/attack_animal(mob/living/simple_animal/M)
	. = ..()
	if(. && length(src.damaged_sound) && src.stat != DEAD)
		playsound(src, pick(src.damaged_sound), 40, 1)

/mob/living/simple_animal/attack_alien(mob/living/carbon/alien/humanoid/M)
	. = ..()
	if(. && length(src.damaged_sound) && src.stat != DEAD)
		playsound(src, pick(src.damaged_sound), 40, 1)

/mob/living/simple_animal/attack_larva(mob/living/carbon/alien/larva/L)
	. = ..()
	if(. && length(src.damaged_sound) && src.stat != DEAD)
		playsound(src, pick(src.damaged_sound), 40, 1)

/mob/living/simple_animal/attack_slime(mob/living/simple_animal/slime/M)
	. = ..()
	if(. && length(src.damaged_sound) && src.stat != DEAD)
		playsound(src, pick(src.damaged_sound), 40, 1)

/mob/living/simple_animal/attack_robot(mob/living/user)
	. = ..()
	if(. && length(src.damaged_sound) && src.stat != DEAD)
		playsound(src, pick(src.damaged_sound), 40, 1)


// Simple animal procs
/mob/living/simple_animal/start_pulling(atom/movable/AM, state, force = pull_force, show_message = FALSE)
	if(pull_constraint(AM, show_message))
		return ..()

/mob/living/simple_animal/proc/pull_constraint(atom/movable/AM, show_message = FALSE)
	return TRUE


// Animals additions

/* Megafauna */
/mob/living/simple_animal/hostile/megafauna/legion
	death_sound = 'modular_ss220/mobs/sound/creatures/legion_death.ogg'

/mob/living/simple_animal/hostile/megafauna/legion/death(gibbed)
	for(var/area/lavaland/L in world)
		SEND_SOUND(L, sound('modular_ss220/mobs/sound/creatures/legion_death_far.ogg'))
	. = ..()

/* Nar Sie */
/obj/singularity/narsie/large/Destroy()
	SEND_SOUND(world, sound('modular_ss220/mobs/sound/creatures/narsie_rises.ogg'))
	. = ..()


/* Loot Drops */
/obj/effect/spawner/lootdrop/bluespace_tap/organic/Initialize(mapload)
	. = ..()
	LAZYADD(loot, list(
		//mob/living/simple_animal/pet/dog/corgi = 5,

		/mob/living/simple_animal/pet/dog/brittany = 2,
		/mob/living/simple_animal/pet/dog/german = 2,
		/mob/living/simple_animal/pet/dog/tamaskan = 2,
		/mob/living/simple_animal/pet/dog/bullterrier = 2,

		//mob/living/simple_animal/pet/cat = 5,

		/mob/living/simple_animal/pet/cat/cak = 2,
		/mob/living/simple_animal/pet/cat/fat = 2,
		/mob/living/simple_animal/pet/cat/white = 2,
		/mob/living/simple_animal/pet/cat/birman = 2,
		/mob/living/simple_animal/pet/cat/spacecat = 2,

		//mob/living/simple_animal/pet/dog/fox = 5,

		/mob/living/simple_animal/pet/dog/fox/forest = 2,
		/mob/living/simple_animal/pet/dog/fox/fennec = 2,
		/mob/living/simple_animal/possum = 2,

		/mob/living/simple_animal/pet/penguin = 5,
		//mob/living/simple_animal/pig = 5,
		))
