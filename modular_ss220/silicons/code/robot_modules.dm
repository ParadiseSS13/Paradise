/obj/item/robot_module/drone/Initialize(mapload)
	. = ..()
	basic_modules |= list(
		/obj/item/holosign_creator/atmos,
		)

/obj/item/robot_module/engineering/Initialize(mapload)
	. = ..()
	basic_modules |= list(
		/obj/item/inflatable/cyborg,
		/obj/item/inflatable/cyborg/door,
		)


// надувные стены
/obj/item/inflatable/cyborg
	name = "надувная стена"
	desc = "Сложенная надувная стена, которая при активации быстро расширяется до большой кубической мембраны."
	var/power_use = 400
	var/structure_type = /obj/structure/inflatable

/obj/item/inflatable/cyborg/door
	name = "надувной шлюз"
	desc = "Сложенный надувной шлюз, который при активации быстро расширяется в простую дверь."
	icon_state = "folded_door"
	power_use = 600
	structure_type = /obj/structure/inflatable/door

/obj/item/inflatable/cyborg/examine(mob/user)
	. = ..()
	. += span_notice("Как синтетик, вы можете восстановить их в <b>cyborg recharger</b>")

/obj/item/inflatable/cyborg/attack_self(mob/user)
	if(locate(/obj/structure/inflatable) in get_turf(user))
		to_chat(user, span_warning("Здесь уже есть надувная стена!"))
		return FALSE

	playsound(loc, 'sound/items/zip.ogg', 75, 1)
	to_chat(user, span_notice("Вы надули [name]"))
	var/obj/structure/inflatable/R = new structure_type(user.loc)
	transfer_fingerprints_to(R)
	R.add_fingerprint(user)
	useResource(user)

/obj/item/inflatable/cyborg/proc/useResource(mob/user)
	if(!isrobot(user))
		return FALSE
	var/mob/living/silicon/robot/R = user
	if(R.cell.charge < power_use)
		to_chat(user, span_warning("Недостаточно заряда!"))
		return FALSE
	return R.cell.use(power_use)

//Небольшой багфикс "непрозрачного открытого шлюза"
/obj/structure/inflatable/door/operate()
	. = ..()
	opacity = FALSE
