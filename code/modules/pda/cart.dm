/obj/item/weapon/cartridge
	name = "generic cartridge"
	desc = "A data cartridge for portable microcomputers."
	icon = 'icons/obj/pda.dmi'
	icon_state = "cart"
	item_state = "electronic"
	w_class = 1

	var/obj/item/radio/integrated/radio = null

	var/charges = 0

	var/list/stored_data = list()
	var/list/programs = list()
	var/list/messenger_plugins = list()

/obj/item/weapon/cartridge/New()
	if(ticker && ticker.current_state >= GAME_STATE_SETTING_UP)
		initialize()

/obj/item/weapon/cartridge/initialize()
	if(radio)
		radio.initialize()
	..()

/obj/item/weapon/cartridge/Destroy()
	QDEL_NULL(radio)
	for(var/A in programs)
		qdel(A)
	programs.Cut()
	for(var/A in messenger_plugins)
		qdel(A)
	messenger_plugins.Cut()
	return ..()

/obj/item/weapon/cartridge/proc/update_programs(obj/item/device/pda/pda)
	for(var/A in programs)
		var/datum/data/pda/P = A
		P.pda = pda
	for(var/A in messenger_plugins)
		var/datum/data/pda/messenger_plugin/P = A
		P.pda = pda

/obj/item/weapon/cartridge/engineering
	name = "Power-ON Cartridge"
	icon_state = "cart-e"
	programs = list(
		new/datum/data/pda/app/power,
		new/datum/data/pda/utility/scanmode/halogen)

/obj/item/weapon/cartridge/atmos
	name = "BreatheDeep Cartridge"
	icon_state = "cart-a"
	programs = list(new/datum/data/pda/utility/scanmode/gas)

/obj/item/weapon/cartridge/medical
	name = "Med-U Cartridge"
	icon_state = "cart-m"
	programs = list(
		new/datum/data/pda/app/crew_records/medical,
		new/datum/data/pda/utility/scanmode/medical)

/obj/item/weapon/cartridge/chemistry
	name = "ChemWhiz Cartridge"
	icon_state = "cart-chem"
	programs = list(new/datum/data/pda/utility/scanmode/reagent)

/obj/item/weapon/cartridge/security
	name = "R.O.B.U.S.T. Cartridge"
	icon_state = "cart-s"
	programs = list(
		new/datum/data/pda/app/crew_records/security,
		new/datum/data/pda/app/secbot_control)

/obj/item/weapon/cartridge/security/initialize()
	radio = new /obj/item/radio/integrated/beepsky(src)
	..()

/obj/item/weapon/cartridge/detective
	name = "D.E.T.E.C.T. Cartridge"
	icon_state = "cart-s"
	programs = list(
		new/datum/data/pda/app/crew_records/medical,
		new/datum/data/pda/utility/scanmode/medical,

		new/datum/data/pda/app/crew_records/security)


/obj/item/weapon/cartridge/janitor
	name = "CustodiPRO Cartridge"
	desc = "The ultimate in clean-room design."
	icon_state = "cart-j"
	programs = list(new/datum/data/pda/app/janitor)

/obj/item/weapon/cartridge/lawyer
	name = "P.R.O.V.E. Cartridge"
	icon_state = "cart-s"
	programs = list(new/datum/data/pda/app/crew_records/security)

/obj/item/weapon/cartridge/clown
	name = "Honkworks 5.0"
	icon_state = "cart-clown"
	charges = 5
	programs = list(new/datum/data/pda/utility/honk)
	messenger_plugins = list(new/datum/data/pda/messenger_plugin/virus/clown)

/obj/item/weapon/cartridge/mime
	name = "Gestur-O 1000"
	icon_state = "cart-mi"
	charges = 5
	messenger_plugins = list(new/datum/data/pda/messenger_plugin/virus/mime)

/*
/obj/item/weapon/cartridge/botanist
	name = "Green Thumb v4.20"
	icon_state = "cart-b"
	access_flora = 1
*/

/obj/item/weapon/cartridge/signal
	name = "generic signaler cartridge"
	desc = "A data cartridge with an integrated radio signaler module."
	programs = list(new/datum/data/pda/app/signaller)

/obj/item/weapon/cartridge/signal/initialize()
	radio = new /obj/item/radio/integrated/signal(src)
	..()

/obj/item/weapon/cartridge/signal/toxins
	name = "Signal Ace 2"
	desc = "Complete with integrated radio signaler!"
	icon_state = "cart-tox"
	programs = list(
		new/datum/data/pda/utility/scanmode/gas,

		new/datum/data/pda/utility/scanmode/reagent,

		new/datum/data/pda/app/signaller)

/obj/item/weapon/cartridge/quartermaster
	name = "Space Parts & Space Vendors Cartridge"
	desc = "Perfect for the Quartermaster on the go!"
	icon_state = "cart-q"
	programs = list(
		new/datum/data/pda/app/supply,
		new/datum/data/pda/app/mule_control)

/obj/item/weapon/cartridge/quartermaster/initialize()
	radio = new /obj/item/radio/integrated/mule(src)
	..()

/obj/item/weapon/cartridge/head
	name = "Easy-Record DELUXE"
	icon_state = "cart-h"
	programs = list(new/datum/data/pda/app/status_display)

/obj/item/weapon/cartridge/hop
	name = "HumanResources9001"
	icon_state = "cart-h"
	programs = list(
		new/datum/data/pda/app/crew_records/security,

		new/datum/data/pda/app/janitor,

		new/datum/data/pda/app/supply,
		new/datum/data/pda/app/mule_control,

		new/datum/data/pda/app/status_display)

/obj/item/weapon/cartridge/hop/initialize()
	radio = new /obj/item/radio/integrated/mule(src)
	..()

/obj/item/weapon/cartridge/hos
	name = "R.O.B.U.S.T. DELUXE"
	icon_state = "cart-hos"
	programs = list(
		new/datum/data/pda/app/crew_records/security,
		new/datum/data/pda/app/secbot_control,

		new/datum/data/pda/app/status_display)

/obj/item/weapon/cartridge/hos/initialize()
	radio = new /obj/item/radio/integrated/beepsky(src)
	..()

/obj/item/weapon/cartridge/ce
	name = "Power-On DELUXE"
	icon_state = "cart-ce"
	programs = list(
		new/datum/data/pda/app/power,
		new/datum/data/pda/utility/scanmode/halogen,

		new/datum/data/pda/utility/scanmode/gas,

		new/datum/data/pda/app/status_display)

/obj/item/weapon/cartridge/cmo
	name = "Med-U DELUXE"
	icon_state = "cart-cmo"
	programs = list(
		new/datum/data/pda/app/crew_records/medical,
		new/datum/data/pda/utility/scanmode/medical,

		new/datum/data/pda/utility/scanmode/reagent,

		new/datum/data/pda/app/status_display)

/obj/item/weapon/cartridge/rd
	name = "Signal Ace DELUXE"
	icon_state = "cart-rd"
	programs = list(
		new/datum/data/pda/utility/scanmode/gas,

		new/datum/data/pda/utility/scanmode/reagent,

		new/datum/data/pda/app/signaller,

		new/datum/data/pda/app/status_display)

/obj/item/weapon/cartridge/rd/initialize()
	radio = new /obj/item/radio/integrated/signal(src)
	..()

/obj/item/weapon/cartridge/captain
	name = "Value-PAK Cartridge"
	desc = "Now with 200% more value!"
	icon_state = "cart-c"
	programs = list(
		new/datum/data/pda/app/power,
		new/datum/data/pda/utility/scanmode/halogen,

		new/datum/data/pda/utility/scanmode/gas,

		new/datum/data/pda/app/crew_records/medical,
		new/datum/data/pda/utility/scanmode/medical,

		new/datum/data/pda/utility/scanmode/reagent,

		new/datum/data/pda/app/crew_records/security,
		new/datum/data/pda/app/secbot_control,

		new/datum/data/pda/app/janitor,

		new/datum/data/pda/app/supply,

		new/datum/data/pda/app/status_display)

/obj/item/weapon/cartridge/captain/initialize()
	radio = new /obj/item/radio/integrated/beepsky(src)
	..()

/obj/item/weapon/cartridge/supervisor
	name = "Easy-Record DELUXE"
	icon_state = "cart-h"
	programs = list(
		new/datum/data/pda/app/crew_records/security,

		new/datum/data/pda/app/status_display)

/obj/item/weapon/cartridge/centcom
	name = "Value-PAK Cartridge"
	desc = "Now with 200% more value!"
	icon_state = "cart-c"
	programs = list(
		new/datum/data/pda/app/power,
		new/datum/data/pda/utility/scanmode/halogen,

		new/datum/data/pda/utility/scanmode/gas,

		new/datum/data/pda/app/crew_records/medical,
		new/datum/data/pda/utility/scanmode/medical,

		new/datum/data/pda/utility/scanmode/reagent,

		new/datum/data/pda/app/crew_records/security,
		new/datum/data/pda/app/secbot_control,

		new/datum/data/pda/app/janitor,

		new/datum/data/pda/app/supply,
		new/datum/data/pda/app/mule_control,

		new/datum/data/pda/app/status_display)

/obj/item/weapon/cartridge/centcom/initialize()
	radio = new /obj/item/radio/integrated/beepsky(src)
	..()

/obj/item/weapon/cartridge/syndicate
	name = "Detomatix Cartridge"
	icon_state = "cart"
	var/initial_remote_door_id = "smindicate" //Make sure this matches the syndicate shuttle's shield/door id!!	//don't ask about the name, testing.
	charges = 4
	programs = list(new/datum/data/pda/utility/toggle_door)
	messenger_plugins = list(new/datum/data/pda/messenger_plugin/virus/detonate)

/obj/item/weapon/cartridge/syndicate/New()
	var/datum/data/pda/utility/toggle_door/D = programs[1]
	if(istype(D))
		D.remote_door_id = initial_remote_door_id

/obj/item/weapon/cartridge/mob_hunt_game
	name = "Nano-Mob Hunter GO! Cartridge"
	desc = "The hit new PDA game that lets you track down and capture your favorite Nano-Mobs living in your world!"
	icon_state = "cart-eye"
	programs = list(new/datum/data/pda/app/mob_hunter_game)
	var/emagged = 0

/obj/item/weapon/cartridge/mob_hunt_game/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/weapon/nanomob_card))
		var/obj/item/weapon/nanomob_card/card = O
		var/datum/data/pda/app/mob_hunter_game/my_game = programs[1]
		if(my_game.register_capture(card.mob_data))
			to_chat(user, "<span class='notice'>Transfer successful!</span>")
			qdel(card)
		else
			to_chat(user, "<span class='warning'>Transfer failed. Could not read mob data from card.</span>")
	else
		..()

/obj/item/weapon/cartridge/mob_hunt_game/emag_act(mob/user)
	if(!emagged)
		emagged = 1
		var/datum/data/pda/app/mob_hunter_game/my_game = programs[1]
		my_game.hacked = 1
		to_chat(user, "<span class='warning'>TR4P_M45T3R.mod successfully initialized. ToS violated. User Agreement nullified. Gotta pwn them all.</span>")
		to_chat(user, "<span class='warning'>You can now create trapped versions of any mob in your collection that will damage hunters who attempt to capture it.</span>")
		description_antag = "This copy of Nano-Mob Hunter GO! has been hacked to allow the creation of trap mobs which will cause any PDA that attempts to capture it to shock anyone holding it. Hacked copies of the game will not trigger the trap."