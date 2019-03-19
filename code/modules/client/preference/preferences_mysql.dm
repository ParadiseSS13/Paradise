/datum/preferences/proc/load_preferences(client/C)

	var/DBQuery/query = dbcon.NewQuery({"SELECT
					ooccolor,
					UI_style,
					UI_style_color,
					UI_style_alpha,
					be_role,
					default_slot,
					toggles,
					sound,
					randomslot,
					volume,
					nanoui_fancy,
					show_ghostitem_attack,
					lastchangelog,
					windowflashing,
					ghost_anonsay,
					exp,
					clientfps,
					atklog
					FROM [format_table_name("player")]
					WHERE ckey='[C.ckey]'"}
					)

	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR during loading player preferences. Error : \[[err]\]\n")
		message_admins("SQL ERROR during loading player preferences. Error : \[[err]\]\n")
		return


	//general preferences
	while(query.NextRow())
		ooccolor = query.item[1]
		UI_style = query.item[2]
		UI_style_color = query.item[3]
		UI_style_alpha = text2num(query.item[4])
		be_special = params2list(query.item[5])
		default_slot = text2num(query.item[6])
		toggles = text2num(query.item[7])
		sound = text2num(query.item[8])
		randomslot = text2num(query.item[9])
		volume = text2num(query.item[10])
		nanoui_fancy = text2num(query.item[11])
		show_ghostitem_attack = text2num(query.item[12])
		lastchangelog = query.item[13]
		windowflashing = text2num(query.item[14])
		ghost_anonsay = text2num(query.item[15])
		exp = query.item[16]
		clientfps = text2num(query.item[17])
		atklog = text2num(query.item[18])

	//Sanitize
	ooccolor		= sanitize_hexcolor(ooccolor, initial(ooccolor))
	UI_style		= sanitize_inlist(UI_style, list("White", "Midnight"), initial(UI_style))
	default_slot	= sanitize_integer(default_slot, 1, max_save_slots, initial(default_slot))
	toggles			= sanitize_integer(toggles, 0, 524287, initial(toggles))
	sound			= sanitize_integer(sound, 0, 65535, initial(sound))
	UI_style_color	= sanitize_hexcolor(UI_style_color, initial(UI_style_color))
	UI_style_alpha	= sanitize_integer(UI_style_alpha, 0, 255, initial(UI_style_alpha))
	randomslot		= sanitize_integer(randomslot, 0, 1, initial(randomslot))
	volume			= sanitize_integer(volume, 0, 100, initial(volume))
	nanoui_fancy	= sanitize_integer(nanoui_fancy, 0, 1, initial(nanoui_fancy))
	show_ghostitem_attack = sanitize_integer(show_ghostitem_attack, 0, 1, initial(show_ghostitem_attack))
	lastchangelog	= sanitize_text(lastchangelog, initial(lastchangelog))
	windowflashing = sanitize_integer(windowflashing, 0, 1, initial(windowflashing))
	ghost_anonsay = sanitize_integer(ghost_anonsay, 0, 1, initial(ghost_anonsay))
	exp	= sanitize_text(exp, initial(exp))
	clientfps = sanitize_integer(clientfps, 0, 1000, initial(clientfps))
	atklog = sanitize_integer(atklog, 0, 100, initial(atklog))
	return 1

/datum/preferences/proc/save_preferences(client/C)

	// Might as well scrub out any malformed be_special list entries while we're here
	for(var/role in be_special)
		if(!(role in special_roles))
			log_runtime(EXCEPTION("[C.key] had a malformed role entry: '[role]'. Removing!"), src)
			be_special -= role

	var/DBQuery/query = dbcon.NewQuery({"UPDATE [format_table_name("player")]
				SET
					ooccolor='[ooccolor]',
					UI_style='[UI_style]',
					UI_style_color='[UI_style_color]',
					UI_style_alpha='[UI_style_alpha]',
					be_role='[sanitizeSQL(list2params(be_special))]',
					default_slot='[default_slot]',
					toggles='[toggles]',
					atklog='[atklog]',
					sound='[sound]',
					randomslot='[randomslot]',
					volume='[volume]',
					nanoui_fancy='[nanoui_fancy]',
					show_ghostitem_attack='[show_ghostitem_attack]',
					lastchangelog='[lastchangelog]',
					windowflashing='[windowflashing]',
					ghost_anonsay='[ghost_anonsay]',
					clientfps='[clientfps]',
					atklog='[atklog]'
					WHERE ckey='[C.ckey]'"}
					)

	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR during saving player preferences. Error : \[[err]\]\n")
		message_admins("SQL ERROR during saving player preferences. Error : \[[err]\]\n")
		return
	return 1

/datum/preferences/proc/load_character(client/C,slot)

	if(!slot)	slot = default_slot
	slot = sanitize_integer(slot, 1, max_save_slots, initial(default_slot))
	if(slot != default_slot)
		default_slot = slot
		var/DBQuery/firstquery = dbcon.NewQuery("UPDATE [format_table_name("player")] SET default_slot=[slot] WHERE ckey='[C.ckey]'")
		firstquery.Execute()

	// Let's not have this explode if you sneeze on the DB
	var/DBQuery/query = dbcon.NewQuery({"SELECT
					OOC_Notes,
					real_name,
					name_is_always_random,
					gender,
					age,
					species,
					language,
					hair_colour,
					secondary_hair_colour,
					facial_hair_colour,
					secondary_facial_hair_colour,
					skin_tone,
					skin_colour,
					marking_colours,
					head_accessory_colour,
					hair_style_name,
					facial_style_name,
					marking_styles,
					head_accessory_style_name,
					alt_head_name,
					eye_colour,
					underwear,
					undershirt,
					backbag,
					b_type,
					alternate_option,
					job_support_high,
					job_support_med,
					job_support_low,
					job_medsci_high,
					job_medsci_med,
					job_medsci_low,
					job_engsec_high,
					job_engsec_med,
					job_engsec_low,
					job_karma_high,
					job_karma_med,
					job_karma_low,
					flavor_text,
					med_record,
					sec_record,
					gen_record,
					disabilities,
					player_alt_titles,
					organ_data,
					rlimb_data,
					nanotrasen_relation,
					speciesprefs,
					socks,
					body_accessory,
					gear,
					autohiss
				 	FROM [format_table_name("characters")] WHERE ckey='[C.ckey]' AND slot='[slot]'"})
	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR during character slot loading. Error : \[[err]\]\n")
		message_admins("SQL ERROR during character slot loading. Error : \[[err]\]\n")
		return

	while(query.NextRow())
		//Character
		metadata = query.item[1]
		real_name = query.item[2]
		be_random_name = text2num(query.item[3])
		gender = query.item[4]
		age = text2num(query.item[5])
		species = query.item[6]
		language = query.item[7]

		h_colour = query.item[8]
		h_sec_colour = query.item[9]
		f_colour = query.item[10]
		f_sec_colour = query.item[11]
		s_tone = text2num(query.item[12])
		s_colour = query.item[13]
		m_colours = params2list(query.item[14])
		hacc_colour = query.item[15]
		h_style = query.item[16]
		f_style = query.item[17]
		m_styles = params2list(query.item[18])
		ha_style = query.item[19]
		alt_head = query.item[20]
		e_colour = query.item[21]
		underwear = query.item[22]
		undershirt = query.item[23]
		backbag = query.item[24]
		b_type = query.item[25]


		//Jobs
		alternate_option = text2num(query.item[26])
		job_support_high = text2num(query.item[27])
		job_support_med = text2num(query.item[28])
		job_support_low = text2num(query.item[29])
		job_medsci_high = text2num(query.item[30])
		job_medsci_med = text2num(query.item[31])
		job_medsci_low = text2num(query.item[32])
		job_engsec_high = text2num(query.item[33])
		job_engsec_med = text2num(query.item[34])
		job_engsec_low = text2num(query.item[35])
		job_karma_high = text2num(query.item[36])
		job_karma_med = text2num(query.item[37])
		job_karma_low = text2num(query.item[38])

		//Miscellaneous
		flavor_text = query.item[39]
		med_record = query.item[40]
		sec_record = query.item[41]
		gen_record = query.item[42]
		// Apparently, the preceding vars weren't always encoded properly...
		if(findtext(flavor_text, "<")) // ... so let's clumsily check for tags!
			flavor_text = html_encode(flavor_text)
		if(findtext(med_record, "<"))
			med_record = html_encode(med_record)
		if(findtext(sec_record, "<"))
			sec_record = html_encode(sec_record)
		if(findtext(gen_record, "<"))
			gen_record = html_encode(gen_record)
		disabilities = text2num(query.item[43])
		player_alt_titles = params2list(query.item[44])
		organ_data = params2list(query.item[45])
		rlimb_data = params2list(query.item[46])
		nanotrasen_relation = query.item[47]
		speciesprefs = text2num(query.item[48])

		//socks
		socks = query.item[49]
		body_accessory = query.item[50]
		gear = params2list(query.item[51])
		autohiss_mode = text2num(query.item[52])

	//Sanitize
	var/datum/species/SP = GLOB.all_species[species]
	metadata		= sanitize_text(metadata, initial(metadata))
	real_name		= reject_bad_name(real_name, 1)
	if(isnull(species)) species = "Human"
	if(isnull(language)) language = "None"
	if(isnull(nanotrasen_relation)) nanotrasen_relation = initial(nanotrasen_relation)
	if(isnull(speciesprefs)) speciesprefs = initial(speciesprefs)
	if(!real_name) real_name = random_name(gender,species)
	be_random_name	= sanitize_integer(be_random_name, 0, 1, initial(be_random_name))
	gender			= sanitize_gender(gender, FALSE, !SP.has_gender)
	age				= sanitize_integer(age, AGE_MIN, AGE_MAX, initial(age))
	h_colour		= sanitize_hexcolor(h_colour)
	h_sec_colour	= sanitize_hexcolor(h_sec_colour)
	f_colour		= sanitize_hexcolor(f_colour)
	f_sec_colour	= sanitize_hexcolor(f_sec_colour)
	s_tone			= sanitize_integer(s_tone, -185, 34, initial(s_tone))
	s_colour		= sanitize_hexcolor(s_colour)
	for(var/marking_location in m_colours)
		m_colours[marking_location] = sanitize_hexcolor(m_colours[marking_location], DEFAULT_MARKING_COLOURS[marking_location])
	hacc_colour		= sanitize_hexcolor(hacc_colour)
	h_style			= sanitize_inlist(h_style, GLOB.hair_styles_public_list, initial(h_style))
	f_style			= sanitize_inlist(f_style, GLOB.facial_hair_styles_list, initial(f_style))
	for(var/marking_location in m_styles)
		m_styles[marking_location] = sanitize_inlist(m_styles[marking_location], GLOB.marking_styles_list, DEFAULT_MARKING_STYLES[marking_location])
	ha_style		= sanitize_inlist(ha_style, GLOB.head_accessory_styles_list, initial(ha_style))
	alt_head		= sanitize_inlist(alt_head, GLOB.alt_heads_list, initial(alt_head))
	e_colour		= sanitize_hexcolor(e_colour)
	underwear		= sanitize_text(underwear, initial(underwear))
	undershirt		= sanitize_text(undershirt, initial(undershirt))
	backbag			= sanitize_text(backbag, initial(backbag))
	b_type			= sanitize_text(b_type, initial(b_type))
	autohiss_mode	= sanitize_integer(autohiss_mode, 0, 2, initial(autohiss_mode))

	alternate_option = sanitize_integer(alternate_option, 0, 2, initial(alternate_option))
	job_support_high = sanitize_integer(job_support_high, 0, 65535, initial(job_support_high))
	job_support_med = sanitize_integer(job_support_med, 0, 65535, initial(job_support_med))
	job_support_low = sanitize_integer(job_support_low, 0, 65535, initial(job_support_low))
	job_medsci_high = sanitize_integer(job_medsci_high, 0, 65535, initial(job_medsci_high))
	job_medsci_med = sanitize_integer(job_medsci_med, 0, 65535, initial(job_medsci_med))
	job_medsci_low = sanitize_integer(job_medsci_low, 0, 65535, initial(job_medsci_low))
	job_engsec_high = sanitize_integer(job_engsec_high, 0, 65535, initial(job_engsec_high))
	job_engsec_med = sanitize_integer(job_engsec_med, 0, 65535, initial(job_engsec_med))
	job_engsec_low = sanitize_integer(job_engsec_low, 0, 65535, initial(job_engsec_low))
	job_karma_high = sanitize_integer(job_karma_high, 0, 65535, initial(job_karma_high))
	job_karma_med = sanitize_integer(job_karma_med, 0, 65535, initial(job_karma_med))
	job_karma_low = sanitize_integer(job_karma_low, 0, 65535, initial(job_karma_low))
	disabilities = sanitize_integer(disabilities, 0, 65535, initial(disabilities))

	socks			= sanitize_text(socks, initial(socks))
	body_accessory	= sanitize_text(body_accessory, initial(body_accessory))

//	if(isnull(disabilities)) disabilities = 0
	if(!player_alt_titles) player_alt_titles = new()
	if(!organ_data) src.organ_data = list()
	if(!rlimb_data) src.rlimb_data = list()
	if(!gear) gear = list()

	return 1

/datum/preferences/proc/save_character(client/C)
	var/organlist
	var/rlimblist
	var/playertitlelist
	var/gearlist

	var/markingcolourslist = list2params(m_colours)
	var/markingstyleslist = list2params(m_styles)
	if(!isemptylist(organ_data))
		organlist = list2params(organ_data)
	if(!isemptylist(rlimb_data))
		rlimblist = list2params(rlimb_data)
	if(!isemptylist(player_alt_titles))
		playertitlelist = list2params(player_alt_titles)
	if(!isemptylist(gear))
		gearlist = list2params(gear)

	var/DBQuery/firstquery = dbcon.NewQuery("SELECT slot FROM [format_table_name("characters")] WHERE ckey='[C.ckey]' ORDER BY slot")
	firstquery.Execute()
	while(firstquery.NextRow())
		if(text2num(firstquery.item[1]) == default_slot)
			var/DBQuery/query = dbcon.NewQuery({"UPDATE [format_table_name("characters")] SET OOC_Notes='[sanitizeSQL(metadata)]',
												real_name='[sanitizeSQL(real_name)]',
												name_is_always_random='[be_random_name]',
												gender='[gender]',
												age='[age]',
												species='[sanitizeSQL(species)]',
												language='[sanitizeSQL(language)]',
												hair_colour='[h_colour]',
												secondary_hair_colour='[h_sec_colour]',
												facial_hair_colour='[f_colour]',
												secondary_facial_hair_colour='[f_sec_colour]',
												skin_tone='[s_tone]',
												skin_colour='[s_colour]',
												marking_colours='[sanitizeSQL(markingcolourslist)]',
												head_accessory_colour='[hacc_colour]',
												hair_style_name='[sanitizeSQL(h_style)]',
												facial_style_name='[sanitizeSQL(f_style)]',
												marking_styles='[sanitizeSQL(markingstyleslist)]',
												head_accessory_style_name='[sanitizeSQL(ha_style)]',
												alt_head_name='[sanitizeSQL(alt_head)]',
												eye_colour='[e_colour]',
												underwear='[underwear]',
												undershirt='[undershirt]',
												backbag='[backbag]',
												b_type='[b_type]',
												alternate_option='[alternate_option]',
												job_support_high='[job_support_high]',
												job_support_med='[job_support_med]',
												job_support_low='[job_support_low]',
												job_medsci_high='[job_medsci_high]',
												job_medsci_med='[job_medsci_med]',
												job_medsci_low='[job_medsci_low]',
												job_engsec_high='[job_engsec_high]',
												job_engsec_med='[job_engsec_med]',
												job_engsec_low='[job_engsec_low]',
												job_karma_high='[job_karma_high]',
												job_karma_med='[job_karma_med]',
												job_karma_low='[job_karma_low]',
												flavor_text='[sanitizeSQL(flavor_text)]',
												med_record='[sanitizeSQL(med_record)]',
												sec_record='[sanitizeSQL(sec_record)]',
												gen_record='[sanitizeSQL(gen_record)]',
												player_alt_titles='[playertitlelist]',
												disabilities='[disabilities]',
												organ_data='[organlist]',
												rlimb_data='[rlimblist]',
												nanotrasen_relation='[nanotrasen_relation]',
												speciesprefs='[speciesprefs]',
												socks='[socks]',
												body_accessory='[body_accessory]',
												gear='[gearlist]',
												autohiss='[autohiss_mode]'
												WHERE ckey='[C.ckey]'
												AND slot='[default_slot]'"}
												)

			if(!query.Execute())
				var/err = query.ErrorMsg()
				log_game("SQL ERROR during character slot saving. Error : \[[err]\]\n")
				message_admins("SQL ERROR during character slot saving. Error : \[[err]\]\n")
				return
			return 1

	var/DBQuery/query = dbcon.NewQuery({"
					INSERT INTO [format_table_name("characters")] (ckey, slot, OOC_Notes, real_name, name_is_always_random, gender,
											age, species, language,
											hair_colour, secondary_hair_colour,
											facial_hair_colour, secondary_facial_hair_colour,
											skin_tone, skin_colour,
											marking_colours,
											head_accessory_colour,
											hair_style_name,
											facial_style_name,
											marking_styles,
											head_accessory_style_name,
											alt_head_name,
											eye_colour,
											underwear, undershirt,
											backbag, b_type, alternate_option,
											job_support_high, job_support_med, job_support_low,
											job_medsci_high, job_medsci_med, job_medsci_low,
											job_engsec_high, job_engsec_med, job_engsec_low,
											job_karma_high, job_karma_med, job_karma_low,
											flavor_text,
											med_record,
											sec_record,
											gen_record,
											player_alt_titles,
											disabilities, organ_data, rlimb_data, nanotrasen_relation, speciesprefs,
											socks, body_accessory, gear, autohiss)

					VALUES
											('[C.ckey]', '[default_slot]', '[sanitizeSQL(metadata)]', '[sanitizeSQL(real_name)]', '[be_random_name]','[gender]',
											'[age]', '[sanitizeSQL(species)]', '[sanitizeSQL(language)]',
											'[h_colour]', '[h_sec_colour]',
											'[f_colour]', '[f_sec_colour]',
											'[s_tone]', '[s_colour]',
											'[sanitizeSQL(markingcolourslist)]',
											'[hacc_colour]',
											'[sanitizeSQL(h_style)]',
											'[sanitizeSQL(f_style)]',
											'[sanitizeSQL(markingstyleslist)]',
											'[sanitizeSQL(ha_style)]',
											'[sanitizeSQL(alt_head)]',
											'[e_colour]',
											'[underwear]', '[undershirt]',
											'[backbag]', '[b_type]', '[alternate_option]',
											'[job_support_high]', '[job_support_med]', '[job_support_low]',
											'[job_medsci_high]', '[job_medsci_med]', '[job_medsci_low]',
											'[job_engsec_high]', '[job_engsec_med]', '[job_engsec_low]',
											'[job_karma_high]', '[job_karma_med]', '[job_karma_low]',
											'[sanitizeSQL(flavor_text)]',
											'[sanitizeSQL(med_record)]',
											'[sanitizeSQL(sec_record)]',
											'[sanitizeSQL(gen_record)]',
											'[playertitlelist]',
											'[disabilities]', '[organlist]', '[rlimblist]', '[nanotrasen_relation]', '[speciesprefs]',
											'[socks]', '[body_accessory]', '[gearlist]', '[autohiss_mode]')

"}
)

	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR during character slot saving. Error : \[[err]\]\n")
		message_admins("SQL ERROR during character slot saving. Error : \[[err]\]\n")
		return
	return 1

/datum/preferences/proc/load_random_character_slot(client/C)
	var/DBQuery/query = dbcon.NewQuery("SELECT slot FROM [format_table_name("characters")] WHERE ckey='[C.ckey]' ORDER BY slot")
	var/list/saves = list()

	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR during random character slot picking. Error : \[[err]\]\n")
		message_admins("SQL ERROR during random character slot picking. Error : \[[err]\]\n")
		return

	while(query.NextRow())
		saves += text2num(query.item[1])

	if(!saves.len)
		load_character(C)
		return 0
	load_character(C,pick(saves))
	return 1

/datum/preferences/proc/SetChangelog(client/C,hash)
	lastchangelog=hash
	if(preferences_datums[C.ckey].toggles & UI_DARKMODE)
		winset(C, "rpane.changelog", "background-color=#40628a;font-color=#ffffff;font-style=none")
	else
		winset(C, "rpane.changelog", "background-color=none;font-style=none")
	var/DBQuery/query = dbcon.NewQuery("UPDATE [format_table_name("player")] SET lastchangelog='[lastchangelog]' WHERE ckey='[C.ckey]'")
	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR during lastchangelog updating. Error : \[[err]\]\n")
		message_admins("SQL ERROR during lastchangelog updating. Error : \[[err]\]\n")
		to_chat(C, "Couldn't update your last seen changelog, please try again later.")
		return
	return 1
