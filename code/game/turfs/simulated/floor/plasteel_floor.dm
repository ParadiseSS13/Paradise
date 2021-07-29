/turf/simulated/floor/plasteel
	icon_state = "floor"
	floor_tile = /obj/item/stack/tile/plasteel
	broken_states = list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5")
	burnt_states = list("floorscorched1", "floorscorched2")

/turf/simulated/floor/plasteel/update_icon()
	if(!..())
		return 0
	if(!broken && !burnt)
		icon_state = icon_regular_floor

/turf/simulated/floor/plasteel/airless
	name = "airless floor"
	oxygen = 0
	nitrogen = 0
	temperature = TCMB

/turf/simulated/floor/plasteel/airless/Initialize(mapload)
	. = ..()
	name = "floor"

/turf/simulated/floor/plasteel/airless/indestructible // For bomb testing range

/turf/simulated/floor/plasteel/airless/indestructible/ex_act(severity)
	return

// Neutral subtype
/turf/simulated/floor/plasteel/neutral
/turf/simulated/floor/plasteel/neutral/black
	icon_state = "blackfull"
/turf/simulated/floor/plasteel/neutral/black/edge
	icon_state = "black"
/turf/simulated/floor/plasteel/neutral/black/corner
	icon_state = "blackcorner"
/turf/simulated/floor/plasteel/neutral/red
	icon_state = "redfull"
/turf/simulated/floor/plasteel/neutral/red/edge
	icon_state = "red"
/turf/simulated/floor/plasteel/neutral/red/corner
	icon_state = "redcorner"
/turf/simulated/floor/plasteel/neutral/redwhite
	icon_state = "redwhitefull"
/turf/simulated/floor/plasteel/neutral/redwhite/edge
	icon_state = "redwhite"
/turf/simulated/floor/plasteel/neutral/redgreen
	icon_state = "redgreenfull"
/turf/simulated/floor/plasteel/neutral/redgreen/edge
	icon_state = "redgreen"
/turf/simulated/floor/plasteel/neutral/redyellow
	icon_state = "redyellowfull"
/turf/simulated/floor/plasteel/neutral/redyellow/edge
	icon_state = "redyellow"
/turf/simulated/floor/plasteel/neutral/yellow
	icon_state = "yellowfull"
/turf/simulated/floor/plasteel/neutral/yellow/edge
	icon_state = "yellow"
/turf/simulated/floor/plasteel/neutral/yellow/corner
	icon_state = "yellowcorner"
/turf/simulated/floor/plasteel/neutral/yellow/siding_edge
	icon_state = "yellowsiding"
/turf/simulated/floor/plasteel/neutral/yellow/siding_corner
	icon_state = "yellowsidingcorner"
/turf/simulated/floor/plasteel/neutral/yellowblack
	icon_state = "yellowblackfull"
/turf/simulated/floor/plasteel/neutral/yellowblack/edge
	icon_state = "yellowblack"
/turf/simulated/floor/plasteel/neutral/blue
	icon_state = "bluefull"
/turf/simulated/floor/plasteel/neutral/blue/edge
	icon_state = "blue"
/turf/simulated/floor/plasteel/neutral/blue/corner
	icon_state = "bluecorner"
/turf/simulated/floor/plasteel/neutral/bluered
	icon_state = "blueredfull"
/turf/simulated/floor/plasteel/neutral/bluered/edge
	icon_state = "bluered"
/turf/simulated/floor/plasteel/neutral/blueyellow
	icon_state = "blueyellowfull"
/turf/simulated/floor/plasteel/neutral/blueyellow/edge
	icon_state = "blueyellow"
/turf/simulated/floor/plasteel/neutral/bluewhite
	icon_state = "bluewhitefull"
/turf/simulated/floor/plasteel/neutral/bluewhite/edge
	icon_state = "bluewhite"
/turf/simulated/floor/plasteel/neutral/brown
	icon_state = "brownfull"
/turf/simulated/floor/plasteel/neutral/brown/edge
	icon_state = "brown"
/turf/simulated/floor/plasteel/neutral/brown/corner
	icon_state = "browncorner"
/turf/simulated/floor/plasteel/neutral/purple
	icon_state = "purplefull"
/turf/simulated/floor/plasteel/neutral/purple/edge
	icon_state = "purple"
/turf/simulated/floor/plasteel/neutral/purple/corner
	icon_state = "purplecorner"
/turf/simulated/floor/plasteel/neutral/green
	icon_state = "greenfull"
/turf/simulated/floor/plasteel/neutral/green/edge
	icon_state = "green"
/turf/simulated/floor/plasteel/neutral/green/corner
	icon_state = "greencorner"
/turf/simulated/floor/plasteel/neutral/greenblue
	icon_state = "greenbluefull"
/turf/simulated/floor/plasteel/neutral/greenblue/edge
	icon_state = "greenblue"
/turf/simulated/floor/plasteel/neutral/greenyellow
	icon_state = "greenyellowfull"
/turf/simulated/floor/plasteel/neutral/greenyellow/edge
	icon_state = "greenyellow"
/turf/simulated/floor/plasteel/neutral/orange
	icon_state = "orangefull"
/turf/simulated/floor/plasteel/neutral/orange/edge
	icon_state = "orange"
/turf/simulated/floor/plasteel/neutral/orange/corner
	icon_state = "orangecorner"
/turf/simulated/floor/plasteel/neutral/highlight
	icon_state = "highlightfull"
/turf/simulated/floor/plasteel/neutral/highlight/edge
	icon_state = "highlight"
/turf/simulated/floor/plasteel/neutral/highlight/corner
	icon_state = "highlightcorner"
/turf/simulated/floor/plasteel/neutral/bar
	icon_state = "bar"
/turf/simulated/floor/plasteel/neutral/cafeteria
	icon_state = "cafeteria"

// Dark subtype

/turf/simulated/floor/plasteel/dark
	icon_state = "dark"
/turf/simulated/floor/plasteel/dark/purple
	icon_state = "darkpurplefull"
/turf/simulated/floor/plasteel/dark/purple/edge
	icon_state = "darkpurple"
/turf/simulated/floor/plasteel/dark/purple/corner
	icon_state = "darkpurplecorner"
/turf/simulated/floor/plasteel/dark/red
	icon_state = "darkredfull"
/turf/simulated/floor/plasteel/dark/red/edge
	icon_state = "darkred"
/turf/simulated/floor/plasteel/dark/red/corner
	icon_state = "darkredcorner"
/turf/simulated/floor/plasteel/dark/redblue
	icon_state = "darkredbluefull"
/turf/simulated/floor/plasteel/dark/redblue/edge
	icon_state = "darkredblue"
/turf/simulated/floor/plasteel/dark/redgreen
	icon_state = "darkredgreenfull"
/turf/simulated/floor/plasteel/dark/redgreen/edge
	icon_state = "darkredgreen"
/turf/simulated/floor/plasteel/dark/redyellow
	icon_state = "darkredyellowfull"
/turf/simulated/floor/plasteel/dark/redyellow/edge
	icon_state = "darkredyellow"
/turf/simulated/floor/plasteel/dark/blue
	icon_state = "darkbluefull"
/turf/simulated/floor/plasteel/dark/blue/edge
	icon_state = "darkblue"
/turf/simulated/floor/plasteel/dark/blue/corner
	icon_state = "darkpurplecorner"
/turf/simulated/floor/plasteel/dark/purple/edge
	icon_state = "darkpurple"
/turf/simulated/floor/plasteel/dark/purple/corner
	icon_state = "darkpurplecorner"
/turf/simulated/floor/plasteel/dark/green
	icon_state = "darkgreenfull"
/turf/simulated/floor/plasteel/dark/green/edge
	icon_state = "darkgreen"
/turf/simulated/floor/plasteel/dark/green/corner
	icon_state = "darkgreencorner"
/turf/simulated/floor/plasteel/dark/yellow
	icon_state = "darkyellowfull"
/turf/simulated/floor/plasteel/dark/yellow/edge
	icon_state = "darkyellow"
/turf/simulated/floor/plasteel/dark/yellow/corner
	icon_state = "darkyellowcorner"
/turf/simulated/floor/plasteel/dark/brown
	icon_state = "darkbrownfull"
/turf/simulated/floor/plasteel/dark/brown/edge
	icon_state = "darkbrown"
/turf/simulated/floor/plasteel/dark/brown/corner
	icon_state = "darkbrowncorner"

// White subtype

/turf/simulated/floor/plasteel/white
	icon_state = "whitefull"
/turf/simulated/floor/plasteel/white/edge
	icon_state = "white"
/turf/simulated/floor/plasteel/white/corner
	icon_state = "whitecorner"
/turf/simulated/floor/plasteel/white/blue
	icon_state = "whitebluefull"
/turf/simulated/floor/plasteel/white/blue/edge
	icon_state = "whiteblue"
/turf/simulated/floor/plasteel/white/blue/corner
	icon_state = "whitebluecorner"
/turf/simulated/floor/plasteel/white/green
	icon_state = "whitegreenfull"
/turf/simulated/floor/plasteel/white/green/edge
	icon_state = "whitegreen"
/turf/simulated/floor/plasteel/white/green/corner
	icon_state = "whitegreencorner"
/turf/simulated/floor/plasteel/white/purple
	icon_state = "whitepurplefull"
/turf/simulated/floor/plasteel/white/purple/edge
	icon_state = "whitepurple"
/turf/simulated/floor/plasteel/white/purple/corner
	icon_state = "whitepurplecorner"
/turf/simulated/floor/plasteel/white/red
	icon_state = "whiteredfull"
/turf/simulated/floor/plasteel/white/red/edge
	icon_state = "whitered"
/turf/simulated/floor/plasteel/white/red/corner
	icon_state = "whiteredcorner"
/turf/simulated/floor/plasteel/white/yellow
	icon_state = "whiteyellowfull"
/turf/simulated/floor/plasteel/white/yellow/edge
	icon_state = "whiteyellow"
/turf/simulated/floor/plasteel/white/yellow/corner
	icon_state = "whiteyellowcorner"

// Misc subtypes

/turf/simulated/floor/plasteel/misc/grimy
	icon_state = "grimy"
/turf/simulated/floor/plasteel/misc/freezer
	icon_state = "freezerfloor"
/turf/simulated/floor/plasteel/misc/stairs
	icon_state = "stairs"
/turf/simulated/floor/plasteel/misc/stairs/left
	icon_state = "stairs-l"
/turf/simulated/floor/plasteel/misc/stairs/medium
	icon_state = "stairs-m"
/turf/simulated/floor/plasteel/misc/stairs/right
	icon_state = "stairs-r"
/turf/simulated/floor/plasteel/misc/circuit/blue
	icon_state = "bcircuit"
/turf/simulated/floor/plasteel/misc/circuit/red
	icon_state = "rcircuit"
/turf/simulated/floor/plasteel/misc/circuit/green
	icon_state = "gcircuit"
/turf/simulated/floor/plasteel/misc/plaque
	icon_state = "plaque"
	name = "Commemorative Plaque"
	desc = "\"This is a plaque in honour of our comrades on the G4407 Stations. Hopefully TG4407 model can live up to your fame and fortune.\" Scratched in beneath that is a crude image of a meteor and a spaceman. The spaceman is laughing. The meteor is exploding."
/turf/simulated/floor/plasteel/misc/chapel
	icon_state = "chapel"
/turf/simulated/floor/plasteel/misc/cult
	icon_state = "cult"
/turf/simulated/floor/plasteel/misc/vault
	icon_state = "vault"
