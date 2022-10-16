///the perfectly normal raven.
/mob/living/simple_animal/pet/raven
	name = "raven"
	desc = "Quoth the raven nevermore! Just now in space!"
	icon = 'icons/mob/animal.dmi'
	icon_state = "raven"
	icon_living = "raven"
	icon_dead = "raven_dead"
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
	can_hide = TRUE
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat = 2)
	can_collar = TRUE
	gold_core_spawnable = FRIENDLY_SPAWN

/mob/living/simple_animal/pet/raven/nevermore//a unique pet, I consider maybe the  icon states are are redundant?
	name = "Nevermore"
	desc = "The coroner's pet. Reminds us that peace and quiet is coming for us all."
	icon_state = "raven"
	icon_living = "raven"
	icon_dead = "raven_dead"
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE

/mob/living/simple_animal/pet/raven/npc_safe(mob/user)//Makes the raven a playable via the ghost menu.
	return TRUE

/mob/living/simple_animal/pet/raven/verb/perch()//The raven category is established here, as well as the fly and take off button
	set name = "Fly/Take off!"
	set category = "Raven"
	set desc = "Sit on a nice comfy perch."

	if(icon_state == "raven")//Changes the state to the flying animation if the check returns true.
		icon_state = "raven_fly"//a place holder, awaiting the animations, ill need alot of coffee for this part

	else
		icon_state = "raven"

	return
/mob/living/simple_animal/pet/raven/verb/caw()//The raven caw ability button
	set name = "Caw!"
	set category = "Raven"
	set desc = "caws"
	if(wait < world.time) // A wait, to stop people being jerks
		playsound(src.loc, 'sound/creatures/caw.ogg', 50, 1)
		wait = world.time  + 2 SECONDS



