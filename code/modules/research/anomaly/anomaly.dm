// Embedded signaller used in anomalies.
/obj/item/assembly/signaler/anomaly
	name = "anomaly core"
	desc = "The neutralized core of an anomaly. It'd probably be valuable for research."
	icon_state = "anomaly_core"
	item_state = "electronic"
	resistance_flags = FIRE_PROOF
	receiving = TRUE
	var/anomaly_type = /obj/effect/anomaly

/obj/item/assembly/signaler/anomaly/receive_signal(datum/signal/signal)
	if(..())
		for(var/obj/effect/anomaly/A in get_turf(src))
			A.anomalyNeutralize()

/obj/item/assembly/signaler/anomaly/attack_self()
	return

//Anomaly cores
/obj/item/assembly/signaler/anomaly/pyro
	name = "\improper pyroclastic anomaly core"
	desc = "The neutralized core of a pyroclastic anomaly. It feels warm to the touch. It'd probably be valuable for research."
	icon_state = "pyro_core"
	anomaly_type = /obj/effect/anomaly/pyro
	origin_tech = "plasmatech=7"

/obj/item/assembly/signaler/anomaly/grav
	name = "\improper gravitational anomaly core"
	desc = "The neutralized core of a gravitational anomaly. It feels much heavier than it looks. It'd probably be valuable for research."
	icon_state = "grav_core"
	anomaly_type = /obj/effect/anomaly/grav
	origin_tech = "magnets=7"

/obj/item/assembly/signaler/anomaly/flux
	name = "\improper flux anomaly core"
	desc = "The neutralized core of a flux anomaly. Touching it makes your skin tingle. It'd probably be valuable for research."
	icon_state = "flux_core"
	anomaly_type = /obj/effect/anomaly/flux
	origin_tech = "powerstorage=7"

/obj/item/assembly/signaler/anomaly/bluespace
	name = "\improper bluespace anomaly core"
	desc = "The neutralized core of a bluespace anomaly. It keeps phasing in and out of view. It'd probably be valuable for research."
	icon_state = "anomaly_core"
	anomaly_type = /obj/effect/anomaly/bluespace
	origin_tech = "bluespace=7"

/obj/item/assembly/signaler/anomaly/vortex
	name = "\improper vortex anomaly core"
	desc = "The neutralized core of a vortex anomaly. It won't sit still, as if some invisible force is acting on it. It'd probably be valuable for research."
	icon_state = "vortex_core"
	anomaly_type = /obj/effect/anomaly/bhole
	origin_tech = "engineering=7"
