/obj/structure/spacepod_frame
	density = 1
	opacity = 0

	anchored = 1
	layer = 3.9

	icon = 'icons/goonstation/48x48/pod_construction.dmi'
	icon_state = "pod_1"

	var/datum/construction/reversible2/construct

/obj/structure/spacepod_frame/New()
	..()
	bound_width = 64
	bound_height = 64

	construct = new /datum/construction/reversible2/pod(src)

	dir = EAST

/obj/structure/spacepod_frame/attackby(obj/item/W as obj, mob/user as mob, params)
	if(construct.index == 1 && istype(W, /obj/item/weapon/wirecutters))
		visible_message(user, "[user] cuts the struts on \the [src]", "You cut the struts on \the [src]")
		//var/obj/item/pod_parts/pod_frame/F = new /obj/item/pod_parts/pod_frame()
		switch(dir)
			if(NORTH)
				new /obj/item/pod_parts/pod_frame/aft_port{dir = 1}(get_turf(src))
				new /obj/item/pod_parts/pod_frame/aft_starboard{dir = 1}(get_step(src, EAST))
				new /obj/item/pod_parts/pod_frame/fore_port{dir = 1}(get_step(src, NORTH))
				new /obj/item/pod_parts/pod_frame/fore_starboard{dir = 1}(get_step(get_step(src, EAST), NORTH))
			if(SOUTH)
				new /obj/item/pod_parts/pod_frame/fore_starboard{dir = 2}(get_turf(src))
				new /obj/item/pod_parts/pod_frame/fore_port{dir = 2}(get_step(src, EAST))
				new /obj/item/pod_parts/pod_frame/aft_starboard{dir = 2}(get_step(src, NORTH))
				new /obj/item/pod_parts/pod_frame/aft_port{dir = 2}(get_step(get_step(src, EAST), NORTH))
			if(EAST)
				new /obj/item/pod_parts/pod_frame/aft_starboard{dir = 4}(get_turf(src))
				new /obj/item/pod_parts/pod_frame/fore_starboard{dir = 4}(get_step(src, EAST))
				new /obj/item/pod_parts/pod_frame/aft_port{dir = 4}(get_step(src, NORTH))
				new /obj/item/pod_parts/pod_frame/fore_port{dir = 4}(get_step(get_step(src, EAST), NORTH))
			if(WEST)
				new /obj/item/pod_parts/pod_frame/fore_port{dir = 8}(get_turf(src))
				new /obj/item/pod_parts/pod_frame/aft_port{dir = 8}(get_step(src, EAST))
				new /obj/item/pod_parts/pod_frame/fore_starboard{dir = 8}(get_step(src, NORTH))
				new /obj/item/pod_parts/pod_frame/aft_starboard{dir = 8}(get_step(get_step(src, EAST), NORTH))
		qdel(src)
		return

	if(!construct || !construct.action(W, user))
		..()
	return

/obj/structure/spacepod_frame/attack_hand()
	return



/////////////////////////////////
// CONSTRUCTION STEPS
/////////////////////////////////
/datum/construction/reversible2/pod
	result = /obj/spacepod
	base_icon="pod"
	//taskpath = /datum/job_objective/make_pod
	steps = list(
				// 1. Initial state
				list(
					"desc" = "An empty pod frame.",
					state_next = list(
						"key"      = /obj/item/stack/cable_coil,
						"vis_msg"  = "{USER} wires the {HOLDER}.",
						"self_msg" = "You wire the {HOLDER}."
					)
				),
				// 2. Crudely Wired
				list(
					"desc" = "A crudely-wired pod frame.",
					state_prev = list(
						"key"      = /obj/item/weapon/wirecutters,
						"vis_msg"  = "{USER} cuts out the {HOLDER}'s wiring.",
						"self_msg" = "You remove the {HOLDER}'s wiring."
					),
					state_next = list(
						"key"      = /obj/item/weapon/screwdriver,
						"vis_msg"  = "{USER} adjusts the wiring.",
						"self_msg" = "You adjust the {HOLDER}'s wiring."
					)
				),
				// 3. Cleanly wired
				list(
					"desc" = "A wired pod frame.",
					state_prev = list(
						"key"      = /obj/item/weapon/screwdriver,
						"vis_msg"  = "{USER} unclips {HOLDER}'s wiring harnesses.",
						"self_msg" = "You unclip {HOLDER}'s wiring harnesses."
					),
					state_next = list(
						"key"      = /obj/item/weapon/circuitboard/mecha/pod,
						"vis_msg"  = "{USER} inserts the mainboard into the {HOLDER}.",
						"self_msg" = "You insert the mainboard into the {HOLDER}.",
						"delete"   = 1
					)
				),
				// 4. Circuit added
				list(
					"desc" = "A wired pod frame with a loose mainboard.",
					state_prev = list(
						"key"      = /obj/item/weapon/crowbar,
						"vis_msg"  = "{USER} pries out the mainboard.",
						"self_msg" = "You pry out the mainboard.",

						"spawn"    = /obj/item/weapon/circuitboard/mecha/pod,
						"amount"   = 1
					),
					state_next = list(
						"key"      = /obj/item/weapon/screwdriver,
						"vis_msg"  = "{USER} secures the mainboard.",
						"self_msg" = "You secure the mainboard."
					)
				),
				// 5. Circuit secured
				list(
					"desc" = "A wired pod frame with a secured mainboard.",
					state_prev = list(
						"key"      = /obj/item/weapon/screwdriver,
						"vis_msg"  = "{USER} unsecures the mainboard.",
						"self_msg" = "You unscrew the mainboard from the {HOLDER}."
					),
					state_next = list(
						"key"      = /obj/item/pod_parts/core,
						,
						"vis_msg"  = "{USER} inserts the core into the {HOLDER}.",
						"self_msg" = "You carefully insert the core into the {HOLDER}.",
						"delete"   = 1
					)
				),
				// 6. Core inserted
				list(
					"desc" = "A naked space pod with a loose core.",
					state_prev = list(
						"key"      = /obj/item/weapon/crowbar,
						"vis_msg"  = "{USER} delicately removes the core from the {HOLDER} with a crowbar.",
						"self_msg" = "You delicately remove the core from the {HOLDER} with a crowbar.",

						"spawn"    = /obj/item/pod_parts/core,
						"amount"   = 1
					),
					state_next = list(
						"key"      = /obj/item/weapon/wrench,
						"vis_msg"  = "{USER} secures the core's bolts.",
						"self_msg" = "You secure the core's bolts."
					)
				),
				// 7. Core secured
				list(
					"desc" = "A naked space pod with an exposed core. How lewd.",
					state_prev = list(
						"key"      = /obj/item/weapon/wrench,
						"vis_msg"  = "{USER} unsecures the {HOLDER}'s core.",
						"self_msg" = "You unsecure the {HOLDER}'s core."
					),
					state_next = list(
						"key"      = /obj/item/stack/sheet/metal,
						"amount"   = 5,
						"vis_msg"  = "{USER} frabricates a pressure bulkhead for the {HOLDER}.",
						"self_msg" = "You frabricate a pressure bulkhead for the {HOLDER}."
					)
				),
				// 8. Bulkhead added
				list(
					"desc" = "A space pod with loose bulkhead panelling exposed.",
					state_prev = list(
						"key"      = /obj/item/weapon/crowbar,
						"vis_msg"  = "{USER} pops the {HOLDER}'s bulkhead panelling loose.",
						"self_msg" = "You pop the {HOLDER}'s bulkhead panelling loose.",

						"spawn"    = /obj/item/stack/sheet/metal,
						"amount"   = 5,
					),
					state_next = list(
						"key"      = /obj/item/weapon/wrench,
						"vis_msg"  = "{USER} secures the {HOLDER}'s bulkhead panelling.",
						"self_msg" = "You secure the {HOLDER}'s bulkhead panelling."
					)
				),
				// 9. Bulkhead secured with bolts
				list(
					"desc" = "A space pod with unwelded bulkhead panelling exposed.",
					state_prev = list(
						"key"      = /obj/item/weapon/wrench,
						"vis_msg"  = "{USER} unbolts the {HOLDER}'s bulkhead panelling.",
						"self_msg" = "You unbolt the {HOLDER}'s bulkhead panelling."
					),
					state_next = list(
						"key"      = /obj/item/weapon/weldingtool,
						"vis_msg"  = "{USER} seals the {HOLDER}'s bulkhead panelling with a weld.",
						"self_msg" = "You seal the {HOLDER}'s bulkhead panelling with a weld."
					)
				)
				// EOF
			)

	spawn_result(mob/user as mob)
		..()
		feedback_inc("spacepod_created",1)
		return