// Embedded signaller used in anomalies.
/obj/item/assembly/signaler/anomaly
	name = "anomaly core"
	desc = "The neutralized core of an anomaly. It'd probably be valuable for research."
	icon_state = "anomaly_core"
	item_state = "electronic"
	resistance_flags = FIRE_PROOF
	receiving = TRUE
	var/anomaly_type = /obj/effect/anomaly

/obj/item/assembly/signaler/anomaly/signal_callback()
	if(istype(loc, /obj/effect/anomaly))
		var/obj/effect/anomaly/A = loc
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

/obj/item/assembly/signaler/anomaly/cryo
	name = "\improper cryogenic anomaly core"
	desc = "The neutralized core of a cryogenic anomaly. Rime is forming on its cold surface. It'd probably be valuable for research."
	icon_state = "cryo_core"
	anomaly_type = /obj/effect/anomaly/cryo
	origin_tech = "biotech=7"

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

/obj/item/assembly/signaler/anomaly/random
	name = "Random anomaly core"

/obj/item/assembly/signaler/anomaly/random/New()
	..()
	var/list/types = list(/obj/item/assembly/signaler/anomaly/pyro, /obj/item/assembly/signaler/anomaly/cryo, /obj/item/assembly/signaler/anomaly/grav, /obj/item/assembly/signaler/anomaly/flux, /obj/item/assembly/signaler/anomaly/bluespace, /obj/item/assembly/signaler/anomaly/vortex)
	var/A = pick(types)
	new A(loc)
	qdel(src)

/obj/item/reactive_armour_shell
	name = "reactive armour shell"
	desc = "An experimental suit of armour, awaiting installation of an anomaly core."
	icon_state = "reactiveoff"
	icon = 'icons/obj/clothing/suits.dmi'
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/reactive_armour_shell/attackby(obj/item/I, mob/user, params)
	var/static/list/anomaly_armour_types = list(
		/obj/item/assembly/signaler/anomaly/grav = /obj/item/clothing/suit/armor/reactive/repulse,
		/obj/item/assembly/signaler/anomaly/flux = /obj/item/clothing/suit/armor/reactive/tesla,
		/obj/item/assembly/signaler/anomaly/bluespace = /obj/item/clothing/suit/armor/reactive/teleport,
		/obj/item/assembly/signaler/anomaly/pyro = /obj/item/clothing/suit/armor/reactive/fire,
		/obj/item/assembly/signaler/anomaly/cryo = /obj/item/clothing/suit/armor/reactive/cryo,
		/obj/item/assembly/signaler/anomaly/vortex = /obj/item/clothing/suit/armor/reactive/stealth
		)

	if(istype(I, /obj/item/assembly/signaler/anomaly))
		var/obj/item/assembly/signaler/anomaly/A = I
		var/armour_path = anomaly_armour_types[A.type]
		if(!armour_path)
			armour_path = /obj/item/clothing/suit/armor/reactive/stealth //Fallback
		to_chat(user, "<span class='notice'>You insert [A] into the chest plate, and the armor gently hums to life.</span>")
		new armour_path(get_turf(src))
		qdel(src)
		qdel(A)
	return ..()
