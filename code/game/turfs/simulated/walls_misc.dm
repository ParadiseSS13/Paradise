/turf/simulated/wall/cult
	name = "runed metal wall"
	desc = "A cold metal wall engraved with indecipherable symbols. Studying them causes your head to pound."
	icon = 'icons/turf/walls/cult_wall.dmi'
	icon_state = "cult"
	builtin_sheet = null
	canSmoothWith = null
	smooth = SMOOTH_FALSE
	sheet_type = /obj/item/stack/sheet/runed_metal
	sheet_amount = 1
	girder_type = /obj/structure/girder/cult

/turf/simulated/wall/cult/New()
	..()
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
	icon_state = "arust"

/turf/simulated/wall/r_wall/rust
	name = "rusted reinforced wall"
	desc = "A huge chunk of rusted reinforced metal."
	icon = 'icons/turf/walls/rusty_reinforced_wall.dmi'
	icon_state = "rrust"

/turf/simulated/wall/r_wall/coated			//Coated for heat resistance
	name = "coated reinforced wall"
	desc = "A huge chunk of reinforced metal used to seperate rooms. It seems to have additional plating to protect against heat."
	icon = 'icons/turf/walls/coated_reinforced_wall.dmi'
	max_temperature = INFINITY

//Clockwork walls
/turf/simulated/wall/clockwork
	name = "clockwork wall"
	desc = "A huge chunk of warm metal. The clanging of machinery emanates from within."
	explosion_block = 2
	hardness = 10
	slicing_duration = 80
	sheet_type = /obj/item/stack/tile/brass
	sheet_amount = 1
	girder_type = /obj/structure/clockwork/wall_gear
	baseturf = /turf/simulated/floor/clockwork/reebe
	var/heated
	var/obj/effect/clockwork/overlay/wall/realappearance

/turf/simulated/wall/clockwork/Initialize()
	. = ..()
	new /obj/effect/temp_visual/ratvar/wall(src)
	new /obj/effect/temp_visual/ratvar/beam(src)
	realappearance = new /obj/effect/clockwork/overlay/wall(src)
	realappearance.linked = src

/turf/simulated/wall/clockwork/Destroy()
	if(realappearance)
		qdel(realappearance)
		realappearance = null

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
		ChangeTurf(baseturf)
	else
		playsound(src, 'sound/items/welder.ogg', 100, 1)
		var/newgirder = break_wall()
		if(newgirder) //maybe we want a gear!
			transfer_fingerprints_to(newgirder)
		ChangeTurf(baseturf)

	for(var/obj/O in src) //Eject contents!
		if(istype(O, /obj/structure/sign/poster))
			var/obj/structure/sign/poster/P = O
			P.roll_and_drop(src)
		else
			O.forceMove(src)

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
