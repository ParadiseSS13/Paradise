/*	This code is responsible for the examine tab.  When someone examines something, it copies the examined object's description_info,
	description_fluff, and description_antag, and shows it in a new tab.

	In this file, some atom and mob stuff is defined here.  It is defined here instead of in the normal files, to keep the whole system self-contained.
	This means that this file can be unchecked, along with the other examine files, and can be removed entirely with no effort.
*/


/atom/
	var/description_info = null //Helpful blue text.
	var/description_fluff = null //Green text about the atom's fluff, if any exists.
	var/description_antag = null //Malicious red text, for the antags.

//Override these if you need special behaviour for a specific type.
/atom/proc/get_description_info()
	if(description_info)
		return description_info
	return

/atom/proc/get_description_fluff()
	if(description_fluff)
		return description_fluff
	return

/atom/proc/get_description_antag()
	if(description_antag)
		return description_antag
	return

