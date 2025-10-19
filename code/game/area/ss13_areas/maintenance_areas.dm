
// MARK: Directionals
/area/station/maintenance
	ambientsounds = MAINTENANCE_SOUNDS
	valid_territory = FALSE
	sound_environment = SOUND_AREA_TUNNEL_ENCLOSED
	airlock_wires = /datum/wires/airlock/maint

/area/station/maintenance/engimaint
	name = "Engineering Maintenance"
	icon_state = "engimaint"

/area/station/maintenance/medmaint
	name = "Medical Maintenance"
	icon_state = "medmaint"

/area/station/maintenance/fpmaint
	name = "Fore-Port Maintenance"
	icon_state = "fpmaint"

/area/station/maintenance/fpmaint2
	name = "Fore-Port Secondary Maintenance"
	icon_state = "fpmaint"

/area/station/maintenance/fsmaint
	name = "Fore-Starboard Maintenance"
	icon_state = "fsmaint"

/area/station/maintenance/fsmaint2
	name = "Fore-Starboard Secondary Maintenance"
	icon_state = "fsmaint"

/area/station/maintenance/asmaint
	name = "Aft-Starboard Maintenance"
	icon_state = "asmaint"

/area/station/maintenance/asmaint2
	name = "Aft-Starboard Secondary Maintenance"
	icon_state = "asmaint"

/area/station/maintenance/apmaint
	name = "Aft-Port Maintenance"
	icon_state = "apmaint"

/area/station/maintenance/apmaint2
	name = "Aft-Port Secondary Maintenance"
	icon_state = "apmaint"

/area/station/maintenance/maintcentral
	name = "Central Maintenance"
	icon_state = "maintcentral"

/area/station/maintenance/maintcentral2
	name = "Central Maintenance Secondary"
	icon_state = "maintcentral"

/area/station/maintenance/fore
	name = "Fore Maintenance"
	icon_state = "fmaint"

/area/station/maintenance/fore2
	name = "Fore Secondary Maintenance"
	icon_state = "fmaint"

/area/station/maintenance/aft
	name = "Aft Maintenance"
	icon_state = "amaint"

/area/station/maintenance/aft2
	name = "Aft Secondary Maintenance"
	icon_state = "amaint"

/area/station/maintenance/starboard
	name = "Starboard Maintenance"
	icon_state = "smaint"

/area/station/maintenance/starboard2
	name = "Starboard Secondary Maintenance"
	icon_state = "smaint"

/area/station/maintenance/port
	name = "Port Maintenance"
	icon_state = "pmaint"

/area/station/maintenance/port2
	name = "Port Secondary Maintenance"
	icon_state = "pmaint"

/area/station/maintenance/storage
	name = "Atmospherics Maintenance"
	icon_state = "atmosmaint"

/area/station/engineering/atmos/asteroid_maint
	name = "Asteroid Filtering Maintenance"
	icon_state = "asteroid_maint"

/area/station/maintenance/xenobio_north
	name = "Xenobiology North Maintenance"
	icon_state = "xenobio_north_maint"

/area/station/maintenance/xenobio_south
	name = "Xenobiology South Maintenance"
	icon_state = "xenobio_south_maint"

// MARK: Maint Rooms
/area/station/maintenance/assembly_line
	name = "\improper Assembly Line"
	icon_state = "ass_line"
	apc_starts_off = TRUE

/area/station/maintenance/abandoned_garden
	name = "\improper Abandoned Garden"
	icon_state = "hydro"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/maintenance/library
	name = "\improper Abandoned Library"
	icon_state = "library"
	apc_starts_off = TRUE

/area/station/maintenance/abandoned_office
	name = "\improper Abandoned Office"
	icon_state = "abandoned_office"
	apc_starts_off = TRUE

/area/station/maintenance/electrical_shop
	name = "\improper Electronics Den"
	icon_state = "elect"

/area/station/maintenance/gambling_den
	name = "\improper Gambling Den"
	icon_state = "yellow"

/area/station/maintenance/theatre
	name = "\improper Abandoned Theatre"
	icon_state = "Theatre"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/station/maintenance/electrical
	name = "\improper Electrical Maintenance"
	icon_state = "elect"

/area/station/maintenance/incinerator
	name = "\improper Incinerator"
	icon_state = "incin"

/area/station/maintenance/electrical/fore
	name = "Fore Electrical Maintenance"

/area/station/maintenance/electrical/aft
	name = "Aft Electrical Maintenance"

/area/station/maintenance/electrical/port
	name = "Port Electrical Maintenance"

/area/station/maintenance/electrical/starboard
	name = "Starboard Electrical Maintenance"

/area/station/maintenance/electrical/fore_port
	name = "Fore Port Electrical Maintenance"

/area/station/maintenance/electrical/aft_port
	name = "Aft Port Electrical Maintenance"

/area/station/maintenance/electrical/fore_starboard
	name = "Fore Starboard Electrical Maintenance"

/area/station/maintenance/electrical/aft_starboard
	name = "Aft Starboard Electrical Maintenance"

/area/station/maintenance/abandonedbar
	name = "\improper Maintenance Bar"
	icon_state = "oldbar"
	apc_starts_off = TRUE

/area/station/maintenance/abandonedservers
	name = "Maintenance Server Room"
	icon_state = "oldserver"
	apc_starts_off = TRUE

/area/station/maintenance/spacehut
	name = "\improper Space Hut"
	icon_state = "spacehut"
	apc_starts_off = TRUE

/area/station/maintenance/turbine
	name = "\improper Turbine"
	icon_state = "turbine"

// MARK: Solars
/area/station/maintenance/solar_maintenance
	name = "\improper Solar Maintenance"
	icon_state = "general_solar_control"

/area/station/maintenance/solar_maintenance/fore
	name = "\improper Fore Solar Maintenance"
	icon_state = "fore_solar_control"

/area/station/maintenance/solar_maintenance/fore_starboard
	name = "\improper Fore-Starboard Solar Maintenance"
	icon_state = "fore_starboard_solar_control"

/area/station/maintenance/solar_maintenance/fore_port
	name = "\improper Fore-Port Solar Maintenance"
	icon_state = "fore_port_solar_control"

/area/station/maintenance/solar_maintenance/aft
	name = "\improper Aft Solar Maintenance"
	icon_state = "aft_solar_control"

/area/station/maintenance/solar_maintenance/aft_starboard
	name = "\improper Aft-Starboard Solar Maintenance"
	icon_state = "aft_starboard_solar_control"

/area/station/maintenance/solar_maintenance/aft_port
	name = "\improper Aft-Port Solar Maintenance"
	icon_state = "aft_port_solar_control"

/area/station/maintenance/solar_maintenance/starboard
	name = "\improper Starboard Solar Maintenance"
	icon_state = "starboard_solar_control"

/area/station/maintenance/solar_maintenance/port
	name = "\improper Port Solar Maintenance"
	icon_state = "port_solar_control"

// MARK: Disposals
/area/station/maintenance/disposal
	name = "Waste Disposal"
	icon_state = "disposals"

/area/station/maintenance/disposal/southwest
	name = "South Western Disposals"

/area/station/maintenance/disposal/south
	name = "Southern Disposals"

/area/station/maintenance/disposal/east
	name = "Eastern Disposals"

/area/station/maintenance/disposal/northeast
	name = "North Eastern Disposals"

/area/station/maintenance/disposal/north
	name = "Northern Disposals"

/area/station/maintenance/disposal/northwest
	name = "North Western Disposals"

/area/station/maintenance/disposal/west
	name = "Western Disposals"

/area/station/maintenance/disposal/westalt
	name = "Western Secondary Disposals"

/area/station/maintenance/disposal/external/southwest
	name = "South-Western External Waste Belt"

/area/station/maintenance/disposal/external/southeast
	name = "South-Eastern External Waste Belt"

/area/station/maintenance/disposal/external/north
	name = "Northern External Waste Belt"

// MARK: Dorms
/area/station/maintenance/dorms
	name = "Dorms Maintenance"
	icon_state = "dorms_maint"

/area/station/maintenance/dorms/port
	name = "Dorms Port Maintenance"
	icon_state = "dorms_maint_port"

/area/station/maintenance/dorms/starboard
	name = "Dorms Starboard Maintenance"
	icon_state = "dorms_maint_starboard"

/area/station/maintenance/dorms/aft
	name = "Dorms Aft Maintenance"
	icon_state = "dorms_maint_aft"

/area/station/maintenance/dorms/fore
	name = "Dorms Fore Maintenance"
	icon_state = "dorms_maint_fore"

// MARK: Command
/area/station/maintenance/command
	name = "\improper Command Maintenance"
	icon_state = "cmd_maint"

/area/station/maintenance/command/fore
	name = "\improper Fore Command Maintenance"
	icon_state = "cmd_maint_fore"

/area/station/maintenance/command/fore_starboard
	name = "\improper Fore-Starboard Command Maintenance"
	icon_state = "cmd_maint_fore_starboard"

/area/station/maintenance/command/fore_port
	name = "\improper Fore-Port Command Maintenance"
	icon_state = "cmd_maint_fore_port"

/area/station/maintenance/command/aft
	name = "\improper Aft Command Maintenance"
	icon_state = "cmd_maint_aft"

/area/station/maintenance/command/aft_starboard
	name = "\improper Aft-Starboard Command Maintenance"
	icon_state = "cmd_maint_aft_starboard"

/area/station/maintenance/command/aft_port
	name = "\improper Aft-Port Command Maintenance"
	icon_state = "cmd_maint_aft_port"

/area/station/maintenance/command/starboard
	name = "\improper Starboard Command Maintenance"
	icon_state = "cmd_maint_starboard"

/area/station/maintenance/command/port
	name = "\improper Port Command Maintenance"
	icon_state = "cmd_maint_port"

// MARK: Security
/area/station/maintenance/security
	name = "\improper Security Maintenance"
	icon_state = "sec_maint"

/area/station/maintenance/security/fore
	name = "\improper Fore Security Maintenance"
	icon_state = "sec_maint_fore"

/area/station/maintenance/security/fore_starboard
	name = "\improper Fore-Starboard Security Maintenance"
	icon_state = "sec_maint_fore_starboard"

/area/station/maintenance/security/fore_port
	name = "\improper Fore-Port Security Maintenance"
	icon_state = "sec_maint_fore_port"

/area/station/maintenance/security/aft
	name = "\improper Aft Security Maintenance"
	icon_state = "sec_maint_aft"

/area/station/maintenance/security/aft_starboard
	name = "\improper Aft-Starboard Security Maintenance"
	icon_state = "sec_maint_aft_starboard"

/area/station/maintenance/security/aft_port
	name = "\improper Aft-Port Security Maintenance"
	icon_state = "sec_maint_aft_port"

/area/station/maintenance/security/starboard
	name = "\improper Starboard Security Maintenance"
	icon_state = "sec_maint_starboard"

/area/station/maintenance/security/port
	name = "\improper Port Security Maintenance"
	icon_state = "sec_maint_port"

// MARK: Service
/area/station/maintenance/service
	name = "\improper Service Maintenance"
	icon_state = "serv_maint"

/area/station/maintenance/service/fore
	name = "\improper Fore Service Maintenance"
	icon_state = "serv_maint_fore"

/area/station/maintenance/service/fore_starboard
	name = "\improper Fore-Starboard Service Maintenance"
	icon_state = "serv_maint_fore_starboard"

/area/station/maintenance/service/fore_port
	name = "\improper Fore-Port Service Maintenance"
	icon_state = "serv_maint_fore_port"

/area/station/maintenance/service/aft
	name = "\improper Aft Service Maintenance"
	icon_state = "serv_maint_aft"

/area/station/maintenance/service/aft_starboard
	name = "\improper Aft-Starboard Service Maintenance"
	icon_state = "serv_maint_aft_starboard"

/area/station/maintenance/service/aft_port
	name = "\improper Aft-Port Service Maintenance"
	icon_state = "serv_maint_aft_port"

/area/station/maintenance/service/starboard
	name = "\improper Starboard Service Maintenance"
	icon_state = "serv_maint_starboard"

/area/station/maintenance/service/port
	name = "\improper Port Service Maintenance"
	icon_state = "serv_maint_port"
