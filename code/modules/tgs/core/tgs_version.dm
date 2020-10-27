/datum/tgs_version/New(raw_parameter)
	src.raw_parameter = raw_parameter
	deprefixed_parameter = replacetext(raw_parameter, "/tg/station 13 Server v", "")
	var/list/version_bits = splittext(deprefixed_parameter, ".")

	suite = text2num(version_bits[1])
	if(version_bits.len > 1)
		minor = text2num(version_bits[2])
		if(version_bits.len > 2)
			patch = text2num(version_bits[3])
			if(version_bits.len == 4)
				deprecated_patch = text2num(version_bits[4])

/datum/tgs_version/proc/Valid(allow_wildcards = FALSE)
	if(suite == null)
		return FALSE
	if(allow_wildcards)
		return TRUE
	return !Wildcard()

/datum/tgs_version/Wildcard()
	return minor == null || patch == null

/datum/tgs_version/Equals(datum/tgs_version/other_version)
	if(!istype(other_version))
		return FALSE

	return suite == other_version.suite && minor == other_version.minor && patch == other_version.patch && deprecated_patch == other_version.deprecated_patch
