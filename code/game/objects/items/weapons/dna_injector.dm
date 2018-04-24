/obj/item/dnainjector
	name = "DNA-Injector"
	desc = "This injects the person with DNA."
	icon = 'icons/obj/items.dmi'
	icon_state = "dnainjector"
	item_state = "dnainjector"
	var/block = 0
	var/datum/dna2/record/buf = null
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "biotech=1"

	var/damage_coeff = 1
	var/used = 0

	// USE ONLY IN PREMADE SYRINGES.  WILL NOT WORK OTHERWISE.
	var/datatype = 0
	var/value = 0

/obj/item/dnainjector/New()
	if(datatype && block)
		buf=new
		buf.dna=new
		buf.types = datatype
		buf.dna.ResetSE()
		SetValue(value)

/obj/item/dnainjector/Destroy()
	QDEL_NULL(buf)
	return ..()

/obj/item/dnainjector/proc/GetRealBlock(var/selblock)
	if(selblock==0)
		return block
	else
		return selblock

/obj/item/dnainjector/proc/GetState(var/selblock=0)
	var/real_block=GetRealBlock(selblock)
	if(buf.types&DNA2_BUF_SE)
		return buf.dna.GetSEState(real_block)
	else
		return buf.dna.GetUIState(real_block)

/obj/item/dnainjector/proc/SetState(var/on, var/selblock=0)
	var/real_block=GetRealBlock(selblock)
	if(buf.types&DNA2_BUF_SE)
		return buf.dna.SetSEState(real_block,on)
	else
		return buf.dna.SetUIState(real_block,on)

/obj/item/dnainjector/proc/GetValue(var/selblock=0)
	var/real_block=GetRealBlock(selblock)
	if(buf.types&DNA2_BUF_SE)
		return buf.dna.GetSEValue(real_block)
	else
		return buf.dna.GetUIValue(real_block)

/obj/item/dnainjector/proc/SetValue(var/val,var/selblock=0)
	var/real_block=GetRealBlock(selblock)
	if(buf.types&DNA2_BUF_SE)
		return buf.dna.SetSEValue(real_block,val)
	else
		return buf.dna.SetUIValue(real_block,val)

/obj/item/dnainjector/proc/inject(mob/living/M as mob, mob/user as mob)
	if(used)
		return
	if(istype(M,/mob/living))
		M.apply_effect(rand(20/(damage_coeff  ** 2),50/(damage_coeff  ** 2)),IRRADIATE,0,1)
	var/mob/living/carbon/human/H
	if(istype(M, /mob/living/carbon/human))
		H = M

	spawn(0) //Some mutations have sleeps in them, like monkey
		if(!(NOCLONE in M.mutations) && !(H && (NO_DNA in H.species.species_traits))) // prevents drained people from having their DNA changed
			var/prev_ue = M.dna.unique_enzymes
			var/mutflags = 0
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
				mutflags = MUTCHK_FORCED
				if(!block) //isolated block?
					M.dna.SE = buf.dna.SE.Copy()
					M.dna.UpdateSE()
				else
					M.dna.SetSEValue(block,src.GetValue())
				domutcheck(M, null, mutflags)
				M.update_mutations()
			if(H)
				H.sync_organ_dna(assimilate = 0, old_ue = prev_ue)

/obj/item/dnainjector/attack(mob/M as mob, mob/user as mob)
	if(used)
		to_chat(user, "<span class='warning'>This injector is used up!</span>")
		return
	if(!M.dna) //You know what would be nice? If the mob you're injecting has DNA, and so doesn't cause runtimes.
		return 0

	if(ishuman(M)) // Would've done this via species instead of type, but the basic mob doesn't have a species, go figure.
		var/mob/living/carbon/human/H = M
		if(NO_DNA in H.species.species_traits)
			return 0

	if(!user.IsAdvancedToolUser())
		return 0

	var/attack_log = "injected with the Isolated [name]"

	if(buf.types & DNA2_BUF_SE)
		if(block)
			if(GetState() && block == MONKEYBLOCK && ishuman(M))
				attack_log = "injected with the Isolated [name] (MONKEY)"
				message_admins("[key_name_admin(user)] injected [key_name_admin(M)] with the Isolated [name] <span class='warning'>(MONKEY)</span>")

		else
			if(GetState(MONKEYBLOCK) && ishuman(M))
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

	add_attack_logs(user, M, attack_log, FALSE)
	if(!iscarbon(user))
		M.LAssailant = null
	else
		M.LAssailant = user

	inject(M, user)
	used = 1
	icon_state = "dnainjector0"
	desc += " This one is used up."

/obj/item/dnainjector/hulkmut
	name = "DNA-Injector (Hulk)"
	desc = "This will make you big and strong, but give you a bad skin condition."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2
	New()
		block = HULKBLOCK
		..()

/obj/item/dnainjector/antihulk
	name = "DNA-Injector (Anti-Hulk)"
	desc = "Cures green skin."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2
	New()
		block = HULKBLOCK
		..()

/obj/item/dnainjector/xraymut
	name = "DNA-Injector (Xray)"
	desc = "Finally you can see what the Captain does."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 8
	New()
		block = XRAYBLOCK
		..()

/obj/item/dnainjector/antixray
	name = "DNA-Injector (Anti-Xray)"
	desc = "It will make you see harder."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 8
	New()
		block = XRAYBLOCK
		..()


/obj/item/dnainjector/firemut
	name = "DNA-Injector (Fire)"
	desc = "Gives you fire."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 10
	New()
		block = FIREBLOCK
		..()

/obj/item/dnainjector/antifire
	name = "DNA-Injector (Anti-Fire)"
	desc = "Cures fire."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 10
	New()
		block = FIREBLOCK
		..()

/obj/item/dnainjector/telemut
	name = "DNA-Injector (Tele.)"
	desc = "Super brain man!"
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 12
	New()
		block = TELEBLOCK
		..()

/obj/item/dnainjector/telemut/darkbundle
	name = "DNA injector"
	desc = "Good. Let the hate flow through you."


/obj/item/dnainjector/antitele
	name = "DNA-Injector (Anti-Tele.)"
	desc = "Will make you not able to control your mind."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 12
	New()
		block = TELEBLOCK
		..()

/obj/item/dnainjector/nobreath
	name = "DNA-Injector (Breathless)"
	desc = "Hold your breath and count to infinity."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2
	New()
		block = BREATHLESSBLOCK
		..()

/obj/item/dnainjector/antinobreath
	name = "DNA-Injector (Anti-Breathless)"
	desc = "Hold your breath and count to 100."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2
	New()
		block = BREATHLESSBLOCK
		..()

/obj/item/dnainjector/remoteview
	name = "DNA-Injector (Remote View)"
	desc = "Stare into the distance for a reason."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2
	New()
		block = REMOTEVIEWBLOCK
		..()

/obj/item/dnainjector/antiremoteview
	name = "DNA-Injector (Anti-Remote View)"
	desc = "Cures green skin."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2
	New()
		block = REMOTEVIEWBLOCK
		..()

/obj/item/dnainjector/regenerate
	name = "DNA-Injector (Regeneration)"
	desc = "Healthy but hungry."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2
	New()
		block = REGENERATEBLOCK
		..()

/obj/item/dnainjector/antiregenerate
	name = "DNA-Injector (Anti-Regeneration)"
	desc = "Sickly but sated."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2
	New()
		block = REGENERATEBLOCK
		..()

/obj/item/dnainjector/runfast
	name = "DNA-Injector (Increase Run)"
	desc = "Running Man."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2
	New()
		block = INCREASERUNBLOCK
		..()

/obj/item/dnainjector/antirunfast
	name = "DNA-Injector (Anti-Increase Run)"
	desc = "Walking Man."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2
	New()
		block = INCREASERUNBLOCK
		..()

/obj/item/dnainjector/morph
	name = "DNA-Injector (Morph)"
	desc = "A total makeover."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2
	New()
		block = MORPHBLOCK
		..()

/obj/item/dnainjector/antimorph
	name = "DNA-Injector (Anti-Morph)"
	desc = "Cures identity crisis."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2
	New()
		block = MORPHBLOCK
		..()

/obj/item/dnainjector/noprints
	name = "DNA-Injector (No Prints)"
	desc = "Better than a pair of budget insulated gloves."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2
	New()
		block = NOPRINTSBLOCK
		..()

/obj/item/dnainjector/antinoprints
	name = "DNA-Injector (Anti-No Prints)"
	desc = "Not quite as good as a pair of budget insulated gloves."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2
	New()
		block = NOPRINTSBLOCK
		..()

/obj/item/dnainjector/insulation
	name = "DNA-Injector (Shock Immunity)"
	desc = "Better than a pair of real insulated gloves."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2
	New()
		block = SHOCKIMMUNITYBLOCK
		..()

/obj/item/dnainjector/antiinsulation
	name = "DNA-Injector (Anti-Shock Immunity)"
	desc = "Not quite as good as a pair of real insulated gloves."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2
	New()
		block = SHOCKIMMUNITYBLOCK
		..()

/obj/item/dnainjector/midgit
	name = "DNA-Injector (Small Size)"
	desc = "Makes you shrink."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2
	New()
		block = SMALLSIZEBLOCK
		..()

/obj/item/dnainjector/antimidgit
	name = "DNA-Injector (Anti-Small Size)"
	desc = "Makes you grow. But not too much."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2
	New()
		block = SMALLSIZEBLOCK
		..()

/////////////////////////////////////
/obj/item/dnainjector/antiglasses
	name = "DNA-Injector (Anti-Glasses)"
	desc = "Toss away those glasses!"
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 1
	New()
		block = GLASSESBLOCK
		..()

/obj/item/dnainjector/glassesmut
	name = "DNA-Injector (Glasses)"
	desc = "Will make you need dorkish glasses."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 1
	New()
		block = GLASSESBLOCK
		..()

/obj/item/dnainjector/epimut
	name = "DNA-Injector (Epi.)"
	desc = "Shake shake shake the room!"
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 3
	New()
		block = EPILEPSYBLOCK
		..()

/obj/item/dnainjector/antiepi
	name = "DNA-Injector (Anti-Epi.)"
	desc = "Will fix you up from shaking the room."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 3
	New()
		block = EPILEPSYBLOCK
		..()

/obj/item/dnainjector/anticough
	name = "DNA-Injector (Anti-Cough)"
	desc = "Will stop that awful noise."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 5
	New()
		block = COUGHBLOCK
		..()

/obj/item/dnainjector/coughmut
	name = "DNA-Injector (Cough)"
	desc = "Will bring forth a sound of horror from your throat."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 5
	New()
		block = COUGHBLOCK
		..()

/obj/item/dnainjector/clumsymut
	name = "DNA-Injector (Clumsy)"
	desc = "Makes clumsy minions."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 6
	New()
		block = CLUMSYBLOCK
		..()

/obj/item/dnainjector/anticlumsy
	name = "DNA-Injector (Anti-Clumy)"
	desc = "Cleans up confusion."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 6
	New()
		block = CLUMSYBLOCK
		..()

/obj/item/dnainjector/antitour
	name = "DNA-Injector (Anti-Tour.)"
	desc = "Will cure tourrets."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 7
	New()
		block = TWITCHBLOCK
		..()

/obj/item/dnainjector/tourmut
	name = "DNA-Injector (Tour.)"
	desc = "Gives you a nasty case off tourrets."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 7
	New()
		block = TWITCHBLOCK
		..()

/obj/item/dnainjector/stuttmut
	name = "DNA-Injector (Stutt.)"
	desc = "Makes you s-s-stuttterrr"
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 9
	New()
		block = NERVOUSBLOCK
		..()


/obj/item/dnainjector/antistutt
	name = "DNA-Injector (Anti-Stutt.)"
	desc = "Fixes that speaking impairment."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 9
	New()
		block = NERVOUSBLOCK
		..()

/obj/item/dnainjector/blindmut
	name = "DNA-Injector (Blind)"
	desc = "Makes you not see anything."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 11
	New()
		block = BLINDBLOCK
		..()

/obj/item/dnainjector/antiblind
	name = "DNA-Injector (Anti-Blind)"
	desc = "ITS A MIRACLE!!!"
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 11
	New()
		block = BLINDBLOCK
		..()

/obj/item/dnainjector/telemut
	name = "DNA-Injector (Tele.)"
	desc = "Super brain man!"
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 12
	New()
		block = TELEBLOCK
		..()

/obj/item/dnainjector/antitele
	name = "DNA-Injector (Anti-Tele.)"
	desc = "Will make you not able to control your mind."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 12
	New()
		block = TELEBLOCK
		..()

/obj/item/dnainjector/deafmut
	name = "DNA-Injector (Deaf)"
	desc = "Sorry, what did you say?"
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 13
	New()
		block = DEAFBLOCK
		..()

/obj/item/dnainjector/antideaf
	name = "DNA-Injector (Anti-Deaf)"
	desc = "Will make you hear once more."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 13
	New()
		block = DEAFBLOCK
		..()

/obj/item/dnainjector/hallucination
	name = "DNA-Injector (Halluctination)"
	desc = "What you see isn't always what you get."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2
	New()
		block = HALLUCINATIONBLOCK
		..()

/obj/item/dnainjector/antihallucination
	name = "DNA-Injector (Anti-Hallucination)"
	desc = "What you see is what you get."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2
	New()
		block = HALLUCINATIONBLOCK
		..()

/obj/item/dnainjector/h2m
	name = "DNA-Injector (Human > Monkey)"
	desc = "Will make you a flea bag."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 14
	New()
		block = MONKEYBLOCK
		..()

/obj/item/dnainjector/m2h
	name = "DNA-Injector (Monkey > Human)"
	desc = "Will make you...less hairy."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 14
	New()
		block = MONKEYBLOCK
		..()
