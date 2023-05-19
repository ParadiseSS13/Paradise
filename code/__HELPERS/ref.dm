/**
 * \ref behaviour got changed in 512 so this is necesary to replicate old behaviour.
 * If it ever becomes necesary to get a more performant REF(), this lies here in wait
 * #define REF(thing) (thing && isdatum(thing) && (thing:datum_flags & DF_USE_TAG) && thing:tag ? "[thing:tag]" : text_ref(thing))
**/
/proc/REF(input) //TEMP TO GET THIS TO WORK
	if(isdatum(input))
		var/datum/thing = input
		if(thing.datum_flags & DF_USE_TAG)
			if(!thing.tag)
				stack_trace("A ref was requested of an object with DF_USE_TAG set but no tag: [thing]")
				thing.datum_flags &= ~DF_USE_TAG
			else
				return "\[[url_encode(thing.tag)]\]"
	return text_ref(input)
