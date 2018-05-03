//For use with the RPD (for now). All pipes here are ones that can be dispensed with the RPD

#define RPD_ATMOS		1
#define RPD_DISPOSAL	2

/datum/pipes
	var/pipename //What the pipe is called in the interface
	var/pipeid //Use the pipe define for this
	var/pipetype //Atmos, disposals etc.
	var/category //What category of pipe
	var/bendy = FALSE//Is this pipe bendy?
	var/orientations //Number of orientations (for interface purposes)
	var/previewicon //icon_state of the dispensed pipe (for interface purposes)

/datum/pipes/atmospheric
	pipetype = RPD_ATMOS
	category = RPD_ATMOS_PIPING

/datum/pipes/disposal
	pipetype = RPD_DISPOSAL

//Normal pipes

/datum/pipes/atmospheric/simple
	pipename = "Straight pipe"
	pipeid = PIPE_SIMPLE_STRAIGHT
	orientations = 2
	previewicon = "simple"

/datum/pipes/atmospheric/simple/bent
	pipename = "Bent pipe"
	pipeid = PIPE_SIMPLE_BENT
	orientations = 4
	bendy = TRUE

/datum/pipes/atmospheric/manifold
	pipename = "T-manifold"
	pipeid = PIPE_MANIFOLD
	orientations = 4
	previewicon = "manifold"

/datum/pipes/atmospheric/manifold4w
	pipename = "4-way manifold"
	pipeid = PIPE_MANIFOLD4W
	orientations = 1
	previewicon = "manifold4w"

/datum/pipes/atmospheric/cap
	pipename = "Pipe cap"
	pipeid = PIPE_CAP
	orientations = 4
	previewicon = "cap"

/datum/pipes/atmospheric/valve
	pipename = "Manual valve"
	pipeid = PIPE_MVALVE
	orientations = 2
	previewicon = "mvalve"

/datum/pipes/atmospheric/valve/digital
	pipename = "Digital valve"
	pipeid = PIPE_DVALVE
	previewicon = "dvalve"

/datum/pipes/atmospheric/tvalve
	pipename = "Manual T-valve"
	pipeid = PIPE_TVALVE
	orientations = 4
	previewicon = "tvalve"

/datum/pipes/atmospheric/tvalve/digital
	pipename = "Digital T-valve"
	pipeid = PIPE_DTVALVE
	previewicon = "dtvalve"

//Supply pipes


/datum/pipes/atmospheric/simple/supply
	pipename = "Straight supply pipe"
	pipeid = PIPE_SUPPLY_STRAIGHT
	category = RPD_SUPPLY_PIPING

/datum/pipes/atmospheric/simple/bent/supply
	pipename = "Bent supply pipe"
	pipeid = PIPE_SUPPLY_BENT
	category = RPD_SUPPLY_PIPING

/datum/pipes/atmospheric/manifold/supply
	pipename = "Supply T-manifold"
	pipeid = PIPE_SUPPLY_MANIFOLD
	category = RPD_SUPPLY_PIPING

/datum/pipes/atmospheric/manifold4w/supply
	pipename = "4-way supply manifold"
	pipeid = PIPE_SUPPLY_MANIFOLD4W
	category = RPD_SUPPLY_PIPING

/datum/pipes/atmospheric/cap/supply
	pipename = "Supply pipe cap"
	pipeid = PIPE_SUPPLY_CAP
	category = RPD_SUPPLY_PIPING

//Scrubbers pipes

/datum/pipes/atmospheric/simple/scrubbers
	pipename = "Straight scrubbers pipe"
	pipeid = PIPE_SCRUBBERS_STRAIGHT
	category = RPD_SCRUBBERS_PIPING

/datum/pipes/atmospheric/simple/bent/scrubbers
	pipename = "Bent scrubbers pipe"
	pipeid = PIPE_SCRUBBERS_BENT
	category = RPD_SCRUBBERS_PIPING

/datum/pipes/atmospheric/manifold/scrubbers
	pipename = "Scrubbers T-manifold"
	pipeid = PIPE_SCRUBBERS_MANIFOLD
	category = RPD_SCRUBBERS_PIPING

/datum/pipes/atmospheric/manifold4w/scrubbers
	pipename = "4-way scrubbers manifold"
	pipeid = PIPE_SCRUBBERS_MANIFOLD4W
	category = RPD_SCRUBBERS_PIPING

/datum/pipes/atmospheric/cap/scrubbers
	pipename = "Scrubbers pipe cap"
	pipeid = PIPE_SCRUBBERS_CAP
	category = RPD_SCRUBBERS_PIPING

//Devices

/datum/pipes/atmospheric/upa
	pipename = "Universal pipe adapter"
	pipeid = PIPE_UNIVERSAL
	orientations = 2
	previewicon = "universal"
	category = RPD_DEVICES

/datum/pipes/atmospheric/connector
	pipename = "Connector"
	pipeid = PIPE_CONNECTOR
	orientations = 4
	previewicon = "connector"
	category = RPD_DEVICES

/datum/pipes/atmospheric/unaryvent
	pipename = "Unary vent"
	pipeid = PIPE_UVENT
	orientations = 4
	previewicon = "uvent"
	category = RPD_DEVICES

/datum/pipes/atmospheric/scrubber
	pipename = "Scrubber"
	pipeid = PIPE_SCRUBBER
	orientations = 4
	previewicon = "scrubber"
	category = RPD_DEVICES

/datum/pipes/atmospheric/pump
	pipename = "Gas pump"
	pipeid = PIPE_PUMP
	orientations = 4
	previewicon = "pump"
	category = RPD_DEVICES

/datum/pipes/atmospheric/volume_pump
	pipename = "Volume pump"
	pipeid = PIPE_VOLUME_PUMP
	orientations = 4
	previewicon = "volumepump"
	category = RPD_DEVICES

/datum/pipes/atmospheric/gate
	pipename = "Passive gate"
	pipeid = PIPE_PASSIVE_GATE
	orientations = 4
	previewicon = "passivegate"
	category = RPD_DEVICES

/datum/pipes/atmospheric/filter
	pipename = "Gas filter"
	pipeid = PIPE_GAS_FILTER
	orientations = 4
	previewicon = "filter"
	category = RPD_DEVICES

/datum/pipes/atmospheric/mixer
	pipename = "Gas mixer"
	pipeid = PIPE_GAS_MIXER
	orientations = 4
	previewicon = "mixer"
	category = RPD_DEVICES

/datum/pipes/atmospheric/sensor
	pipename = "Gas sensor"
	pipeid = PIPE_GAS_SENSOR
	orientations = 1
	previewicon = "sensor"
	category = RPD_DEVICES

/datum/pipes/atmospheric/meter
	pipename = "Gas meter"
	pipeid = PIPE_METER
	orientations = 1
	previewicon = "meter"
	category = RPD_DEVICES

/datum/pipes/atmospheric/passive_vent
	pipename = "Passive vent"
	pipeid = PIPE_PASV_VENT
	orientations = 4
	previewicon = "passive vent"
	category = RPD_DEVICES

/datum/pipes/atmospheric/dual_vent_pump
	pipename = "Dual-port vent pump"
	pipeid = PIPE_DP_VENT
	orientations = 2
	previewicon = "dual-port vent"
	category = RPD_DEVICES

/datum/pipes/atmospheric/injector
	pipename = "Air injector"
	pipeid = PIPE_INJECTOR
	orientations = 4
	previewicon = "injector"
	category = RPD_DEVICES

//Heat exchange pipes

/datum/pipes/atmospheric/he
	pipename = "Straight pipe"
	pipeid = PIPE_HE_STRAIGHT
	orientations = 2
	previewicon = "he"
	category = RPD_HEAT_PIPING

/datum/pipes/atmospheric/he/bent
	pipename = "Bent pipe"
	pipeid = PIPE_HE_BENT
	orientations = 4
	bendy = TRUE

/datum/pipes/atmospheric/he_junction
	pipename = "Junction"
	pipeid = PIPE_JUNCTION
	orientations = 4
	previewicon = "junction"
	category = RPD_HEAT_PIPING

/datum/pipes/atmospheric/heat_exchanger
	pipename = "Heat exchanger"
	pipeid = PIPE_HEAT_EXCHANGE
	orientations = 4
	previewicon = "heunary"
	category = RPD_HEAT_PIPING

//DISPOSALS PIPES

/datum/pipes/disposal/straight
	pipename = "Straight pipe"
	pipeid = PIPE_DISPOSALS_STRAIGHT
	orientations = 2
	previewicon = "conpipe-s"

/datum/pipes/disposal/bent
	pipename = "Bent pipe"
	pipeid = PIPE_DISPOSALS_BENT
	orientations = 4
	previewicon = "conpipe-c"

/datum/pipes/disposal/junction
	pipename = "Junction"
	pipeid = PIPE_DISPOSALS_JUNCTION
	orientations = 4
	previewicon = "conpipe-j1"

/datum/pipes/disposal/y_junction
	pipename = "Y-junction"
	pipeid = PIPE_DISPOSALS_Y_JUNCTION
	orientations = 4
	previewicon = "conpipe-y"

/datum/pipes/disposal/trunk
	pipename = "Trunk"
	pipeid = PIPE_DISPOSALS_TRUNK
	orientations = 4
	previewicon = "conpipe-t"

/datum/pipes/disposal/bin
	pipename = "Bin"
	pipeid = PIPE_DISPOSALS_BIN
	orientations = 1
	previewicon = "condisposal"

/datum/pipes/disposal/outlet
	pipename = "Outlet"
	pipeid = PIPE_DISPOSALS_OUTLET
	orientations = 4
	previewicon = "outlet"

/datum/pipes/disposal/chute
	pipename = "Chute"
	pipeid = PIPE_DISPOSALS_CHUTE
	orientations = 4
	previewicon = "intake"

#undef RPD_ATMOS
#undef RPD_DISPOSAL
