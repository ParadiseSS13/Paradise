/obj/item/device/pda/medical
	default_cartridge = /obj/item/weapon/cartridge/medical
	icon_state = "pda-medical"

/obj/item/device/pda/viro
	default_cartridge = /obj/item/weapon/cartridge/medical
	icon_state = "pda-virology"

/obj/item/device/pda/engineering
	default_cartridge = /obj/item/weapon/cartridge/engineering
	icon_state = "pda-engineer"

/obj/item/device/pda/security
	default_cartridge = /obj/item/weapon/cartridge/security
	icon_state = "pda-security"

/obj/item/device/pda/detective
	default_cartridge = /obj/item/weapon/cartridge/detective
	icon_state = "pda-security"

/obj/item/device/pda/warden
	default_cartridge = /obj/item/weapon/cartridge/security
	icon_state = "pda-warden"

/obj/item/device/pda/janitor
	default_cartridge = /obj/item/weapon/cartridge/janitor
	icon_state = "pda-janitor"
	ttone = "slip"

/obj/item/device/pda/toxins
	default_cartridge = /obj/item/weapon/cartridge/signal/toxins
	icon_state = "pda-science"
	ttone = "boom"

/obj/item/device/pda/clown
	default_cartridge = /obj/item/weapon/cartridge/clown
	icon_state = "pda-clown"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. The surface is coated with polytetrafluoroethylene and banana drippings."
	ttone = "honk"

/obj/item/device/pda/clown/Crossed(AM as mob|obj) //Clown PDA is slippery.
	if(istype(AM, /mob/living/carbon))
		var/mob/living/carbon/M =	AM
		M.slip("pda", 8, 5, 0, 1)

/obj/item/device/pda/mime
	default_cartridge = /obj/item/weapon/cartridge/mime
	icon_state = "pda-mime"
	ttone = "silence"

/obj/item/device/pda/mime/New()
	..()
	var/datum/data/pda/app/M = find_program(/datum/data/pda/app/messenger)
	if(M)
		M.notify_silent = 1
	M = find_program(/datum/data/pda/app/chatroom)
	if(M)
		M.notify_silent = 1

/obj/item/device/pda/heads
	default_cartridge = /obj/item/weapon/cartridge/head
	icon_state = "pda-h"

/obj/item/device/pda/heads/hop
	default_cartridge = /obj/item/weapon/cartridge/hop
	icon_state = "pda-hop"

/obj/item/device/pda/heads/hos
	default_cartridge = /obj/item/weapon/cartridge/hos
	icon_state = "pda-hos"

/obj/item/device/pda/heads/ce
	default_cartridge = /obj/item/weapon/cartridge/ce
	icon_state = "pda-ce"

/obj/item/device/pda/heads/cmo
	default_cartridge = /obj/item/weapon/cartridge/cmo
	icon_state = "pda-cmo"

/obj/item/device/pda/heads/rd
	default_cartridge = /obj/item/weapon/cartridge/rd
	icon_state = "pda-rd"

/obj/item/device/pda/captain
	default_cartridge = /obj/item/weapon/cartridge/captain
	icon_state = "pda-captain"
	detonate = 0
	//toff = 1

/obj/item/device/pda/heads/ntrep
	default_cartridge = /obj/item/weapon/cartridge/supervisor
	icon_state = "pda-h"

/obj/item/device/pda/heads/magistrate
	default_cartridge = /obj/item/weapon/cartridge/supervisor
	icon_state = "pda-h"

/obj/item/device/pda/heads/blueshield
	default_cartridge = /obj/item/weapon/cartridge/hos
	icon_state = "pda-h"

/obj/item/device/pda/cargo
	default_cartridge = /obj/item/weapon/cartridge/quartermaster
	icon_state = "pda-cargo"

/obj/item/device/pda/quartermaster
	default_cartridge = /obj/item/weapon/cartridge/quartermaster
	icon_state = "pda-qm"

/obj/item/device/pda/shaftminer
	icon_state = "pda-miner"

/obj/item/device/pda/syndicate
	default_cartridge = /obj/item/weapon/cartridge/syndicate
	icon_state = "pda-syndi"
	name = "Military PDA"
	owner = "John Doe"

/obj/item/device/pda/syndicate/New()
	..()
	var/datum/data/pda/app/messenger/M = find_program(/datum/data/pda/app/messenger)
	if(M)
		M.m_hidden = 1

/obj/item/device/pda/chaplain
	icon_state = "pda-chaplain"
	ttone = "holy"

/obj/item/device/pda/lawyer
	default_cartridge = /obj/item/weapon/cartridge/lawyer
	icon_state = "pda-lawyer"
	ttone = "..."

/obj/item/device/pda/botanist
	//default_cartridge = /obj/item/weapon/cartridge/botanist
	icon_state = "pda-hydro"

/obj/item/device/pda/roboticist
	icon_state = "pda-roboticist"

/obj/item/device/pda/librarian
	icon_state = "pda-library"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. This is model is a WGW-11 series e-reader."
	model_name = "Thinktronic 5290 WGW-11 Series E-reader and Personal Data Assistant"

/obj/item/device/pda/librarian/New()
	..()
	var/datum/data/pda/app/M = find_program(/datum/data/pda/app/messenger)
	if(M)
		M.notify_silent = 1 //Quiet in the library!
	M = find_program(/datum/data/pda/app/chatroom)
	if(M)
		M.notify_silent = 1 //Quiet in the library!

/obj/item/device/pda/clear
	icon_state = "pda-transp"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. This is model is a special edition with a transparent case."
	model_name = "Thinktronic 5230 Personal Data Assistant Deluxe Special Max Turbo Limited Edition"

/obj/item/device/pda/chef
	icon_state = "pda-chef"

/obj/item/device/pda/bar
	icon_state = "pda-bartender"

/obj/item/device/pda/atmos
	default_cartridge = /obj/item/weapon/cartridge/atmos
	icon_state = "pda-atmos"

/obj/item/device/pda/chemist
	default_cartridge = /obj/item/weapon/cartridge/chemistry
	icon_state = "pda-chemistry"

/obj/item/device/pda/geneticist
	default_cartridge = /obj/item/weapon/cartridge/medical
	icon_state = "pda-genetics"

/obj/item/device/pda/centcom
	default_cartridge = /obj/item/weapon/cartridge/centcom
	icon_state = "pda-h"

//Some spare PDAs in a box
/obj/item/weapon/storage/box/PDAs
	name = "spare PDAs"
	desc = "A box of spare PDA microcomputers."
	icon = 'icons/obj/pda.dmi'
	icon_state = "pdabox"

/obj/item/weapon/storage/box/PDAs/New()
		..()
		new /obj/item/device/pda(src)
		new /obj/item/device/pda(src)
		new /obj/item/device/pda(src)
		new /obj/item/device/pda(src)
		new /obj/item/weapon/cartridge/head(src)

		var/newcart = pick(	/obj/item/weapon/cartridge/engineering,
							/obj/item/weapon/cartridge/security,
							/obj/item/weapon/cartridge/medical,
							/obj/item/weapon/cartridge/signal/toxins,
							/obj/item/weapon/cartridge/quartermaster)
		new newcart(src)