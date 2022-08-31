//Exile implants will allow you to use the station gate, but not return home.
//This will allow security to exile badguys/for badguys to exile their kill targets

/obj/item/implant/exile
	name = "exile bio-chip"
	desc = "Prevents you from returning from away missions"
	origin_tech = "materials=2;biotech=3;magnets=2;bluespace=3"
	activated = BIOCHIP_ACTIVATED_PASSIVE

/obj/item/implant/exile/get_data()
	var/dat = {"<b>Bio-chip Specifications:</b><BR>
				<b>Name:</b> Nanotrasen Employee Exile Bio-chip<BR>
				<b>Bio-chip Details:</b> The onboard gateway system has been modified to reject entry by individuals containing this bio-chip<BR>"}
	return dat


/obj/item/implanter/exile
	name = "bio-chip implanter (exile)"

/obj/item/implanter/exile/New()
	imp = new /obj/item/implant/exile( src )
	..()

/obj/item/implantcase/exile
	name = "bio-chip case - 'Exile'"
	desc = "A glass case containing an exile bio-chip."

/obj/item/implantcase/exile/New()
	imp = new /obj/item/implant/exile(src)
	..()


/obj/structure/closet/secure_closet/exile
	name = "exile bio-chips"
	req_access = list(ACCESS_ARMORY)

/obj/structure/closet/secure_closet/exile/populate_contents()
	new /obj/item/implanter/exile(src)
	new /obj/item/implantcase/exile(src)
	new /obj/item/implantcase/exile(src)
	new /obj/item/implantcase/exile(src)
	new /obj/item/implantcase/exile(src)
	new /obj/item/implantcase/exile(src)
