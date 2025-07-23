/obj/item/dnainjector
	name = "DNA-Injector"
	desc = "This injects the person with DNA."
	icon = 'icons/obj/medical.dmi'
	icon_state = "dnainjector"
	inhand_icon_state = "dnainjector"
	belt_icon = "syringe"
	var/block = 0
	var/datum/dna2_record/buf = null
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "biotech=1"

	var/damage_coeff = 1
	var/used = FALSE

	// USE ONLY IN PREMADE SYRINGES.  WILL NOT WORK OTHERWISE.
	var/datatype = 0
	var/value = 0
	var/forcedmutation = FALSE //Will it give the mutation, guaranteed?

/obj/item/dnainjector/Initialize(mapload)
	. = ..()

	var/init_block = GetInitBlock()
	if(init_block)
		block = init_block

	if(datatype && block)
		buf = new
		buf.dna = new
		buf.types = datatype
		buf.dna.ResetSE()
		SetValue(value)

// Override this with a var reference to do setup
/obj/item/dnainjector/proc/GetInitBlock()
	return null

/obj/item/dnainjector/Destroy()
	QDEL_NULL(buf)
	return ..()

/obj/item/dnainjector/proc/GetRealBlock(selblock)
	if(selblock == 0)
		return block
	else
		return selblock

/obj/item/dnainjector/proc/GetState(selblock = 0)
	var/real_block = GetRealBlock(selblock)
	if(buf.types & DNA2_BUF_SE)
		return buf.dna.GetSEState(real_block)
	else
		return buf.dna.GetUIState(real_block)

/obj/item/dnainjector/proc/SetState(on, selblock = 0)
	var/real_block = GetRealBlock(selblock)
	if(buf.types & DNA2_BUF_SE)
		return buf.dna.SetSEState(real_block,on)
	else
		return buf.dna.SetUIState(real_block,on)

/obj/item/dnainjector/proc/GetValue(selblock = 0)
	var/real_block = GetRealBlock(selblock)
	if(buf.types & DNA2_BUF_SE)
		return buf.dna.GetSEValue(real_block)
	else
		return buf.dna.GetUIValue(real_block)

/obj/item/dnainjector/proc/SetValue(val, selblock = 0)
	var/real_block = GetRealBlock(selblock)
	if(buf.types & DNA2_BUF_SE)
		return buf.dna.SetSEValue(real_block,val)
	else
		return buf.dna.SetUIValue(real_block,val)

/obj/item/dnainjector/proc/inject(mob/living/M, mob/user)
	if(used)
		return
	if(isliving(M))
		M.apply_effect(rand(20 / (damage_coeff ** 2), 50 / (damage_coeff ** 2)), IRRADIATE)
	var/mob/living/carbon/human/H
	if(ishuman(M))
		H = M

	if(!buf)
		stack_trace("[src] used by [user] on [M] failed to initialize properly.")
		return

	spawn(0) //Some mutations have sleeps in them, like monkey
		if(!HAS_TRAIT(M, TRAIT_BADDNA) && !HAS_TRAIT(M, TRAIT_GENELESS)) // prevents drained people from having their DNA changed
			var/prev_ue = M.dna.unique_enzymes
			// UI in syringe.
			if(buf.types & DNA2_BUF_UI)
				if(!block) //isolated block?
					M.dna.UI = buf.dna.UI.Copy()
					M.dna.UpdateUI()
					M.UpdateAppearance()
					if(buf.types & DNA2_BUF_UE) //unique enzymes? yes

						M.real_name = buf.dna.real_name
						M.name = buf.dna.real_name
						M.dna.real_name = buf.dna.real_name
						M.dna.unique_enzymes = buf.dna.unique_enzymes
				else
					M.dna.SetUIValue(block,src.GetValue())
					M.UpdateAppearance()
			if(buf.types & DNA2_BUF_SE)
				if(!block) //isolated block?
					M.dna.SE = buf.dna.SE.Copy()
					M.dna.UpdateSE()
				else
					M.dna.SetSEValue(block,src.GetValue())
				domutcheck(M, forcedmutation ? MUTCHK_FORCED : FALSE)
				M.update_mutations()
			if(H)
				H.sync_organ_dna(assimilate = 0, old_ue = prev_ue)

/obj/item/dnainjector/attack__legacy__attackchain(mob/M, mob/user)
	if(used)
		to_chat(user, "<span class='warning'>This injector is used up!</span>")
		return
	if(!M.dna || HAS_TRAIT(M, TRAIT_GENELESS) || HAS_TRAIT(M, TRAIT_BADDNA)) //You know what would be nice? If the mob you're injecting has DNA, and so doesn't cause runtimes.
		return FALSE

	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return FALSE

	var/attack_log = "injected with the Isolated [name]"

	if(buf && buf.types & DNA2_BUF_SE)
		if(block)
			if(GetState() && block == GLOB.monkeyblock && ishuman(M))
				attack_log = "injected with the Isolated [name] (MONKEY)"
				message_admins("[key_name_admin(user)] injected [key_name_admin(M)] with the Isolated [name] <span class='warning'>(MONKEY)</span>")

		else
			if(GetState(GLOB.monkeyblock) && ishuman(M))
				attack_log = "injected with the Isolated [name] (MONKEY)"
				message_admins("[key_name_admin(user)] injected [key_name_admin(M)] with the Isolated [name] <span class='warning'>(MONKEY)</span>")


	if(M != user)
		M.visible_message("<span class='danger'>[user] is trying to inject [M] with [src]!</span>", "<span class='userdanger'>[user] is trying to inject [M] with [src]!</span>")
		if(!do_mob(user, M))
			return
		M.visible_message("<span class='danger'>[user] injects [M] with the syringe with [src]!", \
						"<span class='userdanger'>[user] injects [M] with the syringe with [src]!")
	else
		to_chat(user, "<span class='notice'>You inject yourself with [src].</span>")

	add_attack_logs(user, M, attack_log, ATKLOG_ALL)

	inject(M, user)
	used = TRUE
	icon_state = "dnainjector0"
	desc += " This one is used up."

/obj/item/dnainjector/hulkmut
	name = "DNA-Injector (Hulk)"
	desc = "This will make you big and strong, but give you a bad skin condition."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	forcedmutation = TRUE

/obj/item/dnainjector/hulkmut/GetInitBlock()
	return GLOB.hulkblock

/obj/item/dnainjector/antihulk
	name = "DNA-Injector (Anti-Hulk)"
	desc = "Cures green skin."
	datatype = DNA2_BUF_SE
	value = 0x001
	forcedmutation = TRUE

/obj/item/dnainjector/antihulk/GetInitBlock()
	return GLOB.hulkblock

/obj/item/dnainjector/firemut
	name = "DNA-Injector (Fire)"
	desc = "Gives you fire."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	forcedmutation = TRUE

/obj/item/dnainjector/firemut/GetInitBlock()
	return GLOB.fireblock

/obj/item/dnainjector/antifire
	name = "DNA-Injector (Anti-Fire)"
	desc = "Cures fire."
	datatype = DNA2_BUF_SE
	value = 0x001
	forcedmutation = TRUE

/obj/item/dnainjector/antifire/GetInitBlock()
	return GLOB.fireblock

/obj/item/dnainjector/telemut
	name = "DNA-Injector (Tele.)"
	desc = "Super brain man!"
	datatype = DNA2_BUF_SE
	value = 0xFFF
	forcedmutation = TRUE

/obj/item/dnainjector/telemut/GetInitBlock()
	return GLOB.teleblock

/obj/item/dnainjector/telemut/darkbundle
	name = "DNA injector"
	desc = "Good. Let the hate flow through you."

/obj/item/dnainjector/antitele
	name = "DNA-Injector (Anti-Tele.)"
	desc = "Will make you not able to control your mind."
	datatype = DNA2_BUF_SE
	value = 0x001
	forcedmutation = TRUE

/obj/item/dnainjector/antitele/GetInitBlock()
	return GLOB.teleblock

/obj/item/dnainjector/nobreath
	name = "DNA-Injector (Breathless)"
	desc = "Hold your breath and count to infinity."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	forcedmutation = TRUE

/obj/item/dnainjector/nobreath/GetInitBlock()
	return GLOB.breathlessblock

/obj/item/dnainjector/antinobreath
	name = "DNA-Injector (Anti-Breathless)"
	desc = "Hold your breath and count to 100."
	datatype = DNA2_BUF_SE
	value = 0x001
	forcedmutation = TRUE

/obj/item/dnainjector/antinobreath/GetInitBlock()
	return GLOB.breathlessblock

/obj/item/dnainjector/remoteview
	name = "DNA-Injector (Remote View)"
	desc = "Stare into the distance for a reason."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	forcedmutation = TRUE

/obj/item/dnainjector/remoteview/GetInitBlock()
	return GLOB.remoteviewblock

/obj/item/dnainjector/antiremoteview
	name = "DNA-Injector (Anti-Remote View)"
	desc = "Cures green skin."
	datatype = DNA2_BUF_SE
	value = 0x001
	forcedmutation = TRUE

/obj/item/dnainjector/antiremoteview/GetInitBlock()
	return GLOB.remoteviewblock

/obj/item/dnainjector/regenerate
	name = "DNA-Injector (Regeneration)"
	desc = "Healthy but hungry."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	forcedmutation = TRUE

/obj/item/dnainjector/regenerate/GetInitBlock()
	return GLOB.regenerateblock

/obj/item/dnainjector/antiregenerate
	name = "DNA-Injector (Anti-Regeneration)"
	desc = "Sickly but sated."
	datatype = DNA2_BUF_SE
	value = 0x001
	forcedmutation = TRUE

/obj/item/dnainjector/antiregenerate/GetInitBlock()
	return GLOB.regenerateblock

/obj/item/dnainjector/morph
	name = "DNA-Injector (Morph)"
	desc = "A total makeover."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	forcedmutation = TRUE

/obj/item/dnainjector/morph/GetInitBlock()
	return GLOB.morphblock

/obj/item/dnainjector/antimorph
	name = "DNA-Injector (Anti-Morph)"
	desc = "Cures identity crisis."
	datatype = DNA2_BUF_SE
	value = 0x001
	forcedmutation = TRUE

/obj/item/dnainjector/antimorph/GetInitBlock()
	return GLOB.morphblock

/obj/item/dnainjector/noprints
	name = "DNA-Injector (No Prints)"
	desc = "Better than a pair of budget insulated gloves."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	forcedmutation = TRUE

/obj/item/dnainjector/noprints/GetInitBlock()
	return GLOB.noprintsblock

/obj/item/dnainjector/antinoprints
	name = "DNA-Injector (Anti-No Prints)"
	desc = "Not quite as good as a pair of budget insulated gloves."
	datatype = DNA2_BUF_SE
	value = 0x001
	forcedmutation = TRUE

/obj/item/dnainjector/antinoprints/GetInitBlock()
	return GLOB.noprintsblock

/obj/item/dnainjector/insulation
	name = "DNA-Injector (Shock Immunity)"
	desc = "Better than a pair of real insulated gloves."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	forcedmutation = TRUE

/obj/item/dnainjector/insulation/GetInitBlock()
	return GLOB.shockimmunityblock

/obj/item/dnainjector/antiinsulation
	name = "DNA-Injector (Anti-Shock Immunity)"
	desc = "Not quite as good as a pair of real insulated gloves."
	datatype = DNA2_BUF_SE
	value = 0x001
	forcedmutation = TRUE

/obj/item/dnainjector/antiinsulation/GetInitBlock()
	return GLOB.shockimmunityblock

/obj/item/dnainjector/small_size
	name = "DNA-Injector (Small Size)"
	desc = "Makes you shrink."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	forcedmutation = TRUE

/obj/item/dnainjector/small_size/GetInitBlock()
	return GLOB.smallsizeblock

/obj/item/dnainjector/anti_small_size
	name = "DNA-Injector (Anti-Small Size)"
	desc = "Makes you grow. But not too much."
	datatype = DNA2_BUF_SE
	value = 0x001
	forcedmutation = TRUE

/obj/item/dnainjector/anti_small_size/GetInitBlock()
	return GLOB.smallsizeblock

/obj/item/dnainjector/eatmut
	name = "DNA-Injector (Matter Eater)"
	desc = "Gives you an appetite for anything."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	forcedmutation = TRUE

/obj/item/dnainjector/eatmut/GetInitBlock()
	return GLOB.eatblock

/obj/item/dnainjector/antieat
	name = "DNA-Injector (Anti-Matter Eater)"
	desc = "Makes you regain your normal appetite."
	datatype = DNA2_BUF_SE
	value = 0x001
	forcedmutation = TRUE

/obj/item/dnainjector/antieat/GetInitBlock()
	return GLOB.eatblock

/////////////////////////////////////
/obj/item/dnainjector/antiglasses
	name = "DNA-Injector (Anti-Glasses)"
	desc = "Toss away those glasses!"
	datatype = DNA2_BUF_SE
	value = 0x001
	forcedmutation = TRUE

/obj/item/dnainjector/antiglasses/GetInitBlock()
	return GLOB.glassesblock

/obj/item/dnainjector/glassesmut
	name = "DNA-Injector (Glasses)"
	desc = "Will make you need dorkish glasses."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	forcedmutation = TRUE

/obj/item/dnainjector/glassesmut/GetInitBlock()
	return GLOB.glassesblock

/obj/item/dnainjector/epimut
	name = "DNA-Injector (Epi.)"
	desc = "Shake shake shake the room!"
	datatype = DNA2_BUF_SE
	value = 0xFFF
	forcedmutation = TRUE

/obj/item/dnainjector/epimut/GetInitBlock()
	return GLOB.epilepsyblock

/obj/item/dnainjector/antiepi
	name = "DNA-Injector (Anti-Epi.)"
	desc = "Will fix you up from shaking the room."
	datatype = DNA2_BUF_SE
	value = 0x001
	forcedmutation = TRUE

/obj/item/dnainjector/antiepi/GetInitBlock()
	return GLOB.epilepsyblock

/obj/item/dnainjector/anticough
	name = "DNA-Injector (Anti-Cough)"
	desc = "Will stop that awful noise."
	datatype = DNA2_BUF_SE
	value = 0x001
	forcedmutation = TRUE

/obj/item/dnainjector/anticough/GetInitBlock()
	return GLOB.coughblock

/obj/item/dnainjector/coughmut
	name = "DNA-Injector (Cough)"
	desc = "Will bring forth a sound of horror from your throat."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	forcedmutation = TRUE

/obj/item/dnainjector/coughmut/GetInitBlock()
	return GLOB.coughblock

/obj/item/dnainjector/clumsymut
	name = "DNA-Injector (Clumsy)"
	desc = "Makes clumsy minions."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	forcedmutation = TRUE

/obj/item/dnainjector/clumsymut/GetInitBlock()
	return GLOB.clumsyblock

/obj/item/dnainjector/anticlumsy
	name = "DNA-Injector (Anti-Clumy)"
	desc = "Cleans up confusion."
	datatype = DNA2_BUF_SE
	value = 0x001
	forcedmutation = TRUE

/obj/item/dnainjector/anticlumsy/GetInitBlock()
	return GLOB.clumsyblock

/obj/item/dnainjector/stuttmut
	name = "DNA-Injector (Stutt.)"
	desc = "Makes you s-s-stuttterrr."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	forcedmutation = TRUE

/obj/item/dnainjector/stuttmut/GetInitBlock()
	return GLOB.nervousblock


/obj/item/dnainjector/antistutt
	name = "DNA-Injector (Anti-Stutt.)"
	desc = "Fixes that speaking impairment."
	datatype = DNA2_BUF_SE
	value = 0x001
	forcedmutation = TRUE

/obj/item/dnainjector/antistutt/GetInitBlock()
	return GLOB.nervousblock

/obj/item/dnainjector/blindmut
	name = "DNA-Injector (Blind)"
	desc = "Makes you not see anything."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	forcedmutation = TRUE

/obj/item/dnainjector/blindmut/GetInitBlock()
	return GLOB.blindblock

/obj/item/dnainjector/antiblind
	name = "DNA-Injector (Anti-Blind)"
	desc = "ITS A MIRACLE!!!"
	datatype = DNA2_BUF_SE
	value = 0x001
	forcedmutation = TRUE

/obj/item/dnainjector/antiblind/GetInitBlock()
	return GLOB.blindblock

/obj/item/dnainjector/paraplegicmut
	name = "DNA-Injector (Paraplegic)"
	desc = "Faceplanting, in needle form."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	forcedmutation = TRUE

/obj/item/dnainjector/paraplegicmut/GetInitBlock()
	return GLOB.paraplegicblock

/obj/item/dnainjector/antiparaplegic
	name = "DNA-Injector (Anti-Paraplegic)"
	desc = "Returns your legs to working order."
	datatype = DNA2_BUF_SE
	value = 0x001
	forcedmutation = TRUE

/obj/item/dnainjector/antiparaplegic/GetInitBlock()
	return GLOB.paraplegicblock

/obj/item/dnainjector/deafmut
	name = "DNA-Injector (Deaf)"
	desc = "Sorry, what did you say?"
	datatype = DNA2_BUF_SE
	value = 0xFFF
	forcedmutation = TRUE

/obj/item/dnainjector/deafmut/GetInitBlock()
	return GLOB.deafblock

/obj/item/dnainjector/antideaf
	name = "DNA-Injector (Anti-Deaf)"
	desc = "Will make you hear once more."
	datatype = DNA2_BUF_SE
	value = 0x001
	forcedmutation = TRUE

/obj/item/dnainjector/antideaf/GetInitBlock()
	return GLOB.deafblock

/obj/item/dnainjector/hallucination
	name = "DNA-Injector (Halluctination)"
	desc = "What you see isn't always what you get."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	forcedmutation = TRUE

/obj/item/dnainjector/hallucination/GetInitBlock()
	return GLOB.hallucinationblock

/obj/item/dnainjector/antihallucination
	name = "DNA-Injector (Anti-Hallucination)"
	desc = "What you see is what you get."
	datatype = DNA2_BUF_SE
	value = 0x001
	forcedmutation = TRUE

/obj/item/dnainjector/antihallucination/GetInitBlock()
	return GLOB.hallucinationblock

/obj/item/dnainjector/h2m
	name = "DNA-Injector (Human > Monkey)"
	desc = "Will make you a flea bag."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	forcedmutation = TRUE

/obj/item/dnainjector/h2m/GetInitBlock()
	return GLOB.monkeyblock

/obj/item/dnainjector/m2h
	name = "DNA-Injector (Monkey > Human)"
	desc = "Will make you...less hairy."
	datatype = DNA2_BUF_SE
	value = 0x001
	forcedmutation = TRUE

/obj/item/dnainjector/m2h/GetInitBlock()
	return GLOB.monkeyblock


/obj/item/dnainjector/comic
	name = "DNA-Injector (Comic)"
	desc = "Honk!"
	datatype = DNA2_BUF_SE
	value = 0xFFF
	forcedmutation = TRUE

/obj/item/dnainjector/comic/GetInitBlock()
	return GLOB.comicblock

/obj/item/dnainjector/anticomic
	name = "DNA-Injector (Ant-Comic)"
	desc = "Honk...?"
	datatype = DNA2_BUF_SE
	value = 0x001
	forcedmutation = TRUE

/obj/item/dnainjector/anticomic/GetInitBlock()
	return GLOB.comicblock
