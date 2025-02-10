/obj/mecha/nkarrdem
	desc = "Тяжёлый санитарный экзокостюм. Оптимизирован для удаления больших объемов грязи, налета и жира."
	name = "Nkarrdem"
	icon_state = "nkarrdem"
	initial_icon = "nkarrdem"
	step_in = 3
	turnsound = 'sound/mecha/mechmove01.ogg'
	stepsound = 'sound/mecha/mechstep.ogg'
	max_temperature = 10000
	max_integrity = 110
	max_equip = 4
	wreckage = /obj/structure/mecha_wreckage/nkarrdem
	internal_damage_threshold = 35
	deflect_chance = 15
	step_energy_drain = 6
	normal_step_energy_drain = 6
	/// Is the janihud on?
	var/builtin_hud_user = FALSE
	/// Action that controls the floor buffer
	var/datum/action/innate/mecha/mech_toggle_floorbuffer/floorbuffer_action = new

/obj/mecha/nkarrdem/examine_more(mob/user)
	..()
	. = list()
	. += "<i>Nkarrdem — это мех старого поколения для ядерной, химической, биологической защиты, разработанный совместно компаниями Interdyne и Shellguard для быстрой деконтаминации в период частого применения биологического оружия. \
	Однако он пострадал от ряда мер по снижению затрат, что подвергает оператора опасным условиям. Лишние единицы затем продаются для уборки..</i>"
	. += ""
	. += "<i>Название «Nkarrdem» происходит из легенды скреллов и означает «Бирюзовые поля». Бирюзовые поля — это поля водорослей, где короли древности отправлялись на свой вечный покой.</i>"


/obj/mecha/nkarrdem/moved_inside(mob/living/carbon/human/H)
	. = ..()
	if(. && ishuman(H))
		if(istype(H.glasses, /obj/item/clothing/glasses/hud))
			occupant_message("<span class='warning'>[capitalize(H.glasses.declent_ru(NOMINATIVE))] мешают вам использовать встроенный уборочный HUD [declent_ru(GENITIVE)].</span>")
		else
			var/datum/atom_hud/data/janitor/jani_hud = GLOB.huds[DATA_HUD_JANITOR]
			jani_hud.add_hud_to(H)
			builtin_hud_user = TRUE

/obj/mecha/nkarrdem/mmi_moved_inside(obj/item/mmi/mmi_as_oc, mob/user)
	. = ..()
	if(.)
		if(occupant.client)
			var/datum/atom_hud/data/janitor/jani_hud = GLOB.huds[DATA_HUD_JANITOR]
			jani_hud.add_hud_to(occupant)
			builtin_hud_user = TRUE

/obj/mecha/nkarrdem/go_out()
	if(ishuman(occupant) && builtin_hud_user)
		var/mob/living/carbon/human/H = occupant
		var/datum/atom_hud/data/janitor/jani_hud = GLOB.huds[DATA_HUD_JANITOR]
		jani_hud.remove_hud_from(H)
		builtin_hud_user = FALSE
	else if((isbrain(occupant) || pilot_is_mmi()) && builtin_hud_user)
		var/mob/living/brain/H = occupant
		var/datum/atom_hud/data/janitor/jani_hud = GLOB.huds[DATA_HUD_JANITOR]
		jani_hud.remove_hud_from(H)
		builtin_hud_user = FALSE
	return ..()

/obj/mecha/nkarrdem/GrantActions(mob/living/user, human_occupant = 0)
	. = ..()
	floorbuffer_action.Grant(user, src)

/obj/mecha/nkarrdem/RemoveActions(mob/living/user, human_occupant = 0)
	. = ..()
	floorbuffer_action.Remove(user)

// Moving has to clean floors if the buffer is active
/obj/mecha/nkarrdem/Move()
	. = ..()
	if(!floor_buffer)
		return
	var/turf/tile = get_turf(src)
	if(!isturf(tile))
		return
	tile.clean_blood()
	for(var/obj/effect/E in tile)
		if(E.is_cleanable())
			qdel(E)

/obj/mecha/nkarrdem/loaded/Initialize(mapload)
	. = ..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/janitor/mega_spray
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/janitor/mega_mop
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/janitor/light_replacer
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/cleaner
	ME.attach(src)
