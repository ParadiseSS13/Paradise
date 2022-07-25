/obj/item/implant/uplink
	name = "uplink implant"
	desc = "Summon things."
	icon = 'icons/obj/radio.dmi'
	icon_state = "radio"
	origin_tech = "materials=4;magnets=4;programming=4;biotech=4;syndicate=5;bluespace=5"
	implant_data = new /datum/implant_fluff/uplink
	implant_state = "implant-syndicate"

/obj/item/implant/uplink/Initialize(mapload)
	hidden_uplink = new(src)
	hidden_uplink.uses = 10
	..()

/obj/item/implant/uplink/sit/Initialize(mapload)
	..()
	if(hidden_uplink)
		hidden_uplink.uplink_type = "sit"

/obj/item/implant/uplink/admin/Initialize(mapload)
	..()
	if(hidden_uplink)
		hidden_uplink.uplink_type = "admin"

/obj/item/implant/uplink/implant(mob/source)
	var/obj/item/implant/imp_e = locate(type) in source
	if(imp_e && imp_e != src)
		imp_e.hidden_uplink.uses += hidden_uplink.uses
		qdel(src)
		return TRUE

	if(..())
		hidden_uplink.uplink_owner="[source.key]"
		return TRUE
	return FALSE

/obj/item/implant/uplink/activate()
	if(hidden_uplink)
		hidden_uplink.check_trigger(imp_in)

/obj/item/implanter/uplink
	name = "implanter (uplink)"

/obj/item/implanter/uplink/Initialize(mapload)
	imp = new /obj/item/implant/uplink(src)
	..()

/obj/item/implantcase/uplink
	name = "implant case - 'Uplink'"
	desc = "A glass case containing an uplink implant."

/obj/item/implantcase/uplink/Initialize(mapload)
	imp = new /obj/item/implant/uplink(src)
	..()
