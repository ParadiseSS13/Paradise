///Anomolous Crystal///

/obj/machinery/anomalous_crystal
	name = "anomalous crystal"
	desc = "A strange chunk of crystal, being in the presence of it fills you with equal parts excitement and dread."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "anomaly_crystal"
	light_range = 8
	power_state = NO_POWER_USE
	density = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/activation_method = "touch"
	var/activation_damage_type = null
	var/last_use_timer = 0
	var/cooldown_add = 30
	var/list/affected_targets = list()
	var/activation_sound = 'sound/effects/break_stone.ogg'

/obj/machinery/anomalous_crystal/Initialize(mapload)
	. = ..()
	activation_method = pick("touch","laser","bullet","energy","bomb","mob_bump","weapon","speech") // "heat" removed due to lack of is_hot()


/obj/machinery/anomalous_crystal/hear_talk(mob/speaker, list/message_pieces)
	..()
	if(isliving(speaker) && LAZYLEN(message_pieces))
		ActivationReaction(speaker, "speech")

/obj/machinery/anomalous_crystal/attack_hand(mob/user)
	..()
	ActivationReaction(user,"touch")

/obj/machinery/anomalous_crystal/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	ActivationReaction(user, "weapon")
	return ..()

/obj/machinery/anomalous_crystal/bullet_act(obj/item/projectile/P, def_zone)
	..()
	if(istype(P, /obj/item/projectile/magic))
		ActivationReaction(P.firer, "magic", P.damage_type)
		return
	ActivationReaction(P.firer, P.flag, P.damage_type)

/obj/machinery/anomalous_crystal/proc/ActivationReaction(mob/user, method, damtype)
	if(world.time < last_use_timer)
		return 0
	if(activation_damage_type && activation_damage_type != damtype)
		return 0
	if(method != activation_method)
		return 0
	last_use_timer = (world.time + cooldown_add)
	playsound(user, activation_sound, 100, 1)
	return 1

/obj/machinery/anomalous_crystal/Bumped(atom/AM as mob|obj)
	..()
	if(ismob(AM))
		ActivationReaction(AM,"mob_bump")

/obj/machinery/anomalous_crystal/ex_act()
	ActivationReaction(null,"bomb")

/obj/machinery/anomalous_crystal/random/Initialize(mapload) //Just a random crysal spawner for loot
	. = ..()
	var/random_crystal = pick(typesof(/obj/machinery/anomalous_crystal) - /obj/machinery/anomalous_crystal/random - /obj/machinery/anomalous_crystal)
	new random_crystal(loc)
	return INITIALIZE_HINT_QDEL

/// Warps the area you're in to look like a new one
/obj/machinery/anomalous_crystal/theme_warp
	cooldown_add = 200
	var/terrain_theme = "winter"
	var/NewTerrainFloors
	var/NewTerrainWalls
	var/NewTerrainChairs
	var/NewTerrainTables
	var/list/NewFlora = list()
	var/florachance = 8

/obj/machinery/anomalous_crystal/theme_warp/Initialize(mapload)
	. = ..()
	terrain_theme = pick("lavaland","winter","jungle","alien")
	switch(terrain_theme)
		if("lavaland")//Free cult metal, I guess.
			NewTerrainFloors = /turf/simulated/floor/plating/false_asteroid
			NewTerrainWalls = /turf/simulated/wall/cult
			NewFlora = list(/mob/living/basic/mining/goldgrub)
			florachance = 1
		if("winter") //Snow terrain is slow to move in and cold! Get the assistants to shovel your driveway.
			NewTerrainFloors = /turf/simulated/floor/snow // Needs to be updated after turf update
			NewTerrainWalls = /turf/simulated/wall/mineral/wood
			NewTerrainChairs = /obj/structure/chair/wood
			NewTerrainTables = /obj/structure/table/glass
			NewFlora = list(/obj/structure/flora/grass/green, /obj/structure/flora/grass/brown, /obj/structure/flora/grass/both)
		if("jungle") //Beneficial due to actually having breathable air. Plus, monkeys and bows and arrows.
			NewTerrainFloors = /turf/simulated/floor/grass
			NewTerrainWalls = /turf/simulated/wall/mineral/sandstone
			NewTerrainChairs = /obj/structure/chair/wood
			NewTerrainTables = /obj/structure/table/wood
			NewFlora = list(/obj/structure/flora/ausbushes/sparsegrass, /obj/structure/flora/ausbushes/fernybush, /obj/structure/flora/ausbushes/leafybush,
							/obj/structure/flora/ausbushes/grassybush, /obj/structure/flora/ausbushes/sunnybush, /obj/structure/flora/tree/palm, /mob/living/carbon/human/monkey,
							/obj/item/gun/projectile/bow, /obj/item/storage/backpack/quiver/full)
			florachance = 20
		if("alien") //Beneficial, turns stuff into alien alloy which is useful to cargo and research. Also repairs atmos.
			NewTerrainFloors = /turf/simulated/floor/mineral/abductor
			NewTerrainWalls = /turf/simulated/wall/mineral/abductor
			NewTerrainChairs = /obj/structure/bed/abductor //ayys apparently don't have chairs. An entire species of people who only recline.
			NewTerrainTables = /obj/structure/table/abductor

/obj/machinery/anomalous_crystal/theme_warp/ActivationReaction(mob/user, method)
	if(..())
		var/area/A = get_area(src)
		if(!A.outdoors && !(A in affected_targets))
			for(var/atom/Stuff in A)
				if(isturf(Stuff))
					var/turf/T = Stuff
					if((isspaceturf(T) || isfloorturf(T)) && NewTerrainFloors)
						var/turf/simulated/O = T.ChangeTurf(NewTerrainFloors, keep_icon = FALSE)
						if(prob(florachance) && length(NewFlora) && !O.is_blocked_turf())
							var/atom/Picked = pick(NewFlora)
							new Picked(O)
						continue
					if(iswallturf(T) && NewTerrainWalls && !istype(T, /turf/simulated/wall/indestructible))
						T.ChangeTurf(NewTerrainWalls, keep_icon = FALSE)
						continue
				if(istype(Stuff, /obj/structure/chair) && NewTerrainChairs)
					var/obj/structure/chair/Original = Stuff
					var/obj/structure/chair/C = new NewTerrainChairs(Original.loc)
					C.dir = Original.dir
					qdel(Stuff)
					continue
				if(istype(Stuff, /obj/structure/table) && NewTerrainTables)
					var/obj/structure/table/Original = Stuff
					var/obj/structure/table/T = new NewTerrainTables(Original.loc)
					T.dir = Original.dir
					qdel(Stuff)
					continue
			affected_targets += A

/// Generates a projectile when interacted with
/obj/machinery/anomalous_crystal/emitter
	cooldown_add = 50
	var/generated_projectile = /obj/item/projectile/beam/emitter

/obj/machinery/anomalous_crystal/emitter/Initialize(mapload)
	. = ..()
	generated_projectile = pick(/obj/item/projectile/magic/fireball/infernal,
								/obj/item/projectile/bullet/meteorshot, /obj/item/projectile/beam/xray, /obj/item/projectile/colossus)

/obj/machinery/anomalous_crystal/emitter/ActivationReaction(mob/user, method)
	if(..())
		var/obj/item/projectile/P = new generated_projectile(get_turf(src))
		P.dir = dir
		switch(dir)
			if(NORTH)
				P.yo = 20
				P.xo = 0
			if(EAST)
				P.yo = 0
				P.xo = 20
			if(WEST)
				P.yo = 0
				P.xo = -20
			else
				P.yo = -20
				P.xo = 0
		P.fire()

/// Revives anyone nearby, but turns them into shadowpeople and renders them uncloneable, so the crystal is your only hope of getting up again if you go down.
/obj/machinery/anomalous_crystal/dark_reprise
	activation_sound = 'sound/hallucinations/growl1.ogg'

/obj/machinery/anomalous_crystal/dark_reprise/ActivationReaction(mob/user, method)
	if(..())
		for(var/i in range(1, src))
			if(isturf(i))
				new /obj/effect/temp_visual/cult/sparks(i)
				continue
			if(ishuman(i))
				var/mob/living/carbon/human/H = i
				if(H.stat == DEAD)
					H.set_species(/datum/species/shadow)
					H.revive()
					ADD_TRAIT(H, TRAIT_BADDNA, MAGIC_TRAIT) //Free revives, but significantly limits your options for reviving except via the crystal
					H.grab_ghost(force = TRUE)

/// Lets ghost spawn as helpful creatures that can only heal people slightly. Incredibly fragile and they can't converse with humans
/obj/machinery/anomalous_crystal/helpers
	var/ready_to_deploy = 0

/obj/machinery/anomalous_crystal/helpers/ActivationReaction(mob/user, method)
	if(..() && !ready_to_deploy)
		ready_to_deploy = 1
		notify_ghosts("An anomalous crystal has been activated in [get_area(src)]! This crystal can always be used by ghosts hereafter.", enter_link = "<a href=byond://?src=[UID()];ghostjoin=1>(Click to enter)</a>", source = src, action = NOTIFY_ATTACK)
		GLOB.poi_list |= src // ghosts should actually know they can join as a lightgeist

/obj/machinery/anomalous_crystal/helpers/attack_ghost(mob/dead/observer/user)
	..()
	if(ready_to_deploy)
		if(!istype(user)) // No revs allowed
			return
		if(!user.check_ahud_rejoin_eligibility())
			to_chat(user, "<span class='warning'>Upon using the antagHUD you forfeited the ability to join the round.</span>")
			return
		var/be_helper = tgui_alert(user, "Become a Lightgeist? (Warning, You can no longer be cloned!)", "Respawn", list("Yes","No"))
		if(be_helper != "Yes")
			return
		if(!loc || QDELETED(src) || QDELETED(user))
			if(user)
				to_chat(user, "<span class='warning'>[src] is no longer usable!</span>")
			return
		var/mob/living/basic/lightgeist/W = new /mob/living/basic/lightgeist(get_turf(loc))
		W.key = user.key

/obj/machinery/anomalous_crystal/helpers/Topic(href, href_list)
	if(href_list["ghostjoin"])
		var/mob/dead/observer/ghost = usr
		if(istype(ghost))
			attack_ghost(ghost)

/obj/machinery/anomalous_crystal/helpers/Destroy()
	GLOB.poi_list -= src
	return ..()

/// Allows you to bodyjack small animals, then exit them at your leisure, but you can only do this once per activation. Because they blow up. Also, if the bodyjacked animal dies, SO DO YOU.
/obj/machinery/anomalous_crystal/possessor

/obj/machinery/anomalous_crystal/possessor/ActivationReaction(mob/user, method)
	if(..())
		if(ishuman(user))
			var/mobcheck = 0
			for(var/mob/living/simple_animal/A in range(1, src))
				if(A.melee_damage_upper > 5 || A.mob_size >= MOB_SIZE_LARGE || A.ckey || A.stat || isbot(A))
					break
				var/obj/structure/closet/stasis/S = new /obj/structure/closet/stasis(A)
				user.forceMove(S)
				mobcheck = 1
				break
			if(!mobcheck)
				new /mob/living/basic/mouse(get_step(src,dir)) //Just in case there aren't any animals on the station, this will leave you with a terrible option to possess if you feel like it

/obj/structure/closet/stasis
	name = "quantum entanglement stasis warp field"
	desc = "You can hardly comprehend this thing... which is why you can't see it."
	icon_state = null //This shouldn't even be visible, so if it DOES show up, at least nobody will notice
	anchored = TRUE
	resistance_flags = FIRE_PROOF | ACID_PROOF | INDESTRUCTIBLE
	var/mob/living/simple_animal/holder_animal

/obj/structure/closet/stasis/process()
	if(holder_animal)
		if(holder_animal.stat == DEAD && !QDELETED(holder_animal))
			dump_contents()
			holder_animal.gib()
			return

/obj/structure/closet/stasis/Initialize(mapload)
	. = ..()
	if(isanimal(loc))
		holder_animal = loc
	START_PROCESSING(SSobj, src)

/obj/structure/closet/stasis/Entered(atom/A)
	if(isliving(A) && holder_animal)
		var/mob/living/L = A
		L.notransform = TRUE
		ADD_TRAIT(L, TRAIT_MUTE, STASIS_MUTE)
		L.status_flags |= GODMODE
		L.mind.transfer_to(holder_animal)
		var/datum/spell/exit_possession/P = new /datum/spell/exit_possession
		holder_animal.mind.AddSpell(P)
		remove_verb(holder_animal, /mob/living/verb/pulled)

/obj/structure/closet/stasis/dump_contents(kill = 1)
	STOP_PROCESSING(SSobj, src)
	for(var/mob/living/L in src)
		REMOVE_TRAIT(L, TRAIT_MUTE, STASIS_MUTE)
		L.status_flags &= ~GODMODE
		L.notransform = FALSE
		if(holder_animal && !QDELETED(holder_animal))
			holder_animal.mind.transfer_to(L)
			L.mind.RemoveSpell(/datum/spell/exit_possession)
		if(kill || !isanimal(loc))
			L.death(0)
	..()

/obj/structure/closet/stasis/emp_act()
	return

/obj/structure/closet/stasis/ex_act()
	return

/datum/spell/exit_possession
	name = "Exit Possession"
	desc = "Exits the body you are possessing."
	base_cooldown = 60
	clothes_req = FALSE
	action_icon_state = "exit_possession"
	sound = null

/datum/spell/exit_possession/create_new_targeting()
	return new /datum/spell_targeting/self

/datum/spell/exit_possession/cast(list/targets, mob/user = usr)
	if(!isfloorturf(user.loc))
		return
	var/datum/mind/target_mind = user.mind
	var/mob/living/current = user // Saving the current mob here to gib as usr seems to get confused after the mind's been transferred, due to delay in transfer_to
	for(var/i in user)
		if(istype(i, /obj/structure/closet/stasis))
			var/obj/structure/closet/stasis/S = i
			S.dump_contents(0)
			qdel(S)
			break
	current.gib()
	target_mind.RemoveSpell(/datum/spell/exit_possession)
