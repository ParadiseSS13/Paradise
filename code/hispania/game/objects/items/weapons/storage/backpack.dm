/obj/item/storage/backpack/New()
	..()
	icon = (hispania_icon ? 'icons/hispania/obj/storage/storage.dmi' : icon)
	lefthand_file = (hispania_icon ? 'icons/hispania/mob/inhands/clothing_lefthand.dmi' : lefthand_file)
	righthand_file = (hispania_icon ? 'icons/hispania/mob/inhands/clothing_righthand.dmi' : righthand_file)

/obj/item/storage/backpack/welderpack
	name = "welderpack"
	desc = "A specialized backpack worn by technicians. It carries a fueltank for quick welder refueling and use."
	icon = 'icons/hispania/obj/storage/storage.dmi'
	icon_state = "welderbackpack"
	item_state = "welderbackpack"
	hispania_icon = TRUE
	var/max_fuel = 200
	var/fuel_type = "fuel"

/obj/item/storage/backpack/welderpack/Initialize()
	. = ..()
	create_reagents(max_fuel)
	reagents.add_reagent(fuel_type, max_fuel)

/obj/item/storage/backpack/welderpack/examine(mob/user)
	. = ..()
	if(get_dist(user, src) <= 0)
		. += "It contains [GET_FUEL] unit\s of fuel out of [max_fuel]."

/obj/item/storage/backpack/welderpack/proc/boom()
	visible_message("<span class='danger'>[src] ruptures!</span>")
	chem_splash(loc, 5, list(reagents))
	qdel(src)

/obj/item/storage/backpack/welderpack/boom(log_attack = FALSE)
	if(log_attack)
		add_attack_logs(usr, src, "blew up", ATKLOG_FEW)
	if(reagents)
		reagents.set_reagent_temp(1000) //hahahaha
	qdel(src)

/obj/item/storage/backpack/welderpack/attacked_by(obj/item/I, mob/living/user)
	..()
	if(istype(I, /obj/item/weldingtool))
		return TRUE

/obj/item/storage/backpack/welderpack/welder_act(mob/living/user, obj/item/I)
	if(!reagents.has_reagent("fuel"))
		to_chat(user, "<span class='warning'>[src] is out of fuel!</span>")
		return
	if(I.tool_enabled && I.use_tool(src, user, volume = I.tool_volume))
		user.visible_message("<span class='danger'>[user] catastrophically fails at refilling [user.p_their()] [I]!</span>", "<span class='userdanger'>That was stupid of you.</span>")
		message_admins("[key_name_admin(user)] triggered a welderpack explosion at [COORD(loc)]")
		log_game("[key_name(user)] triggered a welderpack explosion at [COORD(loc)]")
		add_attack_logs(user, src, "hit with lit welder")
		investigate_log("[key_name(user)] triggered a fueltank explosion at [COORD(loc)]", INVESTIGATE_BOMB)
		boom()
	else
		I.refill(user, src, reagents.get_reagent_amount("fuel"))

/obj/item/storage/backpack/welderpack/afterattack(atom/target, mob/user, proximity, params)
	. = ..()
	if(!proximity)
		return
	if(istype(target, /obj/structure/reagent_dispensers/fueltank) && src.reagents.total_volume < max_fuel)
		target.reagents.trans_to(src, max_fuel)
		to_chat(user, ("<span class='notice'> You crack the cap off the top of the pack and fill it back up again from the tank. </span>"))
		playsound(loc, 'sound/effects/refill.ogg', 25, TRUE, 3)
		return
	else if(istype(target, /obj/structure/reagent_dispensers/fueltank) && src.reagents.total_volume == max_fuel)
		to_chat(user, ("<span class='notice'> The pack is already full! </span>"))
		return
