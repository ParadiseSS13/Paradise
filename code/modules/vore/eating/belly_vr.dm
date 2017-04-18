//
//	The belly object is what holds onto a mob while they're inside a predator.
//	It takes care of altering the pred's decription, digesting the prey, relaying struggles etc.
//

// If you change what variables are on this, then you need to update the copy() proc.

//
// Parent type of all the various "belly" varieties.
//
/datum/belly
	var/name								// Name of this location
	var/inside_flavor						// Flavor text description of inside sight/sound/smells/feels.
	var/vore_sound = 'sound/vore/gulp.ogg'	// Sound when ingesting someone
	var/vore_verb = "ingest"				// Verb for eating with this in messages
	var/human_prey_swallow_time = 100		// Time in deciseconds to swallow /mob/living/carbon/human
	var/nonhuman_prey_swallow_time = 30		// Time in deciseconds to swallow anything else
	var/emoteTime = 600						// How long between stomach emotes at prey
	var/digest_brute = 2					// Brute damage per tick in digestion mode
	var/digest_burn = 3						// Burn damage per tick in digestion mode
	var/digest_tickrate = 3					// Modulus this of air controller tick number to iterate gurgles on
	var/immutable = 0						// Prevents this belly from being deleted
	var/escapable = 0						// Belly can be resisted out of at any time
	var/escapetime = 60 SECONDS				// Deciseconds, how long to escape this belly
	var/digestchance = 0					// % Chance of stomach beginning to digest if prey struggles
	var/absorbchance = 0					// % Chance of stomach beginning to absorb if prey struggles
	var/escapechance = 0 					// % Chance of prey beginning to escape if prey struggles.
	var/transferchance = 0 					// % Chance of prey being
	var/can_taste = 0						// If this belly prints the flavor of prey when it eats someone.
	var/transferlocation = null				// Location that the prey is released if they struggle and get dropped off.

	var/tmp/digest_mode = DM_HOLD				// Whether or not to digest. Default to not digest.
	var/tmp/list/digest_modes = list(DM_HOLD,DM_DIGEST,DM_HEAL,DM_ABSORB,DM_DRAIN,DM_UNABSORB)	// Possible digest modes
	var/tmp/list/transform_modes = list(DM_TRANSFORM_MALE,DM_TRANSFORM_FEMALE,DM_TRANSFORM_KEEP_GENDER, DM_EGG)
	var/tmp/mob/living/owner					// The mob whose belly this is.
	var/tmp/list/internal_contents = list()		// People/Things you've eaten into this belly!
	var/tmp/is_full								// Flag for if digested remeans are present. (for disposal messages)
	var/tmp/emotePend = 0						// If there's already a spawned thing counting for the next emote

	// Don't forget to watch your commas at the end of each line if you change these.
	var/list/struggle_messages_outside = list(
		"%pred's %belly wobbles with a squirming meal.",
		"%pred's %belly jostles with movement.",
		"%pred's %belly briefly swells outward as someone pushes from inside.",
		"%pred's %belly fidgets with a trapped victim.",
		"%pred's %belly jiggles with motion from inside.",
		"%pred's %belly sloshes around.",
		"%pred's %belly gushes softly.",
		"%pred's %belly lets out a wet squelch.")

	var/list/struggle_messages_inside = list(
		"Your useless squirming only causes %pred's slimy %belly to squelch over your body.",
		"Your struggles only cause %pred's %belly to gush softly around you.",
		"Your movement only causes %pred's %belly to slosh around you.",
		"Your motion causes %pred's %belly to jiggle.",
		"You fidget around inside of %pred's %belly.",
		"You shove against the walls of %pred's %belly, making it briefly swell outward.",
		"You jostle %pred's %belly with movement.",
		"You squirm inside of %pred's %belly, making it wobble around.")

	var/list/digest_messages_owner = list(
		"You feel %prey's body succumb to your digestive system, which breaks it apart into soft slurry.",
		"You hear a lewd glorp as your %belly muscles grind %prey into a warm pulp.",
		"Your %belly lets out a rumble as it melts %prey into sludge.",
		"You feel a soft gurgle as %prey's body loses form in your %belly. They're nothing but a soft mass of churning slop now.",
		"Your %belly begins gushing %prey's remains through your system, adding some extra weight to your thighs.",
		"Your %belly begins gushing %prey's remains through your system, adding some extra weight to your rump.",
		"Your %belly begins gushing %prey's remains through your system, adding some extra weight to your belly.",
		"Your %belly groans as %prey falls apart into a thick soup. You can feel their remains soon flowing deeper into your body to be absorbed.",
		"Your %belly kneads on every fiber of %prey, softening them down into mush to fuel your next hunt.",
		"Your %belly churns %prey down into a hot slush. You can feel the nutrients coursing through your digestive track with a series of long, wet glorps.")

	var/list/digest_messages_prey = list(
		"Your body succumbs to %pred's digestive system, which breaks you apart into soft slurry.",
		"%pred's %belly lets out a lewd glorp as their muscles grind you into a warm pulp.",
		"%pred's %belly lets out a rumble as it melts you into sludge.",
		"%pred feels a soft gurgle as your body loses form in their %belly. You're nothing but a soft mass of churning slop now.",
		"%pred's %belly begins gushing your remains through their system, adding some extra weight to %pred's thighs.",
		"%pred's %belly begins gushing your remains through their system, adding some extra weight to %pred's rump.",
		"%pred's %belly begins gushing your remains through their system, adding some extra weight to %pred's belly.",
		"%pred's %belly groans as you fall apart into a thick soup. Your remains soon flow deeper into %pred's body to be absorbed.",
		"%pred's %belly kneads on every fiber of your body, softening you down into mush to fuel their next hunt.",
		"%pred's %belly churns you down into a hot slush. Your nutrient-rich remains course through their digestive track with a series of long, wet glorps.")

	var/list/examine_messages = list(
		"They have something solid in their %belly!",
		"It looks like they have something in their %belly!")

	//Mostly for being overridden on precreated bellies on mobs. Could be VV'd into
	//a carbon's belly if someone really wanted. No UI for carbons to adjust this.
	//List has indexes that are the digestion mode strings, and keys that are lists of strings.
	var/list/emote_lists = list()

// Constructor that sets the owning mob
/datum/belly/New(var/mob/living/owning_mob)
	owner = owning_mob

// Toggle digestion on/off and notify user of the new setting.
// If multiple digestion modes are avaliable (i.e. unbirth) then user should be prompted.
/datum/belly/proc/toggle_digestion()
	return

// Checks if any mobs are present inside the belly
// return True if the belly is empty.
/datum/belly/proc/is_empty()
	return internal_contents.len == 0

// Release all contents of this belly into the owning mob's location.
// If that location is another mob, contents are transferred into whichever of its bellies the owning mob is in.
// Returns the number of mobs so released.
/datum/belly/proc/release_all_contents()
	if (internal_contents.len == 0)
		return 0
	for (var/atom/movable/M in internal_contents)
		if(istype(M,/mob/living))
			var/mob/living/ML = M
			if(ML.absorbed)
				continue

		M.forceMove(owner.loc)  // Move the belly contents into the same location as belly's owner.
		internal_contents -= M  // Remove from the belly contents

		var/datum/belly/B = check_belly(owner) // This makes sure that the mob behaves properly if released into another mob
		if(B)
			B.internal_contents += M

	owner.visible_message("<font color='green'><b>[owner] expels everything from their [lowertext(name)]!</b></font>")
	return 1

// Release a specific atom from the contents of this belly into the owning mob's location.
// If that location is another mob, the atom is transferred into whichever of its bellies the owning mob is in.
// Returns the number of atoms so released.
/datum/belly/proc/release_specific_contents(var/atom/movable/M)
	if (!(M in internal_contents))
		return 0 // They weren't in this belly anyway

	M.forceMove(owner.loc)  // Move the belly contents into the same location as belly's owner.
	src.internal_contents -= M  // Remove from the belly contents

	if(istype(M,/mob/living))
		var/mob/living/ML = M
		var/mob/living/OW = owner
		if(ML.absorbed)
			ML.absorbed = 0
			ML.reagents = new/datum/reagents(1000,M) //Human reagent datums hold 1000
			if(OW.reagents && istype(OW.reagents,/datum/reagents)) //Does the pred have a reagents list?
				var/datum/reagents/OR = owner.reagents
				var/absorbed_count = 2 //Prey that we were, plus the pred gets a portion
				for(var/mob/living/P in internal_contents)
					if(P.absorbed)
						absorbed_count++

				OR.trans_to(ML,OR.total_volume / absorbed_count)

	var/datum/belly/B = check_belly(owner)
	if(B)
		B.internal_contents += M

	owner.visible_message("<font color='green'><b>[owner] expels [M] from their [lowertext(name)]!</b></font>")
	owner.update_icons()
	return 1

// Actually perform the mechanics of devouring the tasty prey.
// The purpose of this method is to avoid duplicate code, and ensure that all necessary
// steps are taken.
/datum/belly/proc/nom_mob(var/mob/prey, var/mob/user)
	if (prey.buckled)
		prey.buckled.unbuckle_mob()

	prey.forceMove(owner)
	internal_contents |= prey

	if(inside_flavor)
		to_chat(prey, "<span class='notice'><B>[inside_flavor]</B></span>")

// Get the line that should show up in Examine message if the owner of this belly
// is examined.   By making this a proc, we not only take advantage of polymorphism,
// but can easily make the message vary based on how many people are inside, etc.
// Returns a string which shoul be appended to the Examine output.
/datum/belly/proc/get_examine_msg()
	if(internal_contents.len && examine_messages.len)
		var/formatted_message
		var/raw_message = pick(examine_messages)

		formatted_message = replacetext(raw_message,"%belly",lowertext(name))

		return("<span class='warning'>[formatted_message]</span><BR>")

// The next function gets the messages set on the belly, in human-readable format.
// This is useful in customization boxes and such. The delimiter right now is \n\n so
// in message boxes, this looks nice and is easily delimited.
/datum/belly/proc/get_messages(var/type, var/delim = "\n\n")
	ASSERT(type == "smo" || type == "smi" || type == "dmo" || type == "dmp" || type == "em")
	var/list/raw_messages

	switch(type)
		if("smo")
			raw_messages = struggle_messages_outside
		if("smi")
			raw_messages = struggle_messages_inside
		if("dmo")
			raw_messages = digest_messages_owner
		if("dmp")
			raw_messages = digest_messages_prey
		if("em")
			raw_messages = examine_messages

	var/messages = jointext(raw_messages, delim)
	return messages

// The next function sets the messages on the belly, from human-readable var
// replacement strings and linebreaks as delimiters (two \n\n by default).
// They also sanitize the messages.
/datum/belly/proc/set_messages(var/raw_text, var/type, var/delim = "\n\n")
	ASSERT(type == "smo" || type == "smi" || type == "dmo" || type == "dmp" || type == "em")

	var/list/raw_list = splittext(html_encode(raw_text), delim)
	if(raw_list.len > 10)
		raw_list.Cut(11)
		log_debug("[owner] tried to set [name] with 11+ messages")

	for(var/i = 1, i <= raw_list.len, i++)
		if(length(raw_list[i]) > 160 || length(raw_list[i]) < 10) //160 is fudged value due to htmlencoding increasing the size
			raw_list.Cut(i,i)
			log_debug("[owner] tried to set [name] with >121 or <10 char message")
		else
			raw_list[i] = readd_quotes(raw_list[i])
			//Also fix % sign for var replacement
			raw_list[i] = replacetext(raw_list[i],"&#37;","%")

	ASSERT(raw_list.len <= 10) //Sanity

	switch(type)
		if("smo")
			struggle_messages_outside = raw_list
		if("smi")
			struggle_messages_inside = raw_list
		if("dmo")
			digest_messages_owner = raw_list
		if("dmp")
			digest_messages_prey = raw_list
		if("em")
			examine_messages = raw_list

	return

// Handle the death of a mob via digestion.
// Called from the process_Life() methods of bellies that digest prey.
// Default implementation calls M.death() and removes from internal contents.
// Indigestable items are removed, and M is deleted.
/datum/belly/proc/digestion_death(var/mob/living/M)
	is_full = 1
	M.death(1)
	internal_contents -= M

	// If digested prey is also a pred... anyone inside their bellies gets moved up.
	if (is_vore_predator(M))
		for (var/bellytype in M.vore_organs)
			var/datum/belly/belly = M.vore_organs[bellytype]
			for (var/obj/thing in belly.internal_contents)
				thing.loc = owner
				internal_contents += thing
			for (var/mob/subprey in belly.internal_contents)
				subprey.loc = owner
				internal_contents += subprey
				to_chat(subprey, "As [M] melts away around you, you find yourself in [owner]'s [name]")

	//Drop all items into the belly.
	if (config.items_survive_digestion)
		for (var/obj/item/W in M)
			_handle_digested_item(W,M)

	//Reagent transfer
	if(M.reagents && istype(M.reagents,/datum/reagents))
		var/mob/living/OW = owner
		if(OW.reagents && istype(OW.reagents,/datum/reagents)) //Does the pred have a reagents list to give to?
			var/datum/reagents/RL = M.reagents
			RL.trans_to(owner,RL.total_volume*0.5)

	// Delete the digested mob
	qdel(M)

// Recursive method - To recursively scan thru someone's inventory for digestable/indigestable.
/datum/belly/proc/_handle_digested_item(var/obj/item/W,var/mob/M)
	// SOME mob has to use some procs. If somehow they're gone, then the pred can handle it.
	if(!M)
		M = owner

	// IDs are handled specially to 'digest' them
	if(istype(W,/obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/ID = W
		ID.desc = "A partially digested card that has seen better days.  Much of it's data has been destroyed."
		ID.icon = 'icons/obj/card_vr.dmi'
		ID.icon_state = "digested"
		ID.access = list() // No access
		M.remove_from_mob(ID,owner)
		internal_contents += ID

	else
		if(!_is_digestable(W))
			M.remove_from_mob(W,owner)
			internal_contents += W
		else
			for (var/obj/item/SubItem in W)
				_handle_digested_item(SubItem,M)

/datum/belly/proc/_is_digestable(var/obj/item/I)
	if(is_type_in_list(I,important_items))
		return 0
	return 1

// Handle a mob being absorbed
/datum/belly/proc/absorb_living(var/mob/living/M)
	M.absorbed = 1
	to_chat(M, "<span class='notice'>[owner]'s [name] absorbs your body, making you part of them.</span>")
	to_chat(owner, "<span class='notice'>Your [name] absorbs [M]'s body, making them part of you.</span>")
	var/mob/living/OW = owner

	//Reagent sharing for absorbed with pred
	if(OW.reagents && istype(OW.reagents,/datum/reagents)) //Does the pred have a reagent list?
		if(M.reagents && istype(M.reagents,/datum/reagents)) //Does the prey have a reagent list?
			var/datum/reagents/OR = owner.reagents
			var/datum/reagents/PR = M.reagents
			PR.trans_to(owner,PR.total_volume)
			M.reagents = OR
			del(PR)

	//This is probably already the case, but for sub-prey, it won't be.
	M.forceMove(owner)

	//Seek out absorbed prey of the prey, absorb them too.
	//This in particular will recurse oddly because if there is absorbed prey of prey of prey...
	//it will just move them up one belly. This should never happen though since... when they were
	//absobred, they should have been absorbed as well!
	for(var/I in M.vore_organs)
		var/datum/belly/B = M.vore_organs[I]
		for(var/mob/living/Mm in B.internal_contents)
			if(Mm.absorbed)
				internal_contents += Mm
				B.internal_contents -= Mm
				absorb_living(Mm)

//Handle a mob struggling
// Called from /mob/living/carbon/relaymove()
/datum/belly/proc/relay_resist(var/mob/living/R)
	if (!(R in internal_contents))
		return  // User is not in this belly, or struggle too soon.

	if(owner.stat) //If owner is stat (dead, KO) we can actually escape
		to_chat(R, "<span class='warning'>You attempt to climb out of \the [name]. (This will take around [escapetime/10] seconds.)</span>")
		to_chat(owner, "<span class='warning'>Someone is attempting to climb out of your [name]!</span>")

		if(do_after(R, escapetime, owner, need_hand = 0, target = owner))
			if((owner.stat || escapable) && (R in internal_contents)) //Can still escape?
				release_specific_contents(R)
				return
			else if(!(R in internal_contents)) //Aren't even in the belly. Quietly fail.
				return
			else //Belly became inescapable or mob revived
				to_chat(R, "<span class='warning'>Your attempt to escape [name] has failed!</span>")
				to_chat(owner, "<span class='notice'>The attempt to escape from your [name] has failed!</span>")
				return
			return
	var/struggle_outer_message = pick(struggle_messages_outside)
	var/struggle_user_message = pick(struggle_messages_inside)

	struggle_outer_message = replacetext(struggle_outer_message,"%pred",owner)
	struggle_outer_message = replacetext(struggle_outer_message,"%prey",R)
	struggle_outer_message = replacetext(struggle_outer_message,"%belly",lowertext(name))

	struggle_user_message = replacetext(struggle_user_message,"%pred",owner)
	struggle_user_message = replacetext(struggle_user_message,"%prey",R)
	struggle_user_message = replacetext(struggle_user_message,"%belly",lowertext(name))

	struggle_outer_message = "<span class='alert'>" + struggle_outer_message + "</span>"
	struggle_user_message = "<span class='alert'>" + struggle_user_message + "</span>"

	for(var/mob/M in hearers(4, owner))
		M.show_message(struggle_outer_message, 2) // hearable
	to_chat(R, struggle_user_message)

	var/strpick = pick(struggle_sounds)
	var/strsound = struggle_sounds[strpick]
	playsound(R.loc, strsound, 50, 1)

	if(escapable) //If the stomach has escapable enabled.
		to_chat(R, "<span class='warning'>You attempt to climb out of \the [name].</span>")
		to_chat(owner, "<span class='warning'>Someone is attempting to climb out of your [name]!</span>")
		if(prob(escapechance)) //Let's have it check to see if the prey escapes first.
			if(do_after(R, escapetime))
				if((escapable) && (R in internal_contents)) //Does the owner still have escapable enabled?
					release_specific_contents(R)
					to_chat(R, "<span class='warning'>You climb out of \the [name].</span>")
					to_chat(owner, "<span class='warning'>[R] climbs out of your [name]!</span>")
					for(var/mob/M in hearers(4, owner))
						M.show_message("<span class='warning'>[R] climbs out of [owner]'s [name]!</span>", 2)
					return
				else if(!(R in internal_contents)) //Aren't even in the belly. Quietly fail.
					return
			else //Belly became inescapable.
				to_chat(R, "<span class='warning'>Your attempt to escape [name] has failed!</span>")
				to_chat(owner, "<span class='notice'>The attempt to escape from your [name] has failed!</span>")
				return

		else if(prob(transferchance) && transferlocation) //Next, let's have it see if they end up getting into an even bigger mess then when they started.
			if(owner.vore_organs[transferlocation])
				var/datum/belly/transfer = owner.vore_organs[transferlocation]
				internal_contents -= R
				transfer.internal_contents |= R
				to_chat(R, "<span class='warning'>Your attempt to escape [name] has failed and your struggles only results in you sliding into [owner]'s [transfer]!</span>")
				to_chat(owner, "<span class='warning'>Someone slid into your [transfer] due to their struggling inside your [name]!</span>")
			else
				to_chat(owner, "<span class='warning'>Someone attempted to slide into your [transferlocation], but it no longer exists! Preference reset.</span>")
				transferlocation = null
			return

		else if(prob(absorbchance)) //After that, let's have it run the absorb chance.
			to_chat(R, "<span class='warning'>In response to your struggling, \the [name] begins to get more active...</span>")
			to_chat(owner, "<span class='warning'>You feel your [name] beginning to become active!</span>")
			digest_mode = DM_ABSORB
			return

		else if(prob(digestchance)) //Finally, let's see if it should run the digest chance.
			to_chat(R, "<span class='warning'>In response to your struggling, \the [name] begins to get more active...</span>")
			to_chat(owner, "<span class='warning'>You feel your [name] beginning to become active!</span>")
			digest_mode = DM_DIGEST
			return
		else //Nothing interesting happened.
			to_chat(R, "<span class='warning'>But make no progress in escaping [owner]'s [name].</span>")
			to_chat(owner, "<span class='warning'>But appears to be unable to make any progress in escaping your [name].</span>")
			return


// Persistence
/datum/belly/serialize()
	var/list/data = ..()
	data["name"] = name
	data["inside_flavor"] = inside_flavor
	data["vore_sound"] = vore_sound
	data["vore_verb"] = vore_verb
	data["human_prey_swallow_time"] = human_prey_swallow_time
	data["nonhuman_prey_swallow_time"] = nonhuman_prey_swallow_time
	data["emoteTime"] = emoteTime
	data["digest_brute"] = digest_brute
	data["digest_burn"] = digest_burn
	data["digest_tickrate"] = digest_tickrate
	data["immutable"] = immutable
	data["can_taste"] = can_taste
	data["escapable"] = escapable
	data["escapetime"] = escapetime
	data["digestchance"] = digestchance
	data["absorbchance"] = absorbchance
	data["escapechance"] = escapechance
	data["transferchance"] = transferchance
	data["transferlocation"] = transferlocation

	data["struggle_messages_outside"] = struggle_messages_outside
	data["struggle_messages_inside"] = struggle_messages_inside
	data["digest_messages_owner"] = digest_messages_owner
	data["digest_messages_prey"] = digest_messages_prey
	data["examine_messages"] = examine_messages
	data["emote_lists"] = emote_lists
	return data

/datum/belly/deserialize(var/list/data)
	name = data["name"]
	inside_flavor = data["inside_flavor"]
	vore_sound = data["vore_sound"]
	vore_verb = data["vore_verb"]
	human_prey_swallow_time = data["human_prey_swallow_time"]
	nonhuman_prey_swallow_time = data["nonhuman_prey_swallow_time"]
	emoteTime = data["emoteTime"]
	digest_brute = data["digest_brute"]
	digest_burn = data["digest_burn"]
	digest_tickrate = data["digest_tickrate"]
	immutable = data["immutable"]
	can_taste = data["can_taste"]
	escapable = data["escapable"]
	escapetime = data["escapetime"]
	digestchance = data["digestchance"]
	absorbchance = data["absorbchance"]
	escapechance = data["escapechance"]
	transferchance = data["transferchance"]
	transferlocation = data["transferlocation"]

	struggle_messages_outside = data["struggle_messages_outside"]
	struggle_messages_inside = data["struggle_messages_inside"]
	digest_messages_owner = data["digest_messages_owner"]
	digest_messages_prey = data["digest_messages_prey"]
	examine_messages = data["examine_messages"]
	emote_lists = data["emote_lists"]