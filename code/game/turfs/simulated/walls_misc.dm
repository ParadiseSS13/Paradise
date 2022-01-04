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
	if(SSticker.mode)//game hasn't started officially don't do shit..
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

//Clockwork walls
/turf/simulated/wall/clockwork
	name = "clockwork wall"
	desc = "A huge chunk of warm metal. The clanging of machinery emanates from within."
	explosion_block = 2
	hardness = 10
	slicing_duration = 80
	sheet_type = /obj/item/stack/tile/brass
	sheet_amount = 2
	girder_type = /obj/structure/clockwork/wall_gear
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

/turf/simulated/wall/clockwork/narsie_act()
	..()
	if(istype(src, /turf/simulated/wall/clockwork)) //if we haven't changed type
		var/previouscolor = color
		color = "#960000"
		animate(src, color = previouscolor, time = 8)
		addtimer(CALLBACK(src, /atom/proc/update_atom_colour), 8)

/turf/simulated/wall/clockwork/devastate_wall()
	for(var/i in 1 to 2)
		new/obj/item/clockwork/alloy_shards/large(src)
	for(var/i in 1 to 2)
		new/obj/item/clockwork/alloy_shards/medium(src)
	for(var/i in 1 to 3)
		new/obj/item/clockwork/alloy_shards/small(src)

/turf/simulated/wall/clockwork/attack_hulk(mob/living/user, does_attack_animation = 0)
	..()
	if(heated)
		to_chat(user, "<span class='userdanger'>The wall is searing hot to the touch!</span>")
		user.adjustFireLoss(5)
		playsound(src, 'sound/machines/fryer/deep_fryer_emerge.ogg', 50, TRUE)

/turf/simulated/wall/clockwork/mech_melee_attack(obj/mecha/M)
	..()
	if(heated)
		to_chat(M.occupant, "<span class='userdanger'>The wall's intense heat completely reflects your [M.name]'s attack!</span>")
		M.take_damage(20, BURN)
