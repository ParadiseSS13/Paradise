/obj/effect/blob/factory
	name = "factory blob"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_factory"
	health = 100
	fire_resist = 2
	var/list/spores = list()
	var/max_spores = 3
	var/spore_delay = 0

	update_icon()
		if(health <= 0)
			playsound(get_turf(src), 'sound/effects/splat.ogg', 50, 1)
			Delete()
			return
		return


	run_action()
		if(spores.len >= max_spores)
			return 0
		if(spore_delay > world.time)
			return 0
		spore_delay = world.time + 100 // 10 seconds
		new/mob/living/simple_animal/hostile/blobspore(src.loc, src)
		return 1


/mob/living/simple_animal/hostile/blobspore
	name = "blob"
	desc = "Some blob thing."
	icon = 'icons/mob/blob.dmi'
	icon_state = "blobpod"
	icon_living = "blobpod"
	pass_flags = PASSBLOB
	health = 40
	maxHealth = 40
	melee_damage_lower = 2
	melee_damage_upper = 4
	attacktext = "hits"
	attack_sound = 'sound/weapons/genhit1.ogg'
	var/obj/effect/blob/factory/factory = null
	var/is_zombie = 0
	faction = list("blob")
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0
	maxbodytemp = 360

	fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
		..()
		adjustBruteLoss(Clamp(0.01 * exposed_temperature, 1, 5))

	blob_act()
		return

	CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
		if(istype(mover, /obj/effect/blob))
			return 1
		return ..()

	New(loc, var/obj/effect/blob/factory/linked_node)
		if(istype(linked_node))
			factory = linked_node
			factory.spores += src
		..()

/mob/living/simple_animal/hostile/blobspore/Life()

	if(!is_zombie && isturf(src.loc))
		for(var/mob/living/carbon/human/H in oview(src,1)) //Only for corpse right next to/on same tile
			if(H.stat == DEAD)
				Zombify(H)
				break
	..()

/mob/living/simple_animal/hostile/blobspore/proc/Zombify(var/mob/living/carbon/human/H)
	is_zombie = 1
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
	H.h_style = null
	H.update_hair()
	overlays = H.overlays
	overlays += image('icons/mob/blob.dmi', icon_state = "blob_head")
	H.loc = src
	loc.visible_message("<span class='warning'> The corpse of [H.name] suddenly rises!</span>")

/mob/living/simple_animal/hostile/blobspore/Die()
	// On death, create a small smoke of harmful gas (s-Acid)
	var/datum/effect/effect/system/chem_smoke_spread/S = new
	var/turf/location = get_turf(src)

	// Create the reagents to put into the air, s-acid is yellow and stings a little
	create_reagents(25)

	reagents.add_reagent("spores", 25)

	// Attach the smoke spreader and setup/start it.
	S.attach(location)
	S.set_up(reagents, 1, 1, location, 15, 1) // only 1-2 smoke cloud
	S.start()

	qdel(src)


/mob/living/simple_animal/hostile/blobspore/Destroy()
	if(factory)
		factory.spores -= src
	if(contents)
		for(var/mob/M in contents)
			M.loc = src.loc
	..()
