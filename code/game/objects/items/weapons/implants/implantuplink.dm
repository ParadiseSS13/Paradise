/obj/item/implant/uplink
	name = "uplink implant"
	desc = "Summon things."
	icon = 'icons/obj/radio.dmi'
	icon_state = "radio"
	origin_tech = "materials=4;magnets=4;programming=4;biotech=4;syndicate=5;bluespace=5"

/obj/item/implant/uplink/New()
	uplink = new /datum/uplink(src)
	uplink.crystals = 10
	..()

/obj/item/implant/uplink/sit/New()
	..()
	uplink = new /datum/uplink/sst(src)

/obj/item/implant/uplink/admin/New()
	..()
	uplink = new /datum/uplink/admin(src)

/obj/item/implant/uplink/implant(mob/source)
	var/obj/item/implant/imp_e = locate(src.type) in source
	if(imp_e && imp_e != src)
		imp_e.uplink.crystals += uplink.crystals
		qdel(src)
		return 1

	if(..())
		uplink.uplink_owner="[source.key]"
		return 1
	return 0

/obj/item/implant/uplink/activate()
	if(uplink)
		uplink.check_trigger(imp_in)


/obj/item/implanter/uplink
	name = "implanter (uplink)"

/obj/item/implanter/uplink/New()
	imp = new /obj/item/implant/uplink(src)
	..()
