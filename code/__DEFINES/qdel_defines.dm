//defines that give qdel hints. these can be given as a return in destory() or by calling


#define QDEL_HINT_QUEUE 		0 //qdel should queue the object for deletion.
#define QDEL_HINT_LETMELIVE		1 //qdel should let the object live after calling destory.
#define QDEL_HINT_IWILLGC		2 //functionally the same as the above. qdel should assume the object will gc on its own, and not check it.
#define QDEL_HINT_HARDDEL		3 //qdel should assume this object won't gc, and queue a hard delete using a hard reference.
#define QDEL_HINT_HARDDEL_NOW	4 //qdel should assume this object won't gc, and hard del it post haste.
#define QDEL_HINT_FINDREFERENCE	5 //functionally identical to QDEL_HINT_QUEUE if TESTING is not enabled in _compiler_options.dm.
								//if TESTING is enabled, qdel will call this object's find_references() verb.
#define QDEL_HINT_IFFAIL_FINDREFERENCE 6		//Above but only if gc fails.
//defines for the gc_destroyed var

// Defines for the ssgarbage queues
#define GC_QUEUE_FILTER 1 //! short queue to filter out quick gc successes so they don't hang around in the main queue for 5 minutes
#define GC_QUEUE_CHECK 2 //! main queue that waits 5 minutes because thats the longest byond can hold a reference to our shit.
#define GC_QUEUE_HARDDELETE 3 //! short queue for things that hard delete instead of going thru the gc subsystem, this is purely so if they *can* softdelete, they will soft delete rather then wasting time with a hard delete.
#define GC_QUEUE_COUNT 3 //! Number of queues, used for allocating the nested lists. Don't forget to increase this if you add a new queue stage


// Defines for the ssgarbage queue items
#define GC_QUEUE_ITEM_QUEUE_TIME 1 //! Time this item entered the queue
#define GC_QUEUE_ITEM_REF 2 //! Ref to the item
#define GC_QUEUE_ITEM_GCD_DESTROYED 3 //! Item's gc_destroyed var value. Used to detect ref reuse.
#define GC_QUEUE_ITEM_INDEX_COUNT 3 //! Number of item indexes, used for allocating the nested lists. Don't forget to increase this if you add a new queue item index

// Defines for the time an item has to get its reference cleaned before it fails the queue and moves to the next.
#define GC_FILTER_QUEUE (1 SECONDS)
#define GC_CHECK_QUEUE (5 MINUTES)
#define GC_DEL_QUEUE (10 SECONDS)

// Defines for the [gc_destroyed][/datum/var/gc_destroyed] var.
#define GC_CURRENTLY_BEING_QDELETED -2

#define QDELING(X) (X.gc_destroyed)
#define QDELETED(X) (!X || QDELING(X))
#define QDESTROYING(X) (!X || X.gc_destroyed == GC_CURRENTLY_BEING_QDELETED)
