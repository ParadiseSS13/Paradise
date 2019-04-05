
////////////////
// BASE TYPE //
////////////////

//Do not spawn
/mob/living/simple_animal/hostile/blob
	icon = 'icons/mob/blob.dmi'
	pass_flags = PASSBLOB
	faction = list("blob")
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 360
	universal_speak = 1 //So mobs can understand them when a blob uses Blob Broadcast
	sentience_type = SENTIENCE_OTHER
	gold_core_spawnable = CHEM_MOB_SPAWN_INVALID
	var/mob/camera/blob/overmind = null

/mob/living/simple_animal/hostile/blob/proc/adjustcolors(var/a_color)
	if(a_color)
		color = a_color

/mob/living/simple_animal/hostile/blob/blob_act()
	return


////////////////
// BLOB SPORE //
////////////////

/mob/living/simple_animal/hostile/blob/blobspore
	name = "blob"
	desc = "Some blob thing."
	icon_state = "blobpod"
	icon_living = "blobpod"
	health = 40
	maxHealth = 40
	melee_damage_lower = 2
	melee_damage_upper = 4
	obj_damage = 20
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	attacktext = "hits"
	attack_sound = 'sound/weapons/genhit1.ogg'
	speak_emote = list("pulses")
	var/obj/structure/blob/factory/factory = null
	var/list/human_overlays = list()
	var/is_zombie = 0
	pressure_resistance = 100    //100 kPa difference required to push
	throw_pressure_limit = 120  //120 kPa difference required to throw

/mob/living/simple_animal/hostile/blob/blobspore/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	..()
	adjustBruteLoss(Clamp(0.01 * exposed_temperature, 1, 5))


/mob/living/simple_animal/hostile/blob/blobspore/CanPass(atom/movable/mover, turf/target, height=0)
	if(istype(mover, /obj/structure/blob))
		return 1
	return ..()

/mob/living/simple_animal/hostile/blob/blobspore/New(loc, var/obj/structure/blob/factory/linked_node)
	if(istype(linked_node))
		factory = linked_node
		factory.spores += src
	..()

/mob/living/simple_animal/hostile/blob/blobspore/Life(seconds, times_fired)

	if(!is_zombie && isturf(src.loc))
		for(var/mob/living/carbon/human/H in oview(src, 1)) //Only for corpse right next to/on same tile
			if(H.stat == DEAD || (!H.check_death_method() && H.health <= HEALTH_THRESHOLD_DEAD))
				Zombify(H)
				break
	..()

/mob/living/simple_animal/hostile/blob/blobspore/proc/Zombify(mob/living/carbon/human/H)
	if(!H.check_death_method())
		H.death()
	var/obj/item/organ/external/head/head_organ = H.get_organ("head")
	is_zombie = TRUE
	if(H.wear_suit)
		var/obj/item/clothing/suit/armor/A = H.wear_suit
		if(A.armor && A.armor["melee"])
			maxHealth += A.armor["melee"] //That zombie's got armor, I want armor!
	maxHealth += 40
	health = maxHealth
	name = "blob zombie"
	desc = "A shambling corpse animated by the blob."
	melee_damage_lower = 10
	melee_damage_upper = 15
	icon = H.icon
	speak_emote = list("groans")
	icon_state = "zombie2_s"
	if(head_organ)
		head_organ.h_style = null
	H.update_hair()
	human_overlays = H.overlays
	update_icons()
	H.forceMove(src)
	pressure_resistance = 20  //5 kPa difference required to push lowered
	throw_pressure_limit = 30  //15 kPa difference required to throw lowered
	visible_message("<span class='warning'>The corpse of [H.name] suddenly rises!</span>")

/mob/living/simple_animal/hostile/blob/blobspore/death(gibbed)
	// Only execute the below if we successfuly died
	. = ..()
	if(!.)
		return FALSE
	// On death, create a small smoke of harmful gas (s-Acid)
	var/datum/effect_system/smoke_spread/chem/S = new
	var/turf/location = get_turf(src)

	// Create the reagents to put into the air
	create_reagents(8)

	if(overmind && overmind.blob_reagent_datum)
		reagents.add_reagent(overmind.blob_reagent_datum.id, 8)
	else
		reagents.add_reagent("spore", 8)

	// Setup up the smoke spreader and start it.
	S.set_up(reagents, location, TRUE)
	S.start()
	qdel(src)

/mob/living/simple_animal/hostile/blob/blobspore/Destroy()
	if(factory)
		factory.spores -= src
	factory = null
	if(contents)
		for(var/mob/M in contents)
			M.loc = get_turf(src)
	return ..()


/mob/living/simple_animal/hostile/blob/blobspore/update_icons()
	..()

	if(overmind && overmind.blob_reagent_datum)
		adjustcolors(overmind.blob_reagent_datum.complementary_color)
	else
		adjustcolors(overmind.blob_reagent_datum.complementary_color) //to ensure zombie/other overlays update


/mob/living/simple_animal/hostile/blob/blobspore/adjustcolors(var/a_color)
	color = a_color

	if(is_zombie)
		overlays.Cut()
		overlays = human_overlays
		var/image/I = image('icons/mob/blob.dmi', icon_state = "blob_head")
		I.color = overmind.blob_reagent_datum.complementary_color
		color = initial(overmind.blob_reagent_datum.complementary_color)//looks better.
		overlays += I

/////////////////
// BLOBBERNAUT //
/////////////////

/mob/living/simple_animal/hostile/blob/blobbernaut
	name = "blobbernaut"
	desc = "Some HUGE blob thing."
	icon_state = "blobbernaut"
	icon_living = "blobbernaut"
	icon_dead = "blobbernaut_dead"
	health = 240
	maxHealth = 240
	melee_damage_lower = 20
	melee_damage_upper = 20
	obj_damage = 60
	attacktext = "hits"
	attack_sound = 'sound/effects/blobattack.ogg'
	speak_emote = list("gurgles")
	minbodytemp = 0
	maxbodytemp = 360
	force_threshold = 10
	mob_size = MOB_SIZE_LARGE
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	pressure_resistance = 100    //100 kPa difference required to push
	throw_pressure_limit = 120  //120 kPa difference required to throw


/mob/living/simple_animal/hostile/blob/blobbernaut/blob_act()
	return

/mob/living/simple_animal/hostile/blob/blobbernaut/death(gibbed)
	// Only execute the below if we successfully died
	. = ..()
	if(!.)
		return FALSE
	flick("blobbernaut_death", src)
