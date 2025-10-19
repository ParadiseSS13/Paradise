/obj/item/pda/medical
	default_cartridge = /obj/item/cartridge/medical
	icon_state = "pda-medical"

/obj/item/pda/viro
	default_cartridge = /obj/item/cartridge/medical
	icon_state = "pda-virology"

/obj/item/pda/engineering
	default_cartridge = /obj/item/cartridge/engineering
	icon_state = "pda-engineer"

/obj/item/pda/security
	default_cartridge = /obj/item/cartridge/security
	icon_state = "pda-security"

/obj/item/pda/detective
	default_cartridge = /obj/item/cartridge/detective
	icon_state = "pda-detective"
	default_pen = /obj/item/pen/multi

/obj/item/pda/warden
	default_cartridge = /obj/item/cartridge/security
	icon_state = "pda-warden"
	default_pen = /obj/item/pen/multi

/obj/item/pda/janitor
	default_cartridge = /obj/item/cartridge/janitor
	icon_state = "pda-janitor"
	ttone = "slip"

/obj/item/pda/toxins
	default_cartridge = /obj/item/cartridge/signal/toxins
	icon_state = "pda-science"
	ttone = "boom"

/obj/item/pda/clown
	default_cartridge = /obj/item/cartridge/clown
	icon_state = "pda-clown"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. The surface is coated with polytetrafluoroethylene and banana drippings."
	ttone = "honk"

/obj/item/pda/clown/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/slippery, src, 16 SECONDS, 100)

/obj/item/pda/mime
	default_cartridge = /obj/item/cartridge/mime
	icon_state = "pda-mime"
	ttone = "silence"
	silent = TRUE

/obj/item/pda/heads
	default_cartridge = /obj/item/cartridge/head
	icon_state = "pda-h"

/obj/item/pda/heads/hop
	default_cartridge = /obj/item/cartridge/hop
	icon_state = "pda-hop"
	default_pen = /obj/item/pen/hop

/obj/item/pda/heads/hos
	default_cartridge = /obj/item/cartridge/hos
	icon_state = "pda-hos"
	default_pen = /obj/item/pen/hos

/obj/item/pda/heads/ce
	default_cartridge = /obj/item/cartridge/ce
	icon_state = "pda-ce"
	default_pen = /obj/item/pen/ce

/obj/item/pda/heads/cmo
	default_cartridge = /obj/item/cartridge/cmo
	icon_state = "pda-cmo"
	default_pen = /obj/item/pen/cmo

/obj/item/pda/heads/rd
	default_cartridge = /obj/item/cartridge/rd
	icon_state = "pda-rd"
	default_pen = /obj/item/pen/rd

/obj/item/pda/heads/qm
	default_cartridge = /obj/item/cartridge/qm
	icon_state = "pda-qm"
	default_pen = /obj/item/pen/qm

/obj/item/pda/captain
	default_cartridge = /obj/item/cartridge/captain
	icon_state = "pda-captain"
	detonate = FALSE
	default_pen = /obj/item/pen/cap
	//toff = 1

/obj/item/pda/heads/ntrep
	default_cartridge = /obj/item/cartridge/supervisor
	icon_state = "pda-ntr"
	default_pen = /obj/item/pen/multi/fountain

/obj/item/pda/heads/magistrate
	default_cartridge = /obj/item/cartridge/supervisor
	icon_state = "pda-magistrate"
	default_pen = /obj/item/pen/multi/gold

/obj/item/pda/heads/blueshield
	default_cartridge = /obj/item/cartridge/hos
	default_pen = /obj/item/pen/fancy

/obj/item/pda/heads/ert
	default_cartridge = /obj/item/cartridge/captain
	detonate = FALSE
	default_pen = /obj/item/pen/multi/fountain

/obj/item/pda/heads/ert/engineering
	icon_state = "pda-engineer"

/obj/item/pda/heads/ert/security
	icon_state = "pda-security"

/obj/item/pda/heads/ert/medical
	icon_state = "pda-medical"

/obj/item/pda/heads/ert/janitor
	icon_state = "pda-janitor"

/obj/item/pda/heads/ert/paranormal
	icon_state = "pda-chaplain"

/obj/item/pda/cargo
	default_cartridge = /obj/item/cartridge/cargo
	icon_state = "pda-cargo"

/obj/item/pda/shaftminer
	icon_state = "pda-miner"

/obj/item/pda/explorer
	icon_state = "pda-exp"

/obj/item/pda/syndicate
	default_cartridge = /obj/item/cartridge/syndicate/nuclear
	icon_state = "pda-syndi"
	name = "Military PDA"
	owner = "John Doe"
	default_pen = /obj/item/pen/multi/syndicate

/obj/item/pda/syndicate/New()
	..()
	var/datum/data/pda/app/messenger/M = find_program(/datum/data/pda/app/messenger)
	if(M)
		M.m_hidden = TRUE

/obj/item/pda/syndicate_fake
	icon_state = "pda-syndi"
	name = "Military PDA"
	default_pen = /obj/item/pen/multi/syndicate

/obj/item/pda/chaplain
	icon_state = "pda-chaplain"
	ttone = "holy"

/obj/item/pda/iaa
	default_cartridge = /obj/item/cartridge/iaa
	icon_state = "pda-iaa"
	ttone = "..."
	default_pen = /obj/item/pen/multi

/obj/item/pda/botanist
	//default_cartridge = /obj/item/cartridge/botanist
	icon_state = "pda-hydro"

/obj/item/pda/roboticist
	icon_state = "pda-roboticist"

/obj/item/pda/librarian
	icon_state = "pda-library"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. This is model is a WGW-11 series e-reader."
	model_name = "Thinktronic 5290 WGW-11 Series E-reader and Personal Data Assistant"
	silent = TRUE
	default_pen = /obj/item/pen/multi

/obj/item/pda/clear
	icon_state = "pda-clear"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. This is model is a special edition with a transparent case."
	model_name = "Thinktronic 5230 Personal Data Assistant Deluxe Special Max Turbo Limited Edition"

/obj/item/pda/chef
	default_cartridge = /obj/item/cartridge/chef
	icon_state = "pda-chef"

/obj/item/pda/bar
	icon_state = "pda-bartender"

/obj/item/pda/atmos
	default_cartridge = /obj/item/cartridge/atmos
	icon_state = "pda-atmos"

/obj/item/pda/chemist
	default_cartridge = /obj/item/cartridge/chemistry
	icon_state = "pda-chemistry"

/obj/item/pda/geneticist
	default_cartridge = /obj/item/cartridge/medical
	icon_state = "pda-genetics"

/obj/item/pda/centcom
	default_cartridge = /obj/item/cartridge/captain
	detonate = FALSE
	icon_state = "pda-h"
	default_pen = /obj/item/pen/multi/gold

/obj/item/pda/centcom/New()
	..()
	var/datum/data/pda/app/messenger/M = find_program(/datum/data/pda/app/messenger)
	if(M)
		M.m_hidden = 1
