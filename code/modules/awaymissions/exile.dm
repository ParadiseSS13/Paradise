//Exile implants will allow you to use the station gate, but not return home.
//This will allow security to exile badguys/for badguys to exile their kill targets

/obj/item/implant/exile
	name = "exile implant"
	desc = "Prevents you from returning from away missions"
	origin_tech = "materials=2;biotech=3;magnets=2;bluespace=3"
	activated = 0

/obj/item/implant/exile/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Nanotrasen Employee Exile Implant<BR>
				<b>Implant Details:</b> The onboard gateway system has been modified to reject entry by individuals containing this implant<BR>"}
	return dat


/obj/item/implanter/exile
	name = "implanter (exile)"

/obj/item/implanter/exile/New()
	imp = new /obj/item/implant/exile( src )
	..()

/obj/item/implantcase/exile
	name = "implant case - 'Exile'"
	desc = "A glass case containing an exile implant."

/obj/item/implantcase/exile/New()
	imp = new /obj/item/implant/exile(src)
	..()


/obj/structure/closet/secure_closet/exile
	name = "exile implants"
	req_access = list(ACCESS_ARMORY)

/obj/structure/closet/secure_closet/exile/New()
	..()
	new /obj/item/implanter/exile(src)
	new /obj/item/implantcase/exile(src)
	new /obj/item/implantcase/exile(src)
	new /obj/item/implantcase/exile(src)
	new /obj/item/implantcase/exile(src)
	new /obj/item/implantcase/exile(src)