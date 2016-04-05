
/// Slime Extracts ///

/obj/item/slime_extract
	name = "slime extract"
	desc = "Goo extracted from a slime. Legends claim these to have \"magical powers\"."
	icon = 'icons/mob/slimes.dmi'
	icon_state = "grey slime extract"
	force = 1.0
	w_class = 1.0
	throwforce = 0
	throw_speed = 3
	throw_range = 6
	origin_tech = "biotech=4"
	item_color = "grey"
	var/Uses = 1 // uses before it goes inert
	var/enhanced = 0 //has it been enhanced before?

	attackby(obj/item/O as obj, mob/user as mob, params)
		if(istype(O, /obj/item/weapon/slimesteroid2))
			if(enhanced == 1)
				user << "<span class='warning'> This extract has already been enhanced!</span>"
				return ..()
			if(Uses == 0)
				user << "<span class='warning'> You can't enhance a used extract!</span>"
				return ..()
			user <<"You apply the enhancer. It now has triple the amount of uses."
			Uses = 3
			enhanced = 1
			qdel(O)
		if(istype(O,/obj/item/weapon/storage/bag))
			..()

/obj/item/slime_extract/New()
		..()
		create_reagents(100)


/obj/item/slime_extract/grey
	name = "grey slime extract"
	icon_state = "grey slime extract"
	item_color = "grey"

/obj/item/slime_extract/gold
	name = "gold slime extract"
	icon_state = "gold slime extract"
	item_color = "gold"

/obj/item/slime_extract/silver
	name = "silver slime extract"
	icon_state = "silver slime extract"
	item_color = "silver"

/obj/item/slime_extract/metal
	name = "metal slime extract"
	icon_state = "metal slime extract"
	item_color = "metal"

/obj/item/slime_extract/purple
	name = "purple slime extract"
	icon_state = "purple slime extract"
	item_color = "purple"

/obj/item/slime_extract/darkpurple
	name = "dark purple slime extract"
	icon_state = "dark purple slime extract"
	item_color = "darkpurple"

/obj/item/slime_extract/orange
	name = "orange slime extract"
	icon_state = "orange slime extract"
	item_color = "orange"

/obj/item/slime_extract/yellow
	name = "yellow slime extract"
	icon_state = "yellow slime extract"
	item_color = "yellow"

/obj/item/slime_extract/red
	name = "red slime extract"
	icon_state = "red slime extract"
	item_color = "red"

/obj/item/slime_extract/blue
	name = "blue slime extract"
	icon_state = "blue slime extract"
	item_color = "blue"

/obj/item/slime_extract/darkblue
	name = "dark blue slime extract"
	icon_state = "dark blue slime extract"
	item_color = "darkblue"

/obj/item/slime_extract/pink
	name = "pink slime extract"
	icon_state = "pink slime extract"
	item_color = "pink"

/obj/item/slime_extract/green
	name = "green slime extract"
	icon_state = "green slime extract"
	item_color = "green"

/obj/item/slime_extract/lightpink
	name = "light pink slime extract"
	icon_state = "light pink slime extract"
	item_color = "lightpink"

/obj/item/slime_extract/black
	name = "black slime extract"
	icon_state = "black slime extract"
	item_color = "black"

/obj/item/slime_extract/oil
	name = "oil slime extract"
	icon_state = "oil slime extract"
	item_color = "oil"

/obj/item/slime_extract/adamantine
	name = "adamantine slime extract"
	icon_state = "adamantine slime extract"
	item_color = "adamantine"

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

////Pet Slime Creation///

/obj/item/weapon/slimepotion
	name = "docility potion"
	desc = "A potent chemical mix that will nullify a slime's powers, causing it to become docile and tame."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle19"
	w_class = 1
	origin_tech = "biotech=4"

	attack(mob/living/carbon/slime/M as mob, mob/user as mob)
		if(!istype(M, /mob/living/carbon/slime))//If target is not a slime.
			user << "<span class='warning'> The potion only works on slimes!</span>"
			return ..()
		if(M.stat)
			user << "<span class='warning'> The slime is dead!</span>"
			return..()
		if(M.mind)
			user << "<span class='warning'> The slime resists!</span>"
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
		user <<"You feed the slime the potion, removing it's powers and calming it."

/obj/item/weapon/sentience_potion
	name = "sentience potion"
	desc = "A miraculous chemical mix that can raise the intelligence of creatures to human levels. Unlike normal slime potions, it can be absorbed by any nonsentient being."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle19"
	origin_tech = "biotech=5"
	var/list/not_interested = list()
	var/being_used = 0
	w_class = 1
	var/sentience_type = SENTIENCE_ORGANIC


/obj/item/weapon/sentience_potion/afterattack(mob/living/M, mob/user)
	if(being_used || !ismob(M))
		return
	if(!isanimal(M) || M.ckey) //only works on animals that aren't player controlled
		user << "<span class='warning'>[M] is already too intelligent for this to work!</span>"
		return ..()
	if(M.stat)
		user << "<span class='warning'>[M] is dead!</span>"
		return ..()
	var/mob/living/simple_animal/SM = M
	if(SM.sentience_type != sentience_type)
		user << "<span class='warning'>The potion won't work on [SM].</span>"
		return ..()

	user << "<span class='notice'>You offer the sentience potion to [SM]...</span>"
	being_used = 1

	var/list/candidates = pollCandidates("Do you want to play as [SM.name]?", ROLE_SENTIENT, 0, 100)

	if(!src)
		return

	if(candidates.len)
		var/mob/C = pick(candidates)
		SM.key = C.key
		SM.universal_speak = 1
		SM.faction = user.faction
		SM.master_commander = user
		SM.sentience_act()
		SM << "<span class='warning'>All at once it makes sense: you know what you are and who you are! Self awareness is yours!</span>"
		SM << "<span class='userdanger'>You are grateful to be self aware and owe [user] a great debt. Serve [user], and assist them in completing their goals at any cost.</span>"
		user << "<span class='notice'>[M] accepts the potion and suddenly becomes attentive and aware. It worked!</span>"
		qdel(src)
	else
		user << "<span class='notice'>[M] looks interested for a moment, but then looks back down. Maybe you should try again later.</span>"
		being_used = 0
		..()


/obj/item/weapon/slimesteroid
	name = "slime steroid"
	desc = "A potent chemical mix that will cause a slime to generate more extract."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle16"
	w_class = 1
	origin_tech = "biotech=4"


	attack(mob/living/carbon/slime/M as mob, mob/user as mob)
		if(!istype(M, /mob/living/carbon/slime))//If target is not a slime.
			user << "<span class='warning'> The steroid only works on baby slimes!</span>"
			return ..()
		if(M.is_adult) //Can't tame adults
			user << "<span class='warning'> Only baby slimes can use the steroid!</span>"
			return..()
		if(M.stat)
			user << "<span class='warning'> The slime is dead!</span>"
			return..()
		if(M.cores == 3)
			user <<"<span class='warning'> The slime already has the maximum amount of extract!</span>"
			return..()

		user <<"You feed the slime the steroid. It now has triple the amount of extract."
		M.cores = 3
		qdel(src)

/obj/item/weapon/slimesteroid2
	name = "extract enhancer"
	desc = "A potent chemical mix that will give a slime extract three uses."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle17"
	w_class = 1
	origin_tech = "biotech=4"


/obj/item/weapon/slimespeed
	name = "slime speed potion"
	desc = "A potent chemical mix that will remove the slowdown from any item."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle3"
	w_class = 1
	origin_tech = "biotech=4"

/obj/item/weapon/slimespeed/afterattack(obj/item/C, mob/user)
	..()
	if(!istype(C))
		user << "<span class='warning'>The potion can only be used on items!</span>"
		return
	if(C.slowdown <= 0)
		user << "<span class='warning'>The [C] can't be made any faster!</span>"
		return..()
	user <<"<span class='notice'>You slather the red gunk over the [C], making it faster.</span>"
	C.color = "#FF0000"
	C.slowdown = 0
	qdel(src)

/obj/item/weapon/slimefireproof
	name = "slime chill potion"
	desc = "A potent chemical mix that will fireproof any article of clothing. Has three uses."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle17"
	var/uses = 3
	w_class = 1
	origin_tech = "biotech=4"


/obj/item/weapon/slimefireproof/afterattack(obj/item/clothing/C, mob/user)
	..()
	if(!uses)
		qdel(src)
		return
	if(!istype(C))
		user << "<span class='warning'>The potion can only be used on clothing!</span>"
		return
	if(C.max_heat_protection_temperature == FIRE_IMMUNITY_SUIT_MAX_TEMP_PROTECT)
		user << "<span class='warning'>The [C] is already fireproof!</span>"
		return..()
	user <<"<span class='notice'>You slather the blue gunk over the [C], fireproofing it.</span>"
	C.name = "fireproofed [C.name]"
	C.color = "#000080"
	C.max_heat_protection_temperature = FIRE_IMMUNITY_SUIT_MAX_TEMP_PROTECT
	C.heat_protection = C.body_parts_covered
	uses --
	if(!uses)
		qdel(src)



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

/obj/effect/goleRUNe
	anchored = 1
	desc = "a strange rune used to create golems. It glows when spirits are nearby."
	name = "rune"
	icon = 'icons/obj/rune.dmi'
	icon_state = "golem"
	unacidable = 1
	layer = TURF_LAYER
	var/list/mob/dead/observer/ghosts[0]

	New()
		..()
		processing_objects.Add(src)

	process()
		if(ghosts.len>0)
			icon_state = "golem2"
		else
			icon_state = "golem"

	attack_hand(mob/living/user as mob)
		var/mob/dead/observer/ghost
		for(var/mob/dead/observer/O in src.loc)
			if(!check_observer(O))
				O << "\red You are not eligible to become a golem."
				continue
			ghost = O
			break
		if(!ghost)
			user << "The rune fizzles uselessly. There is no spirit nearby."
			return
		var/mob/living/carbon/human/golem/G = new /mob/living/carbon/human/golem
		G.change_gender(pick(MALE,FEMALE))
		G.loc = src.loc
		G.key = ghost.key
		G << "You are an adamantine golem. You move slowly, but are highly resistant to heat and cold as well as blunt trauma. You are unable to wear clothes, but can still use most tools. Serve [user], and assist them in completing their goals at any cost."
		qdel(src)


	proc/announce_to_ghosts()
		for(var/mob/dead/observer/O in player_list)
			if(O.client)
				var/area/A = get_area(src)
				if(A)
					O << "\blue <b>Golem rune created in [A.name]. (<a href='?src=\ref[O];jump=\ref[src]'>Teleport</a> | <a href='?src=\ref[src];signup=\ref[O]'>Sign Up</a>)</b>"

	Topic(href,href_list)
		if("signup" in href_list)
			var/mob/dead/observer/O = locate(href_list["signup"])
			volunteer(O)

	attack_ghost(var/mob/dead/observer/O)
		if(!O) return
		volunteer(O)

	proc/check_observer(var/mob/dead/observer/O)
		if(!O)
			return 0
		if(!O.client)
			return 0
		if(O.mind && O.mind.current && O.mind.current.stat != DEAD)
			return 0
		if(O.has_enabled_antagHUD == 1 && config.antag_hud_restricted)
			return 0
		return 1

	proc/volunteer(var/mob/dead/observer/O)
		if(O in ghosts)
			ghosts.Remove(O)
			O << "\red You are no longer signed up to be a golem."
		else
			if(!check_observer(O))
				O << "\red You are not eligible to become a golem."
				return
			ghosts.Add(O)
			O << "\blue You are signed up to be a golem."