/**
 * When attached to something, will make that thing shatter into shards on throw impact or z level falling
 */
/datum/element/shatters_when_thrown
	element_flags = ELEMENT_BESPOKE

	/// What type of item is spawned as a 'shard' once the shattering happens
	var/obj/item/shard_type
	/// How many shards total are made when the thing we're attached to shatters
	var/number_of_shards
	/// What sound plays when the thing we're attached to shatters
	var/shattering_sound

/datum/element/shatters_when_thrown/Attach(datum/target, shard_type = /obj/item/shard, number_of_shards = 5, shattering_sound = "shatter")
	. = ..()

	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE

	src.shard_type = shard_type
	src.number_of_shards = number_of_shards
	src.shattering_sound = shattering_sound

	RegisterSignal(target, COMSIG_MOVABLE_IMPACT, PROC_REF(on_throw_impact))

/datum/element/shatters_when_thrown/Detach(datum/target)
	. = ..()

	UnregisterSignal(target,COMSIG_MOVABLE_IMPACT)

/// Tells the parent to shatter if we are thrown and impact something
/datum/element/shatters_when_thrown/proc/on_throw_impact(datum/source, atom/hit_atom)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(shatter), source, hit_atom)

/// Handles the actual shattering part, throwing shards of whatever is defined on the component everywhere
/datum/element/shatters_when_thrown/proc/shatter(atom/movable/source, atom/hit_atom)
	var/generator/scatter_gen = generator(GEN_CIRCLE, 0, 48, NORMAL_RAND)
	var/scatter_turf = get_turf(hit_atom)

	for(var/obj/item/scattered_item as anything in source.contents)
		scattered_item.forceMove(scatter_turf)
		var/list/scatter_vector = scatter_gen.Rand()
		scattered_item.pixel_x = scatter_vector[1]
		scattered_item.pixel_y = scatter_vector[2]

	for(var/iteration in 1 to number_of_shards)
		var/obj/item/shard = new shard_type(scatter_turf)
		shard.pixel_x = rand(-6, 6)
		shard.pixel_y = rand(-6, 6)
	playsound(scatter_turf, shattering_sound, 60, TRUE)
	if(isobj(source))
		var/obj/obj_source = source
		obj_source.deconstruct(FALSE)
		return
	qdel(source)
