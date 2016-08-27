// Main garbage collection code

// For general information about how the GC works and how to use it, see __gc_info.dm

#define GC_COLLECTIONS_PER_TICK 150 // Was 100.
#define GC_COLLECTION_TIMEOUT (30 SECONDS)
#define GC_FORCE_DEL_PER_TICK 30
//#define GC_DEBUG

// A list of types that were queued in the GC, and had to be soft deleted; used in testing
var/list/gc_hard_del_types = list()
var/global/datum/controller/process/garbage_collector/garbageCollector

// The time a datum was destroyed by the GC, or null if it hasn't been
/datum/var/gcDestroyed
// Whether a datum was hard-deleted by the GC; 0 if not, 1 if it was queued, -1 if directly deleted
/datum/var/hard_deleted = 0

/datum/controller/process/garbage_collector
	var/list/queue = new
	var/del_everything = 0

	// To let them know how hardworking am I :^).
	var/dels_count = 0
	var/hard_dels = 0
	var/soft_dels = 0

/datum/controller/process/garbage_collector/proc/addTrash(var/datum/D)
	if(!istype(D) || del_everything)
		del(D)
		hard_dels++
		dels_count++
		return

	queue -= "\ref[D]" // If this is a re-used ref, remove the old ref from the queue
	queue["\ref[D]"] = world.time

/datum/controller/process/garbage_collector/proc/processGarbage()
	var/remainingCollectionPerTick = GC_COLLECTIONS_PER_TICK
	var/remainingForceDelPerTick = GC_FORCE_DEL_PER_TICK
	var/collectionTimeScope = world.time - GC_COLLECTION_TIMEOUT
	while(queue.len && --remainingCollectionPerTick >= 0)
		var/refID = queue[1]
		var/destroyedAtTime = queue[refID]

		if(destroyedAtTime > collectionTimeScope)
			break

		var/datum/D = locate(refID)
		// If the object still exists, and it's the same object, hard del it
		if(D && D.gcDestroyed == destroyedAtTime)
			if(remainingForceDelPerTick <= 0)
				break

			#ifdef GC_DEBUG
			gcwarning("GC process force delete [D.type]")
			#endif

			hardDel(D)
			queue.Cut(1, 2)

			remainingForceDelPerTick--
		else // Otherwise, it was GC'd - remove it from the queue
			queue.Cut(1, 2)
			soft_dels++
			dels_count++
		SCHECK

#ifdef GC_DEBUG
#undef GC_DEBUG
#endif

#undef GC_FORCE_DEL_PER_TICK
#undef GC_COLLECTION_TIMEOUT
#undef GC_COLLECTIONS_PER_TICK

/datum/controller/process/garbage_collector/proc/hardDel(var/datum/D)
	gc_hard_del_types |= D.type
	D.hard_deleted = 1
	if(!D.gcDestroyed)
		spawn(-1)
			D.Destroy()
		D.gcDestroyed = world.time
	del(D)
	hard_dels++
	dels_count++

// Effectively replaces del for any datum-based type
/proc/qdel(var/datum/D)
	if(isnull(D))
		return

	if(!istype(D)) // A non-datum was passed into qdel - just delete it outright.
		// warning("qdel() passed object of type [D.type]. qdel() can only handle /datum/ types.")
		del(D)
		return

	if(isnull(garbageCollector))
		D.Destroy()
		del(D)
		return

	if(isnull(D.gcDestroyed))
		// Let our friend know they're about to get fucked up.
		var/hint
		D.gcDestroyed = world.time
		try
			hint = D.Destroy()
		catch(var/exception/e)
			if(istype(e))
				log_runtime(e, D, "Caught by qdel() destroying [D.type]")
			else
				gcwarning("qdel() caught runtime destroying [D.type]: [e]")
			// Destroy runtimed? Panic! Hard delete!
			D.hard_deleted = -1
			del(D)
			if(garbageCollector)
				garbageCollector.dels_count++
			return
		if(!isnull(D.gcDestroyed) && D.gcDestroyed != world.time)
			gcwarning("Sleep detected in Destroy() call of [D.type]")
			D.gcDestroyed = world.time

		switch(hint)
			if(QDEL_HINT_QUEUE)     //qdel should queue the object for deletion
				garbageCollector.addTrash(D)
			if(QDEL_HINT_LETMELIVE)   //qdel should let the object live after calling destroy.
				return
			if(QDEL_HINT_IWILLGC)   //functionally the same as the above. qdel should assume the object will gc on its own, and not check it.
				return
			if(QDEL_HINT_HARDDEL_NOW)  //qdel should assume this object won't gc, and hard del it post haste.
				D.hard_deleted = -1 // -1 means "this hard del skipped the queue", used for profiling
				del(D)
				if(garbageCollector)
					garbageCollector.dels_count++
			if(QDEL_HINT_PUTINPOOL)  //qdel will put this object in the pool.
				PlaceInPool(D,0)
			if(QDEL_HINT_FINDREFERENCE)//qdel will, if TESTING is enabled, display all references to this object, then queue the object for deletion.
				#ifdef TESTING
				D.find_references(remove_from_queue = FALSE)
				#endif
				garbageCollector.addTrash(D)
			else
//				to_chat(world, "WARNING GC DID NOT GET A RETURN VALUE FOR [D], [D.type]!")
				garbageCollector.addTrash(D)


// Returns 1 if the object has been queued for deletion.
/proc/qdeleted(var/datum/D)
	if(!istype(D))
		return 0
	if(!isnull(D.gcDestroyed))
		return 1
	return 0

/*
 * Like Del(), but for qdel.
 * Called BEFORE qdel moves shit.
 */
/datum/proc/Destroy()
	tag = null
	return QDEL_HINT_QUEUE // Garbage Collect everything.

/proc/gcwarning(msg)
	log_to_dd("## GC WARNING: [msg]")
	log_runtime(EXCEPTION(msg))
