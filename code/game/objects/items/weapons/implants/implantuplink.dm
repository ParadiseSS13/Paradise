/obj/item/implant/uplink
	name = "uplink implant"
	desc = "Summon things."
	icon = 'icons/obj/radio.dmi'
	icon_state = "radio"
	origin_tech = "materials=4;magnets=4;programming=4;biotech=4;syndicate=5;bluespace=5"

/obj/item/implant/uplink/New()
	hidden_uplink = new(src)
	hidden_uplink.uses = 10
	..()

/obj/item/implant/uplink/sit/New()
	..()
	if(hidden_uplink)
		hidden_uplink.uplink_type = "sit"

/obj/item/implant/uplink/admin/New()
	..()
	if(hidden_uplink)
		hidden_uplink.uplink_type = "admin"

/obj/item/implant/uplink/implant(mob/source)
	var/obj/item/implant/imp_e = locate(src.type) in source
	if(imp_e && imp_e != src)
		imp_e.hidden_uplink.uses += hidden_uplink.uses
		qdel(src)
		return 1

	if(..())
		hidden_uplink.uplink_owner="[source.key]"
		return 1
	return 0

/obj/item/implant/uplink/activate()
	if(hidden_uplink)
		hidden_uplink.check_trigger(imp_in)


/obj/item/implanter/uplink
	name = "implanter (uplink)"

/obj/item/implanter/uplink/New()
	imp = new /obj/item/implant/uplink(src)
	..()
