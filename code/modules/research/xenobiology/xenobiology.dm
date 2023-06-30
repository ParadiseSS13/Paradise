
/// Slime Extracts ///

/obj/item/slime_extract
	name = "slime extract"
	desc = "Goo extracted from a slime. Legends claim these to have \"magical powers\"."
	icon = 'icons/mob/slimes.dmi'
	icon_state = "grey slime extract"
	force = 1
	w_class = WEIGHT_CLASS_TINY
	container_type = INJECTABLE | DRAWABLE
	throwforce = 0
	throw_speed = 3
	throw_range = 6
	origin_tech = "biotech=3"
	/// Uses before it goes inert
	var/Uses = 1
	/// The mob who last injected the extract with plasma, water or blood. Used for logging.
	var/mob/living/injector_mob

/obj/item/slime_extract/attackby(obj/item/O, mob/user)
	if(istype(O, /obj/item/slimepotion/enhancer))
		if(Uses >= 5)
			to_chat(user, "<span class='warning'>You cannot enhance this extract further!</span>")
			return ..()
		to_chat(user, "<span class='notice'>You apply the enhancer to the slime extract. It may now be reused one more time.</span>")
		Uses++
		qdel(O)
	if(istype(O, /obj/item/reagent_containers/syringe))
		injector_mob = user
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
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle3"
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "biotech=4"
	var/being_used = FALSE

/obj/item/slimepotion/attack(mob/living/simple_animal/slime/M, mob/user)
	if(!isslime(M))
		to_chat(user, "<span class='warning'>[src] only works on slimes!</span>")
		return FALSE
	if(M.stat)
		to_chat(user, "<span class='warning'>The slime is dead!</span>")
		return FALSE
	if(being_used)
		to_chat(user, "<span class='warning'>You're already using this on another slime!</span>")
		return FALSE
	return TRUE

/obj/item/slimepotion/afterattack(obj/item/reagent_containers/target, mob/user, proximity_flag)
	if(!proximity_flag)
		return
	if(istype(target))
		to_chat(user, "<span class='notice'>You cannot give [src] to [target]! It must be given directly to a slime to absorb.</span>") // le fluff faec
		return

/obj/item/slimepotion/slime/docility
	name = "docility potion"
	desc = "A potent chemical mix that nullifies a slime's hunger, causing it to become docile and tame."
	icon_state = "bottle19"

/obj/item/slimepotion/slime/docility/attack(mob/living/simple_animal/slime/M, mob/user)
	. = ..()
	if(!.)
		return

	if(M.rabid) //Stops being rabid, but doesn't become truly docile.
		to_chat(M, "<span class='warning'>You absorb the potion, and your rabid hunger finally settles to a normal desire to feed.</span>")
		to_chat(user, "<span class='notice'>You feed the slime the potion, calming its rabid rage.</span>")
		M.rabid = FALSE
		qdel(src)
		return
	M.docile = TRUE
	M.set_nutrition(700)
	to_chat(M, "<span class='warning'>You absorb the potion and feel your intense desire to feed melt away.</span>")
	to_chat(user, "<span class='notice'>You feed the slime the potion, removing its hunger and calming it.</span>")
	being_used = TRUE
	var/newname = sanitize(copytext(input(user, "Would you like to give the slime a name?", "Name your new pet", "pet slime") as null|text,1,MAX_NAME_LEN))

	if(!newname)
		newname = "pet slime"
	M.name = newname
	M.real_name = newname
	qdel(src)

/obj/item/slimepotion/sentience
	name = "sentience potion"
	desc = "A miraculous chemical mix that can raise the intelligence of creatures to human levels."
	icon_state = "bottle19"
	origin_tech = "biotech=6"
	var/list/not_interested = list()
	var/sentience_type = SENTIENCE_ORGANIC
	var/heat_stage = 0 //When used at stage 2 or above, the Sentience Potion explodes. Stop bugging ghosts

/obj/item/slimepotion/sentience/examine(mob/user)
	. = ..()
	if(!user.Adjacent(src))
		return

	switch(heat_stage)
		if(1)
			. += "<span class='warning'>The vial is hot to the touch.</span>"
		if(2)
			. += "<span class='warning'>The vial is scalding hot! Is it really a good idea to use this..?</span>"

/obj/item/slimepotion/sentience/attack()
	return

/obj/item/slimepotion/sentience/afterattack(mob/living/M, mob/user, proximity_flag)
	if(!proximity_flag)
		return
	if(being_used || !ismob(M))
		return
	if(!isanimal(M) || M.mind) //only works on animals that aren't player controlled
		to_chat(user, "<span class='warning'>[M] is already too intelligent for this to work!</span>")
		return ..()
	if(M.stat)
		to_chat(user, "<span class='warning'>[M] is dead!</span>")
		return ..()
	var/mob/living/simple_animal/SM = M
	if(SM.sentience_type != sentience_type)
		to_chat(user, "<span class='warning'>The potion won't work on [SM].</span>")
		return ..()

	if(heat_stage >= 2)
		to_chat(user, "<span class='danger'>[src] violently explodes!</span>")
		var/turf/T = get_turf(loc)
		if(T)
			T.hotspot_expose(700, 125)
			explosion(T, -1, -1, 2, 3)
		qdel(src)
		return
	to_chat(user, "<span class='notice'>You offer [src] sentience potion to [SM]...</span>")
	being_used = TRUE

	var/ghostmsg = "Play as [SM.name], pet of [user.name]?"
	var/list/candidates = SSghost_spawns.poll_candidates(ghostmsg, ROLE_SENTIENT, FALSE, 10 SECONDS, source = M)

	if(QDELETED(src) || QDELETED(SM))
		return

	if(candidates.len)
		var/mob/C = pick(candidates)
		SM.key = C.key
		SM.universal_speak = TRUE
		SM.faction = user.faction
		SM.master_commander = user
		SM.sentience_act()
		SM.can_collar = TRUE
		to_chat(SM, "<span class='warning'>All at once it makes sense: you know what you are and who you are! Self awareness is yours!</span>")
		to_chat(SM, "<span class='userdanger'>You are grateful to be self aware and owe [user] a great debt. Serve [user], and assist [user.p_them()] in completing [user.p_their()] goals at any cost.</span>")
		if(SM.flags_2 & HOLOGRAM_2) //Check to see if it's a holodeck creature
			to_chat(SM, "<span class='userdanger'>You also become depressingly aware that you are not a real creature, but instead a holoform. Your existence is limited to the parameters of the holodeck.</span>")
		to_chat(user, "<span class='notice'>[M] accepts the potion and suddenly becomes attentive and aware. It worked!</span>")
		after_success(user, SM)
		qdel(src)
	else
		to_chat(user, "<span class='notice'>[M] looks interested for a moment, but then looks back down. Maybe you should try again later.</span>")
		heat_stage += 1
		addtimer(CALLBACK(src, PROC_REF(cooldown_potion)), 60 SECONDS)
		if(user.Adjacent(src))
			switch(heat_stage)
				if(1)
					to_chat(user, "<span class='warning'>An intense heat emanates from [src]. It might need to cool off for awhile.</span>")
				if(2)
					to_chat(user, "<span class='warning'>[src] is boiling hot! You shudder to think what would happen if you used it again...</span>")
		being_used = FALSE
		..()

/obj/item/slimepotion/sentience/proc/cooldown_potion()
	if(!heat_stage)
		return

	heat_stage -= 1

/obj/item/slimepotion/sentience/proc/after_success(mob/living/user, mob/living/simple_animal/SM)
	return

/obj/item/slimepotion/transference
	name = "consciousness transference potion"
	desc = "A strange slime-based chemical that, when used, allows the user to transfer their consciousness to a lesser being."
	icon_state = "bottle19"
	origin_tech = "biotech=6"
	var/prompted = FALSE
	var/animal_type = SENTIENCE_ORGANIC

/obj/item/slimepotion/transference/afterattack(mob/living/M, mob/user, proximity_flag)
	if(!proximity_flag)
		return
	if(prompted || !ismob(M))
		return
	if(!isanimal(M) || M.ckey) //much like sentience, these will not work on something that is already player controlled
		to_chat(user, "<span class='warning'>[M] already has a higher consciousness!</span>")
		return ..()
	if(M.stat)
		to_chat(user, "<span class='warning'>[M] is dead!</span>")
		return ..()
	var/mob/living/simple_animal/SM = M
	if(SM.sentience_type != animal_type)
		to_chat(user, "<span class='warning'>You cannot transfer your consciousness to [SM].</span>") //no controlling machines
		return ..()
	if(jobban_isbanned(user, ROLE_SENTIENT))
		to_chat(user, "<span class='warning'>Your mind goes blank as you attempt to use the potion.</span>")
		return

	prompted = TRUE
	if(alert("This will permanently transfer your consciousness to [SM]. Are you sure you want to do this?",,"Yes","No")=="No")
		prompted = FALSE
		return

	to_chat(user, "<span class='notice'>You drink the potion then place your hands on [SM]...</span>")
	user.mind.transfer_to(SM)
	SM.universal_speak = TRUE
	SM.faction = user.faction
	SM.sentience_act() //Same deal here as with sentience
	SM.can_collar = TRUE
	user.death()
	to_chat(SM, "<span class='notice'>In a quick flash, you feel your consciousness flow into [SM]!</span>")
	to_chat(SM, "<span class='warning'>You are now [SM]. Your allegiances, alliances, and roles are still the same as they were prior to consciousness transfer!</span>")
	SM.name = "[SM.name] as [user.real_name]"
	qdel(src)

/obj/item/slimepotion/slime/steroid
	name = "slime steroid"
	desc = "A potent chemical mix that will cause a baby slime to generate more extract."
	icon_state = "bottle16"

/obj/item/slimepotion/slime/steroid/attack(mob/living/simple_animal/slime/M, mob/user)
	. = ..()
	if(!.)
		return

	if(M.is_adult) //Can't steroidify adults
		to_chat(user, "<span class='warning'>Only baby slimes can use the steroid!</span>")
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
	icon_state = "bottle17"

/obj/item/slimepotion/slime/stabilizer
	name = "slime stabilizer"
	desc = "A potent chemical mix that will reduce the chance of a slime mutating."
	icon_state = "bottle15"

/obj/item/slimepotion/slime/stabilizer/attack(mob/living/simple_animal/slime/M, mob/user)
	. = ..()
	if(!.)
		return

	if(M.mutation_chance == 0)
		to_chat(user, "<span class='warning'>The slime already has no chance of mutating!</span>")
		return ..()

	to_chat(user, "<span class='notice'>You feed the slime the stabilizer. It is now less likely to mutate.</span>")
	M.mutation_chance = clamp(M.mutation_chance-15,0,100)
	qdel(src)

/obj/item/slimepotion/slime/mutator
	name = "slime mutator"
	desc = "A potent chemical mix that will increase the chance of a slime mutating."
	icon_state = "bottle3"

/obj/item/slimepotion/slime/mutator/attack(mob/living/simple_animal/slime/M, mob/user)
	. = ..()
	if(!.)
		return

	if(M.mutator_used)
		to_chat(user, "<span class='warning'>This slime has already consumed a mutator, any more would be far too unstable!</span>")
		return ..()
	if(M.mutation_chance == 100)
		to_chat(user, "<span class='warning'>The slime is already guaranteed to mutate!</span>")
		return ..()

	to_chat(user, "<span class='notice'>You feed the slime the mutator. It is now more likely to mutate.</span>")
	M.mutation_chance = clamp(M.mutation_chance+12,0,100)
	M.mutator_used = TRUE
	qdel(src)

// Potion to make the slime go fast for about 20 seconds, by heating them up
// For the sake of its mechanics, it is a potion. Its effects cannot be stacked
/obj/item/slimepotion/speed
	name = "slime speed treat"
	desc = "A monkey-shaped treat that heats up your little slime friend!"
	icon_state = "slime_treat"

/obj/item/slimepotion/speed/attack(mob/living/simple_animal/slime/M, mob/user)
	. = ..()
	if(!.)
		return

	heat_up(M)

/obj/item/slimepotion/speed/proc/heat_up(mob/living/simple_animal/slime/M)
	M.visible_message("<span class='notice'>As [M] gobbles [src], it starts buzzing with joyful energy!</span>")
	M.bodytemperature = 550

	// We remain jittery even if we cool down for it was a good treat
	M.SetJitter(15 SECONDS, TRUE)
	qdel(src)

// Slimes can eat this by themselves, no need to feed them
/obj/item/slimepotion/speed/attack_slime(mob/living/simple_animal/slime/M)
	heat_up(M)

/obj/item/slimepotion/fireproof
	name = "slime chill potion"
	desc = "A potent chemical mix that will fireproof any article of clothing. Has three uses."
	icon_state = "bottle17"
	origin_tech = "biotech=5"
	resistance_flags = FIRE_PROOF
	var/uses = 3

/obj/item/slimepotion/fireproof/afterattack(obj/item/clothing/C, mob/user, proximity_flag)
	..()
	if(!proximity_flag)
		return
	if(!uses)
		qdel(src)
		return
	if(!istype(C))
		to_chat(user, "<span class='warning'>The potion can only be used on clothing!</span>")
		return
	if(C.max_heat_protection_temperature == FIRE_IMMUNITY_MAX_TEMP_PROTECT)
		to_chat(user, "<span class='warning'>[C] is already fireproof!</span>")
		return ..()
	to_chat(user, "<span class='notice'>You slather the blue gunk over [C], fireproofing it.</span>")
	C.name = "fireproofed [C.name]"
	C.color = "#000080"
	C.max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	C.heat_protection = C.body_parts_covered
	C.resistance_flags |= FIRE_PROOF
	uses --
	if(!uses)
		qdel(src)

/obj/item/slimepotion/fireproof/MouseDrop(obj/over_object)
	if(usr.incapacitated())
		return
	if(loc == usr && loc.Adjacent(over_object))
		afterattack(over_object, usr, TRUE)

/obj/effect/timestop
	anchored = TRUE
	name = "chronofield"
	desc = "ZA WARUDO"
	icon = 'icons/effects/160x160.dmi'
	icon_state = "time"
	layer = FLY_LAYER
	pixel_x = -64
	pixel_y = -64
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/mob/living/immune = list() // the one who creates the timestop is immune
	var/list/stopped_atoms = list()
	var/freezerange = 2
	var/duration = 140
	alpha = 125

/obj/effect/timestop/New()
	..()
	for(var/mob/living/M in GLOB.player_list)
		for(var/obj/effect/proc_holder/spell/aoe/conjure/timestop/T in M.mind.spell_list) //People who can stop time are immune to timestop
			immune |= M


/obj/effect/timestop/proc/timestop()
	playsound(get_turf(src), 'sound/magic/timeparadox2.ogg', 100, 1, -1)
	for(var/i in 1 to duration-1)
		for(var/A in orange (freezerange, loc))
			if(isliving(A))
				var/mob/living/M = A
				if(M in immune)
					continue
				M.notransform = TRUE
				M.anchored = TRUE
				if(ishostile(M))
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
	M.notransform = FALSE
	M.anchored = FALSE
	if(ishostile(M))
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
	w_class = WEIGHT_CLASS_NORMAL
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
	w_class = WEIGHT_CLASS_NORMAL
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
	desc = "A one use set of blueprints made of jelly like organic material. Extends the reach of the management console."
	color = "#2956B2"

/obj/item/areaeditor/blueprints/slime/edit_area()
	..()
	var/area/A = get_area(src)
	for(var/turf/T in A)
		T.color = "#7ea9ff"
	A.xenobiology_compatible = TRUE
	qdel(src)

/turf/simulated/floor/sepia
	slowdown = 2
	icon_state = "sepia"
	desc = "Time seems to flow very slowly around these tiles."
	floor_tile = /obj/item/stack/tile/sepia
