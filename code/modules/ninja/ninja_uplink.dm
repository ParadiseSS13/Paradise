/obj/item/bio_chip/uplink/ninja
	name = "spider clan uplink bio-chip"
	desc = "Purchase things from the spider clan with earned currency."

/obj/item/bio_chip/uplink/ninja/Initialize(mapload)
	. = ..()
	if(hidden_uplink)
		hidden_uplink.update_uplink_type(UPLINK_TYPE_NINJA)
		hidden_uplink.uses = 0
