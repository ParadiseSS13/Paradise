/*

//This is the output of the stringpercent(print) proc, and means about 80% of
//the print must be there for it to be complete.  (Prints are 32 digits)
var/const/FINGERPRINT_COMPLETE = 6
proc/is_complete_print(print)
	return stringpercent(print) <= FINGERPRINT_COMPLETE

atom/var/list/suit_fibers
atom/var/var/list/fingerprints
atom/var/var/list/fingerprintshidden
atom/var/var/fingerprintslast = null

/atom/proc/add_hiddenprint(mob/M)
	if(!M || !M.key)
		return
	if(fingerprintslast == M.key)
		return
	fingerprintslast = M.key
	if(!fingerprintshidden)
		fingerprintshidden = list()
	if (ishuman(M))
		var/mob/living/carbon/human/H = M
		if (H.gloves)
			src.fingerprintshidden += "\[[time_stamp()]\] (Wearing gloves). Real name: [H.real_name], Key: [H.key]"
			return 0

	src.fingerprintshidden += "\[[time_stamp()]\] Real name: [M.real_name], Key: [M.key]"
	return 1

/atom/proc/add_fingerprint(mob/M, ignoregloves, obj/item)
	if(isnull(M)) return
	if(isAI(M)) return
	if(!M || !M.key)
		return
	if(istype(tool) && (tool.item_flags & ITEM_FLAG_NO_PRINT))
		return

	add_hiddenprint(M)
	add_fibers(M)

	if(!fingerprints)
		fingerprints = list()

	//Hash this shit.
	var/full_print = M.get_full_print(ignoregloves)
	if(!full_print)
		return

	var/obj/item/organ/external/E = M.get_active_hand()
	if(src != E && istype(E) && E.get_fingerprint())
		full_print = E.get_fingerprint()
		ignoregloves = 1

	if(!ignoregloves && ishuman(M))
		var/mob/living/carbon/human/H = M
		if (H.gloves && H.gloves.body_parts_covered & HANDS && H.gloves != src)
			H.gloves.add_fingerprint(M)
			if(!istype(H.gloves, /obj/item/clothing/gloves/latex))
				return 0
			else if(prob(75))
				return 0

	// Add the fingerprints
	add_partial_print(full_print)
	return 1

/atom/proc/add_partial_print(full_print)
	if(!fingerprints[full_print])
		fingerprints[full_print] = stars(full_print, rand(0, 20))	//Initial touch, not leaving much evidence the first time.
	else
		switch(stringpercent(fingerprints[full_print]))		//tells us how many stars are in the current prints.
			if(28 to 32)
				if(prob(1))
					fingerprints[full_print] = full_print 		// You rolled a one buddy.
				else
					fingerprints[full_print] = stars(full_print, rand(0,40)) // 24 to 32

			if(24 to 27)
				if(prob(3))
					fingerprints[full_print] = full_print     	//Sucks to be you.
				else
					fingerprints[full_print] = stars(full_print, rand(15, 55)) // 20 to 29

			if(20 to 23)
				if(prob(5))
					fingerprints[full_print] = full_print		//Had a good run didn't ya.
				else
					fingerprints[full_print] = stars(full_print, rand(30, 70)) // 15 to 25

			if(16 to 19)
				if(prob(5))
					fingerprints[full_print] = full_print		//Welp.
				else
					fingerprints[full_print]  = stars(full_print, rand(40, 100))  // 0 to 21

			if(0 to 15)
				if(prob(5))
					fingerprints[full_print] = stars(full_print, rand(0,50)) 	// small chance you can smudge.
				else
					fingerprints[full_print] = full_print

/atom/proc/transfer_fingerprints_to(atom/A)
	if(fingerprints)
		if(!A.fingerprints)
			A.fingerprints = list()
		A.fingerprints |= fingerprints.Copy()            //detective
	if(fingerprintshidden)
		if(!A.fingerprintshidden)
			A.fingerprintshidden = list()
		A.fingerprintshidden |= fingerprintshidden.Copy()    //admin
		A.fingerprintslast = fingerprintslast

atom/proc/add_fibers(mob/living/carbon/human/M)
	if(!istype(M))
		return
	if(M.gloves && istype(M.gloves,/obj/item/clothing/gloves))
		var/obj/item/clothing/gloves/G = M.gloves
		if(G.transfer_blood) //bloodied gloves transfer blood to touched objects
			if(add_blood(G.bloody_hands_mob)) //only reduces the bloodiness of our gloves if the item wasn't already bloody
				G.transfer_blood--
	else if(M.bloody_hands)
		if(add_blood(M.bloody_hands_mob))
			M.bloody_hands--

	if(!suit_fibers) suit_fibers = list()
	var/fibertext
	var/item_multiplier = istype(src,/obj/item)?1.2:1
	var/suit_coverage = 0
	if(istype(M.wear_suit, /obj/item/clothing))
		var/obj/item/clothing/C = M.wear_suit
		fibertext = C.get_fibers()
		if(fibertext && prob(10*item_multiplier))
			suit_fibers |= fibertext
		suit_coverage = C.body_parts_covered

	if(istype(M.w_uniform, /obj/item/clothing) && (M.w_uniform.body_parts_covered & ~suit_coverage))
		var/obj/item/clothing/C = M.w_uniform
		fibertext = C.get_fibers()
		if(fibertext && prob(15*item_multiplier))
			suit_fibers |= fibertext

	if(istype(M.gloves, /obj/item/clothing) && (M.gloves.body_parts_covered & ~suit_coverage))
		var/obj/item/clothing/C = M.gloves
		fibertext = C.get_fibers()
		if(fibertext && prob(20*item_multiplier))
			suit_fibers |= fibertext

/mob/proc/get_full_print()
	return FALSE

/mob/living/carbon/get_full_print()
	if (!dna || (mFingerprints in mutations))
		return FALSE
	return md5(dna.uni_identity)

/mob/living/carbon/human/get_full_print(ignoregloves)
	if(!..())
		return FALSE

	var/obj/item/organ/external/E = has_organ[hand ? "l_hand" : "r_hand"]
	if(E)
		return E.get_fingerprint()
*/
