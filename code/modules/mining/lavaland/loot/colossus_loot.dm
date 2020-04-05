//Colossus
/obj/structure/closet/crate/necropolis/colossus
	name = "colossus chest"

/obj/structure/closet/crate/necropolis/colossus/New()
	..()
	var/list/choices = subtypesof(/obj/machinery/anomalous_crystal)
	var/random_crystal = pick(choices)
	new random_crystal(src)
	new /obj/item/organ/internal/vocal_cords/colossus(src)

/obj/structure/closet/crate/necropolis/colossus/crusher
	name = "angelic colossus chest"

/obj/structure/closet/crate/necropolis/colossus/crusher/New()
	..()
	new /obj/item/crusher_trophy/blaster_tubes(src)


//Black Box

/obj/machinery/smartfridge/black_box
	name = "black box"
	desc = "A completely indestructible chunk of crystal, rumoured to predate the start of this universe. It looks like you could store things inside it."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "blackbox"
	luminosity = 8
	max_n_of_items = INFINITY
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	pixel_y = -4
	use_power = NO_POWER_USE
	var/memory_saved = FALSE
	var/list/stored_items = list()
	var/static/list/blacklist = typecacheof(list(/obj/item/spellbook))

/obj/machinery/smartfridge/black_box/update_icon()
	return

/obj/machinery/smartfridge/black_box/accept_check(obj/item/O)
	if(!istype(O))
		return FALSE
	if(is_type_in_typecache(O, blacklist))
		return FALSE
	return TRUE

/obj/machinery/smartfridge/black_box/New()
	var/static/obj/machinery/smartfridge/black_box/current
	if(current && current != src)
		qdel(src, force=TRUE)
		return
	current = src
	ReadMemory()
	. = ..()

/obj/machinery/smartfridge/black_box/process()
	..()
	if(!memory_saved && SSticker.current_state == GAME_STATE_FINISHED)
		WriteMemory()

/obj/machinery/smartfridge/black_box/proc/WriteMemory()
	var/savefile/S = new /savefile("data/npc_saves/Blackbox.sav")
	stored_items = list()

	for(var/obj/O in (contents-component_parts))
		stored_items += O.type

	S["stored_items"]				<< stored_items
	memory_saved = TRUE

/obj/machinery/smartfridge/black_box/proc/ReadMemory()
	var/savefile/S = new /savefile("data/npc_saves/Blackbox.sav")
	S["stored_items"] 		>> stored_items

	if(isnull(stored_items))
		stored_items = list()

	for(var/item in stored_items)
		create_item(item)

//in it's own proc to avoid issues with items that nolonger exist in the code base.
//try catch doesn't always prevent byond runtimes from halting a proc,
/obj/machinery/smartfridge/black_box/proc/create_item(item_type)
	new item_type(src)

/obj/machinery/smartfridge/black_box/Destroy(force = FALSE)
	if(force)
		for(var/thing in src)
			qdel(thing)
		return ..()
	else
		return QDEL_HINT_LETMELIVE


//No taking it apart

/obj/machinery/smartfridge/black_box/default_deconstruction_screwdriver()
	return

/obj/machinery/smartfridge/black_box/exchange_parts()
	return

/obj/machinery/smartfridge/black_box/default_unfasten_wrench()
	return

/obj/machinery/smartfridge/black_box/default_deconstruction_crowbar()
	return

///Anomolous Crystal///

/obj/machinery/anomalous_crystal
	name = "anomalous crystal"
	desc = "A strange chunk of crystal, being in the presence of it fills you with equal parts excitement and dread."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "anomaly_crystal"
	light_range = 8
	use_power = NO_POWER_USE
	density = 1
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/activation_method = "touch"
	var/activation_damage_type = null
	var/last_use_timer = 0
	var/cooldown_add = 30
	var/list/affected_targets = list()
	var/activation_sound = 'sound/effects/break_stone.ogg'

/obj/machinery/anomalous_crystal/New()
	activation_method = pick("touch","laser","bullet","energy","bomb","mob_bump","weapon","speech") // "heat" removed due to lack of is_hot()
	..()

/obj/machinery/anomalous_crystal/hear_talk(mob/speaker, list/message_pieces)
	..()
	if(isliving(speaker) && LAZYLEN(message_pieces))
		ActivationReaction(speaker, "speech")

/obj/machinery/anomalous_crystal/attack_hand(mob/user)
	..()
	ActivationReaction(user,"touch")

/obj/machinery/anomalous_crystal/attackby(obj/item/I, mob/user, params)
	ActivationReaction(user,"weapon")
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

/obj/machinery/anomalous_crystal/random/New()//Just a random crysal spawner for loot
	var/random_crystal = pick(typesof(/obj/machinery/anomalous_crystal) - /obj/machinery/anomalous_crystal/random - /obj/machinery/anomalous_crystal)
	new random_crystal(loc)
	qdel(src)

/obj/machinery/anomalous_crystal/honk //Strips and equips you as a clown. I apologize for nothing
	activation_method = "mob_bump"
	activation_sound = 'sound/items/bikehorn.ogg'

/obj/machinery/anomalous_crystal/honk/ActivationReaction(mob/user)
	if(..() && ishuman(user) && !(user in affected_targets))
		var/mob/living/carbon/human/H = user
		for(var/obj/item/W in H)
			H.unEquip(W)
		var/datum/job/clown/C = SSjobs.GetJob("Clown")
		C.equip(H)
		affected_targets.Add(H)

/obj/machinery/anomalous_crystal/honk/New()
	..()
	activation_method = pick("mob_bump","speech")

/obj/machinery/anomalous_crystal/theme_warp //Warps the area you're in to look like a new one
	activation_method = "touch"
	cooldown_add = 200
	var/terrain_theme = "winter"
	var/NewTerrainFloors
	var/NewTerrainWalls
	var/NewTerrainChairs
	var/NewTerrainTables
	var/list/NewFlora = list()
	var/florachance = 8

/obj/machinery/anomalous_crystal/theme_warp/New()
	..()
	terrain_theme = pick("lavaland","winter","jungle","alien")
	switch(terrain_theme)
		if("lavaland")//Depressurizes the place... and free cult metal, I guess.
			NewTerrainFloors = /turf/simulated/floor/plating/asteroid/basalt // Needs to be updated after turf update
			NewTerrainWalls = /turf/simulated/wall/cult
			NewFlora = list(/mob/living/simple_animal/hostile/asteroid/goldgrub)
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
						var/turf/simulated/O = T.ChangeTurf(NewTerrainFloors)
						if(O.air)
							var/datum/gas_mixture/G = O.air
							G.copy_from(O.air)
						if(prob(florachance) && NewFlora.len && !is_blocked_turf(O))
							var/atom/Picked = pick(NewFlora)
							new Picked(O)
						continue
					if(iswallturf(T) && NewTerrainWalls)
						T.ChangeTurf(NewTerrainWalls)
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

/obj/machinery/anomalous_crystal/emitter //Generates a projectile when interacted with
	activation_method = "touch"
	cooldown_add = 50
	var/generated_projectile = /obj/item/projectile/beam/emitter

/obj/machinery/anomalous_crystal/emitter/New()
	..()
	generated_projectile = pick(/obj/item/projectile/magic/fireball/infernal,/obj/item/projectile/magic/spellblade,
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

/obj/machinery/anomalous_crystal/dark_reprise //Revives anyone nearby, but turns them into shadowpeople and renders them uncloneable, so the crystal is your only hope of getting up again if you go down.
	activation_method = "touch"
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
					H.disabilities |= NOCLONE //Free revives, but significantly limits your options for reviving except via the crystal
					H.grab_ghost(force = TRUE)

/obj/machinery/anomalous_crystal/helpers //Lets ghost spawn as helpful creatures that can only heal people slightly. Incredibly fragile and they can't converse with humans
	activation_method = "touch"
	var/ready_to_deploy = 0

/obj/machinery/anomalous_crystal/helpers/ActivationReaction(mob/user, method)
	if(..() && !ready_to_deploy)
		ready_to_deploy = 1
		notify_ghosts("An anomalous crystal has been activated in [get_area(src)]! This crystal can always be used by ghosts hereafter.", enter_link = "<a href=?src=\ref[src];ghostjoin=1>(Click to enter)</a>", source = src, action = NOTIFY_ATTACK)

/obj/machinery/anomalous_crystal/helpers/attack_ghost(mob/dead/observer/user)
	..()
	if(ready_to_deploy)
		var/be_helper = alert("Become a Lightgeist? (Warning, You can no longer be cloned!)",,"Yes","No")
		if(be_helper == "No")
			return
		var/mob/living/simple_animal/hostile/lightgeist/W = new /mob/living/simple_animal/hostile/lightgeist(get_turf(loc))
		W.key = user.key

/obj/machinery/anomalous_crystal/helpers/Topic(href, href_list)
	if(href_list["ghostjoin"])
		var/mob/dead/observer/ghost = usr
		if(istype(ghost))
			attack_ghost(ghost)

/mob/living/simple_animal/hostile/lightgeist
	name = "lightgeist"
	desc = "This small floating creature is a completely unknown form of life... being near it fills you with a sense of tranquility."
	icon_state = "lightgeist"
	icon_living = "lightgeist"
	icon_dead = "butterfly_dead"
	turns_per_move = 1
	response_help = "waves away"
	response_disarm = "brushes aside"
	response_harm = "disrupts"
	speak_emote = list("oscillates")
	maxHealth = 2
	health = 2
	harm_intent_damage = 1
	friendly = "mends"
	density = 0
	flying = 1
	obj_damage = 0
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	ventcrawler = 2
	mob_size = MOB_SIZE_TINY
	gold_core_spawnable = HOSTILE_SPAWN
	speak_emote = list("warps")
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	luminosity = 4
	faction = list("neutral")
	universal_understand = 1
	del_on_death = 1
	unsuitable_atmos_damage = 0
	flying = 1
	minbodytemp = 0
	maxbodytemp = 1500
	environment_smash = 0
	AIStatus = AI_OFF
	stop_automated_movement = 1
	var/heal_power = 5

/mob/living/simple_animal/hostile/lightgeist/New()
	..()
	verbs -= /mob/living/verb/pulled
	verbs -= /mob/verb/me_verb
	var/datum/atom_hud/medsensor = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	medsensor.add_hud_to(src)

/mob/living/simple_animal/hostile/lightgeist/AttackingTarget()
	. = ..()
	if(isliving(target) && target != src)
		var/mob/living/L = target
		if(L.stat < DEAD)
			L.heal_overall_damage(heal_power, heal_power)
			new /obj/effect/temp_visual/heal(get_turf(target), "#80F5FF")

/mob/living/simple_animal/hostile/lightgeist/ghostize()
	if(..())
		death()

/obj/machinery/anomalous_crystal/refresher //Deletes and recreates a copy of the item, "refreshing" it.
	activation_method = "touch"
	cooldown_add = 50
	activation_sound = 'sound/magic/timeparadox2.ogg'
	var/list/banned_items_typecache = list(/obj/item/storage, /obj/item/implant, /obj/item/implanter, /obj/item/disk/nuclear, /obj/item/projectile, /obj/item/spellbook)

/obj/machinery/anomalous_crystal/refresher/New()
	..()
	banned_items_typecache = typecacheof(banned_items_typecache)


/obj/machinery/anomalous_crystal/refresher/ActivationReaction(mob/user, method)
	if(..())
		var/list/L = list()
		var/turf/T = get_step(src, dir)
		new /obj/effect/temp_visual/emp/pulse(T)
		for(var/i in T)
			if(istype(i, /obj/item) && !is_type_in_typecache(i, banned_items_typecache))
				var/obj/item/W = i
				if(!W.admin_spawned && !(W.flags_2 & HOLOGRAM_2) && !(W.flags & ABSTRACT))
					L += W
		if(L.len)
			var/obj/item/CHOSEN = pick(L)
			new CHOSEN.type(T)
			qdel(CHOSEN)

/obj/machinery/anomalous_crystal/possessor //Allows you to bodyjack small animals, then exit them at your leisure, but you can only do this once per activation. Because they blow up. Also, if the bodyjacked animal dies, SO DO YOU.
	activation_method = "touch"

/obj/machinery/anomalous_crystal/possessor/ActivationReaction(mob/user, method)
	if(..())
		if(ishuman(user))
			var/mobcheck = 0
			for(var/mob/living/simple_animal/A in range(1, src))
				if(A.melee_damage_upper > 5 || A.mob_size >= MOB_SIZE_LARGE || A.ckey || A.stat)
					break
				var/obj/structure/closet/stasis/S = new /obj/structure/closet/stasis(A)
				user.forceMove(S)
				mobcheck = 1
				break
			if(!mobcheck)
				new /mob/living/simple_animal/cockroach(get_step(src,dir)) //Just in case there aren't any animals on the station, this will leave you with a terrible option to possess if you feel like it

/obj/structure/closet/stasis
	name = "quantum entanglement stasis warp field"
	desc = "You can hardly comprehend this thing... which is why you can't see it."
	icon_state = null //This shouldn't even be visible, so if it DOES show up, at least nobody will notice
	density = 1
	anchored = 1
	resistance_flags = FIRE_PROOF | ACID_PROOF | INDESTRUCTIBLE
	var/mob/living/simple_animal/holder_animal

/obj/structure/closet/stasis/process()
	if(holder_animal)
		if(holder_animal.stat == DEAD && !QDELETED(holder_animal))
			dump_contents()
			holder_animal.gib()
			return

/obj/structure/closet/stasis/New()
	..()
	if(isanimal(loc))
		holder_animal = loc
	START_PROCESSING(SSobj, src)

/obj/structure/closet/stasis/Entered(atom/A)
	if(isliving(A) && holder_animal)
		var/mob/living/L = A
		L.notransform = 1
		L.disabilities |= MUTE
		L.status_flags |= GODMODE
		L.mind.transfer_to(holder_animal)
		var/obj/effect/proc_holder/spell/targeted/exit_possession/P = new /obj/effect/proc_holder/spell/targeted/exit_possession
		holder_animal.mind.AddSpell(P)
		holder_animal.verbs -= /mob/living/verb/pulled

/obj/structure/closet/stasis/dump_contents(var/kill = 1)
	STOP_PROCESSING(SSobj, src)
	for(var/mob/living/L in src)
		L.disabilities &= ~MUTE
		L.status_flags &= ~GODMODE
		L.notransform = 0
		if(holder_animal && !QDELETED(holder_animal))
			holder_animal.mind.transfer_to(L)
			L.mind.RemoveSpell(/obj/effect/proc_holder/spell/targeted/exit_possession)
		if(kill || !isanimal(loc))
			L.death(0)
	..()

/obj/structure/closet/stasis/emp_act()
	return

/obj/structure/closet/stasis/ex_act()
	return

/obj/effect/proc_holder/spell/targeted/exit_possession
	name = "Exit Possession"
	desc = "Exits the body you are possessing"
	charge_max = 60
	clothes_req = 0
	invocation_type = "none"
	max_targets = 1
	range = -1
	include_user = 1
	selection_type = "view"
	action_icon_state = "exit_possession"
	sound = null

/obj/effect/proc_holder/spell/targeted/exit_possession/cast(list/targets, mob/user = usr)
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
	target_mind.RemoveSpell(/obj/effect/proc_holder/spell/targeted/exit_possession)
