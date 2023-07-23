/obj/effect/mapping_helpers/airlock/windoor/access
	layer = DOOR_HELPER_LAYER
	icon_state = "access_windoor"
	var/access

// Windoor direction code section (thanks S34M for help with making my dumb idea work as code, all credits to him for this file.)
// These are mutually exclusive; can't have req_any and req_all
/obj/effect/mapping_helpers/airlock/windoor/access/any/payload(obj/machinery/door/window/windoor)
	// Check we are applying to the correct windoor
	if(windoor.dir != dir)
		return

	// Access already set in map edit
	if(windoor.req_access_txt != "0")
		log_world("[src] at [AREACOORD(src)] tried to set req_one_access, but req_access was already set!")
		return

	// Overwrite if there is no access set, otherwise add onto existing access
	if(windoor.req_one_access_txt == "0")
		windoor.req_one_access_txt = "[access]"
		return

	windoor.req_one_access_txt += ";[access]"

/obj/effect/mapping_helpers/airlock/windoor/access/all/payload(obj/machinery/door/window/windoor)
	if(windoor.dir != dir)
		return

	if(windoor.req_one_access_txt != "0")
		log_world("[src] at [AREACOORD(src)] tried to set req_access, but req_one_access was already set!")
		return

	if(windoor.req_access_txt == "0")
		windoor.req_access_txt = "[access]"
		return

	windoor.req_access_txt += ";[access]"

// -------------------- Req Any (Only requires ONE of the given accesses to open)
// -------------------- Command access helpers
/obj/effect/mapping_helpers/airlock/windoor/access/any/command
	icon_state = "access_windoor_com"

/obj/effect/mapping_helpers/airlock/windoor/access/any/command/general
	access = ACCESS_HEADS

/obj/effect/mapping_helpers/airlock/windoor/access/any/command/ai_upload
	access = ACCESS_AI_UPLOAD

/obj/effect/mapping_helpers/airlock/windoor/access/any/command/teleporter
	access = ACCESS_TELEPORTER

/obj/effect/mapping_helpers/airlock/windoor/access/any/command/eva
	access = ACCESS_EVA

/obj/effect/mapping_helpers/airlock/windoor/access/any/command/expedition
	access = ACCESS_EXPEDITION

/obj/effect/mapping_helpers/airlock/windoor/access/any/command/hop
	access = ACCESS_HOP

/obj/effect/mapping_helpers/airlock/windoor/access/any/command/captain
	access = ACCESS_CAPTAIN

/obj/effect/mapping_helpers/airlock/windoor/access/any/command/blueshield
	access = ACCESS_BLUESHIELD

/obj/effect/mapping_helpers/airlock/windoor/access/any/command/ntrep
	access = ACCESS_NTREP

/obj/effect/mapping_helpers/airlock/windoor/access/any/command/magistrate
	access = ACCESS_MAGISTRATE

// -------------------- Engineering access helpers
/obj/effect/mapping_helpers/airlock/windoor/access/any/engineering
	icon_state = "access_windoor_eng"

/obj/effect/mapping_helpers/airlock/windoor/access/any/engineering/general
	access = ACCESS_ENGINE

/obj/effect/mapping_helpers/airlock/windoor/access/any/engineering/construction
	access = ACCESS_CONSTRUCTION

/obj/effect/mapping_helpers/airlock/windoor/access/any/engineering/maintenance
	access = ACCESS_MAINT_TUNNELS

/obj/effect/mapping_helpers/airlock/windoor/access/any/engineering/external
	access = ACCESS_EXTERNAL_AIRLOCKS

/obj/effect/mapping_helpers/airlock/windoor/access/any/engineering/tech_storage
	access = ACCESS_TECH_STORAGE

/obj/effect/mapping_helpers/airlock/windoor/access/any/engineering/atmos
	access = ACCESS_ATMOSPHERICS

/obj/effect/mapping_helpers/airlock/windoor/access/any/engineering/tcoms
	access = ACCESS_TCOMSAT

/obj/effect/mapping_helpers/airlock/windoor/access/any/engineering/ce
	access = ACCESS_CE

// -------------------- Medical access helpers
/obj/effect/mapping_helpers/airlock/windoor/access/any/medical
	icon_state = "access_windoor_med"

/obj/effect/mapping_helpers/airlock/windoor/access/any/medical/general
	access = ACCESS_MEDICAL

/obj/effect/mapping_helpers/airlock/windoor/access/any/medical/morgue
	access = ACCESS_MORGUE

/obj/effect/mapping_helpers/airlock/windoor/access/any/medical/chemistry
	access = ACCESS_CHEMISTRY

/obj/effect/mapping_helpers/airlock/windoor/access/any/medical/virology
	access = ACCESS_VIROLOGY

/obj/effect/mapping_helpers/airlock/windoor/access/any/medical/surgery
	access = ACCESS_SURGERY

/obj/effect/mapping_helpers/airlock/windoor/access/any/medical/cmo
	access = ACCESS_CMO

/obj/effect/mapping_helpers/airlock/windoor/access/any/medical/psychology
	access = ACCESS_PSYCHIATRIST

/obj/effect/mapping_helpers/airlock/windoor/access/any/medical/genetics
	access = ACCESS_GENETICS

/obj/effect/mapping_helpers/airlock/windoor/access/any/medical/paramedic
	access = ACCESS_PARAMEDIC

// -------------------- Science access helpers
/obj/effect/mapping_helpers/airlock/windoor/access/any/science
	icon_state = "access_windoor_sci"

/obj/effect/mapping_helpers/airlock/windoor/access/any/science/research
	access = ACCESS_RESEARCH

/obj/effect/mapping_helpers/airlock/windoor/access/any/science/tox
	access = ACCESS_TOX

/obj/effect/mapping_helpers/airlock/windoor/access/any/science/tox_storage
	access = ACCESS_TOX_STORAGE

/obj/effect/mapping_helpers/airlock/windoor/access/any/science/genetics
	access = ACCESS_GENETICS

/obj/effect/mapping_helpers/airlock/windoor/access/any/science/robotics
	access = ACCESS_ROBOTICS

/obj/effect/mapping_helpers/airlock/windoor/access/any/science/xenobio
	access = ACCESS_XENOBIOLOGY

/obj/effect/mapping_helpers/airlock/windoor/access/any/science/minisat
	access = ACCESS_MINISAT

/obj/effect/mapping_helpers/airlock/windoor/access/any/science/rd
	access = ACCESS_RD

// -------------------- Security access helpers
/obj/effect/mapping_helpers/airlock/windoor/access/any/security
	icon_state = "access_windoor_sec"

/obj/effect/mapping_helpers/airlock/windoor/access/any/security/general
	access = ACCESS_SECURITY

/obj/effect/mapping_helpers/airlock/windoor/access/any/security/doors
	access = ACCESS_SEC_DOORS

/obj/effect/mapping_helpers/airlock/windoor/access/any/security/brig
	access = ACCESS_BRIG

/obj/effect/mapping_helpers/airlock/windoor/access/any/security/armory
	access = ACCESS_ARMORY

/obj/effect/mapping_helpers/airlock/windoor/access/any/security/court
	access = ACCESS_COURT

/obj/effect/mapping_helpers/airlock/windoor/access/any/security/hos
	access = ACCESS_HOS

/obj/effect/mapping_helpers/airlock/windoor/access/any/security/iaa
	access = ACCESS_LAWYER

// -------------------- Service access helpers
/obj/effect/mapping_helpers/airlock/windoor/access/any/service
	icon_state = "access_windoor_serv"

/obj/effect/mapping_helpers/airlock/windoor/access/any/service/kitchen
	access = ACCESS_KITCHEN

/obj/effect/mapping_helpers/airlock/windoor/access/any/service/bar
	access = ACCESS_BAR

/obj/effect/mapping_helpers/airlock/windoor/access/any/service/hydroponics
	access = ACCESS_HYDROPONICS

/obj/effect/mapping_helpers/airlock/windoor/access/any/service/janitor
	access = ACCESS_JANITOR

/obj/effect/mapping_helpers/airlock/windoor/access/any/service/chapel_office
	access = ACCESS_CHAPEL_OFFICE

/obj/effect/mapping_helpers/airlock/windoor/access/any/service/crematorium
	access = ACCESS_CREMATORIUM

/obj/effect/mapping_helpers/airlock/windoor/access/any/service/library
	access = ACCESS_LIBRARY

/obj/effect/mapping_helpers/airlock/windoor/access/any/service/library
	access = ACCESS_THEATRE

/obj/effect/mapping_helpers/airlock/windoor/access/any/service/clown
	access = ACCESS_CLOWN

/obj/effect/mapping_helpers/airlock/windoor/access/any/service/mime
	access = ACCESS_MIME

// -------------------- Supply access helpers
/obj/effect/mapping_helpers/airlock/windoor/access/any/supply
	icon_state = "access_windoor_sup"

/obj/effect/mapping_helpers/airlock/windoor/access/any/supply/general
	access = ACCESS_CARGO

/obj/effect/mapping_helpers/airlock/windoor/access/any/supply/mail_sorting
	access = ACCESS_MAILSORTING

/obj/effect/mapping_helpers/airlock/windoor/access/any/supply/mining
	access = ACCESS_MINING

/obj/effect/mapping_helpers/airlock/windoor/access/any/supply/mining_station
	access = ACCESS_MINING_STATION

/obj/effect/mapping_helpers/airlock/windoor/access/any/supply/mineral_storage
	access = ACCESS_MINERAL_STOREROOM

/obj/effect/mapping_helpers/airlock/windoor/access/any/supply/qm
	access = ACCESS_QM

/obj/effect/mapping_helpers/airlock/windoor/access/any/supply/vault
	access = ACCESS_HEADS_VAULT

/obj/effect/mapping_helpers/airlock/windoor/access/any/supply/mule_bot
	access = ACCESS_CARGO_BOT

// -------------------- Req All (Requires ALL of the given accesses to open)
// -------------------- Command access helpers
/obj/effect/mapping_helpers/airlock/windoor/access/all/command
	icon_state = "access_windoor_com"

/obj/effect/mapping_helpers/airlock/windoor/access/all/command/general
	access = ACCESS_HEADS

/obj/effect/mapping_helpers/airlock/windoor/access/all/command/ai_upload
	access = ACCESS_AI_UPLOAD

/obj/effect/mapping_helpers/airlock/windoor/access/all/command/teleporter
	access = ACCESS_TELEPORTER

/obj/effect/mapping_helpers/airlock/windoor/access/all/command/eva
	access = ACCESS_EVA

/obj/effect/mapping_helpers/airlock/windoor/access/all/command/expedition
	access = ACCESS_EXPEDITION

/obj/effect/mapping_helpers/airlock/windoor/access/all/command/hop
	access = ACCESS_HOP

/obj/effect/mapping_helpers/airlock/windoor/access/all/command/captain
	access = ACCESS_CAPTAIN

/obj/effect/mapping_helpers/airlock/windoor/access/all/command/blueshield
	access = ACCESS_BLUESHIELD

/obj/effect/mapping_helpers/airlock/windoor/access/all/command/ntrep
	access = ACCESS_NTREP

/obj/effect/mapping_helpers/airlock/windoor/access/all/command/magistrate
	access = ACCESS_MAGISTRATE

// -------------------- Engineering access helpers
/obj/effect/mapping_helpers/airlock/windoor/access/all/engineering
	icon_state = "access_windoor_eng"

/obj/effect/mapping_helpers/airlock/windoor/access/all/engineering/general
	access = ACCESS_ENGINE

/obj/effect/mapping_helpers/airlock/windoor/access/all/engineering/construction
	access = ACCESS_CONSTRUCTION

/obj/effect/mapping_helpers/airlock/windoor/access/all/engineering/maintenance
	access = ACCESS_MAINT_TUNNELS

/obj/effect/mapping_helpers/airlock/windoor/access/all/engineering/external
	access = ACCESS_EXTERNAL_AIRLOCKS

/obj/effect/mapping_helpers/airlock/windoor/access/all/engineering/tech_storage
	access = ACCESS_TECH_STORAGE

/obj/effect/mapping_helpers/airlock/windoor/access/all/engineering/atmos
	access = ACCESS_ATMOSPHERICS

/obj/effect/mapping_helpers/airlock/windoor/access/all/engineering/tcoms
	access = ACCESS_TCOMSAT

/obj/effect/mapping_helpers/airlock/windoor/access/all/engineering/ce
	access = ACCESS_CE

// -------------------- Medical access helpers
/obj/effect/mapping_helpers/airlock/windoor/access/all/medical
	icon_state = "access_windoor_med"

/obj/effect/mapping_helpers/airlock/windoor/access/all/medical/general
	access = ACCESS_MEDICAL

/obj/effect/mapping_helpers/airlock/windoor/access/all/medical/morgue
	access = ACCESS_MORGUE

/obj/effect/mapping_helpers/airlock/windoor/access/all/medical/chemistry
	access = ACCESS_CHEMISTRY

/obj/effect/mapping_helpers/airlock/windoor/access/all/medical/virology
	access = ACCESS_VIROLOGY

/obj/effect/mapping_helpers/airlock/windoor/access/all/medical/surgery
	access = ACCESS_SURGERY

/obj/effect/mapping_helpers/airlock/windoor/access/all/medical/cmo
	access = ACCESS_CMO

/obj/effect/mapping_helpers/airlock/windoor/access/all/medical/paramedic
	access = ACCESS_PARAMEDIC

/obj/effect/mapping_helpers/airlock/windoor/access/all/medical/psychology
	access = ACCESS_PSYCHIATRIST

/obj/effect/mapping_helpers/airlock/windoor/access/all/medical/genetics
	access = ACCESS_GENETICS

// -------------------- Science access helpers
/obj/effect/mapping_helpers/airlock/windoor/access/all/science
	icon_state = "access_windoor_sci"

/obj/effect/mapping_helpers/airlock/windoor/access/all/science/research
	access = ACCESS_RESEARCH

/obj/effect/mapping_helpers/airlock/windoor/access/all/science/tox
	access = ACCESS_TOX

/obj/effect/mapping_helpers/airlock/windoor/access/all/science/tox_storage
	access = ACCESS_TOX_STORAGE

/obj/effect/mapping_helpers/airlock/windoor/access/all/science/genetics
	access = ACCESS_GENETICS

/obj/effect/mapping_helpers/airlock/windoor/access/all/science/robotics
	access = ACCESS_ROBOTICS

/obj/effect/mapping_helpers/airlock/windoor/access/all/science/xenobio
	access = ACCESS_XENOBIOLOGY

/obj/effect/mapping_helpers/airlock/windoor/access/all/science/minisat
	access = ACCESS_MINISAT

/obj/effect/mapping_helpers/airlock/windoor/access/all/science/rd
	access = ACCESS_RD

// -------------------- Security access helpers
/obj/effect/mapping_helpers/airlock/windoor/access/all/security
	icon_state = "access_windoor_sec"

/obj/effect/mapping_helpers/airlock/windoor/access/all/security/general
	access = ACCESS_SECURITY

/obj/effect/mapping_helpers/airlock/windoor/access/all/security/doors
	access = ACCESS_SEC_DOORS

/obj/effect/mapping_helpers/airlock/windoor/access/all/security/brig
	access = ACCESS_BRIG

/obj/effect/mapping_helpers/airlock/windoor/access/all/security/armory
	access = ACCESS_ARMORY

/obj/effect/mapping_helpers/airlock/windoor/access/all/security/court
	access = ACCESS_COURT

/obj/effect/mapping_helpers/airlock/windoor/access/all/security/hos
	access = ACCESS_HOS

/obj/effect/mapping_helpers/airlock/windoor/access/all/security/iaa
	access = ACCESS_LAWYER

// -------------------- Service access helpers
/obj/effect/mapping_helpers/airlock/windoor/access/all/service
	icon_state = "access_windoor_serv"

/obj/effect/mapping_helpers/airlock/windoor/access/all/service/kitchen
	access = ACCESS_KITCHEN

/obj/effect/mapping_helpers/airlock/windoor/access/all/service/bar
	access = ACCESS_BAR

/obj/effect/mapping_helpers/airlock/windoor/access/all/service/hydroponics
	access = ACCESS_HYDROPONICS

/obj/effect/mapping_helpers/airlock/windoor/access/all/service/janitor
	access = ACCESS_JANITOR

/obj/effect/mapping_helpers/airlock/windoor/access/all/service/chapel_office
	access = ACCESS_CHAPEL_OFFICE

/obj/effect/mapping_helpers/airlock/windoor/access/all/service/crematorium
	access = ACCESS_CREMATORIUM

/obj/effect/mapping_helpers/airlock/windoor/access/all/service/crematorium
	access = ACCESS_CREMATORIUM

/obj/effect/mapping_helpers/airlock/windoor/access/all/service/library
	access = ACCESS_LIBRARY

/obj/effect/mapping_helpers/airlock/windoor/access/all/service/library
	access = ACCESS_THEATRE

/obj/effect/mapping_helpers/airlock/windoor/access/all/service/clown
	access = ACCESS_CLOWN

/obj/effect/mapping_helpers/airlock/windoor/access/all/service/mime
	access = ACCESS_MIME

// -------------------- Supply access helpers
/obj/effect/mapping_helpers/airlock/windoor/access/all/supply
	icon_state = "access_windoor_sup"

/obj/effect/mapping_helpers/airlock/windoor/access/all/supply/general
	access = ACCESS_CARGO

/obj/effect/mapping_helpers/airlock/windoor/access/all/supply/mail_sorting
	access = ACCESS_MAILSORTING

/obj/effect/mapping_helpers/airlock/windoor/access/all/supply/mining
	access = ACCESS_MINING

/obj/effect/mapping_helpers/airlock/windoor/access/all/supply/mining_station
	access = ACCESS_MINING_STATION

/obj/effect/mapping_helpers/airlock/windoor/access/all/supply/mineral_storage
	access = ACCESS_MINERAL_STOREROOM

/obj/effect/mapping_helpers/airlock/windoor/access/all/supply/qm
	access = ACCESS_QM

/obj/effect/mapping_helpers/airlock/windoor/access/all/supply/vault
	access = ACCESS_HEADS_VAULT

/obj/effect/mapping_helpers/airlock/windoor/access/all/supply/mule_bot
	access = ACCESS_CARGO_BOT
