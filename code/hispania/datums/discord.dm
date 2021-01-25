/datum/discord_embed/new_round_embed
	//var/embed_title
	//var/embed_content
	//var/embed_colour

/datum/discord_embed/new_round_embed/serialize2list()
	var/list/json = list()
	// All these fields can be nulled so presence check them all
	if(embed_title)
		json["title"] = embed_title
	if(embed_content)
		json["description"] = embed_content
	if(embed_colour)
		json["color"] = hex2num(embed_colour)
	json["timestamp"] = embed_timestamp

	// Now serialize the fields
	if(length(fields))
		json["fields"] = list()
		for(var/f in fields)
			var/datum/discord_embed_field/field = f
			json["fields"] += list(field.serialize2list())

	var/datum/discord_embed_newround_author/a = new // whip whip
	json["author"] = a.serialize2list() // and nae nae

	var/datum/discord_embed_newround_thumbnail/t = new // whip whip
	json["thumbnail"] = t.serialize2list() // and nae nae

	return json

// AUTHOR DEL EMBED

/datum/discord_embed_newround_author
	var/author_name = "SPACE STATION 13"

/datum/discord_embed_newround_author/proc/serialize2list()
	// name and content CANNOT be nulled, so assert them
	ASSERT(author_name)
	// Now serialize
	var/list/json = list()
	json["name"] = author_name

	return json

// IMAGEN DEL EMBED

/datum/discord_embed_newround_thumbnail
	var/embed_url = "https://cdn.discordapp.com/attachments/626176190721556481/726555014423904337/logo.png"

/datum/discord_embed_newround_thumbnail/proc/serialize2list()
	// name and content CANNOT be nulled, so assert them
	ASSERT(embed_url)
	// Now serialize
	var/list/json = list()
	json["url"] = embed_url

	return json
