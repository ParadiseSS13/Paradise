/obj/item/cartridge
	name = "generic cartridge"
	desc = "A data cartridge for portable microcomputers."
	icon = 'icons/obj/pda.dmi'
	icon_state = "cart"
	item_state = "electronic"
	w_class = WEIGHT_CLASS_TINY

	/// Integrated signaler for captain, science & generic signaler cartridge
	var/obj/item/assembly/signaler/integ_signaler

	var/charges = 0

	var/list/stored_data = list()
	var/list/programs = list()
	var/list/messenger_plugins = list()

/obj/item/cartridge/Destroy()
	QDEL_LIST_CONTENTS(programs)
	QDEL_LIST_CONTENTS(messenger_plugins)
	return ..()

/obj/item/cartridge/proc/update_programs(obj/item/pda/pda)
	for(var/A in programs)
		var/datum/data/pda/P = A
		P.pda = pda

	for(var/A in messenger_plugins)
		var/datum/data/pda/messenger_plugin/P = A
		P.pda = pda

/obj/item/cartridge/engineering
	name = "Power-ON Cartridge"
	desc = "A data cartridge for portable microcomputers. Has a power monitor and a halogen counter."
	icon_state = "cart-e"
	programs = list(
		new /datum/data/pda/app/power,
		new /datum/data/pda/utility/scanmode/halogen
	)

/obj/item/cartridge/atmos
	name = "BreatheDeep Cartridge"
	desc = "A data cartridge for portable microcomputers. Has a gas scanner."
	icon_state = "cart-a"
	programs = list(
		new /datum/data/pda/utility/scanmode/gas
	)

/obj/item/cartridge/medical
	name = "Med-U Cartridge"
	desc = "A data cartridge for portable microcomputers. Has medical records and a med scanner."
	icon_state = "cart-m"
	programs = list(
		new /datum/data/pda/app/crew_records/medical,
		new /datum/data/pda/utility/scanmode/medical
	)

/obj/item/cartridge/chemistry
	name = "ChemWhiz Cartridge"
	desc = "A data cartridge for portable microcomputers. Has a reagent scanner."
	icon_state = "cart-chem"
	programs = list(
		new /datum/data/pda/utility/scanmode/reagent
	)

/obj/item/cartridge/security
	name = "R.O.B.U.S.T. Cartridge"
	desc = "A data cartridge for portable microcomputers. Has security records and security bot control."
	icon_state = "cart-s"
	programs = list(
		new /datum/data/pda/app/crew_records/security,
		new /datum/data/pda/app/secbot_control
	)

/obj/item/cartridge/detective
	name = "D.E.T.E.C.T. Cartridge"
	desc = "A data cartridge for portable microcomputers. Has medical records, security records and a med scanner."
	icon_state = "cart-s"
	programs = list(
		new /datum/data/pda/app/crew_records/medical,
		new /datum/data/pda/utility/scanmode/medical,
		new /datum/data/pda/app/crew_records/security
	)


/obj/item/cartridge/janitor
	name = "CustodiPRO Cartridge"
	desc = "A data cartridge for portable microcomputers. Tracks custodial equipment."
	icon_state = "cart-j"
	programs = list(
		new /datum/data/pda/app/janitor
	)

/obj/item/cartridge/lawyer
	name = "P.R.O.V.E. Cartridge"
	desc = "A data cartridge for portable microcomputers. Has security records."
	icon_state = "cart-s"
	programs = list(
		new /datum/data/pda/app/crew_records/security
	)

/obj/item/cartridge/clown
	name = "Honkworks 5.0"
	desc = "A data cartridge for portable microcomputers. Has a virus sender to make anyones PDA honk on any action."
	icon_state = "cart-clown"
	charges = 5
	programs = list(
		new /datum/data/pda/utility/honk
	)
	messenger_plugins = list(
		new /datum/data/pda/messenger_plugin/virus/clown
	)

/obj/item/cartridge/mime
	name = "Gestur-O 1000"
	desc = "A data cartridge for portable microcomputers. Has a virus sender to mute anyones PDA."
	icon_state = "cart-mi"
	charges = 5
	messenger_plugins = list(
		new /datum/data/pda/messenger_plugin/virus/mime
	)

/obj/item/cartridge/signal
	name = "generic signaler cartridge"
	desc = "A data cartridge with an integrated radio signaler module."
	programs = list(
		new /datum/data/pda/app/signaller
	)

/obj/item/cartridge/signal/Initialize(mapload)
	. = ..()
	integ_signaler = new /obj/item/assembly/signaler(src)

/obj/item/cartridge/signal/toxins
	name = "Signal Ace 2"
	desc = "A data cartridge for portable microcomputers. Has a reagent scanner, gas scanner and signaler system."
	icon_state = "cart-tox"
	programs = list(
		new /datum/data/pda/utility/scanmode/gas,
		new /datum/data/pda/utility/scanmode/reagent,
		new /datum/data/pda/app/signaller
	)

/obj/item/cartridge/quartermaster
	name = "Space Parts & Space Vendors Cartridge"
	desc = "A data cartridge for portable microcomputers. Has supply records and MULEbot control."
	icon_state = "cart-q"
	programs = list(
		new /datum/data/pda/app/supply,
		new /datum/data/pda/app/mule_control
	)

/obj/item/cartridge/head
	name = "Easy-Record"
	desc = "A data cartridge for portable microcomputers. Has a status display controller."
	icon_state = "cart-h"
	programs = list(
		new /datum/data/pda/app/status_display
	)

/obj/item/cartridge/hop
	name = "HumanResources9001"
	desc = "A data cartridge for portable microcomputers. Has supply records, MULEbot control, a custodial locator and a status display controller."
	icon_state = "cart-h"
	programs = list(
		new /datum/data/pda/app/crew_records/security,
		new /datum/data/pda/app/janitor,
		new /datum/data/pda/app/supply,
		new /datum/data/pda/app/mule_control,
		new /datum/data/pda/app/status_display
	)

/obj/item/cartridge/hos
	name = "R.O.B.U.S.T. DELUXE"
	desc = "A data cartridge for portable microcomputers. Has security records, security bot control and a status display controller."
	icon_state = "cart-hos"
	programs = list(
		new /datum/data/pda/app/crew_records/security,
		new /datum/data/pda/app/secbot_control,
		new /datum/data/pda/app/status_display
	)

/obj/item/cartridge/ce
	name = "Power-On DELUXE"
	desc = "A data cartridge for portable microcomputers. Has a power monitor, gas scanner, halogen counter and status display controller."
	icon_state = "cart-ce"
	programs = list(
		new /datum/data/pda/app/power,
		new /datum/data/pda/utility/scanmode/halogen,
		new /datum/data/pda/utility/scanmode/gas,
		new /datum/data/pda/app/status_display
	)

/obj/item/cartridge/cmo
	name = "Med-U DELUXE"
	desc = "A data cartridge for portable microcomputers. Has medical records, a reagent scanner, med scanner and status display controller."
	icon_state = "cart-cmo"
	programs = list(
		new /datum/data/pda/app/crew_records/medical,
		new /datum/data/pda/utility/scanmode/medical,
		new /datum/data/pda/utility/scanmode/reagent,
		new /datum/data/pda/app/status_display
	)

/obj/item/cartridge/rd
	name = "Signal Ace DELUXE"
	desc = "A data cartridge for portable microcomputers. Has a reagent scanner, gas scanner, a status display controller and signaler system."
	icon_state = "cart-rd"
	programs = list(
		new /datum/data/pda/utility/scanmode/gas,
		new /datum/data/pda/utility/scanmode/reagent,
		new /datum/data/pda/app/signaller,
		new /datum/data/pda/app/status_display
	)

/obj/item/cartridge/rd/Initialize(mapload)
	. = ..()
	integ_signaler = new /obj/item/assembly/signaler(src)

/obj/item/cartridge/captain
	name = "Value-PAK Cartridge"
	desc = "A data cartridge for portable microcomputers. Has everything except a signaler system."
	icon_state = "cart-c"
	programs = list(
		new /datum/data/pda/app/power,
		new /datum/data/pda/utility/scanmode/halogen,
		new /datum/data/pda/utility/scanmode/gas,
		new /datum/data/pda/app/crew_records/medical,
		new /datum/data/pda/utility/scanmode/medical,
		new /datum/data/pda/utility/scanmode/reagent,
		new /datum/data/pda/app/crew_records/security,
		new /datum/data/pda/app/secbot_control,
		new /datum/data/pda/app/janitor,
		new /datum/data/pda/app/supply,
		new /datum/data/pda/app/status_display,
		new /datum/data/pda/app/signaller
	)

/obj/item/cartridge/captain/Initialize(mapload)
	. = ..()
	integ_signaler = new /obj/item/assembly/signaler(src)

/obj/item/cartridge/supervisor
	name = "Easy-Record DELUXE"
	desc = "A data cartridge for portable microcomputers. Has security records and a status display controller."
	icon_state = "cart-h"
	programs = list(
		new /datum/data/pda/app/crew_records/security,
		new /datum/data/pda/app/status_display
	)

/obj/item/cartridge/centcom
	name = "Value-PAK Cartridge"
	desc = "Now with 200% more value!"
	icon_state = "cart-c"
	programs = list(
		new /datum/data/pda/app/power,
		new /datum/data/pda/utility/scanmode/halogen,
		new /datum/data/pda/utility/scanmode/gas,
		new /datum/data/pda/app/crew_records/medical,
		new /datum/data/pda/utility/scanmode/medical,
		new /datum/data/pda/utility/scanmode/reagent,
		new /datum/data/pda/app/crew_records/security,
		new /datum/data/pda/app/secbot_control,
		new /datum/data/pda/app/janitor,
		new /datum/data/pda/app/supply,
		new /datum/data/pda/app/status_display
	)

/obj/item/cartridge/syndicate
	name = "Detomatix Cartridge"
	desc = "Allows you to remotely detonate other people's PDAs through the messenger program."
	icon_state = "cart"
	charges = 4
	messenger_plugins = list(new/datum/data/pda/messenger_plugin/virus/detonate)

/obj/item/cartridge/syndicate/nuclear //needed subtype so regular traitors can't open and close nuclear shuttle doors
	name = "Nuclear Agent Detomatix Cartridge"
	desc = "The same reliable Detomatix program except with the added ability of remotely toggling your nuclear shuttle airlock from your PDA"
	var/initial_remote_door_id = "smindicate" //Make sure this matches the syndicate shuttle's shield/door id!!	//don't ask about the name, testing.
	programs = list(
		new /datum/data/pda/utility/toggle_door
	)

/obj/item/cartridge/syndicate/nuclear/Initialize(mapload)
	. = ..()
	var/datum/data/pda/utility/toggle_door/D = programs[1]
	if(istype(D))
		D.remote_door_id = initial_remote_door_id

/obj/item/cartridge/frame
	name = "F.R.A.M.E. cartridge"
	desc = "Allows you to upload a virus onto a PDA with it's messenger on."
	icon_state = "cart"
	charges = 5
	var/telecrystals = 0
	messenger_plugins = list(
		new /datum/data/pda/messenger_plugin/virus/frame
	)

/obj/item/cartridge/mob_hunt_game
	name = "Nano-Mob Hunter GO! Cartridge"
	desc = "The hit new PDA game that lets you track down and capture your favorite Nano-Mobs living in your world!"
	icon_state = "cart-eye"
	programs = list(
		new /datum/data/pda/app/mob_hunter_game
	)

/obj/item/cartridge/mob_hunt_game/examine(mob/user)
	. = ..()
	if(emagged)
		if(isAntag(user))
			. += "<span class='warning'>This copy of Nano-Mob Hunter GO! has been hacked to allow the creation of trap mobs which will cause any PDA that attempts to capture it to shock anyone holding it. Hacked copies of the game will not trigger the trap. Provided you actually find someone playing nanomobs, that is.</span>"

/obj/item/cartridge/mob_hunt_game/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/nanomob_card))
		var/obj/item/nanomob_card/card = O
		var/datum/data/pda/app/mob_hunter_game/my_game = programs[1]

		if(my_game.register_capture(card.mob_data))
			to_chat(user, "<span class='notice'>Transfer successful!</span>")
			qdel(card)
		else
			to_chat(user, "<span class='warning'>Transfer failed. Could not read mob data from card.</span>")

	else
		..()

/obj/item/cartridge/mob_hunt_game/emag_act(mob/user)
	if(!emagged)
		emagged = TRUE
		var/datum/data/pda/app/mob_hunter_game/my_game = programs[1]
		my_game.hacked = TRUE
		to_chat(user, "<span class='warning'>TR4P_M45T3R.mod successfully initialized. ToS violated. User Agreement nullified. Gotta pwn them all.</span>")
		to_chat(user, "<span class='warning'>You can now create trapped versions of any mob in your collection that will damage hunters who attempt to capture it.</span>")
