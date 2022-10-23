
////////////////
// BASE TYPE //
////////////////

//Do not spawn
/mob/living/simple_animal/hostile/blob
	icon = 'icons/mob/blob.dmi'
	pass_flags = PASSBLOB
	status_flags = NONE //No throwing blobspores into deep space to despawn, or throwing blobbernaughts, which are bigger than you.
	faction = list(ROLE_BLOB)
	bubble_icon = "blob"
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 360
	universal_speak = TRUE //So mobs can understand them when a blob uses Blob Broadcast
	sentience_type = SENTIENCE_OTHER
	gold_core_spawnable = NO_SPAWN
	can_be_on_fire = TRUE
	fire_damage = 3
	var/mob/camera/blob/overmind = null

/mob/living/simple_animal/hostile/blob/proc/adjustcolors(a_color)
	if(a_color)
		color = a_color

/mob/living/simple_animal/hostile/blob/blob_act()
	if(stat != DEAD && health < maxHealth)
		for(var/i in 1 to 2)
			var/obj/effect/temp_visual/heal/H = new /obj/effect/temp_visual/heal(get_turf(src)) //hello yes you are being healed
			if(overmind)
				H.color = overmind.blob_reagent_datum.complementary_color
				if(H.color == COMPLEMENTARY_COLOR_RIPPING_TENDRILS) //the colour define for ripping tendrils
					H.color = COLOR_HEALING_GREEN //bye red cross
			else
				H.color = COLOR_BLACK
		adjustHealth(-maxHealth * 0.0125)

/mob/living/simple_animal/hostile/blob/Process_Spacemove(movement_dir = 0)
	// Use any nearby blob structures to allow space moves.
	for(var/obj/structure/blob/B in range(1, src))
		return TRUE
	return ..()

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
	flying = TRUE
	speak_emote = list("pulses")
	var/obj/structure/blob/factory/factory = null
	var/list/human_overlays = list()
	var/mob/living/carbon/human/oldguy
	var/is_zombie = FALSE

/mob/living/simple_animal/hostile/blob/blobspore/CanPass(atom/movable/mover, turf/target, height=0)
	if(istype(mover, /obj/structure/blob))
		return 1
	return ..()

/mob/living/simple_animal/hostile/blob/blobspore/Initialize(mapload, obj/structure/blob/factory/linked_node)
	. = ..()
	if(istype(linked_node))
		factory = linked_node
		factory.spores += src

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
		if(A.armor && A.armor.getRating(MELEE))
			maxHealth += A.armor.getRating(MELEE) //That zombie's got armor, I want armor!
	maxHealth += 40
	health = maxHealth
	name = "blob zombie"
	desc = "A shambling corpse animated by the blob."
	mob_biotypes |= MOB_HUMANOID
	melee_damage_lower = 10
	melee_damage_upper = 15
	icon = H.icon
	speak_emote = list("groans")
	icon_state = "zombie2_s"
	if(head_organ && !(NO_HAIR in H.dna.species.species_traits))
		head_organ.h_style = null
	H.update_hair()
	human_overlays = H.overlays
	update_icons()
	H.forceMove(src)
	oldguy = H
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
	if(oldguy)
		oldguy.forceMove(get_turf(src))
		oldguy = null
	return ..()


/mob/living/simple_animal/hostile/blob/blobspore/update_icons()
	..()

	adjustcolors(overmind?.blob_reagent_datum?.complementary_color)

/mob/living/simple_animal/hostile/blob/blobspore/adjustcolors(a_color)
	color = a_color

	if(is_zombie)
		overlays.Cut()
		overlays = human_overlays
		var/image/I = image('icons/mob/blob.dmi', icon_state = "blob_head")
		I.color = color
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
	health = 200
	maxHealth = 200
	melee_damage_lower = 10
	melee_damage_upper = 15
	obj_damage = 60
	attacktext = "hits"
	attack_sound = 'sound/effects/blobattack.ogg'
	speak_emote = list("gurgles")
	minbodytemp = 0
	maxbodytemp = 360
	force_threshold = 10
	mob_size = MOB_SIZE_LARGE
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	pressure_resistance = 50
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	move_resist = MOVE_FORCE_OVERPOWERING
	a_intent = INTENT_HARM

/mob/living/simple_animal/hostile/blob/blobbernaut/Life(seconds, times_fired)
	if(stat != DEAD && (getBruteLoss() || getFireLoss())) // Heal on blob structures
		if(locate(/obj/structure/blob) in get_turf(src))
			adjustBruteLoss(-0.25)
			adjustFireLoss(-0.25)
			if(on_fire)
				adjust_fire_stacks(-1)	// Slowly extinguish the flames
		else
			adjustBruteLoss(0.2) // If you are at full health, you won't lose health. You'll need it. However the moment anybody sneezes on you, the decaying will begin.
			adjustFireLoss(0.2)
	..()

/mob/living/simple_animal/hostile/blob/blobbernaut/Initialize(mapload)
	. = ..()
	if(name == "blobbernaut")
		name = text("blobbernaut ([rand(1, 1000)])")

/mob/living/simple_animal/hostile/blob/blobbernaut/death(gibbed)
	// Only execute the below if we successfully died
	. = ..()
	if(!.)
		return FALSE
	flick("blobbernaut_death", src)

/mob/living/simple_animal/hostile/blob/blobbernaut/verb/communicate_overmind()
	set category = "Blobbernaut"
	set name = "Blob Telepathy"
	set desc = "Send a message to the Overmind"

	if(stat != DEAD)
		blob_talk()

/mob/living/simple_animal/hostile/blob/blobbernaut/proc/blob_talk()
	var/message = input(src, "Announce to the overmind", "Blob Telepathy")
	var/rendered
	var/follow_text
	if(message)
		for(var/mob/M in GLOB.mob_list)
			follow_text = isobserver(M) ? " ([ghost_follow_link(src, ghost = M)])" : ""
			rendered = "<font color=\"#EE4000\"><i><span class='game say'>Blob Telepathy, <span class='name'>[name]([overmind])</span>[follow_text] <span class='message'>states, \"[message]\"</span></span></i></font>"
			if(isovermind(M) || isobserver(M) || istype(M, /mob/living/simple_animal/hostile/blob/blobbernaut))
				M.show_message(rendered, EMOTE_AUDIBLE)
