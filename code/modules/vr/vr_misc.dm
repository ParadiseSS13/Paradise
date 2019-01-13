var/list/vr_reset_buttons = list()

/obj/machinery/vr_medical_dummy
	name = "human dummy spawner"
	desc = "Press to make a medical dummy for all your medical practice needs."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "doorctrl0"
	anchored = 1.0
	var/mob/living/carbon/human/dummy = /mob/living/carbon/human
	var/cooldown = 0

/obj/machinery/vr_medical_dummy/attack_hand(mob/user as mob)
	if(cooldown > world.time)
		to_chat(user, "Querying medical database for the next [round((cooldown-world.time)/10)] seconds. Please wait.")
	else
		var/mob/living/carbon/human/medical_dummy
		var/new_species = input(user, "Choose a Species for your medical dummy.","Select Species", null) as null|anything in GLOB.all_species
		if(!new_species)
			return 0
		var/datum/species/S = GLOB.all_species[new_species]
		medical_dummy = new(loc)
		medical_dummy.set_species(S.type)
		medical_dummy.dna.species.after_equip_job(null, medical_dummy)
		if(medical_dummy.dna.species.type == "Plasmaman") // This is a hack around how the after_equip_job proc works.
			for(var/obj/item/plasmensuit_cartridge/C in medical_dummy.loc)
				qdel(C)
		icon_state = "doorctrl1"
		cooldown = world.time + 1 MINUTES
		spawn(1 MINUTES)
			icon_state = "doorctrl0"

/obj/item/radio/headset/vr
	name = "vr radio headset"
	desc = "Your link to the world that you once knew."
	ks2type = /obj/item/encryptionkey/headset_vr
	flags = NODROP

/obj/item/encryptionkey/headset_vr
	name = "Virtual Reality Radio Encryption Key"
	channels = list("VR" = 1)
	flags = NODROP

obj/machinery/vr_reset_button
	name = "area reset button"
	desc = "Press to remake the area as new."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "doorctrl0"
	anchored = 1.0
	var/datum/vr_room/room = null
	var/datum/map_template/vr/template = null
	var/template_id = null
	var/cooldown = 0

obj/machinery/vr_reset_button/New()
	vr_reset_buttons.Add(src)
	..()

obj/machinery/vr_reset_button/attack_hand(mob/user as mob)
	if(cooldown > world.time)
		to_chat(user, "Querying map database for the next [round((cooldown-world.time)/10)] seconds. Please wait.")
	else
		var/obj/effect/landmark/C = room.reset_point
		template = vr_templates[template_id]
		for(var/turf/T in block(locate(C.x+1, C.y+1, C.z), locate(C.x+template.width, C.y+template.height, C.z)))
			for(var/i = 1 to 3)
				for(var/atom/movable/M in T)
					if(istype(M, /mob/dead/observer) || istype(M, /mob/dview))
						continue
					else if(istype(M, /mob/living/carbon/human/virtual_reality))
						M.forceMove(src.loc)
						continue
					qdel(M, TRUE)
					CHECK_TICK
			T.ChangeTurf(/turf/space)
			CHECK_TICK
		template.load(locate(C.x+1,C.y+1, C.z), centered = FALSE)
		cooldown = world.time + 1 MINUTES
		spawn(1 MINUTES)
			icon_state = "doorctrl0"

obj/machinery/vr_reset_button/bombs
	template_id = "bomb_range"

obj/machinery/vr_reset_button/engineering
	template_id = "engine"

/obj/machinery/the_singularitygen/vr
	creation_type = /obj/singularity/vr

/obj/singularity/vr
	name = "virtual gravitational singularity"

/obj/singularity/vr/move(force_move = 0)
	return 0

/obj/machinery/the_singularitygen/tesla/vr
	creation_type = /obj/singularity/energy_ball/vr

/obj/singularity/energy_ball/vr
	name = "virtual energy ball"

/obj/singularity/energy_ball/vr/move_the_basket_ball(var/move_amount)
	return 0

/obj/machinery/computer/rdconsole/vr
	sync = 0

/obj/machinery/computer/rdconsole/vr/New()
	..()
	Maximize()

/obj/machinery/computer/rdconsole/vr/upload_data()
	to_chat(usr, "<span class='danger'>Unable to access outside database!</span>")

/obj/item/clothing/under/virtual_reality
	name = "dark undersuit"
	desc = "Clothing so light, it might as well be made of light."
	icon_state = "psysuit"
	item_state = "psysuit"
	item_color = "psysuit"
	flags = NODROP

/obj/structure/closet/blast_shelter
	name = "blast shelter"
	desc = "This will protect you from all explosions. We recomend thinking happy thoughts as a failsafe."
	icon_state = "cardboard"
	icon_opened = "cardboard_open"
	icon_closed = "cardboard"

/obj/structure/closet/blast_shelter/ex_act(var/severity)
	return