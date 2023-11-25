/obj/item/implant/uplink
	name = "uplink bio-chip"
	desc = "Summon things."
	icon = 'icons/obj/radio.dmi'
	icon_state = "radio"
	origin_tech = "materials=4;magnets=4;programming=4;biotech=4;syndicate=5;bluespace=5"
	implant_data = /datum/implant_fluff/uplink
	implant_state = "implant-syndicate"

/obj/item/implant/uplink/Initialize(mapload)
	. = ..()
	hidden_uplink = new(src)
	hidden_uplink.uses = 50

/obj/item/implant/uplink/nuclear/Initialize(mapload)
	. = ..()
	if(hidden_uplink)
		hidden_uplink.update_uplink_type(UPLINK_TYPE_NUCLEAR)

/obj/item/implant/uplink/sit/Initialize(mapload)
	. = ..()
	if(hidden_uplink)
		hidden_uplink.update_uplink_type(UPLINK_TYPE_SIT)

/obj/item/implant/uplink/admin/Initialize(mapload)
	. = ..()
	if(hidden_uplink)
		hidden_uplink.update_uplink_type(UPLINK_TYPE_ADMIN)


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
	name = "bio-chip implanter (uplink)"
	implant_type = /obj/item/implant/uplink

/obj/item/implantcase/uplink
	name = "bio-chip case - 'Syndicate Uplink'"
	desc = "A glass case containing an uplink bio-chip."
	implant_type = /obj/item/implant/uplink

/obj/item/implanter/nuclear
	name = "bio-chip implanter (Nuclear Agent Uplink)"
	implant_type = /obj/item/implant/uplink/nuclear

/obj/item/implantcase/nuclear
	name = "bio-chip case - 'Nuclear Agent Uplink'"
	implant_type = /obj/item/implant/uplink/nuclear
