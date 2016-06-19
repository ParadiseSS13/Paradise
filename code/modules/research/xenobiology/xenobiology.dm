
/// Slime Extracts ///

/obj/item/slime_extract
	name = "slime extract"
	desc = "Goo extracted from a slime. Legends claim these to have \"magical powers\"."
	icon = 'icons/mob/slimes.dmi'
	icon_state = "grey slime extract"
	force = 1
	w_class = 1
	throwforce = 0
	throw_speed = 3
	throw_range = 6
	origin_tech = "biotech=3"
	var/Uses = 1 // uses before it goes inert

/obj/item/slime_extract/attackby(obj/item/O, mob/user)
	if(istype(O, /obj/item/slimepotion/enhancer))
		if(Uses >= 5)
			to_chat(user, "<span class='warning'>You cannot enhance this extract further!</span>")
			return ..()
		to_chat(user, "<span class='notice'>You apply the enhancer to the slime extract. It may now be reused one more time.</span>")
		Uses++
		qdel(O)
	..()

/obj/item/slime_extract/New()
		..()
		create_reagents(100)

/obj/item/slime_extract/grey
	name = "grey slime extract"
	icon_state = "grey slime extract"

/obj/item/slime_extract/gold
	name = "gold slime extract"
	icon_state = "gold slime extract"

/obj/item/slime_extract/silver
	name = "silver slime extract"
	icon_state = "silver slime extract"

/obj/item/slime_extract/metal
	name = "metal slime extract"
	icon_state = "metal slime extract"

/obj/item/slime_extract/purple
	name = "purple slime extract"
	icon_state = "purple slime extract"

/obj/item/slime_extract/darkpurple
	name = "dark purple slime extract"
	icon_state = "dark purple slime extract"

/obj/item/slime_extract/orange
	name = "orange slime extract"
	icon_state = "orange slime extract"

/obj/item/slime_extract/yellow
	name = "yellow slime extract"
	icon_state = "yellow slime extract"

/obj/item/slime_extract/red
	name = "red slime extract"
	icon_state = "red slime extract"

/obj/item/slime_extract/blue
	name = "blue slime extract"
	icon_state = "blue slime extract"

/obj/item/slime_extract/darkblue
	name = "dark blue slime extract"
	icon_state = "dark blue slime extract"

/obj/item/slime_extract/pink
	name = "pink slime extract"
	icon_state = "pink slime extract"

/obj/item/slime_extract/green
	name = "green slime extract"
	icon_state = "green slime extract"

/obj/item/slime_extract/lightpink
	name = "light pink slime extract"
	icon_state = "light pink slime extract"

/obj/item/slime_extract/black
	name = "black slime extract"
	icon_state = "black slime extract"

/obj/item/slime_extract/oil
	name = "oil slime extract"
	icon_state = "oil slime extract"

/obj/item/slime_extract/adamantine
	name = "adamantine slime extract"
	icon_state = "adamantine slime extract"

/obj/item/slime_extract/bluespace
	name = "bluespace slime extract"
	icon_state = "bluespace slime extract"

/obj/item/slime_extract/pyrite
	name = "pyrite slime extract"
	icon_state = "pyrite slime extract"

/obj/item/slime_extract/cerulean
	name = "cerulean slime extract"
	icon_state = "cerulean slime extract"

/obj/item/slime_extract/sepia
	name = "sepia slime extract"
	icon_state = "sepia slime extract"

/obj/item/slime_extract/rainbow
	name = "rainbow slime extract"
	icon_state = "rainbow slime extract"

////Slime-derived potions///

/obj/item/slimepotion
	name = "slime potion"
	desc = "A hard yet gelatinous capsule excreted by a slime, containing mysterious substances."
	w_class = 1
	origin_tech = "biotech=4"

/obj/item/slimepotion/afterattack(obj/item/weapon/reagent_containers/target, mob/user , proximity)
	if (istype(target))
		to_chat(user, "<span class='notice'>You cannot transfer [src] to [target]! It appears the potion must be given directly to a slime to absorb.</span>") // le fluff faec
		return

/obj/item/slimepotion/docility
	name = "docility potion"
	desc = "A potent chemical mix that nullifies a slime's hunger, causing it to become docile and tame."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle19"

/obj/item/slimepotion/docility/attack(mob/living/carbon/slime/M, mob/user)
	if(!isslime(M))
		to_chat(user, "<span class='warning'> The potion only works on slimes!</span>")
		return ..()
	if(M.stat)
		to_chat(user, "<span class='warning'> The slime is dead!</span>")
		return..()
	if(M.mind)
		to_chat(user, "<span class='warning'> The slime resists!</span>")
		return ..()
	if(M.is_adult)
		var/mob/living/simple_animal/adultslime/pet = new /mob/living/simple_animal/adultslime(M.loc)
		pet.icon_state = "[M.colour] adult slime"
		pet.icon_living = "[M.colour] adult slime"
		pet.icon_dead = "[M.colour] baby slime dead"
		pet.colour = "[M.colour]"
		qdel(M)
		var/newname = sanitize(copytext(input(user, "Would you like to give the slime a name?", "Name your new pet", "pet slime") as null|text,1,MAX_NAME_LEN))

		if (!newname)
			newname = "pet slime"
		pet.name = newname
		pet.real_name = newname
		qdel(src)
	else
		var/mob/living/simple_animal/slime/pet = new /mob/living/simple_animal/slime(M.loc)
		pet.icon_state = "[M.colour] baby slime"
		pet.icon_living = "[M.colour] baby slime"
		pet.icon_dead = "[M.colour] baby slime dead"
		pet.colour = "[M.colour]"
		qdel(M)
		var/newname = sanitize(copytext(input(user, "Would you like to give the slime a name?", "Name your new pet", "pet slime") as null|text,1,MAX_NAME_LEN))

		if (!newname)
			newname = "pet slime"
		pet.name = newname
		pet.real_name = newname
		qdel(src)
	to_chat(user, "You feed the slime the potion, removing it's powers and calming it.")

/obj/item/slimepotion/sentience
	name = "sentience potion"
	desc = "A miraculous chemical mix that can raise the intelligence of creatures to human levels. Unlike normal slime potions, it can be absorbed by any nonsentient being."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle19"
	origin_tech = "biotech=5"
	var/list/not_interested = list()
	var/being_used = 0
	var/sentience_type = SENTIENCE_ORGANIC

/obj/item/slimepotion/sentience/afterattack(mob/living/M, mob/user)
	if(being_used || !ismob(M))
		return
	if(!isanimal(M) || M.ckey) //only works on animals that aren't player controlled
		to_chat(user, "<span class='warning'>[M] is already too intelligent for this to work!</span>")
		return ..()
	if(M.stat)
		to_chat(user, "<span class='warning'>[M] is dead!</span>")
		return ..()
	var/mob/living/simple_animal/SM = M
	if(SM.sentience_type != sentience_type)
		to_chat(user, "<span class='warning'>The potion won't work on [SM].</span>")
		return ..()

	to_chat(user, "<span class='notice'>You offer [src] sentience potion to [SM]...</span>")
	being_used = 1

	var/ghostmsg = "Play as [SM.name], pet of [user.name]?"
	var/list/candidates = pollCandidates(ghostmsg, ROLE_SENTIENT, 0, 100)

	if(!src)
		return

	if(candidates.len)
		var/mob/C = pick(candidates)
		SM.key = C.key
		SM.universal_speak = 1
		SM.faction = user.faction
		SM.master_commander = user
		SM.sentience_act()
		to_chat(SM, "<span class='warning'>All at once it makes sense: you know what you are and who you are! Self awareness is yours!</span>")
		to_chat(SM, "<span class='userdanger'>You are grateful to be self aware and owe [user] a great debt. Serve [user], and assist them in completing their goals at any cost.</span>")
		to_chat(user, "<span class='notice'>[M] accepts the potion and suddenly becomes attentive and aware. It worked!</span>")
		qdel(src)
	else
		to_chat(user, "<span class='notice'>[M] looks interested for a moment, but then looks back down. Maybe you should try again later.</span>")
		being_used = 0
		..()

/obj/item/slimepotion/steroid
	name = "slime steroid"
	desc = "A potent chemical mix that will cause a baby slime to generate more extract."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle16"

/obj/item/slimepotion/steroid/attack(mob/living/carbon/slime/M, mob/user)
	if(!isslime(M))//If target is not a slime.
		to_chat(user, "<span class='warning'>The steroid only works on baby slimes!</span>")
		return ..()
	if(M.is_adult) //Can't steroidify adults
		to_chat(user, "<span class='warning'>Only baby slimes can use the steroid!</span>")
		return ..()
	if(M.stat)
		to_chat(user, "<span class='warning'>The slime is dead!</span>")
		return ..()
	if(M.cores >= 5)
		to_chat(user, "<span class='warning'>The slime already has the maximum amount of extract!</span>")
		return ..()

	to_chat(user, "<span class='notice'>You feed the slime the steroid. It will now produce one more extract.</span>")
	M.cores++
	qdel(src)

/obj/item/slimepotion/enhancer
	name = "extract enhancer"
	desc = "A potent chemical mix that will give a slime extract an additional use."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle17"

/obj/item/slimepotion/stabilizer
	name = "slime stabilizer"
	desc = "A potent chemical mix that will reduce the chance of a slime mutating."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle15"

/obj/item/slimepotion/stabilizer/attack(mob/living/carbon/slime/M, mob/user)
	if(!isslime(M))
		to_chat(user, "<span class='warning'>The stabilizer only works on slimes!</span>")
		return ..()
	if(M.stat)
		to_chat(user, "<span class='warning'>The slime is dead!</span>")
		return ..()
	if(M.mutation_chance == 0)
		to_chat(user, "<span class='warning'>The slime already has no chance of mutating!</span>")
		return ..()

	to_chat(user, "<span class='notice'>You feed the slime the stabilizer. It is now less likely to mutate.</span>")
	M.mutation_chance = Clamp(M.mutation_chance-15,0,100)
	qdel(src)

/obj/item/slimepotion/mutator
	name = "slime mutator"
	desc = "A potent chemical mix that will increase the chance of a slime mutating."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle3"

/obj/item/slimepotion/mutator/attack(mob/living/carbon/slime/M, mob/user)
	if(!isslime(M))
		to_chat(user, "<span class='warning'>The mutator only works on slimes!</span>")
		return ..()
	if(M.stat)
		to_chat(user, "<span class='warning'>The slime is dead!</span>")
		return ..()
	if(M.mutator_used)
		to_chat(user, "<span class='warning'>This slime has already consumed a mutator, any more would be far too unstable!</span>")
		return ..()
	if(M.mutation_chance == 100)
		to_chat(user, "<span class='warning'>The slime is already guaranteed to mutate!</span>")
		return ..()

	to_chat(user, "<span class='notice'>You feed the slime the mutator. It is now more likely to mutate.</span>")
	M.mutation_chance = Clamp(M.mutation_chance+12,0,100)
	M.mutator_used = TRUE
	qdel(src)

/obj/item/slimepotion/speed
	name = "slime speed potion"
	desc = "A potent chemical mix that will remove the slowdown from any item."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle3"

/obj/item/slimepotion/speed/afterattack(obj/item/C, mob/user)
	..()
	if(!istype(C))
		to_chat(user, "<span class='warning'>The potion can only be used on items!</span>")
		return
	if(C.slowdown <= 0)
		to_chat(user, "<span class='warning'>The [C] can't be made any faster!</span>")
		return..()
	to_chat(user, "<span class='notice'>You slather the red gunk over the [C], making it faster.</span>")
	C.color = "#FF0000"
	C.slowdown = 0
	qdel(src)

/obj/item/slimepotion/fireproof
	name = "slime chill potion"
	desc = "A potent chemical mix that will fireproof any article of clothing. Has three uses."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle17"
	var/uses = 3

/obj/item/slimepotion/fireproof/afterattack(obj/item/clothing/C, mob/user)
	..()
	if(!uses)
		qdel(src)
		return
	if(!istype(C))
		to_chat(user, "<span class='warning'>The potion can only be used on clothing!</span>")
		return
	if(C.max_heat_protection_temperature == FIRE_IMMUNITY_SUIT_MAX_TEMP_PROTECT)
		to_chat(user, "<span class='warning'>The [C] is already fireproof!</span>")
		return ..()
	to_chat(user, "<span class='notice'>You slather the blue gunk over the [C], fireproofing it.</span>")
	C.name = "fireproofed [C.name]"
	C.color = "#000080"
	C.max_heat_protection_temperature = FIRE_IMMUNITY_SUIT_MAX_TEMP_PROTECT
	C.heat_protection = C.body_parts_covered
	uses --
	if(!uses)
		qdel(src)

////////Adamantine Golem stuff I dunno where else to put it

/obj/effect/golemrune
	anchored = 1
	desc = "a strange rune used to create golems. It glows when spirits are nearby."
	name = "rune"
	icon = 'icons/obj/rune.dmi'
	icon_state = "golem"
	unacidable = 1
	layer = TURF_LAYER
	var/list/mob/dead/observer/ghosts[0]

/obj/effect/golemrune/New()
	..()
	processing_objects.Add(src)

/obj/effect/golemrune/process()
	if(ghosts.len>0)
		icon_state = "golem2"
	else
		icon_state = "golem"

/obj/effect/golemrune/attack_hand(mob/living/user as mob)
	var/mob/dead/observer/ghost
	for(var/mob/dead/observer/O in src.loc)
		if(!check_observer(O))
			to_chat(O, "\red You are not eligible to become a golem.")
			continue
		ghost = O
		break
	if(!ghost)
		to_chat(user, "The rune fizzles uselessly. There is no spirit nearby.")
		return
	var/mob/living/carbon/human/golem/G = new /mob/living/carbon/human/golem
	G.change_gender(pick(MALE,FEMALE))
	G.loc = src.loc
	G.key = ghost.key
	to_chat(G, "You are an adamantine golem. You move slowly, but are highly resistant to heat and cold as well as blunt trauma. You are unable to wear clothes, but can still use most tools. Serve [user], and assist them in completing their goals at any cost.")
	qdel(src)

/obj/effect/golemrune/Topic(href,href_list)
	if("signup" in href_list)
		var/mob/dead/observer/O = locate(href_list["signup"])
		volunteer(O)

/obj/effect/golemrune/attack_ghost(var/mob/dead/observer/O)
	if(!O) return
	volunteer(O)

/obj/effect/golemrune/proc/check_observer(var/mob/dead/observer/O)
	if(!O)
		return 0
	if(!O.client)
		return 0
	if(O.mind && O.mind.current && O.mind.current.stat != DEAD)
		return 0
	if(O.has_enabled_antagHUD == 1 && config.antag_hud_restricted)
		return 0
	return 1

/obj/effect/golemrune/proc/volunteer(var/mob/dead/observer/O)
	if(O in ghosts)
		ghosts.Remove(O)
		to_chat(O, "\red You are no longer signed up to be a golem.")
	else
		if(!check_observer(O))
			to_chat(O, "\red You are not eligible to become a golem.")
			return
		ghosts.Add(O)
		to_chat(O, "\blue You are signed up to be a golem.")




/obj/effect/timestop
	anchored = 1
	name = "chronofield"
	desc = "ZA WARUDO"
	icon = 'icons/effects/160x160.dmi'
	icon_state = "time"
	layer = FLY_LAYER
	pixel_x = -64
	pixel_y = -64
	unacidable = 1
	mouse_opacity = 0
	var/mob/living/immune = list() // the one who creates the timestop is immune
	var/list/stopped_atoms = list()
	var/freezerange = 2
	var/duration = 140
	alpha = 125

/obj/effect/timestop/New()
	..()
	for(var/mob/living/M in player_list)
		for(var/obj/effect/proc_holder/spell/aoe_turf/conjure/timestop/T in M.mind.spell_list) //People who can stop time are immune to timestop
			immune |= M


/obj/effect/timestop/proc/timestop()
	playsound(get_turf(src), 'sound/magic/TIMEPARADOX2.ogg', 100, 1, -1)
	for(var/i in 1 to duration-1)
		for(var/A in orange (freezerange, src.loc))
			if(istype(A, /mob/living))
				var/mob/living/M = A
				if(M in immune)
					continue
				M.notransform = 1
				M.anchored = 1
				if(istype(M, /mob/living/simple_animal/hostile))
					var/mob/living/simple_animal/hostile/H = M
					H.AIStatus = AI_OFF
					H.LoseTarget()
				stopped_atoms |= M
			else if(istype(A, /obj/item/projectile))
				var/obj/item/projectile/P = A
				P.paused = TRUE
				stopped_atoms |= P

		for(var/mob/living/M in stopped_atoms)
			if(get_dist(get_turf(M),get_turf(src)) > freezerange) //If they lagged/ran past the timestop somehow, just ignore them
				unfreeze_mob(M)
				stopped_atoms -= M
		sleep(1)

	//End
	for(var/mob/living/M in stopped_atoms)
		unfreeze_mob(M)

	for(var/obj/item/projectile/P in stopped_atoms)
		P.paused = FALSE
	qdel(src)
	return

/obj/effect/timestop/proc/unfreeze_mob(mob/living/M)
	M.notransform = 0
	M.anchored = 0
	if(istype(M, /mob/living/simple_animal/hostile))
		var/mob/living/simple_animal/hostile/H = M
		H.AIStatus = initial(H.AIStatus)

/obj/effect/timestop/wizard
	duration = 100

/obj/effect/timestop/wizard/New()
	..()
	timestop()

/obj/item/stack/tile/bluespace
	name = "bluespace floor tile"
	singular_name = "floor tile"
	desc = "Through a series of micro-teleports, these tiles let people move at incredible speeds."
	icon_state = "tile-bluespace"
	w_class = 3
	force = 6
	materials = list(MAT_METAL=500)
	throwforce = 10
	throw_speed = 3
	throw_range = 7
	flags = CONDUCT
	max_amount = 60
	turf_type = /turf/simulated/floor/bluespace


/turf/simulated/floor/bluespace
	slowdown = -1
	icon_state = "bluespace"
	desc = "Through a series of micro-teleports, these tiles let people move at incredible speeds."
	floor_tile = /obj/item/stack/tile/bluespace


/obj/item/stack/tile/sepia
	name = "sepia floor tile"
	singular_name = "floor tile"
	desc = "Time seems to flow very slowly around these tiles."
	icon_state = "tile-sepia"
	w_class = 3
	force = 6
	materials = list(MAT_METAL=500)
	throwforce = 10
	throw_speed = 3
	throw_range = 7
	flags = CONDUCT
	max_amount = 60
	turf_type = /turf/simulated/floor/sepia

/obj/item/areaeditor/blueprints/slime
	name = "cerulean prints"
	desc = "A one use set of blueprints made of jelly like organic material. Renaming an area to 'Xenobiology Lab' will extend the reach of the management console."
	color = "#2956B2"

/obj/item/areaeditor/blueprints/slime/edit_area()
	. = ..()
	var/area/A = get_area(src)
	if(.)
		for(var/turf/T in A)
			T.color = "#2956B2"
		qdel(src)

/turf/simulated/floor/sepia
	slowdown = 2
	icon_state = "sepia"
	desc = "Time seems to flow very slowly around these tiles."
	floor_tile = /obj/item/stack/tile/sepia
