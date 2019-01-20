/mob/living
	var/list/ownedSoullinks //soullinks we are the owner of
	var/list/sharedSoullinks //soullinks we are a/the sharer of

/mob/living/Destroy()
	for(var/s in ownedSoullinks)
		var/datum/soullink/S = s
		S.ownerDies(FALSE)
		qdel(s) //If the owner is destroy()'d, the soullink is destroy()'d
	ownedSoullinks = null
	for(var/s in sharedSoullinks)
		var/datum/soullink/S = s
		S.sharerDies(FALSE)
		S.removeSoulsharer(src) //If a sharer is destroy()'d, they are simply removed
	sharedSoullinks = null
	return ..()

//Keeps track of a Mob->Mob (potentially Player->Player) connection
//Can be used to trigger actions on one party when events happen to another
//Eg: shared deaths
//Can be used to form a linked list of mob-hopping
//Does NOT transfer with minds
/datum/soullink
	var/mob/living/soulowner
	var/mob/living/soulsharer
	var/id //Optional ID, for tagging and finding specific instances

/datum/soullink/Destroy()
	if(soulowner)
		LAZYREMOVE(soulowner.ownedSoullinks, src)
		soulowner = null
	if(soulsharer)
		LAZYREMOVE(soulsharer.sharedSoullinks, src)
		soulsharer = null
	return ..()

/datum/soullink/proc/removeSoulsharer(mob/living/sharer)
	if(soulsharer == sharer)
		soulsharer = null
		LAZYREMOVE(sharer.sharedSoullinks, src)

//Used to assign variables, called primarily by soullink()
//Override this to create more unique soullinks (Eg: 1->Many relationships)
//Return TRUE/FALSE to return the soullink/null in soullink()
/datum/soullink/proc/parseArgs(mob/living/owner, mob/living/sharer)
	if(!owner || !sharer)
		return FALSE
	soulowner = owner
	soulsharer = sharer
	LAZYADD(owner.ownedSoullinks, src)
	LAZYADD(sharer.sharedSoullinks, src)
	return TRUE

//Runs after /living death()
//Override this for content
/datum/soullink/proc/ownerDies(gibbed, mob/living/owner)

//Runs after /living death()
//Override this for content
/datum/soullink/proc/sharerDies(gibbed, mob/living/owner)

//Runs after /living update_revive()
//Override this for content
/datum/soullink/proc/ownerRevives(mob/living/owner)

//Runs after /living update_revive()
//Override this for content
/datum/soullink/proc/sharerRevives(mob/living/owner)

//Quick-use helper
/proc/soullink(typepath, ...)
	var/datum/soullink/S = new typepath()
	if(S.parseArgs(arglist(args.Copy(2, 0))))
		return S



/////////////////
// MULTISHARER //
/////////////////
//Abstract soullink for use with 1 Owner -> Many Sharer setups
/datum/soullink/multisharer
	var/list/soulsharers

/datum/soullink/multisharer/parseArgs(mob/living/owner, list/sharers)
	if(!owner || !LAZYLEN(sharers))
		return FALSE
	soulowner = owner
	soulsharers = sharers
	LAZYADD(owner.ownedSoullinks, src)
	for(var/l in sharers)
		var/mob/living/L = l
		LAZYADD(L.sharedSoullinks, src)
	return TRUE

/datum/soullink/multisharer/removeSoulsharer(mob/living/sharer)
	LAZYREMOVE(soulsharers, sharer)



/////////////////
// SHARED FATE //
/////////////////
//When the soulowner dies, the soulsharer dies, and vice versa
//This is intended for two players(or AI) and two mobs

/datum/soullink/sharedfate/ownerDies(gibbed, mob/living/owner)
	if(soulsharer)
		soulsharer.death(gibbed)

/datum/soullink/sharedfate/sharerDies(gibbed, mob/living/sharer)
	if(soulowner)
		soulowner.death(gibbed)

/////////////////
// Demon Bind  //
/////////////////
//When the soulowner dies, the soulsharer dies, but NOT vice versa
//This is intended for two players(or AI) and two mobs

/datum/soullink/oneway/ownerDies(gibbed, mob/living/owner)
	if(soulsharer)
		soulsharer.dust(FALSE)

/datum/soullink/oneway/devilfriend

/////////////////
// SHARED BODY //
/////////////////
//When the soulsharer dies, they're placed in the soulowner, who remains alive
//If the soulowner dies, the soulsharer is killed and placed into the soulowner (who is still dying)
//This one is intended for one player moving between many mobs

/datum/soullink/sharedbody/ownerDies(gibbed, mob/living/owner)
	if(soulowner && soulsharer)
		if(soulsharer.mind)
			soulsharer.mind.transfer_to(soulowner)
		soulsharer.death(gibbed)

/datum/soullink/sharedbody/sharerDies(gibbed, mob/living/sharer)
	if(soulowner && soulsharer && soulsharer.mind)
		soulsharer.mind.transfer_to(soulowner)



//////////////////////
// REPLACEMENT POOL //
//////////////////////
//When the owner dies, one of the sharers is placed in the owner's body, fully healed
//Sort of a "winner-stays-on" soullink
//Gibbing ends it immediately

/datum/soullink/multisharer/replacementpool/ownerDies(gibbed, mob/living/owner)
	if(LAZYLEN(soulsharers) && !gibbed) //let's not put them in some gibs
		var/list/souls = shuffle(soulsharers.Copy())
		for(var/l in souls)
			var/mob/living/L = l
			if(L.stat != DEAD && L.mind)
				L.mind.transfer_to(soulowner)
				soulowner.revive(TRUE, TRUE)
				L.death(FALSE)

//Lose your claim to the throne!
/datum/soullink/multisharer/replacementpool/sharerDies(gibbed, mob/living/sharer)
	removeSoulsharer(sharer)


////////////////
// SOUL HOOK //
////////////////
// When the owner transitions from dead to alive or vice versa,
// the linked atom is notified

// Atoms that actually utilize this system are responsible for handling the GC cleanup themselves
// Splashing the GC handling onto every atom would be a big old waste

/datum/soullink/soulhook
	var/atom/movable/otherend

/datum/soullink/soulhook/Destroy()
	if(otherend)
		LAZYREMOVE(otherend.sharedSoulhooks, src)
		otherend = null
	return ..()

/datum/soullink/soulhook/parseArgs(mob/living/owner, atom/movable/other)
	if(!owner || !other)
		return FALSE
	soulowner = owner
	otherend = other
	LAZYADD(owner.ownedSoullinks, src)
	LAZYADD(other.sharedSoulhooks, src)
	return TRUE

/datum/soullink/soulhook/ownerDies(gibbed, mob/living/owner)
	if(otherend)
		otherend.onSoullinkDeath(gibbed, owner)

/datum/soullink/soulhook/ownerRevives(mob/living/owner)
	if(otherend)
		otherend.onSoullinkRevive(owner)

// oops I'm butchering the application of this
/datum/soullink/soulhook/removeSoulsharer(atom/movable/other)
	if(otherend == other)
		otherend = null
		LAZYREMOVE(other.sharedSoulhooks, src)
	qdel(src) // not much point in a soul link with one end out of the picture for good

/atom/movable
	var/list/sharedSoulhooks = null

/atom/movable/proc/onSoullinkDeath(gibbed, mob/living/owner)

/atom/movable/proc/onSoullinkRevive(mob/living/owner)
