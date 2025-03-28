/// Turns :ai: into an emoji in text.
/proc/emoji_parse_old(text)
	if(!text)
		return text
	. = text
	var/static/list/emojis = icon_states(icon(EMOJI_SET))
	var/parsed = ""
	var/pos = 1
	var/search = 0
	var/emoji = ""
	while(TRUE)
		search = findtext(text, ":", pos)
		parsed += copytext(text, pos, search)
		if(search)
			pos = search
			search = findtext(text, ":", pos + length(text[pos]))
			if(search)
				emoji = lowertext(copytext(text, pos + length(text[pos]), search))
				var/datum/asset/spritesheet/sheet = get_asset_datum(/datum/asset/spritesheet/emoji)
				var/tag = sheet.icon_tag("emoji-[emoji]")
				if(tag)
					parsed += tag
					pos = search + length(text[pos])
				else
					parsed += copytext(text, pos, search)
					pos = search
				emoji = ""
				continue
			else
				parsed += copytext(text, pos, search)
		break
	return parsed


/// Turns :ai: into an emoji in text.
/proc/emoji_parse(text, list/emoji_found)
	if(!text)
		return text
	. = text
	var/static/list/emojis = icon_states(icon(EMOJI_SET))
	var/parsed = ""
	var/pos = 1
	var/search = 0
	var/emoji = ""
	while(TRUE)
		search = findtext(text, ":", pos)
		parsed += copytext(text, pos, search)
		if(search)
			pos = search
			search = findtext(text, ":", pos + length(text[pos]))
			if(search)
				// we found a candidate emoji tag, everything between pos and search should be checked as a tag
				emoji = lowertext(copytext(text, pos + length(text[pos]), search))
				var/datum/asset/spritesheet/sheet = get_asset_datum(/datum/asset/spritesheet/emoji)
				var/tag = sheet.icon_tag("emoji-[emoji]")
				if(tag)
					if(islist(emoji_found))
						emoji_found += emoji
					// emoji str here works for maptext
					// tag shou;d
					var/emoji_str = "<span class='chat-emoji'><img src='[EMOJI_SET]' icon='[EMOJI_SET]' iconstate='[emoji]'></span>"
					parsed += emoji_str + tag
					pos = search + length(text[pos])
				else
					parsed += copytext(text, pos, search)
					pos = search
				emoji = ""
				continue
			else
				parsed += copytext(text, pos, search)
		break
	return parsed


