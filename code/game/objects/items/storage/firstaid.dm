/* First aid storage
 * Contains:
 *		First Aid Kits
 * 		Pill Bottles
 *		Dice Pack (in a pill bottle)
 */

/*
 * First Aid Kits
 */
/obj/item/storage/firstaid
	name = "generic first-aid kit"
	desc = "If you can see this, make a bug report on GitHub, something went wrong!"
	icon_state = "firstaid_generic"
	throw_range = 8
	req_one_access =list(ACCESS_MEDICAL, ACCESS_ROBOTICS) //Access and treatment are utilized for medbots.
	var/treatment_brute = "salglu_solution"
	var/treatment_oxy = "salbutamol"
	var/treatment_fire = "salglu_solution"
	var/treatment_tox = "charcoal"
	var/treatment_virus = "spaceacillin"
	var/med_bot_skin = null
	var/syndicate_aligned = FALSE
	var/robot_arm // This is for robot construction


/obj/item/storage/firstaid/regular
	name = "first-aid kit"
	desc = "A general medical kit that contains medical patches for both brute damage and burn damage. Also contains an epinephrine syringe for emergency use and a health analyzer."
	icon_state = "firstaid_regular"
	inhand_icon_state = "firstaid_regular"

/obj/item/storage/firstaid/regular/populate_contents()
	new /obj/item/reagent_containers/patch/styptic(src)
	new /obj/item/reagent_containers/patch/styptic(src)
	new /obj/item/reagent_containers/pill/salicylic(src)
	new /obj/item/reagent_containers/patch/silver_sulf(src)
	new /obj/item/reagent_containers/patch/silver_sulf(src)
	new /obj/item/healthanalyzer(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/epinephrine(src)

/obj/item/storage/firstaid/regular/empty/populate_contents()
	return

/obj/item/storage/firstaid/regular/doctor
	desc = "A medical kit designed for Nanotrasen medical personnel."

/obj/item/storage/firstaid/regular/doctor/populate_contents()
	new /obj/item/reagent_containers/applicator/brute(src)
	new /obj/item/reagent_containers/applicator/burn(src)
	new /obj/item/reagent_containers/patch/styptic(src)
	new /obj/item/reagent_containers/patch/silver_sulf(src)
	new /obj/item/reagent_containers/pill/salicylic(src)
	new /obj/item/healthanalyzer/advanced(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/epinephrine(src)

/obj/item/storage/firstaid/fire
	name = "fire first-aid kit"
	desc = "A medical kit that contains several medical patches and pills for treating burns. Contains one epinephrine syringe for emergency use and a health analyzer."
	icon_state = "firstaid_burn"
	inhand_icon_state = "firstaid_burn"
	med_bot_skin = "ointment"

/obj/item/storage/firstaid/fire/populate_contents()
	new /obj/item/stack/medical/suture/regen_mesh/advanced(src)
	new /obj/item/stack/medical/suture/regen_mesh(src)
	new /obj/item/reagent_containers/patch/silver_sulf/small(src)
	new /obj/item/healthanalyzer(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/epinephrine(src)
	new /obj/item/reagent_containers/pill/salicylic(src)

/obj/item/storage/firstaid/fire/empty/populate_contents()
	return

/obj/item/storage/firstaid/toxin
	name = "toxin first aid kit"
	desc = "A medical kit designed to counter poisoning by common toxins. Contains three pills and syringes, and a health analyzer to determine the health of the patient."
	icon_state = "firstaid_toxin"
	inhand_icon_state = "firstaid_toxin"
	med_bot_skin = "tox"

/obj/item/storage/firstaid/toxin/populate_contents()
	for(var/I in 1 to 3)
		new /obj/item/reagent_containers/syringe/charcoal(src)
		new /obj/item/reagent_containers/pill/charcoal(src)
	new /obj/item/healthanalyzer(src)

/obj/item/storage/firstaid/toxin/empty/populate_contents()
	return

/obj/item/storage/firstaid/o2
	name = "oxygen deprivation first aid kit"
	desc = "A first aid kit that contains four pills of salbutamol, which is able to counter injuries caused by suffocation. Also contains a health analyzer to determine the health of the patient."
	icon_state = "firstaid_o2"
	inhand_icon_state = "firstaid_o2"
	med_bot_skin = "o2"

/obj/item/storage/firstaid/o2/populate_contents()
	new /obj/item/reagent_containers/pill/salbutamol(src)
	new /obj/item/reagent_containers/pill/salbutamol(src)
	new /obj/item/reagent_containers/pill/salbutamol(src)
	new /obj/item/reagent_containers/pill/salbutamol(src)
	new /obj/item/healthanalyzer(src)

/obj/item/storage/firstaid/o2/empty/populate_contents()
	return

/obj/item/storage/firstaid/brute
	name = "brute trauma treatment kit"
	desc = "A medical kit that contains several medical patches and pills for treating brute injuries. Contains one epinephrine syringe for emergency use and a health analyzer."
	icon_state = "firstaid_brute"
	inhand_icon_state = "firstaid_brute"
	med_bot_skin = "brute"

/obj/item/storage/firstaid/brute/populate_contents()
	new /obj/item/stack/medical/suture/medicated(src)
	new /obj/item/stack/medical/suture(src)
	new /obj/item/reagent_containers/patch/styptic/small(src)
	new /obj/item/healthanalyzer(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/epinephrine(src)
	new /obj/item/stack/medical/bruise_pack(src)

/obj/item/storage/firstaid/brute/empty/populate_contents()
	return

/obj/item/storage/firstaid/adv
	name = "advanced first-aid kit"
	desc = "Contains advanced medical treatments."
	icon_state = "firstaid_advanced"
	inhand_icon_state = "firstaid_advanced"
	med_bot_skin = "adv"

/obj/item/storage/firstaid/adv/populate_contents()
	new /obj/item/stack/medical/bruise_pack(src)
	new /obj/item/stack/medical/bruise_pack/advanced(src)
	new /obj/item/stack/medical/bruise_pack/advanced(src)
	new /obj/item/stack/medical/ointment/advanced(src)
	new /obj/item/stack/medical/ointment/advanced(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/epinephrine(src)
	new /obj/item/healthanalyzer(src)

/obj/item/storage/firstaid/adv/empty/populate_contents()
	return

/obj/item/storage/firstaid/machine
	name = "machine repair kit"
	desc = "A kit that contains supplies to repair IPCs on the go."
	icon_state = "firstaid_machine"
	inhand_icon_state = "firstaid_machine"
	med_bot_skin = "machine"

/obj/item/storage/firstaid/machine/populate_contents()
	new /obj/item/weldingtool/mini(src)
	new /obj/item/stack/cable_coil(src)
	new /obj/item/stack/cable_coil(src)
	new /obj/item/stack/nanopaste(src)
	new /obj/item/robotanalyzer(src)
	new /obj/item/stack/synthetic_skin(src, 3)

/obj/item/storage/firstaid/machine/empty/populate_contents()
	return

/obj/item/storage/firstaid/tactical
	name = "tactical first-aid kit"
	desc = "I hope you've got insurance."
	icon_state = "firstaid_elite"
	inhand_icon_state = "firstaid_elite"
	treatment_oxy = "perfluorodecalin"
	treatment_brute = "bicaridine"
	treatment_fire = "kelotane"
	req_one_access = list(ACCESS_SYNDICATE)
	med_bot_skin = "bezerk"
	syndicate_aligned = TRUE

/obj/item/storage/firstaid/tactical/populate_contents()
	new /obj/item/reagent_containers/hypospray/combat(src)
	new /obj/item/reagent_containers/applicator/dual/syndi(src) // Because you ain't got no time to look at what damage dey taking yo
	new /obj/item/reagent_containers/hypospray/autoinjector/emergency_nuclear(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/emergency_nuclear(src)
	new /obj/item/storage/pill_bottle/painkillers(src)
	new /obj/item/clothing/glasses/hud/health/night(src)
	new /obj/item/healthanalyzer/advanced(src)

/obj/item/storage/firstaid/tactical/empty/populate_contents()
	return

/obj/item/storage/firstaid/surgery
	name = "field surgery kit"
	desc = "A kit for surgery in the field."
	icon_state = "firstaid_surgery"
	inhand_icon_state = "firstaid_o2"
	max_w_class = WEIGHT_CLASS_BULKY
	max_combined_w_class = 21
	storage_slots = 10
	can_hold = list(/obj/item/roller,/obj/item/bonesetter,/obj/item/bonegel, /obj/item/scalpel, /obj/item/hemostat,
		/obj/item/cautery, /obj/item/retractor, /obj/item/fix_o_vein, /obj/item/surgicaldrill, /obj/item/circular_saw)

/obj/item/storage/firstaid/surgery/populate_contents()
	new /obj/item/roller(src)
	new /obj/item/bonesetter(src)
	new /obj/item/bonegel(src)
	new /obj/item/scalpel(src)
	new /obj/item/hemostat(src)
	new /obj/item/cautery(src)
	new /obj/item/retractor(src)
	new /obj/item/fix_o_vein(src)
	new /obj/item/surgicaldrill(src)
	new /obj/item/circular_saw(src)

/obj/item/storage/firstaid/ert
	name = "ert first-aid kit"
	desc = "A medical kit used by Nanotrasen emergency response team personnel."
	icon_state = "firstaid_elite"
	inhand_icon_state = "firstaid_elite"
	med_bot_skin = "bezerk"

/obj/item/storage/firstaid/ert/populate_contents()
	new /obj/item/healthanalyzer/advanced(src)
	new /obj/item/stack/medical/splint(src)
	new /obj/item/reagent_containers/applicator/dual(src)
	new /obj/item/stack/medical/ointment/advanced(src)
	new /obj/item/stack/medical/ointment/advanced(src)
	new /obj/item/stack/medical/bruise_pack/advanced(src)
	new /obj/item/stack/medical/bruise_pack/advanced(src)

/obj/item/storage/firstaid/ert_amber
	name = "amber ert first-aid kit"
	desc = "A medical kit used by Amber level emergency response team personnel."
	icon_state = "firstaid_elite"
	inhand_icon_state = "firstaid_elite"
	med_bot_skin = "bezerk"

/obj/item/storage/firstaid/ert_amber/populate_contents()
	new /obj/item/healthanalyzer/advanced(src)
	new /obj/item/reagent_containers/applicator/brute(src)
	new /obj/item/reagent_containers/applicator/burn(src)
	new /obj/item/stack/medical/bruise_pack/advanced(src)
	new /obj/item/stack/medical/ointment/advanced(src)
	new /obj/item/storage/pill_bottle/ert_amber(src)
	new /obj/item/storage/pill_bottle/patch_pack/ert_amber(src)

/obj/item/storage/firstaid/fake_tactical
	name = "tactical first-aid kit"
	desc = "I hope you've got insurance. The paint is still wet."
	icon_state = "firstaid_elite"
	inhand_icon_state = "firstaid_elite"
	med_bot_skin = "bezerk"

/obj/item/storage/firstaid/fake_tactical/populate_contents()
	return

/*
 * Pill Bottles
 */

/obj/item/storage/pill_bottle
	name = "pill bottle"
	desc = "It's an airtight container for storing medication."
	icon_state = "pill_canister"
	icon = 'icons/obj/chemical.dmi'
	inhand_icon_state = "contsolid"
	belt_icon = "pill_bottle"
	use_sound = "pillbottle"
	w_class = WEIGHT_CLASS_SMALL
	can_hold = list(/obj/item/reagent_containers/pill)
	cant_hold = list(/obj/item/reagent_containers/patch)
	allow_quick_gather = TRUE
	use_to_pickup = TRUE
	storage_slots = 50
	max_combined_w_class = 50
	display_contents_with_number = TRUE
	var/base_name = ""
	var/label_text = ""
	var/applying_meds = FALSE //To Prevent spam clicking and generating runtimes from apply a deleting pill multiple times.
	var/rapid_intake_message = "unscrews the cap on the pill bottle and begins dumping the entire contents down their throat!"
	var/rapid_post_instake_message = "downs the entire bottle of pills in one go!"
	/// Whether to render a coloured wrapper overlay on the icon.
	var/allow_wrap = TRUE
	/// The color of the wrapper overlay.
	var/wrapper_color = null
	/// The icon state of the wrapper overlay.
	var/wrapper_state = "pillbottle_wrap"

/obj/item/storage/pill_bottle/Initialize(mapload)
	. = ..()
	base_name = name
	if(allow_wrap)
		apply_wrap()

/obj/item/storage/pill_bottle/proc/apply_wrap()
	if(wrapper_color)
		overlays.Cut()
		var/image/I = image(icon, wrapper_state)
		I.color = wrapper_color
		overlays += I

/obj/item/storage/pill_bottle/attack__legacy__attackchain(mob/M, mob/user)
	if(iscarbon(M) && length(contents))
		if(applying_meds)
			to_chat(user, "<span class='warning'>You are already applying meds.</span>")
			return
		applying_meds = TRUE
		for(var/obj/item/reagent_containers/P in contents)
			if(P.mob_act(M, user))
				applying_meds = FALSE
			else
				applying_meds = FALSE
			break
	else
		return ..()

/obj/item/storage/pill_bottle/ert_red
	wrapper_color = COLOR_NT_RED

/obj/item/storage/pill_bottle/ert_red/populate_contents()
	for(var/I in 1 to 6)
		new /obj/item/reagent_containers/pill/pentetic(src)
		new /obj/item/reagent_containers/pill/ironsaline(src)
		new /obj/item/reagent_containers/pill/salicylic(src)
		new /obj/item/reagent_containers/pill/mannitol(src)

/obj/item/storage/pill_bottle/ert_amber
	wrapper_color = COLOR_ORANGE

/obj/item/storage/pill_bottle/ert_amber/populate_contents()
	for(var/I in 1 to 6)
		new /obj/item/reagent_containers/pill/salbutamol(src)
		new /obj/item/reagent_containers/pill/charcoal(src)
		new /obj/item/reagent_containers/pill/salicylic(src)

/obj/item/storage/pill_bottle/ert_gamma
	wrapper_color = COLOR_YELLOW_GRAY

/obj/item/storage/pill_bottle/ert_gamma/populate_contents()
	for(var/I in 1 to 6)
		new /obj/item/reagent_containers/pill/pentetic(src)
		new /obj/item/reagent_containers/pill/ironsaline(src)
		new /obj/item/reagent_containers/pill/hydrocodone(src)
		new /obj/item/reagent_containers/pill/mannitol(src)
		new /obj/item/reagent_containers/pill/lazarus_reagent(src)
		new /obj/item/reagent_containers/pill/rezadone(src)

/obj/item/storage/pill_bottle/MouseDrop(obj/over_object) // Best utilized if you're a cantankerous doctor with a Vicodin habit.
	if(iscarbon(over_object))
		var/mob/living/carbon/C = over_object
		if(loc == C && src == C.get_active_hand())
			if(!length(contents))
				to_chat(C, "<span class='notice'>There is nothing in [src]!</span>")
				return
			C.visible_message("<span class='danger'>[C] [rapid_intake_message]</span>")
			if(do_mob(C, C, 100)) // 10 seconds
				for(var/obj/item/reagent_containers/pill/P in contents)
					P.interact_with_atom(C, C)
				C.visible_message("<span class='danger'>[C] [rapid_post_instake_message]</span>")
			return

	return ..()

/obj/item/storage/pill_bottle/attackby__legacy__attackchain(obj/item/I, mob/user, params)
	if(is_pen(I))
		rename_interactive(user, I)
	else
		return ..()

/obj/item/storage/pill_bottle/proc/apply_wrapper_color(color_number)
	var/static/list/colors = list(COLOR_RED, COLOR_ORANGE, COLOR_YELLOW, COLOR_GREEN, COLOR_CYAN_BLUE, COLOR_VIOLET, COLOR_PURPLE)
	wrapper_color = colors[(color_number - 1) % length(colors) + 1]
	apply_wrap()

/obj/item/storage/pill_bottle/patch_pack
	name = "patch pack"
	desc = "It's a container for storing medical patches."
	icon_state = "patch_pack"
	belt_icon = "patch_pack"
	use_sound = "patchpack"
	can_hold = list(/obj/item/reagent_containers/patch)
	cant_hold = list()
	rapid_intake_message = "flips the lid of the patch pack open and begins rapidly stamping patches on themselves!"
	rapid_post_instake_message = "stamps the entire contents of the patch pack all over their entire body!"
	wrapper_state = "patch_pack_wrap"

/obj/item/storage/pill_bottle/charcoal
	name = "Pill bottle (Charcoal)"
	desc = "Contains pills used to counter toxins."
	wrapper_color = COLOR_GREEN

/obj/item/storage/pill_bottle/charcoal/populate_contents()
	for(var/I in 1 to 7)
		new /obj/item/reagent_containers/pill/charcoal(src)

/obj/item/storage/pill_bottle/painkillers
	name = "Pill Bottle (Salicylic Acid)"
	desc = "Contains various pills for minor pain relief."
	wrapper_color = COLOR_RED

/obj/item/storage/pill_bottle/painkillers/populate_contents()
	for(var/I in 1 to 8)
		new /obj/item/reagent_containers/pill/salicylic(src)

/obj/item/storage/pill_bottle/fakedeath
	allow_wrap = FALSE

/obj/item/storage/pill_bottle/fakedeath/populate_contents()
	new /obj/item/reagent_containers/pill/fakedeath(src)
	new /obj/item/reagent_containers/pill/fakedeath(src)
	new /obj/item/reagent_containers/pill/fakedeath(src)

/obj/item/storage/pill_bottle/patch_pack/ert
	name = "ert red patch pack"
	desc = "A patch pack containing medical patches. Issued to Nanotrasen ERT Red level medics."
	wrapper_color = COLOR_NT_RED

/obj/item/storage/pill_bottle/patch_pack/ert/populate_contents()
	for(var/I in 1 to 5)
		new /obj/item/reagent_containers/patch/perfluorodecalin(src)
		new /obj/item/reagent_containers/patch/silver_sulf(src)
		new /obj/item/reagent_containers/patch/styptic(src)

/obj/item/storage/pill_bottle/patch_pack/ert/gamma
	name = "ert gamma patch pack"
	desc = "A patch pack containing medical patches. Issued to Nanotrasen ERT Gamma level medics."
	wrapper_color = COLOR_YELLOW_GRAY

/obj/item/storage/pill_bottle/patch_pack/ert_amber
	name = "ert amber patch pack"
	desc = "A patch pack containing medical patches. Issued to Nanotrasen ERT Amber level medics"
	wrapper_color = COLOR_ORANGE

/obj/item/storage/pill_bottle/patch_pack/ert_amber/populate_contents()
	for(var/I in 1 to 5)
		new /obj/item/reagent_containers/patch/silver_sulf/small(src)
		new /obj/item/reagent_containers/patch/styptic/small(src)
