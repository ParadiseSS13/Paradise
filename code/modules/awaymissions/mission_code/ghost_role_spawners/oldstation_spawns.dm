//Ancient cryogenic sleepers. Players become NT crewmen from a hundred year old space station, now on the verge of collapse.

/obj/effect/mob_spawn/human/alive/old
	name = "old cryogenics pod"
	desc = "A humming cryo pod. You can barely recognise a security uniform underneath the built up ice. The machine is attempting to wake up its occupant."
	description = "Work as a team with your fellow survivors aboard a ruined, ancient space station."
	assignedrole = "Ancient Crew"
	allow_gender_pick = TRUE

/obj/effect/mob_spawn/human/alive/old/Initialize(mapload)
	flavour_text = "You are \a [role_name] working for Nanotrasen, stationed onboard a state of the art research station. You vaguely recall rushing into a \
	cryogenics pod due to an oncoming radiation storm. The last thing you remember is the station's Artificial Program telling you that you would only be asleep for eight hours. As you open \
	your eyes, everything seems rusted and broken, a dark feeling swells in your gut as you climb out of your pod."
	return ..()

/obj/effect/mob_spawn/human/alive/old/Destroy()
	new /obj/structure/showcase/machinery/oldpod/used(drop_location())
	return ..()

/obj/effect/mob_spawn/human/alive/old/sec
	role_name = "security officer"
	uniform = /obj/item/clothing/under/retro/security
	shoes = /obj/item/clothing/shoes/jackboots
	id = /obj/item/card/id/away/old/sec
	r_pocket = /obj/item/restraints/handcuffs
	l_pocket = /obj/item/flash

/obj/effect/mob_spawn/human/alive/old/med
	role_name = "medical doctor"
	uniform = /obj/item/clothing/under/retro/medical
	shoes = /obj/item/clothing/shoes/black
	id = /obj/item/card/id/away/old/med
	l_pocket = /obj/item/stack/medical/ointment
	r_pocket = /obj/item/stack/medical/ointment

/obj/effect/mob_spawn/human/alive/old/eng
	role_name = "engineer"
	uniform = /obj/item/clothing/under/retro/engineering
	shoes = /obj/item/clothing/shoes/workboots
	id = /obj/item/card/id/away/old/eng
	gloves = /obj/item/clothing/gloves/color/fyellow/old
	l_pocket = /obj/item/tank/internals/emergency_oxygen

/obj/effect/mob_spawn/human/alive/old/sci
	role_name = "scientist"
	uniform = /obj/item/clothing/under/retro/science
	shoes = /obj/item/clothing/shoes/laceup
	id = /obj/item/card/id/away/old/sci
	l_pocket = /obj/item/stack/medical/bruise_pack

/obj/structure/showcase/machinery/oldpod
	name = "damaged cryogenic pod"
	desc = "A damaged cryogenic pod long since lost to time, including its former occupant..."
	icon = 'icons/obj/cryogenic2.dmi'
	icon_state = "sleeper-open"

/obj/structure/showcase/machinery/oldpod/used
	name = "opened cryogenic pod"
	desc = "A cryogenic pod that has recently discharged its occupant. The pod appears non-functional."

/obj/structure/showcase/machinery/server_broken
	name = "derelict R&D server"
	desc = "An R&D server long since rendered non-functional due to lack of maintenance. Any scientific data that used to be stored inside has been lost to time."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "server-off"

/obj/structure/showcase/machinery/thermomachine_broken
	name = "derelict thermomachine"
	desc = "A thermomachine long since rendered non-functional due to lack of maintenance. All the components are burned out and useless."
	icon = 'icons/obj/cryogenic2.dmi'
	icon_state = "freezer"
