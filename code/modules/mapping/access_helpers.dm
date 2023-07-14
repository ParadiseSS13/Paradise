/obj/effect/mapping_helpers/airlock/access
	layer = DOOR_HELPER_LAYER
	icon_state = "access_helper"
	var/access

// These are mutually exclusive; can't have req_any and req_all
/obj/effect/mapping_helpers/airlock/access/any/payload(obj/machinery/door/airlock/airlock)
	if(airlock.req_access_txt == "0")
		// Overwrite if there is no access set, otherwise add onto existing access
		if(airlock.req_one_access_txt == "0")
			airlock.req_one_access_txt = "[access]"
		else
			airlock.req_one_access_txt += ";[access]"
	else
		log_world("[src] at [AREACOORD(src)] tried to set req_one_access, but req_access was already set!")

/obj/effect/mapping_helpers/airlock/access/all/payload(obj/machinery/door/airlock/airlock)
	if(airlock.req_one_access_txt == "0")
		if(airlock.req_access_txt == "0")
			airlock.req_access_txt = "[access]"
		else
			airlock.req_access_txt += ";[access]"
	else
		log_world("[src] at [AREACOORD(src)] tried to set req_access, but req_one_access was already set!")

// -------------------- Req Any (Only requires ONE of the given accesses to open)
// -------------------- Command access helpers
/obj/effect/mapping_helpers/airlock/access/any/command
	icon_state = "access_helper_com"

/obj/effect/mapping_helpers/airlock/access/any/command/general
	access = ACCESS_HEADS

/obj/effect/mapping_helpers/airlock/access/any/command/ai_upload
	access = ACCESS_AI_UPLOAD

/obj/effect/mapping_helpers/airlock/access/any/command/teleporter
	access = ACCESS_TELEPORTER

/obj/effect/mapping_helpers/airlock/access/any/command/eva
	access = ACCESS_EVA

/obj/effect/mapping_helpers/airlock/access/any/command/expedition
	access = ACCESS_EXPEDITION

/obj/effect/mapping_helpers/airlock/access/any/command/hop
	access = ACCESS_HOP

/obj/effect/mapping_helpers/airlock/access/any/command/captain
	access = ACCESS_CAPTAIN

/obj/effect/mapping_helpers/airlock/access/any/command/blueshield
	access = ACCESS_BLUESHIELD

/obj/effect/mapping_helpers/airlock/access/any/command/ntrep
	access = ACCESS_NTREP

/obj/effect/mapping_helpers/airlock/access/any/command/magistrate
	access = ACCESS_MAGISTRATE

// -------------------- Engineering access helpers
/obj/effect/mapping_helpers/airlock/access/any/engineering
	icon_state = "access_helper_eng"

/obj/effect/mapping_helpers/airlock/access/any/engineering/general
	access = ACCESS_ENGINE

/obj/effect/mapping_helpers/airlock/access/any/engineering/equipment
	access = ACCESS_ENGINE_EQUIP

/obj/effect/mapping_helpers/airlock/access/any/engineering/construction
	access = ACCESS_CONSTRUCTION

/obj/effect/mapping_helpers/airlock/access/any/engineering/maintenance
	access = ACCESS_MAINT_TUNNELS

/obj/effect/mapping_helpers/airlock/access/any/engineering/external
	access = ACCESS_EXTERNAL_AIRLOCKS

/obj/effect/mapping_helpers/airlock/access/any/engineering/tech_storage
	access = ACCESS_TECH_STORAGE

/obj/effect/mapping_helpers/airlock/access/any/engineering/atmos
	access = ACCESS_ATMOSPHERICS

/obj/effect/mapping_helpers/airlock/access/any/engineering/tcoms
	access = ACCESS_TCOMSAT

/obj/effect/mapping_helpers/airlock/access/any/engineering/ce
	access = ACCESS_CE

// -------------------- Medical access helpers
/obj/effect/mapping_helpers/airlock/access/any/medical
	icon_state = "access_helper_med"

/obj/effect/mapping_helpers/airlock/access/any/medical/general
	access = ACCESS_MEDICAL

/obj/effect/mapping_helpers/airlock/access/any/medical/morgue
	access = ACCESS_MORGUE

/obj/effect/mapping_helpers/airlock/access/any/medical/chemistry
	access = ACCESS_CHEMISTRY

/obj/effect/mapping_helpers/airlock/access/any/medical/virology
	access = ACCESS_VIROLOGY

/obj/effect/mapping_helpers/airlock/access/any/medical/surgery
	access = ACCESS_SURGERY

/obj/effect/mapping_helpers/airlock/access/any/medical/cmo
	access = ACCESS_CMO

/obj/effect/mapping_helpers/airlock/access/any/medical/psychology
	access = ACCESS_PSYCHIATRIST

/obj/effect/mapping_helpers/airlock/access/any/medical/genetics
	access = ACCESS_GENETICS

/obj/effect/mapping_helpers/airlock/access/any/medical/paramedic
	access = ACCESS_PARAMEDIC

// -------------------- Science access helpers
/obj/effect/mapping_helpers/airlock/access/any/science
	icon_state = "access_helper_sci"

/obj/effect/mapping_helpers/airlock/access/any/science/research
	access = ACCESS_RESEARCH

/obj/effect/mapping_helpers/airlock/access/any/science/tox
	access = ACCESS_TOX

/obj/effect/mapping_helpers/airlock/access/any/science/tox_storage
	access = ACCESS_TOX_STORAGE

/obj/effect/mapping_helpers/airlock/access/any/science/robotics
	access = ACCESS_ROBOTICS

/obj/effect/mapping_helpers/airlock/access/any/science/xenobio
	access = ACCESS_XENOBIOLOGY

/obj/effect/mapping_helpers/airlock/access/any/science/minisat
	access = ACCESS_MINISAT

/obj/effect/mapping_helpers/airlock/access/any/science/rd
	access = ACCESS_RD

// -------------------- Security access helpers
/obj/effect/mapping_helpers/airlock/access/any/security
	icon_state = "access_helper_sec"

/obj/effect/mapping_helpers/airlock/access/any/security/general
	access = ACCESS_SECURITY

/obj/effect/mapping_helpers/airlock/access/any/security/forensics
	access = ACCESS_FORENSICS_LOCKERS

/obj/effect/mapping_helpers/airlock/access/any/security/doors
	access = ACCESS_SEC_DOORS

/obj/effect/mapping_helpers/airlock/access/any/security/brig
	access = ACCESS_BRIG

/obj/effect/mapping_helpers/airlock/access/any/security/armory
	access = ACCESS_ARMORY

/obj/effect/mapping_helpers/airlock/access/any/security/court
	access = ACCESS_COURT

/obj/effect/mapping_helpers/airlock/access/any/security/hos
	access = ACCESS_HOS

/obj/effect/mapping_helpers/airlock/access/any/security/iaa
	access = ACCESS_LAWYER

// -------------------- Service access helpers
/obj/effect/mapping_helpers/airlock/access/any/service
	icon_state = "access_helper_serv"

/obj/effect/mapping_helpers/airlock/access/any/service/kitchen
	access = ACCESS_KITCHEN

/obj/effect/mapping_helpers/airlock/access/any/service/bar
	access = ACCESS_BAR

/obj/effect/mapping_helpers/airlock/access/any/service/hydroponics
	access = ACCESS_HYDROPONICS

/obj/effect/mapping_helpers/airlock/access/any/service/janitor
	access = ACCESS_JANITOR

/obj/effect/mapping_helpers/airlock/access/any/service/chapel_office
	access = ACCESS_CHAPEL_OFFICE

/obj/effect/mapping_helpers/airlock/access/any/service/crematorium
	access = ACCESS_CREMATORIUM

/obj/effect/mapping_helpers/airlock/access/any/service/library
	access = ACCESS_LIBRARY

/obj/effect/mapping_helpers/airlock/access/any/service/theatre
	access = ACCESS_THEATRE

/obj/effect/mapping_helpers/airlock/access/any/service/clown
	access = ACCESS_CLOWN

/obj/effect/mapping_helpers/airlock/access/any/service/mime
	access = ACCESS_MIME

// -------------------- Supply access helpers
/obj/effect/mapping_helpers/airlock/access/any/supply
	icon_state = "access_helper_sup"

/obj/effect/mapping_helpers/airlock/access/any/supply/general
	access = ACCESS_CARGO

/obj/effect/mapping_helpers/airlock/access/any/supply/mail_sorting
	access = ACCESS_MAILSORTING

/obj/effect/mapping_helpers/airlock/access/any/supply/mining
	access = ACCESS_MINING

/obj/effect/mapping_helpers/airlock/access/any/supply/mining_station
	access = ACCESS_MINING_STATION

/obj/effect/mapping_helpers/airlock/access/any/supply/mineral_storage
	access = ACCESS_MINERAL_STOREROOM

/obj/effect/mapping_helpers/airlock/access/any/supply/qm
	access = ACCESS_QM

/obj/effect/mapping_helpers/airlock/access/any/supply/vault
	access = ACCESS_HEADS_VAULT

/obj/effect/mapping_helpers/airlock/access/any/supply/mule_bot
	access = ACCESS_CARGO_BOT

// -------------------- Req All (Requires ALL of the given accesses to open)
// -------------------- Command access helpers
/obj/effect/mapping_helpers/airlock/access/all/command
	icon_state = "access_helper_com"

/obj/effect/mapping_helpers/airlock/access/all/command/general
	access = ACCESS_HEADS

/obj/effect/mapping_helpers/airlock/access/all/command/ai_upload
	access = ACCESS_AI_UPLOAD

/obj/effect/mapping_helpers/airlock/access/all/command/teleporter
	access = ACCESS_TELEPORTER

/obj/effect/mapping_helpers/airlock/access/all/command/eva
	access = ACCESS_EVA

/obj/effect/mapping_helpers/airlock/access/all/command/expedition
	access = ACCESS_EXPEDITION

/obj/effect/mapping_helpers/airlock/access/all/command/hop
	access = ACCESS_HOP

/obj/effect/mapping_helpers/airlock/access/all/command/captain
	access = ACCESS_CAPTAIN

/obj/effect/mapping_helpers/airlock/access/all/command/blueshield
	access = ACCESS_BLUESHIELD

/obj/effect/mapping_helpers/airlock/access/all/command/ntrep
	access = ACCESS_NTREP

/obj/effect/mapping_helpers/airlock/access/all/command/magistrate
	access = ACCESS_MAGISTRATE

// -------------------- Engineering access helpers
/obj/effect/mapping_helpers/airlock/access/all/engineering
	icon_state = "access_helper_eng"

/obj/effect/mapping_helpers/airlock/access/all/engineering/general
	access = ACCESS_ENGINE

/obj/effect/mapping_helpers/airlock/access/all/engineering/equipment
	access = ACCESS_ENGINE_EQUIP

/obj/effect/mapping_helpers/airlock/access/all/engineering/construction
	access = ACCESS_CONSTRUCTION

/obj/effect/mapping_helpers/airlock/access/all/engineering/maintenance
	access = ACCESS_MAINT_TUNNELS

/obj/effect/mapping_helpers/airlock/access/all/engineering/external
	access = ACCESS_EXTERNAL_AIRLOCKS

/obj/effect/mapping_helpers/airlock/access/all/engineering/tech_storage
	access = ACCESS_TECH_STORAGE

/obj/effect/mapping_helpers/airlock/access/all/engineering/atmos
	access = ACCESS_ATMOSPHERICS

/obj/effect/mapping_helpers/airlock/access/all/engineering/tcoms
	access = ACCESS_TCOMSAT

/obj/effect/mapping_helpers/airlock/access/all/engineering/ce
	access = ACCESS_CE

// -------------------- Medical access helpers
/obj/effect/mapping_helpers/airlock/access/all/medical
	icon_state = "access_helper_med"

/obj/effect/mapping_helpers/airlock/access/all/medical/general
	access = ACCESS_MEDICAL

/obj/effect/mapping_helpers/airlock/access/all/medical/morgue
	access = ACCESS_MORGUE

/obj/effect/mapping_helpers/airlock/access/all/medical/chemistry
	access = ACCESS_CHEMISTRY

/obj/effect/mapping_helpers/airlock/access/all/medical/virology
	access = ACCESS_VIROLOGY

/obj/effect/mapping_helpers/airlock/access/all/medical/surgery
	access = ACCESS_SURGERY

/obj/effect/mapping_helpers/airlock/access/all/medical/cmo
	access = ACCESS_CMO

/obj/effect/mapping_helpers/airlock/access/all/medical/paramedic
	access = ACCESS_PARAMEDIC

/obj/effect/mapping_helpers/airlock/access/all/medical/psychology
	access = ACCESS_PSYCHIATRIST

/obj/effect/mapping_helpers/airlock/access/all/medical/genetics
	access = ACCESS_GENETICS

// -------------------- Science access helpers
/obj/effect/mapping_helpers/airlock/access/all/science
	icon_state = "access_helper_sci"

/obj/effect/mapping_helpers/airlock/access/all/science/research
	access = ACCESS_RESEARCH

/obj/effect/mapping_helpers/airlock/access/all/science/tox
	access = ACCESS_TOX

/obj/effect/mapping_helpers/airlock/access/all/science/tox_storage
	access = ACCESS_TOX_STORAGE

/obj/effect/mapping_helpers/airlock/access/all/science/robotics
	access = ACCESS_ROBOTICS

/obj/effect/mapping_helpers/airlock/access/all/science/xenobio
	access = ACCESS_XENOBIOLOGY

/obj/effect/mapping_helpers/airlock/access/all/science/minisat
	access = ACCESS_MINISAT

/obj/effect/mapping_helpers/airlock/access/all/science/rd
	access = ACCESS_RD

// -------------------- Security access helpers
/obj/effect/mapping_helpers/airlock/access/all/security
	icon_state = "access_helper_sec"

/obj/effect/mapping_helpers/airlock/access/all/security/general
	access = ACCESS_SECURITY

/obj/effect/mapping_helpers/airlock/access/all/security/forensics
	access = ACCESS_FORENSICS_LOCKERS

/obj/effect/mapping_helpers/airlock/access/all/security/doors
	access = ACCESS_SEC_DOORS

/obj/effect/mapping_helpers/airlock/access/all/security/brig
	access = ACCESS_BRIG

/obj/effect/mapping_helpers/airlock/access/all/security/armory
	access = ACCESS_ARMORY

/obj/effect/mapping_helpers/airlock/access/all/security/court
	access = ACCESS_COURT

/obj/effect/mapping_helpers/airlock/access/all/security/hos
	access = ACCESS_HOS

/obj/effect/mapping_helpers/airlock/access/all/security/iaa
	access = ACCESS_LAWYER

// -------------------- Service access helpers
/obj/effect/mapping_helpers/airlock/access/all/service
	icon_state = "access_helper_serv"

/obj/effect/mapping_helpers/airlock/access/all/service/kitchen
	access = ACCESS_KITCHEN

/obj/effect/mapping_helpers/airlock/access/all/service/bar
	access = ACCESS_BAR

/obj/effect/mapping_helpers/airlock/access/all/service/hydroponics
	access = ACCESS_HYDROPONICS

/obj/effect/mapping_helpers/airlock/access/all/service/janitor
	access = ACCESS_JANITOR

/obj/effect/mapping_helpers/airlock/access/all/service/chapel_office
	access = ACCESS_CHAPEL_OFFICE

/obj/effect/mapping_helpers/airlock/access/all/service/crematorium
	access = ACCESS_CREMATORIUM

/obj/effect/mapping_helpers/airlock/access/all/service/crematorium
	access = ACCESS_CREMATORIUM

/obj/effect/mapping_helpers/airlock/access/all/service/library
	access = ACCESS_LIBRARY

/obj/effect/mapping_helpers/airlock/access/all/service/theatre
	access = ACCESS_THEATRE

/obj/effect/mapping_helpers/airlock/access/all/service/clown
	access = ACCESS_CLOWN

/obj/effect/mapping_helpers/airlock/access/all/service/mime
	access = ACCESS_MIME

// -------------------- Supply access helpers
/obj/effect/mapping_helpers/airlock/access/all/supply
	icon_state = "access_helper_sup"

/obj/effect/mapping_helpers/airlock/access/all/supply/general
	access = ACCESS_CARGO

/obj/effect/mapping_helpers/airlock/access/all/supply/mail_sorting
	access = ACCESS_MAILSORTING

/obj/effect/mapping_helpers/airlock/access/all/supply/mining
	access = ACCESS_MINING

/obj/effect/mapping_helpers/airlock/access/all/supply/mining_station
	access = ACCESS_MINING_STATION

/obj/effect/mapping_helpers/airlock/access/all/supply/mineral_storage
	access = ACCESS_MINERAL_STOREROOM

/obj/effect/mapping_helpers/airlock/access/all/supply/qm
	access = ACCESS_QM

/obj/effect/mapping_helpers/airlock/access/all/supply/vault
	access = ACCESS_HEADS_VAULT

/obj/effect/mapping_helpers/airlock/access/all/supply/mule_bot
	access = ACCESS_CARGO_BOT
