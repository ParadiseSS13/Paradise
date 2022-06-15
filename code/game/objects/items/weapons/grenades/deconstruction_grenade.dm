#define DECON_WALL		"toggle deconstruct walls"
#define DECON_DOOR		"toggle deconstruct airlocks"
#define DECON_WINDOWS	"toggle deconstruct windows"
#define RECYCLE			"toggle recycle items"
#define CONSUME_ALL		"toggle destroy unrecycleable items"
#define DECONSTRUCT_ATTEMPTS 3

/obj/item/grenade/deconstruction
	name = "material repossession device"
	desc = "The R-3 material repossession device was designed by NT to remove unwanted constructions from their stations, and reclaim the materials from it. Can be configured to deconstruct walls and windows as well."
	icon_state = "deconstruction_core" //So when activated it looks like it has a core in it, otherwise we change to base on initialize
	w_class = WEIGHT_CLASS_NORMAL
	atom_say_verb = "beeps"
	bubble_icon = "swarmer"
	det_time = 10 SECONDS
	light_power = 4
	var/obj/item/assembly/signaler/anomaly/vortex/core = null
	var/obj/item/radio/radio //Internal radio to annouce to engineering when used / where

	var/recycle = FALSE //If true, it will consume all the building materials dropped from deconstruction that have mineral value, and recycle them. A configureable option, incase someone wants the stock parts or something else inside.
	var/consume_all = FALSE //If true, this will consumue EVERY ITEM that is not indestructable. Good for cleaning... or sabatoge.
	var/deconstruct_walls = FALSE
	var/deconstruct_doors = FALSE
	var/deconstruct_windows = FALSE

	var/on_cooldown = FALSE

/obj/item/grenade/deconstruction/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/material_container, list(MAT_METAL, MAT_GLASS, MAT_PLASMA, MAT_SILVER, MAT_GOLD, MAT_DIAMOND, MAT_URANIUM, MAT_BANANIUM, MAT_TRANQUILLITE, MAT_TITANIUM, MAT_PLASTIC, MAT_BLUESPACE), 0, TRUE, null, null, null, TRUE)
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	materials.max_amount = 150000 //stack is 100000, and it dumps after each item, so it should be impossible to overfill
	radio = new /obj/item/radio(src)
	radio.listening = 0
	radio.config(list("Engineering" = 0))
	icon_state = "deconstruction"

/obj/item/grenade/deconstruction/Destroy()
	QDEL_NULL(core)
	QDEL_NULL(radio)
	return ..()

/obj/item/grenade/deconstruction/attack_self(mob/user as mob)
	var/area/A = get_area(src)
	if(!core)
		atom_say("ERROR. No vortex core detected. Activation faliure.")
		return
	if(on_cooldown)
		atom_say("Internal capacitors still recharging. Please hold.")
		return
	if(!user.drop_item())
		to_chat(user, "<span class='warning'>[src] is stuck to your hand!</span>")
		return
	else
		atom_say("Area repossession commencing. Please clear the area.") // sound / visuals after
		if(!emagged)
			announce_radio_message("Begining authorised repossession in [A.name]!")
		else
			announce_radio_message("Begining authorised agressive repossession in [Gibberish(A.name, 90)]!")
		anchored = TRUE
		set_light(8)
		playsound(loc, 'sound/machines/warning-buzzer.ogg', 60, 0)
		addtimer(CALLBACK(GLOBAL_PROC, .proc/playsound, loc, 'sound/machines/warning-buzzer.ogg', 60, 0), 3.5 SECONDS)
		addtimer(CALLBACK(GLOBAL_PROC, .proc/playsound, loc, 'sound/machines/warning-buzzer.ogg', 60, 0), 7 SECONDS)//So the alarm plays 3 times
	return ..()

/obj/item/grenade/deconstruction/attack_hand(mob/user)
	if(active)
		to_chat(user, "<span class='notice'>You deactivate [src]</span>")
		unprime()
		atom_say("Repossession aborted. Have a Nanotrasen Day.")
		announce_radio_message("Repossession aborted.")
		playsound(loc, 'sound/machines/terminal_off.ogg', 60, 0)
	else
		return ..()

/obj/item/grenade/deconstruction/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/assembly/signaler/anomaly/vortex))
		if(core)
			to_chat(user, "<span class='notice'>[src] already has a [O]!</span>")
			return
		if(!user.drop_item())
			to_chat(user, "<span class='warning'>[O] is stuck to your hand!</span>")
			return
		to_chat(user, "<span class='notice'>You insert [O] into [src], and [src] starts to warm up.</span>")
		O.forceMove(src)
		core = O
		icon_state = "deconstruction_core"
		update_icon()

/obj/item/grenade/deconstruction/CtrlClick(mob/living/L)
	radial_menu(L)

/obj/item/grenade/deconstruction/proc/radial_menu(mob/user)
	if(!check_menu(user))
		return
	var/list/choices = list(
		DECON_DOOR = image(icon = 'icons/obj/interface.dmi', icon_state = "airlock"),
		CONSUME_ALL = image(icon = 'icons/obj/interface.dmi', icon_state = "trash"),
		DECON_WINDOWS = image(icon = 'icons/obj/interface.dmi', icon_state = "grillewindow"),
		DECON_WALL = image(icon = 'icons/obj/interface.dmi', icon_state = "wall"),
		RECYCLE = image(icon = 'icons/obj/interface.dmi', icon_state = "recycle")
	)
	var/outcome = "on"
	var/choice = show_radial_menu(user, src, choices, custom_check = CALLBACK(src, .proc/check_menu, user))
	if(!check_menu(user))
		return
	switch(choice)
		if(DECON_DOOR)
			if(deconstruct_doors)
				deconstruct_doors = FALSE
				outcome = "off"
			else
				deconstruct_doors = TRUE
		if(CONSUME_ALL)
			if(consume_all)
				consume_all = FALSE
				outcome = "off"
			else
				consume_all = TRUE
		if(DECON_WINDOWS)
			if(deconstruct_windows)
				deconstruct_windows = FALSE
				outcome = "off"
			else
				deconstruct_windows = TRUE
		if(DECON_WALL)
			if(deconstruct_walls)
				deconstruct_walls = FALSE
				outcome = "off"
			else
				deconstruct_walls = TRUE
		if(RECYCLE)
			if(recycle)
				recycle = FALSE
				outcome = "off"
			else
				recycle = TRUE

	playsound(src, 'sound/effects/pop.ogg', 50, 0)
	if(choice)
		to_chat(user, "<span class='notice'>You [choice] to '[outcome]'.</span>")

/obj/item/grenade/deconstruction/proc/check_menu(mob/living/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated() || !user.Adjacent(src))
		return FALSE
	return TRUE

/obj/item/grenade/deconstruction/prime()
	if(!active) //For if it has been deactivated
		return
	unprime()
	if(get_turf(src) == level_name_to_num(CENTCOMM)) //Safety first.
		atom_say("Activation denied: Area does not need repossession ")
		return
	deconstruct_obj(DECONSTRUCT_ATTEMPTS)
	addtimer(CALLBACK(src, .proc/reboot), 60 SECONDS)
	on_cooldown = TRUE

/obj/item/grenade/deconstruction/unprime()
	..()
	anchored = FALSE
	set_light(0)

/obj/item/grenade/deconstruction/proc/deconstruct_obj(loops = 0) //We want structures fully deconstructed, no frames or anything, so multiple go arounds.
	if(deconstruct_walls)
		for(var/turf/simulated/wall/W in view(7, src))
			var/area/A = get_turf(src)
			if(W.safety_check() && !emagged)
				continue
			if(istype(A, /area/engine/supermatter) & !emagged)
				continue
			if(loops == DECONSTRUCT_ATTEMPTS) //We only want to do this on first go so we don't display frames disapering
				new /obj/effect/temp_visual/fadeout(get_turf(W), W)
			W.dismantle_wall() //Indestructible walls overide this to false

	for(var/obj/structure/S in view(7, src)) //Two runs for objects of structures and machinery, so we don't try to disasemble mechs, or items, or some other strange typepath.
		var/area/A = get_turf(src)
		if(S.resistance_flags & INDESTRUCTIBLE)
			continue
		if(S.safety_check() && !emagged)
			continue
		if(istype(A, /area/engine/supermatter) & !emagged)
			continue
		if(istype(S, /obj/structure/window) && !deconstruct_windows)
			continue
		if(istype(S, /obj/structure/blob) && !istype(S, /obj/structure/blob/normal)) //I'll let it work on weak blobs, but not on any strong blob structures.
			continue
		if(S.invisibility > INVISIBILITY_HIDDEN_RUNES) //for those weird invisible structures that control stuff (looking at you spacevines)
			continue
		if(loops == DECONSTRUCT_ATTEMPTS)
			new /obj/effect/temp_visual/fadeout(get_turf(S), S)
		S.deconstruct(TRUE)

	for(var/obj/machinery/O in view(7, src))
		var/area/A = get_turf(src)
		if(O.resistance_flags & INDESTRUCTIBLE)
			continue
		if(O.safety_check() && !emagged)
			continue
		if(istype(A, /area/engine/supermatter) & !emagged)
			continue
		if(istype(O, /obj/machinery/door) && !deconstruct_doors)
			continue
		if(loops == DECONSTRUCT_ATTEMPTS)
			new /obj/effect/temp_visual/fadeout(get_turf(O), O)
		O.deconstruct(TRUE)

	if(loops)
		deconstruct_obj(loops - 1)

	else if(recycle || consume_all)
		deconstruct_items()

/obj/item/grenade/deconstruction/proc/deconstruct_items()
	for(var/obj/item/I in oview(7, src))
		if(I.resistance_flags & INDESTRUCTIBLE) //No eating objective items, thank you.
			continue
		if(length(I.materials) || consume_all)
			var/list/curently_recycling = list(I) //This needs to be done to handle everything inside boxes and bags nicely
			curently_recycling += I.GetAllContents()
			curently_recycling = reverselist(curently_recycling) //Deconstruct the stuff in the box in the bag, then the box, then the bag.
			for(var/atom/movable/A in curently_recycling)
				if(!istype(A, /obj/item)&& isliving(A))
					A.forceMove(get_turf(A)) //soul in a soul shard, for example
					continue
				var/obj/item/O = A
				if(QDELETED(O))
					continue
				else if(isliving(O))
					O.forceMove(get_turf(O))
					continue
				if(O.resistance_flags & INDESTRUCTIBLE)
					O.forceMove(get_turf(O)) //No eating objective items in bags
					continue
				var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
				var/material_amount = materials.get_item_material_amount(O)
				if(!material_amount)
					qdel(O)
					continue
				materials.insert_item(O, multiplier = 0.8) //Slight material loss, but still incredibly good.
				qdel(O)
				materials.retrieve_all()


/obj/item/grenade/deconstruction/proc/reboot()
	on_cooldown = FALSE
	atom_say("Capacitors charged. System ready for repossession")

/obj/item/grenade/deconstruction/emag_act(user as mob)
	if(!emagged)
		atom_say("Safeties disabled. Agressive repossession enabled, location reporting scrambled.")
		emagged = TRUE
	else
		atom_say("System reset to default settings.")
		emagged = FALSE

/obj/item/grenade/deconstruction/proc/announce_radio_message(message)
	radio.autosay(message, name, "Engineering", list(z))


/obj/effect/temp_visual/fadeout
	duration = 2.5 SECONDS

/obj/effect/temp_visual/fadeout/New(loc, atom/target)
	..()
	icon = target.icon
	icon_state = target.icon_state
	alpha = target.alpha * 0.66
	dir = target.dir
	update_icon()
	addtimer(CALLBACK(src, .proc/fade, 4), 0.5 SECONDS)

/obj/effect/temp_visual/fadeout/proc/fade(loops)
	alpha = alpha * 0.66
	loops -= 1
	if(loops > 0)
		addtimer(CALLBACK(src, .proc/fade, loops), 0.5 SECONDS)


#undef DECON_WALL
#undef DECON_DOOR
#undef DECON_WINDOWS
#undef RECYCLE
#undef CONSUME_ALL
#undef DECONSTRUCT_ATTEMPTS
