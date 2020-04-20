/obj/structure/spacepod_frame
	density = 1
	opacity = 0

	anchored = 1
	layer = 3.9

	icon = 'icons/goonstation/48x48/pod_construction.dmi'
	icon_state = "pod_1"

	var/datum/construction/construct

/obj/structure/spacepod_frame/New()
	..()
	bound_width = 64
	bound_height = 64

	construct = new /datum/construction/reversible2/pod(src)

	dir = EAST

/obj/structure/spacepod_frame/Destroy()
	QDEL_NULL(construct)
	return ..()

/obj/structure/spacepod_frame/attackby(obj/item/W as obj, mob/user as mob, params)
	if(!construct || !construct.action(W, user))
		return ..()

/obj/structure/spacepod_frame/attack_hand()
	return



/////////////////////////////////
// CONSTRUCTION STEPS
/////////////////////////////////
/datum/construction/reversible2/pod
	result = /obj/spacepod/civilian
	base_icon="pod"
	//taskpath = /datum/job_objective/make_pod
	steps = list(
				// 1. Initial state
				list(
					"desc" = "Un marco de pod vacio.",
					state_next = list(
						"key"      = /obj/item/stack/cable_coil,
						"vis_msg"  = "{USER} cablea el {HOLDER}.",
						"self_msg" = "Cableas el {HOLDER}."
					)
				),
				// 2. Crudely Wired
				list(
					"desc" = "Un marco de pod cableado crudamente.",
					state_prev = list(
						"key"      = TOOL_WIRECUTTER,
						"vis_msg"  = "{USER} corta el cableado'.",
						"self_msg" = "Remueves el cableado'."
					),
					state_next = list(
						"key"      = TOOL_SCREWDRIVER,
						"vis_msg"  = "{USER} ajusta el cableado.",
						"self_msg" = "Ajustas el cableado'."
					)
				),
				// 3. Cleanly wired
				list(
					"desc" = "Un marco de pod cableado.",
					state_prev = list(
						"key"      = TOOL_SCREWDRIVER,
						"vis_msg"  = "{USER} unclips {HOLDER}'s wiring harnesses.",
						"self_msg" = "You unclip {HOLDER}'s wiring harnesses."
					),
					state_next = list(
						"key"      = /obj/item/circuitboard/mecha/pod,
						"vis_msg"  = "{USER} inserta la placa base.",
						"self_msg" = "Insertas la placa base.",
						"delete"   = 1
					)
				),
				// 4. Circuit added
				list(
					"desc" = "Un marco de pod cableado con la placa base suelta.",
					state_prev = list(
						"key"      = TOOL_CROWBAR,
						"vis_msg"  = "{USER} quita la placa base",
						"self_msg" = "Sacas la placa base.",

						"spawn"    = /obj/item/circuitboard/mecha/pod,
						"amount"   = 1
					),
					state_next = list(
						"key"      = TOOL_SCREWDRIVER,
						"vis_msg"  = "{USER} asegura la placa base.",
						"self_msg" = "Aseguras la placa base."
					)
				),
				// 5. Circuit secured
				list(
					"desc" = "Una marco cableado con una placa base.",
					state_prev = list(
						"key"      = TOOL_SCREWDRIVER,
						"vis_msg"  = "{USER} desasegura la placa base.",
						"self_msg" = "desatornillas la placa base."
					),
					state_next = list(
						"key"      = /obj/item/pod_parts/core,
						,
						"vis_msg"  = "{USER} inserta el nucleo.",
						"self_msg" = "Cuidadosamente insertas el nucleo.",
						"delete"   = 1
					)
				),
				// 6. Core inserted
				list(
					"desc" = "A naked space pod with a loose core.",
					state_prev = list(
						"key"      = TOOL_CROWBAR,
						"vis_msg"  = "{USER} delicadamente remuve el nucleo con una barreta.",
						"self_msg" = "Quitas delicadamente el nucleo con una barreta.",

						"spawn"    = /obj/item/pod_parts/core,
						"amount"   = 1
					),
					state_next = list(
						"key"      = TOOL_WRENCH,
						"vis_msg"  = "{USER} Asegura el nucleo.",
						"self_msg" = "Aseguras el nucleo."
					)
				),
				// 7. Core secured
				list(
					"desc" = "A naked space pod with an exposed core. How lewd.",
					state_prev = list(
						"key"      = TOOL_WRENCH,
						"vis_msg"  = "{USER} asegura el nucleo.",
						"self_msg" = "Desaseguras el nucleo."
					),
					state_next = list(
						"key"      = /obj/item/stack/sheet/metal,
						"amount"   = 5,
						"vis_msg"  = "{USER} fabricates a pressure bulkhead for the {HOLDER}.",
						"self_msg" = "You frabricate a pressure bulkhead for the {HOLDER}."
					)
				),
				// 8. Bulkhead added
				list(
					"desc" = "A space pod with loose bulkhead panelling exposed.",
					state_prev = list(
						"key"      = TOOL_CROWBAR,
						"vis_msg"  = "{USER} pops the {HOLDER}'s bulkhead panelling loose.",
						"self_msg" = "You pop the {HOLDER}'s bulkhead panelling loose.",

						"spawn"    = /obj/item/stack/sheet/metal,
						"amount"   = 5,
					),
					state_next = list(
						"key"      = TOOL_WRENCH,
						"vis_msg"  = "{USER} secures the {HOLDER}'s bulkhead panelling.",
						"self_msg" = "You secure the {HOLDER}'s bulkhead panelling."
					)
				),
				// 9. Bulkhead secured with bolts
				list(
					"desc" = "A space pod with unwelded bulkhead panelling exposed.",
					state_prev = list(
						"key"      = TOOL_WRENCH,
						"vis_msg"  = "{USER} unbolts the {HOLDER}'s bulkhead panelling.",
						"self_msg" = "You unbolt the {HOLDER}'s bulkhead panelling."
					),
					state_next = list(
						"key"      = TOOL_WELDER,
						"vis_msg"  = "{USER} seals the {HOLDER}'s bulkhead panelling with a weld.",
						"self_msg" = "You seal the {HOLDER}'s bulkhead panelling with a weld."
					)
				),
				// 10. Welded bulkhead
				list(
					"desc" = "A space pod with sealed bulkhead panelling exposed.",
					state_prev = list(
						"key"      = TOOL_WELDER,
						"vis_msg"  = "{USER} cuts the {HOLDER}'s bulkhead panelling loose.",
						"self_msg" = "You cut the {HOLDER}'s bulkhead panelling loose."
					),
					state_next = list(
						"key"      = /obj/item/pod_parts/armor,
						"vis_msg"  = "{USER} installs the {HOLDER}'s armor plating.",
						"self_msg" = "You install the {HOLDER}'s armor plating.",
						"delete"   = 1
					)
				),
				// 11. Loose armor
				list(
					"desc" = "A space pod with unsecured armor.",
					state_prev = list(
						"key"      = TOOL_CROWBAR,
						"vis_msg"  = "{USER} quita la armadura.",
						"self_msg" = "Quitas la armadura.",
						"spawn"    = /obj/item/pod_parts/armor,
						"amount"   = 1
					),
					state_next = list(
						"key"      = TOOL_WRENCH,
						"vis_msg"  = "{USER} desasegura la armadura.",
						"self_msg" = "Desaseguras la armadura."
					)
				),
				// 12. Bolted-down armor
				list(
					"desc" = "Una pod espacial sin armadura.",
					state_prev = list(
						"key"      = TOOL_WRENCH,
						"vis_msg"  = "{USER} desasegura la armadura.",
						"self_msg" = "Desaseguras la armadura."
					),
					state_next = list(
						"key"      = TOOL_WELDER,
						"vis_msg"  = "{USER} suelda la armadura.",
						"self_msg" = "Sueldas la armadura."
					)
				)
				// EOF
			)

	spawn_result(mob/user as mob)
		..()
		feedback_inc("spacepod_created",1)
		return
