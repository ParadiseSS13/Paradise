/obj/item/implant/tracking
	name = "tracking microchip"
	desc = "Track with this."
	activated = MICROCHIP_ACTIVATED_PASSIVE
	origin_tech = "materials=2;magnets=2;programming=2;biotech=2"
	var/id = 1
	var/warn_cooldown = 0


/obj/item/implant/tracking/New()
	..()
	GLOB.tracked_implants += src

/obj/item/implant/tracking/Destroy()
	GLOB.tracked_implants -= src
	return ..()

/obj/item/implant/tracking/get_data()
	var/dat = {"<b>Microchip Specifications:</b><BR>
				<b>Name:</b> Tracking Beacon<BR>
				<b>Life:</b> 10 minutes after death of host<BR>
				<b>Important Notes:</b> None<BR>
				<HR>
				<b>Microchip Details:</b> <BR>
				<b>Function:</b> Continuously transmits low power signal. Useful for tracking.<BR>
				<b>Special Features:</b><BR>
				<i>Neuro-Safe</i>- Specialized shell absorbs excess voltages self-destructing the microchip if
				a malfunction occurs thereby securing safety of subject. The microchip will melt and
				disintegrate into bio-safe elements.<BR>
				<b>Integrity:</b> Gradient creates slight risk of being overcharged and frying the
				circuitry. As a result neurotoxins can cause massive damage.<HR>
				Microchip Specifics:<BR>"}
	return dat
