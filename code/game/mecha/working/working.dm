/obj/mecha/working
	internal_damage_threshold = 60
	var/list/cargo = new
	var/cargo_capacity = 15

/obj/mecha/working/New()
	..()
	if(!ruin_mecha)
		trackers += new /obj/item/mecha_parts/mecha_tracking(src)

/obj/mecha/working/proc/collect_ore()
	if(locate(/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp) in equipment)
		var/obj/structure/ore_box/ore_box = locate(/obj/structure/ore_box) in cargo
		if(ore_box)
			for(var/obj/item/stack/ore/ore in range(1, src))
				if(ore.Adjacent(src) && ((get_dir(src, ore) & dir) || ore.loc == loc)) //we can reach it and it's in front of us? grab it!
					ore.forceMove(ore_box)

/obj/mecha/working/Topic(href, href_list)
	..()
	if(href_list["drop_from_cargo"])
		var/obj/O = locate(href_list["drop_from_cargo"])
		if(O && (O in cargo))
			occupant_message("<span class='notice'>You unload [O].</span>")
			O.loc = get_turf(src)
			cargo -= O
			var/turf/T = get_turf(O)
			if(T)
				T.Entered(O)
			log_message("Unloaded [O]. Cargo compartment capacity: [cargo_capacity - cargo.len]")
	return

/obj/mecha/working/Move()
	. = ..()
	if(.)
		collect_ore()

/obj/mecha/working/go_out()
	..()
	update_icon()

/obj/mecha/working/moved_inside(mob/living/carbon/human/H)
	..()
	update_icon()

/obj/mecha/working/mmi_moved_inside(obj/item/mmi/mmi_as_oc, mob/user)
	..()
	update_icon()

/obj/mecha/working/Exit(atom/movable/O)
	if(O in cargo)
		return 0
	return ..()

/obj/mecha/working/get_stats_part()
	var/output = ..()
	output += "<b>Cargo Compartment Contents:</b><div style=\"margin-left: 15px;\">"
	if(cargo.len)
		for(var/obj/O in cargo)
			output += "<a href='?src=[UID()];drop_from_cargo=\ref[O]'>Unload</a> : [O]<br>"
	else
		output += "Nothing"
	output += "</div>"
	return output

/obj/mecha/working/Destroy()
	for(var/mob/M in src)
		if(M == occupant)
			continue
		M.loc = get_turf(src)
		M.loc.Entered(M)
		step_rand(M)
	for(var/atom/movable/A in cargo)
		A.loc = get_turf(src)
		var/turf/T = get_turf(A)
		if(T)
			T.Entered(A)
		step_rand(A)
	return ..()

/obj/mecha/working/ex_act(severity)
	..()
	for(var/X in cargo)
		var/obj/O = X
		if(prob(30 / severity))
			cargo -= O
			O.forceMove(drop_location())
