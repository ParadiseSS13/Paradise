/obj/effect/decal/cleanable/radioactive_sludge
	gender = PLURAL
	name = "Radioactive Sludge"
	desc = "You should probably clean this up."
	icon_state = "greenglow"

/obj/effect/decal/cleanable/radioactive_sludge/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/inherent_radioactivity, 400, 400, 0, 1.5)

