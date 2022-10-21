/turf/simulated/wall/cult
	name = "runed metal wall"
	desc = "A cold metal wall engraved with indecipherable symbols. Studying them causes your head to pound."
	icon = 'icons/turf/walls/cult_wall.dmi'
	icon_state = "cult_wall-0"
	base_icon_state = "cult_wall"
	smoothing_flags = SMOOTH_BITMASK
	canSmoothWith = null
	sheet_type = /obj/item/stack/sheet/runed_metal
	sheet_amount = 1
	girder_type = /obj/structure/girder/cult

/turf/simulated/wall/cult/Initialize(mapload)
	. = ..()
	if(SSticker.mode)//game hasn't started offically don't do shit..
		new /obj/effect/temp_visual/cult/turf(src)
		icon_state = SSticker.cultdat.cult_wall_icon_state

/turf/simulated/wall/cult/artificer
	name = "runed stone wall"
	desc = "A cold stone wall engraved with indecipherable symbols. Studying them causes your head to pound."

/turf/simulated/wall/cult/artificer/break_wall()
	new /obj/effect/temp_visual/cult/turf(get_turf(src))
	return null //excuse me we want no runed metal here

/turf/simulated/wall/cult/artificer/devastate_wall()
	new /obj/effect/temp_visual/cult/turf(get_turf(src))

/turf/simulated/wall/cult/narsie_act()
	return

/turf/simulated/wall/cult/devastate_wall()
	new sheet_type(get_turf(src), sheet_amount)

/turf/simulated/wall/rust
	name = "rusted wall"
	desc = "A rusted metal wall."
	icon = 'icons/turf/walls/rusty_wall.dmi'
	icon_state = "rusty_wall-0"
	base_icon_state = "rusty_wall"
	smoothing_flags = SMOOTH_BITMASK

/turf/simulated/wall/r_wall/rust
	name = "rusted reinforced wall"
	desc = "A huge chunk of rusted reinforced metal."
	icon = 'icons/turf/walls/rusty_reinforced_wall.dmi'
	icon_state = "rusty_reinforced_wall-0"
	base_icon_state = "rusty_reinforced_wall"
	smoothing_flags = SMOOTH_BITMASK

/turf/simulated/wall/r_wall/coated			//Coated for heat resistance
	name = "coated reinforced wall"
	desc = "A huge chunk of reinforced metal used to seperate rooms. It seems to have additional plating to protect against heat."
	icon = 'icons/turf/walls/coated_reinforced_wall.dmi'
	icon_state = "coated_reinforced_wall_0"
	base_icon_state = "coated_reinforced_wall"
	smoothing_flags = SMOOTH_BITMASK
	max_temperature = INFINITY

//Clockwork walls
/turf/simulated/wall/clockwork
	name = "clockwork wall"
	desc = "A huge chunk of warm metal. The clanging of machinery emanates from within."
	explosion_block = 2
	hardness = 10
	slicing_duration = 80
	sheet_type = /obj/item/stack/sheet/brass
	sheet_amount = 1
	girder_type = /obj/structure/clockwork/wall_gear
	baseturf = /turf/simulated/floor/clockwork
	var/heated
	var/obj/effect/clockwork/overlay/wall/realappearance
	smoothing_groups = list(SMOOTH_GROUP_WALLS, SMOOTH_GROUP_BRASS_WALL)
	canSmoothWith = list(SMOOTH_GROUP_BRASS_WALL)

/turf/simulated/wall/clockwork/Initialize()
	. = ..()
	new /obj/effect/temp_visual/ratvar/wall(src)
	new /obj/effect/temp_visual/ratvar/beam(src)
	realappearance = new /obj/effect/clockwork/overlay/wall(src)
	realappearance.linked = src

/turf/simulated/wall/clockwork/Destroy()
	QDEL_NULL(realappearance)
	return ..()

/turf/simulated/wall/clockwork/ReplaceWithLattice()
	..()
	for(var/obj/structure/lattice/L in src)
		L.ratvar_act()

/turf/simulated/wall/clockwork/narsie_act()
	..()
	if(istype(src, /turf/simulated/wall/clockwork)) //if we haven't changed type
		var/previouscolor = color
		color = "#960000"
		animate(src, color = previouscolor, time = 8)
		addtimer(CALLBACK(src, /atom/proc/update_atom_colour), 8)

/turf/simulated/wall/clockwork/dismantle_wall(devastated=0, explode=0)
	if(devastated)
		devastate_wall()
	else
		playsound(src, 'sound/items/welder.ogg', 100, 1)
		var/newgirder = break_wall()
		if(newgirder) //maybe we want a gear!
			transfer_fingerprints_to(newgirder)

	for(var/obj/O in src.contents) //Eject contents!
		if(istype(O, /obj/structure/sign/poster))
			var/obj/structure/sign/poster/P = O
			P.roll_and_drop(src)
		else
			O.forceMove(src)

	ChangeTurf(/turf/simulated/floor/clockwork)
	return TRUE

/turf/simulated/wall/clockwork/devastate_wall()
	new sheet_type(src, sheet_amount)

/turf/simulated/wall/clockwork/mech_melee_attack(obj/mecha/M)
	..()
	if(heated)
		to_chat(M.occupant, "<span class='userdanger'>The wall's intense heat completely reflects your [M.name]'s attack!</span>")
		M.take_damage(20, BURN)

/turf/simulated/wall/clockwork/proc/turn_up_the_heat()
	if(!heated)
		name = "superheated [name]"
		visible_message("<span class='warning'>[src] sizzles with heat!</span>")
		playsound(src, 'sound/machines/fryer/deep_fryer_emerge.ogg', 50, TRUE)
		heated = TRUE
		hardness = -100 //Lower numbers are tougher, so this makes the wall essentially impervious to smashing
		slicing_duration = 150
		animate(realappearance, color = "#FFC3C3", time = 5)
	else
		name = initial(name)
		visible_message("<span class='notice'>[src] cools down.</span>")
		heated = FALSE
		hardness = initial(hardness)
		slicing_duration = initial(slicing_duration)
		animate(realappearance, color = initial(realappearance.color), time = 25)
