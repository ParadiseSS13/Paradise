///the perfectly normal raven.
/mob/living/simple_animal/pet/raven
	name = "raven"
	desc = "Quoth the raven nevermore! Just now in space!"
	icon = 'icons/mob/animal.dmi'
	icon_state = "raven"
	icon_living = "raven"
	icon_dead = "raven_dead"
	icon_resting = "raven"
	speak_emote = list("caws")
	health = 7
	maxHealth = 7
	attacktext = "bites"
	melee_damage_lower = 2
	melee_damage_upper = 2
	response_help  = "pets"
	response_disarm = "shoos"
	response_harm   = "kicks"
	ventcrawler = VENTCRAWLER_ALWAYS
	density = FALSE
	pass_flags = PASSTABLE | PASSMOB
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat = 2)
	gold_core_spawnable = FRIENDLY_SPAWN
	turns_per_move = 5
	///This varible allows you to set a cooldown on an ability, for an example usage reference the raven.dm, last line.
	var/caw_cooldown


/mob/living/simple_animal/pet/raven/npc_safe(mob/user)//Makes the raven a playable via the ghost menu.
	return TRUE
	
//The raven category is established here, as well as the fly and take off button
/mob/living/simple_animal/pet/raven/verb/perch()
	set name = "Fly/Take off!"
	set category = "Raven"
	set desc = "Sit on a nice comfy perch."
	//Changes the state to the flying animation if the check returns true
	if(icon_state == "raven")
		icon_state = "raven_fly"
	else
		icon_state = "raven"
//The raven caw ability button
/mob/living/simple_animal/pet/raven/verb/caw()
	set name = "Caw!"
	set category = "Raven"
	set desc = "caws"
	// A caw_cooldown, to stop people being jerks
	if(caw_cooldown < world.time)
		playsound(loc, 'sound/creatures/caw.ogg', 50, 1)
		caw_cooldown = world.time + 2 SECONDS
