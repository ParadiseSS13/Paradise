// AREAS
/area/ruin/space/crashedipcship/engine
	name = "Engine zone"
	icon_state = "ipc_ship3"
	requires_power = TRUE
	report_alerts = FALSE

/area/ruin/space/crashedipcship/shard
	name = "Shard zone"
	icon_state = "ipc_ship4"
	requires_power = TRUE
	report_alerts = FALSE

/area/ruin/space/crashedipcship/middle
	name = "Middle zone"
	icon_state = "ipc_ship2"
	requires_power = TRUE

/area/ruin/space/crashedipcship/asteroid
	name = "IPC asteroid zone"
	icon_state = "ipc_ship"
	requires_power = FALSE

/area/ruin/space/crashedipcship/aft
	name = "IPC aft zone"
	icon_state = "ipc_ship1"
	requires_power = TRUE

// IPC corpse
/obj/effect/mob_spawn/human/corpse/ipc
	mob_type = /mob/living/carbon/human/machine
	name = "Machine corpse"
	icon = 'icons/mob/human_races/r_golem.dmi'
	icon_state = "overlay_husk"
	mob_name = "Unknown IPC"
	random = TRUE
	death = TRUE
	disable_sensors = TRUE
	outfit = /datum/outfit/ipc_corpse

/datum/outfit/ipc_corpse
	name = "IPC corpse"
	uniform = /obj/item/clothing/under/misc/durathread
	shoes = /obj/item/clothing/shoes/rainbow
	back = /obj/item/storage/backpack/duffel/durathread
	l_ear = /obj/item/radio/headset
	gloves = /obj/item/clothing/gloves/color/black

/obj/effect/mob_spawn/human/corpse/ipc/Initialize()
	brute_damage = rand(50, 99)
	burn_damage = rand(50, 99)
	return ..()

// Headcrab corpse

/obj/effect/mob_spawn/headcrab
	mob_type = /mob/living/simple_animal/hostile/headcrab
	death = TRUE
	name = "Dead headcrab"
	desc = "A small dead parasitic creature that would like to connect with your brain stem."
	icon = 'icons/mob/headcrab.dmi'
	icon_state = "headcrab_dead"

// SM shard that can't be moved
/obj/machinery/power/supermatter_shard/anchored
	name = "Well anchored supermatter shard"
	desc = "A strangely translucent and iridescent crystal that looks like it used to be part of a larger structure. Apparently the structure is attached to the surface with industrial equipment, it cannot be unanchored with simple equipment. <span class='danger'>You get headaches just from looking at it.</span>"
	anchored = TRUE

/obj/machinery/power/supermatter_shard/anchored/attackby(obj/item/W as obj, mob/living/user as mob, params)
	if(istype(W,/obj/item/wrench))
		user.visible_message("<span class='danger'>As [user] tries to loose bolts of \the [src] with \a [W] but the tool disappears</span>")
	consume_wrench(W)
	user.apply_effect(150, IRRADIATE)
