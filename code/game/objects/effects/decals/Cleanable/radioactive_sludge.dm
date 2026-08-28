/obj/effect/decal/cleanable/radioactive_sludge
	gender = PLURAL
	name = "Radioactive Sludge"
	desc = "You should probably clean this up."
	icon_state = "greenglow"

/obj/effect/decal/cleanable/radioactive_sludge/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/inherent_radioactivity, 800, 800, 0, 1.5)

