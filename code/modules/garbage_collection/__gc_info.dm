/*

===============================================================================
                         How Garbage Collection Works                          
===============================================================================

In BYOND, there are exactly two ways anything gets deleted:

- A "soft delete", which occurs when an object's reference count hits 0, meaning it is not being referenced by anything
  in the world (more on references further down). When an object is unreferenced, nothing can access it, so it has no
  reason to exist, and BYOND's garbage collector simply deletes the object. This is fast.

- A "hard delete", which occurs when the del keyword is used to directly delete an object. This forces BYOND to find
  every reference to the object being deleted, and null them all out. This is slow.

A reference is anything that refers to an object, and can thus be used to access it. A variable on another object, a
variable in a proc, an argument to a proc, the src of a running proc, the locs of contained objects, another object's
contents list (but not the world's automatic contents list), anything. BYOND keeps track of how many references there
are to an object - the reference count goes up when you make a new reference to an object, and back down when that
reference gets set to null, goes out of scope, or is deleted. When the reference count hits 0, there are no remaining
references to the object, and it is deleted by BYOND's garbage collector.

When you have something that exists in the world, and you want it to stop existing (maybe it got blown up, or eaten by
the singularity, or whatever), it needs to be deleted. You can use the del keyword to make sure it's deleted instantly,
but del is slow, and you want things to be deleted as quickly as possible, especially if you're deleting a whole lot of
them. You want soft deletes.

That's where the garbage collection system comes in - it prepares things to be soft deleted, and hard deletes anything
that can't be. There are two main procs involved in this process:

/proc/qdel(datumToDelete)
  This is, effectively, a replacement for del that tells an object to prepare itself to be soft deleted by calling its
  Destroy() proc. Depending on the qdel hint returned by Destroy(), qdel will queue the object in the garbage collector
  (to be hard deleted if it isn't soft deleted), directly delete the object, pool the object, or ignore the object and
  assume it will handle deleting itself. An object passed into qdel will have its gcDestroyed var set, so 
  isnull(gcDestroyed) will be true if an object is not being destroyed, and false if it is (which means you should get
  rid of the reference you have to it).

  Note that qdel can only work with datum-based objects, which excludes the world (deleting this shuts down the world),
  clients (deleting these disconnect the client), lists, and savefiles. If any of these are passed to qdel, they will
  be directly deleted, just as if they had been passed straight to del, so it should never be unsafe to qdel anything
  you could del.

/datum/proc/Destroy()
  This is, effectively, a replacement for Del() (with some exceptions) which is also responsible for nulling out
  references to or on the object it is called on. Unlike Del, the Destroy proc will only be called by qdel; generally,
  this should only happen to datums that are no longer referenced by anything, which shouldn't be an issue.

  The exceptions where Destroy cannot replace Del are for the same non-datum types mentioned under qdel, above. Those
  should use a Del proc for any necessary cleanup, as a Destroy proc on them will not automatically get called.

  When called by qdel, Destroy is expected to return a qdel hint, which determines whether the object should be directly
  deleted, queued for deletion, pooled, or ignored entirely; which of these are appropriate will vary, though objects
  should be pooled or queued whenever possible. The full list of qdel hints are in the code for the qdel proc.

As mentioned above, gcDestroyed can be used to tell whether an object is being destroyed. This is important, because if
an object is being destroyed, it WILL still exist, and any code that references it should stop referencing it as soon as
possible. In the same places that you check whether a reference still exists, you should also check for something like
isnull(myRefVar.gcDestroyed), which will be false if your object is being destroyed, meaning you should throw out the
reference immediately.

The inner workings of the GC itself and the stuff related to testing it probably don't need a detailed description - if
you intend to work with them, it would be best to read the code to understand what they do.

Pooling is related to GC, in that it's meant to reduce deletion overhead, but it does so by re-using objects instead of
deleting them at all. Explaining pooling is outside the scope of this file.

*/