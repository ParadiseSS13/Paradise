/datum/supply_packs/telecommunications
	name = "HEADER"
	group = SUPPLY_TELECOMMUNICATIONS
	announce_beacons = list()
	containertype = /obj/structure/closet/crate/sci

/datum/supply_packs/telecommunications/research_headsets
	name = "Research Headset Crate"
	contains = list(
		/obj/item/radio/headset/heads/rd,
		/obj/item/radio/headset/headset_sci,
		/obj/item/radio/headset/headset_sci,
		/obj/item/radio/headset/headset_xenobio)
	cost = 500
	containertype = /obj/structure/closet/crate/secure/scisec
	containername = "research headset crate"
	access = ACCESS_RD
	announce_beacons = list("Research Division" = list("Research Director's Desk"))
	department_restrictions = list(DEPARTMENT_SCIENCE)

/datum/supply_packs/telecommunications/engineering_headsets
	name = "Engineering Headset Crate"
	contains = list(
		/obj/item/radio/headset/heads/ce,
		/obj/item/radio/headset/headset_eng,
		/obj/item/radio/headset/headset_eng,
		/obj/item/radio/headset/headset_eng)
	cost = 500
	containertype = /obj/structure/closet/crate/secure/engineering
	containername = "engineering headset crate"
	access = ACCESS_CE
	announce_beacons = list("Engineering" = list("Chief Engineer's Desk"))
	department_restrictions = list(DEPARTMENT_ENGINEERING)

/datum/supply_packs/telecommunications/security_headsets
	name = "Security Headset Crate"
	contains = list(
		/obj/item/radio/headset/heads/hos/alt,
		/obj/item/radio/headset/headset_sec/alt,
		/obj/item/radio/headset/headset_sec/alt,
		/obj/item/radio/headset/headset_sec/alt)
	cost = 500
	containertype = /obj/structure/closet/crate/secure/gear
	containername = "security headset crate"
	access = ACCESS_HOS
	announce_beacons = list("Security" = list("Head of Security's Desk"))
	department_restrictions = list(DEPARTMENT_SECURITY)

/datum/supply_packs/telecommunications/medbay_headsets
	name = "Medical Headset Crate"
	contains = list(
		/obj/item/radio/headset/heads/cmo,
		/obj/item/radio/headset/headset_med,
		/obj/item/radio/headset/headset_med,
		/obj/item/radio/headset/headset_med/para)
	cost = 500
	containertype = /obj/structure/closet/crate/secure/medical
	containername = "medical headset crate"
	access = ACCESS_CMO
	announce_beacons = list("Medbay" = list("Chief Medical Officer's Desk"))
	department_restrictions = list(DEPARTMENT_MEDICAL)

/datum/supply_packs/telecommunications/service_headsets
	name = "Service Headset Crate"
	contains = list(
		/obj/item/radio/headset/heads/hop,
		/obj/item/radio/headset/headset_service,
		/obj/item/radio/headset/headset_service,
		/obj/item/radio/headset/headset_service)
	cost = 500
	containertype = /obj/structure/closet/crate/secure/service
	containername = "service headset crate"
	access = ACCESS_HOP
	announce_beacons = list("Service" = list("Head of Personnel's Desk"))
	department_restrictions = list(DEPARTMENT_SERVICE)

/datum/supply_packs/telecommunications/supply_headsets
	name = "Supply Headset Crate"
	contains = list(
		/obj/item/radio/headset/heads/qm,
		/obj/item/radio/headset/headset_cargo,
		/obj/item/radio/headset/headset_cargo,
		/obj/item/radio/headset/headset_cargo)
	cost = 500
	containertype = /obj/structure/closet/crate/secure/supply
	containername = "supply headset crate"
	access = ACCESS_QM
	announce_beacons = list("Supply" = list("Quartermasters's Desk"))
	department_restrictions = list(DEPARTMENT_SERVICE)

/datum/supply_packs/telecommunications/legalistic_headsets
	name = "Legalistic Headset Crate"
	contains = list(
		/obj/item/radio/headset/heads/magistrate/alt,
		/obj/item/radio/headset/headset_iaa,
		/obj/item/radio/headset/headset_iaa,
		/obj/item/radio/headset/headset_iaa)
	cost = 500
	containertype = /obj/structure/closet/crate/secure/gear
	containername = "legalistic headset crate"
	access = ACCESS_MAGISTRATE
	announce_beacons = list("Security" = list("Magistrates's Office"))
	department_restrictions = list(DEPARTMENT_COMMAND)

/datum/supply_packs/telecommunications/command_headsets
	name = "Command Headset Crate"
	contains = list(
		/obj/item/radio/headset/heads/captain/alt,
		/obj/item/radio/headset/headset_com,
		/obj/item/radio/headset/headset_com,
		/obj/item/radio/headset/headset_com)
	cost = 750
	containertype = /obj/structure/closet/crate/secure/command
	containername = "command headset crate"
	access = ACCESS_CAPTAIN
	announce_beacons = list("Command" = list("Captains's Office"))
	department_restrictions = list(DEPARTMENT_COMMAND)

/datum/supply_packs/telecommunications/headsets
	name = "Standard Headset Crate"
	contains = list(
		/obj/item/radio/headset,
		/obj/item/radio/headset,
		/obj/item/radio/headset,
		/obj/item/radio/headset)
	cost = 100
	containertype = /obj/structure/closet/crate/
	containername = "standard headset crate"
	department_restrictions = list()
