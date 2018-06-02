//For use with the RPD (for now). All pipes here are ones that can be dispensed with the RPD

#define RPD_ATMOS		1
#define RPD_DISPOSAL	2

GLOBAL_LIST_EMPTY(construction_pipe_list)	//List of all pipe datums

/datum/pipes
	var/pipe_name //What the pipe is called in the interface
	var/pipe_id //Use the pipe define for this
	var/pipe_type //Atmos, disposals etc.
	var/pipe_category //What category of pipe
	var/bendy = FALSE//Is this pipe bendy?
	var/orientations //Number of orientations (for interface purposes)
	var/pipe_icon //icon_state of the dispensed pipe (for interface purposes)

/datum/pipes/atmospheric
	pipe_type = RPD_ATMOS
	pipe_category = RPD_ATMOS_PIPING

/datum/pipes/disposal
	pipe_type = RPD_DISPOSAL

//Normal pipes

/datum/pipes/atmospheric/simple
	pipe_name = "Straight pipe"
	pipe_id = PIPE_SIMPLE_STRAIGHT
	orientations = 2
	pipe_icon = "simple"

/datum/pipes/atmospheric/bent //Why is this not atmospheric/simple/bent you ask? Because otherwise the ordering of the pipes in the UI menu gets weird
	pipe_name = "Bent pipe"
	pipe_id = PIPE_SIMPLE_BENT
	orientations = 4
	bendy = TRUE
	pipe_icon = "simple"

/datum/pipes/atmospheric/manifold
	pipe_name = "T-manifold"
	pipe_id = PIPE_MANIFOLD
	orientations = 4
	pipe_icon = "manifold"

/datum/pipes/atmospheric/manifold4w
	pipe_name = "4-way manifold"
	pipe_id = PIPE_MANIFOLD4W
	orientations = 1
	pipe_icon = "manifold4w"

/datum/pipes/atmospheric/cap
	pipe_name = "Pipe cap"
	pipe_id = PIPE_CAP
	orientations = 4
	pipe_icon = "cap"

/datum/pipes/atmospheric/valve
	pipe_name = "Manual valve"
	pipe_id = PIPE_MVALVE
	orientations = 2
	pipe_icon = "mvalve"

/datum/pipes/atmospheric/valve/digital
	pipe_name = "Digital valve"
	pipe_id = PIPE_DVALVE
	pipe_icon = "dvalve"

/datum/pipes/atmospheric/tvalve
	pipe_name = "Manual T-valve"
	pipe_id = PIPE_TVALVE
	orientations = 4
	pipe_icon = "tvalve"

/datum/pipes/atmospheric/tvalve/digital
	pipe_name = "Digital T-valve"
	pipe_id = PIPE_DTVALVE
	pipe_icon = "dtvalve"

//Supply pipes

/datum/pipes/atmospheric/simple/supply
	pipe_name = "Straight supply pipe"
	pipe_id = PIPE_SUPPLY_STRAIGHT
	pipe_category = RPD_SUPPLY_PIPING

/datum/pipes/atmospheric/bent/supply
	pipe_name = "Bent supply pipe"
	pipe_id = PIPE_SUPPLY_BENT
	pipe_category = RPD_SUPPLY_PIPING

/datum/pipes/atmospheric/manifold/supply
	pipe_name = "Supply T-manifold"
	pipe_id = PIPE_SUPPLY_MANIFOLD
	pipe_category = RPD_SUPPLY_PIPING

/datum/pipes/atmospheric/manifold4w/supply
	pipe_name = "4-way supply manifold"
	pipe_id = PIPE_SUPPLY_MANIFOLD4W
	pipe_category = RPD_SUPPLY_PIPING

/datum/pipes/atmospheric/cap/supply
	pipe_name = "Supply pipe cap"
	pipe_id = PIPE_SUPPLY_CAP
	pipe_category = RPD_SUPPLY_PIPING

//Scrubbers pipes

/datum/pipes/atmospheric/simple/scrubbers
	pipe_name = "Straight scrubbers pipe"
	pipe_id = PIPE_SCRUBBERS_STRAIGHT
	pipe_category = RPD_SCRUBBERS_PIPING

/datum/pipes/atmospheric/bent/scrubbers
	pipe_name = "Bent scrubbers pipe"
	pipe_id = PIPE_SCRUBBERS_BENT
	pipe_category = RPD_SCRUBBERS_PIPING

/datum/pipes/atmospheric/manifold/scrubbers
	pipe_name = "Scrubbers T-manifold"
	pipe_id = PIPE_SCRUBBERS_MANIFOLD
	pipe_category = RPD_SCRUBBERS_PIPING

/datum/pipes/atmospheric/manifold4w/scrubbers
	pipe_name = "4-way scrubbers manifold"
	pipe_id = PIPE_SCRUBBERS_MANIFOLD4W
	pipe_category = RPD_SCRUBBERS_PIPING

/datum/pipes/atmospheric/cap/scrubbers
	pipe_name = "Scrubbers pipe cap"
	pipe_id = PIPE_SCRUBBERS_CAP
	pipe_category = RPD_SCRUBBERS_PIPING

//Devices

/datum/pipes/atmospheric/upa
	pipe_name = "Universal pipe adapter"
	pipe_id = PIPE_UNIVERSAL
	orientations = 2
	pipe_icon = "universal"
	pipe_category = RPD_DEVICES

/datum/pipes/atmospheric/connector
	pipe_name = "Connector"
	pipe_id = PIPE_CONNECTOR
	orientations = 4
	pipe_icon = "connector"
	pipe_category = RPD_DEVICES

/datum/pipes/atmospheric/unaryvent
	pipe_name = "Unary vent"
	pipe_id = PIPE_UVENT
	orientations = 4
	pipe_icon = "uvent"
	pipe_category = RPD_DEVICES

/datum/pipes/atmospheric/scrubber
	pipe_name = "Scrubber"
	pipe_id = PIPE_SCRUBBER
	orientations = 4
	pipe_icon = "scrubber"
	pipe_category = RPD_DEVICES

/datum/pipes/atmospheric/pump
	pipe_name = "Gas pump"
	pipe_id = PIPE_PUMP
	orientations = 4
	pipe_icon = "pump"
	pipe_category = RPD_DEVICES

/datum/pipes/atmospheric/volume_pump
	pipe_name = "Volume pump"
	pipe_id = PIPE_VOLUME_PUMP
	orientations = 4
	pipe_icon = "volumepump"
	pipe_category = RPD_DEVICES

/datum/pipes/atmospheric/gate
	pipe_name = "Passive gate"
	pipe_id = PIPE_PASSIVE_GATE
	orientations = 4
	pipe_icon = "passivegate"
	pipe_category = RPD_DEVICES

/datum/pipes/atmospheric/filter
	pipe_name = "Gas filter"
	pipe_id = PIPE_GAS_FILTER
	orientations = 4
	pipe_icon = "filter"
	pipe_category = RPD_DEVICES

/datum/pipes/atmospheric/mixer
	pipe_name = "Gas mixer"
	pipe_id = PIPE_GAS_MIXER
	orientations = 4
	pipe_icon = "mixer"
	pipe_category = RPD_DEVICES

/datum/pipes/atmospheric/sensor
	pipe_name = "Gas sensor"
	pipe_id = PIPE_GAS_SENSOR
	orientations = 1
	pipe_icon = "sensor"
	pipe_category = RPD_DEVICES

/datum/pipes/atmospheric/meter
	pipe_name = "Gas meter"
	pipe_id = PIPE_METER
	orientations = 1
	pipe_icon = "meter"
	pipe_category = RPD_DEVICES

/datum/pipes/atmospheric/passive_vent
	pipe_name = "Passive vent"
	pipe_id = PIPE_PASV_VENT
	orientations = 4
	pipe_icon = "passive vent"
	pipe_category = RPD_DEVICES

/datum/pipes/atmospheric/dual_vent_pump
	pipe_name = "Dual-port vent pump"
	pipe_id = PIPE_DP_VENT
	orientations = 2
	pipe_icon = "dual-port vent"
	pipe_category = RPD_DEVICES

/datum/pipes/atmospheric/injector
	pipe_name = "Air injector"
	pipe_id = PIPE_INJECTOR
	orientations = 4
	pipe_icon = "injector"
	pipe_category = RPD_DEVICES

//Heat exchange pipes

/datum/pipes/atmospheric/he
	pipe_name = "Straight pipe"
	pipe_id = PIPE_HE_STRAIGHT
	orientations = 2
	pipe_icon = "he"
	pipe_category = RPD_HEAT_PIPING

/datum/pipes/atmospheric/he/bent
	pipe_name = "Bent pipe"
	pipe_id = PIPE_HE_BENT
	orientations = 4
	bendy = TRUE

/datum/pipes/atmospheric/he_junction
	pipe_name = "Junction"
	pipe_id = PIPE_JUNCTION
	orientations = 4
	pipe_icon = "junction"
	pipe_category = RPD_HEAT_PIPING

/datum/pipes/atmospheric/heat_exchanger
	pipe_name = "Heat exchanger"
	pipe_id = PIPE_HEAT_EXCHANGE
	orientations = 4
	pipe_icon = "heunary"
	pipe_category = RPD_HEAT_PIPING

//DISPOSALS PIPES

/datum/pipes/disposal/straight
	pipe_name = "Straight pipe"
	pipe_id = PIPE_DISPOSALS_STRAIGHT
	orientations = 2
	pipe_icon = "conpipe-s"

/datum/pipes/disposal/bent
	pipe_name = "Bent pipe"
	pipe_id = PIPE_DISPOSALS_BENT
	orientations = 4
	pipe_icon = "conpipe-c"

/datum/pipes/disposal/junction
	pipe_name = "Junction"
	pipe_id = PIPE_DISPOSALS_JUNCTION
	orientations = 4
	pipe_icon = "conpipe-j1"

/datum/pipes/disposal/y_junction
	pipe_name = "Y-junction"
	pipe_id = PIPE_DISPOSALS_Y_JUNCTION
	orientations = 4
	pipe_icon = "conpipe-y"

/datum/pipes/disposal/trunk
	pipe_name = "Trunk"
	pipe_id = PIPE_DISPOSALS_TRUNK
	orientations = 4
	pipe_icon = "conpipe-t"

/datum/pipes/disposal/bin
	pipe_name = "Bin"
	pipe_id = PIPE_DISPOSALS_BIN
	orientations = 1
	pipe_icon = "condisposal"

/datum/pipes/disposal/outlet
	pipe_name = "Outlet"
	pipe_id = PIPE_DISPOSALS_OUTLET
	orientations = 4
	pipe_icon = "outlet"

/datum/pipes/disposal/chute
	pipe_name = "Chute"
	pipe_id = PIPE_DISPOSALS_CHUTE
	orientations = 4
	pipe_icon = "intake"

#undef RPD_ATMOS
#undef RPD_DISPOSAL
