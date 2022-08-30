//Exile implants will allow you to use the station gate, but not return home.
//This will allow security to exile badguys/for badguys to exile their kill targets

/obj/item/implant/exile
	name = "exile microchip"
	desc = "Prevents you from returning from away missions"
	origin_tech = "materials=2;biotech=3;magnets=2;bluespace=3"
	activated = MICROCHIP_ACTIVATED_PASSIVE

/obj/item/implant/exile/get_data()
	var/dat = {"<b>Microchip Specifications:</b><BR>
				<b>Name:</b> Nanotrasen Employee Exile Microchip<BR>
				<b>Microchip Details:</b> The onboard gateway system has been modified to reject entry by individuals containing this microchip<BR>"}
	return dat


/obj/item/implanter/exile
	name = "microchip implanter (exile)"

/obj/item/implanter/exile/New()
	imp = new /obj/item/implant/exile( src )
	..()

/obj/item/implantcase/exile
	name = "microchip case - 'Exile'"
	desc = "A glass case containing an exile microchip."

/obj/item/implantcase/exile/New()
	imp = new /obj/item/implant/exile(src)
	..()


/obj/structure/closet/secure_closet/exile
	name = "exile microchips"
	req_access = list(ACCESS_ARMORY)

/obj/structure/closet/secure_closet/exile/populate_contents()
	new /obj/item/implanter/exile(src)
	new /obj/item/implantcase/exile(src)
	new /obj/item/implantcase/exile(src)
	new /obj/item/implantcase/exile(src)
	new /obj/item/implantcase/exile(src)
	new /obj/item/implantcase/exile(src)
