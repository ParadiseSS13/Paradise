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
					lastchangelog
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

	//Sanitize
	ooccolor		= sanitize_hexcolor(ooccolor, initial(ooccolor))
	UI_style		= sanitize_inlist(UI_style, list("White", "Midnight"), initial(UI_style))
	default_slot	= sanitize_integer(default_slot, 1, max_save_slots, initial(default_slot))
	toggles			= sanitize_integer(toggles, 0, 65535, initial(toggles))
	sound			= sanitize_integer(sound, 0, 65535, initial(sound))
	UI_style_color	= sanitize_hexcolor(UI_style_color, initial(UI_style_color))
	UI_style_alpha	= sanitize_integer(UI_style_alpha, 0, 255, initial(UI_style_alpha))
	randomslot		= sanitize_integer(randomslot, 0, 1, initial(randomslot))
	volume			= sanitize_integer(volume, 0, 100, initial(volume))
	nanoui_fancy	= sanitize_integer(nanoui_fancy, 0, 1, initial(nanoui_fancy))
	show_ghostitem_attack = sanitize_integer(show_ghostitem_attack, 0, 1, initial(show_ghostitem_attack))
	lastchangelog	= sanitize_text(lastchangelog, initial(lastchangelog))
	return 1

/datum/preferences/proc/save_preferences(client/C)

	// Might as well scrub out any malformed be_special list entries while we're here
	for (var/role in be_special)
		if(!(role in special_roles))
			log_to_dd("[C.key] had a malformed role entry: '[role]'. Removing!")
			be_special -= role

	var/DBQuery/query = dbcon.NewQuery({"UPDATE [format_table_name("player")]
				SET
					ooccolor='[ooccolor]',
					UI_style='[UI_style]',
					UI_style_color='[UI_style_color]',
					UI_style_alpha='[UI_style_alpha]',
					be_role='[list2params(sql_sanitize_text_list(be_special))]',
					default_slot='[default_slot]',
					toggles='[toggles]',
					sound='[sound]',
					randomslot='[randomslot]',
					volume='[volume]',
					nanoui_fancy='[nanoui_fancy]',
					show_ghostitem_attack='[show_ghostitem_attack]',
					lastchangelog='[lastchangelog]'
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
					hair_red,
					hair_green,
					hair_blue,
					facial_red,
					facial_green,
					facial_blue,
					skin_tone,
					skin_red,
					skin_green,
					skin_blue,
					markings_red,
					markings_green,
					markings_blue,
					head_accessory_red,
					head_accessory_green,
					head_accessory_blue,
					hair_style_name,
					facial_style_name,
					marking_style_name,
					head_accessory_style_name,
					eyes_red,
					eyes_green,
					eyes_blue,
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
					body_accessory
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

		//colors to be consolidated into hex strings (requires some work with dna code)
		r_hair = text2num(query.item[8])
		g_hair = text2num(query.item[9])
		b_hair = text2num(query.item[10])
		r_facial = text2num(query.item[11])
		g_facial = text2num(query.item[12])
		b_facial = text2num(query.item[13])
		s_tone = text2num(query.item[14])
		r_skin = text2num(query.item[15])
		g_skin = text2num(query.item[16])
		b_skin = text2num(query.item[17])
		r_markings = text2num(query.item[18])
		g_markings = text2num(query.item[19])
		b_markings = text2num(query.item[20])
		r_headacc = text2num(query.item[21])
		g_headacc = text2num(query.item[22])
		b_headacc = text2num(query.item[23])
		h_style = query.item[24]
		f_style = query.item[25]
		m_style = query.item[26]
		ha_style = query.item[27]
		r_eyes = text2num(query.item[28])
		g_eyes = text2num(query.item[29])
		b_eyes = text2num(query.item[30])
		underwear = query.item[31]
		undershirt = query.item[32]
		backbag = text2num(query.item[33])
		b_type = query.item[34]


		//Jobs
		alternate_option = text2num(query.item[35])
		job_support_high = text2num(query.item[36])
		job_support_med = text2num(query.item[37])
		job_support_low = text2num(query.item[38])
		job_medsci_high = text2num(query.item[39])
		job_medsci_med = text2num(query.item[40])
		job_medsci_low = text2num(query.item[41])
		job_engsec_high = text2num(query.item[42])
		job_engsec_med = text2num(query.item[43])
		job_engsec_low = text2num(query.item[44])
		job_karma_high = text2num(query.item[45])
		job_karma_med = text2num(query.item[46])
		job_karma_low = text2num(query.item[47])

		//Miscellaneous
		flavor_text = query.item[48]
		med_record = query.item[49]
		sec_record = query.item[50]
		gen_record = query.item[51]
		disabilities = text2num(query.item[52])
		player_alt_titles = params2list(query.item[53])
		organ_data = params2list(query.item[54])
		rlimb_data = params2list(query.item[55])
		nanotrasen_relation = query.item[56]
		speciesprefs = text2num(query.item[57])

		//socks
		socks = query.item[58]
		body_accessory = query.item[59]

	//Sanitize
	metadata		= sanitize_text(metadata, initial(metadata))
	real_name		= reject_bad_name(real_name)
	if(isnull(species)) species = "Human"
	if(isnull(language)) language = "None"
	if(isnull(nanotrasen_relation)) nanotrasen_relation = initial(nanotrasen_relation)
	if(isnull(speciesprefs)) speciesprefs = initial(speciesprefs)
	if(!real_name) real_name = random_name(gender,species)
	be_random_name	= sanitize_integer(be_random_name, 0, 1, initial(be_random_name))
	gender			= sanitize_gender(gender)
	age				= sanitize_integer(age, AGE_MIN, AGE_MAX, initial(age))
	r_hair			= sanitize_integer(r_hair, 0, 255, initial(r_hair))
	g_hair			= sanitize_integer(g_hair, 0, 255, initial(g_hair))
	b_hair			= sanitize_integer(b_hair, 0, 255, initial(b_hair))
	r_facial		= sanitize_integer(r_facial, 0, 255, initial(r_facial))
	g_facial		= sanitize_integer(g_facial, 0, 255, initial(g_facial))
	b_facial		= sanitize_integer(b_facial, 0, 255, initial(b_facial))
	s_tone			= sanitize_integer(s_tone, -185, 34, initial(s_tone))
	r_skin			= sanitize_integer(r_skin, 0, 255, initial(r_skin))
	g_skin			= sanitize_integer(g_skin, 0, 255, initial(g_skin))
	b_skin			= sanitize_integer(b_skin, 0, 255, initial(b_skin))
	r_markings		= sanitize_integer(r_markings, 0, 255, initial(r_markings))
	g_markings		= sanitize_integer(g_markings, 0, 255, initial(g_markings))
	b_markings		= sanitize_integer(b_markings, 0, 255, initial(b_markings))
	r_headacc		= sanitize_integer(r_headacc, 0, 255, initial(r_headacc))
	g_headacc		= sanitize_integer(g_headacc, 0, 255, initial(g_headacc))
	b_headacc		= sanitize_integer(b_headacc, 0, 255, initial(b_headacc))
	h_style			= sanitize_inlist(h_style, hair_styles_list, initial(h_style))
	f_style			= sanitize_inlist(f_style, facial_hair_styles_list, initial(f_style))
	m_style			= sanitize_inlist(m_style, marking_styles_list, initial(m_style))
	ha_style		= sanitize_inlist(ha_style, head_accessory_styles_list, initial(ha_style))
	r_eyes			= sanitize_integer(r_eyes, 0, 255, initial(r_eyes))
	g_eyes			= sanitize_integer(g_eyes, 0, 255, initial(g_eyes))
	b_eyes			= sanitize_integer(b_eyes, 0, 255, initial(b_eyes))
	underwear		= sanitize_text(underwear, initial(underwear))
	undershirt		= sanitize_text(undershirt, initial(undershirt))
	backbag			= sanitize_integer(backbag, 1, backbaglist.len, initial(backbag))
	b_type			= sanitize_text(b_type, initial(b_type))

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

	return 1

/datum/preferences/proc/save_character(client/C)
	var/organlist
	var/rlimblist
	var/playertitlelist
	if(!isemptylist(organ_data))
		organlist = list2params(organ_data)
	if(!isemptylist(rlimb_data))
		rlimblist = list2params(rlimb_data)
	if(!isemptylist(player_alt_titles))
		playertitlelist = list2params(player_alt_titles)

	var/DBQuery/firstquery = dbcon.NewQuery("SELECT slot FROM [format_table_name("characters")] WHERE ckey='[C.ckey]' ORDER BY slot")
	firstquery.Execute()
	while(firstquery.NextRow())
		if(text2num(firstquery.item[1]) == default_slot)
			var/DBQuery/query = dbcon.NewQuery({"UPDATE [format_table_name("characters")] SET OOC_Notes='[sql_sanitize_text(metadata)]',
												real_name='[sql_sanitize_text(real_name)]',
												name_is_always_random='[be_random_name]',
												gender='[gender]',
												age='[age]',
												species='[sql_sanitize_text(species)]',
												language='[sql_sanitize_text(language)]',
												hair_red='[r_hair]',
												hair_green='[g_hair]',
												hair_blue='[b_hair]',
												facial_red='[r_facial]',
												facial_green='[g_facial]',
												facial_blue='[b_facial]',
												skin_tone='[s_tone]',
												skin_red='[r_skin]',
												skin_green='[g_skin]',
												skin_blue='[b_skin]',
												markings_red='[r_markings]',
												markings_green='[g_markings]',
												markings_blue='[b_markings]',
												head_accessory_red='[r_headacc]',
												head_accessory_green='[g_headacc]',
												head_accessory_blue='[b_headacc]',
												hair_style_name='[sql_sanitize_text(h_style)]',
												facial_style_name='[sql_sanitize_text(f_style)]',
												marking_style_name='[sql_sanitize_text(m_style)]',
												head_accessory_style_name='[sql_sanitize_text(ha_style)]',
												eyes_red='[r_eyes]',
												eyes_green='[g_eyes]',
												eyes_blue='[b_eyes]',
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
												flavor_text='[sql_sanitize_text(html_decode(flavor_text))]',
												med_record='[sql_sanitize_text(html_decode(med_record))]',
												sec_record='[sql_sanitize_text(html_decode(sec_record))]',
												gen_record='[sql_sanitize_text(html_decode(gen_record))]',
												player_alt_titles='[playertitlelist]',
												disabilities='[disabilities]',
												organ_data='[organlist]',
												rlimb_data='[rlimblist]',
												nanotrasen_relation='[nanotrasen_relation]',
												speciesprefs='[speciesprefs]',
												socks='[socks]',
												body_accessory='[body_accessory]'
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
											hair_red, hair_green, hair_blue,
											facial_red, facial_green, facial_blue,
											skin_tone, skin_red, skin_green, skin_blue,
											markings_red, markings_green, markings_blue,
											head_accessory_red, head_accessory_green, head_accessory_blue,
											hair_style_name, facial_style_name, marking_style_name, head_accessory_style_name,
											eyes_red, eyes_green, eyes_blue,
											underwear, undershirt,
											backbag, b_type, alternate_option,
											job_support_high, job_support_med, job_support_low,
											job_medsci_high, job_medsci_med, job_medsci_low,
											job_engsec_high, job_engsec_med, job_engsec_low,
											job_karma_high, job_karma_med, job_karma_low,
											flavor_text, med_record, sec_record, gen_record,
											player_alt_titles,
											disabilities, organ_data, rlimb_data, nanotrasen_relation, speciesprefs,
											socks, body_accessory)

					VALUES
											('[C.ckey]', '[default_slot]', '[sql_sanitize_text(metadata)]', '[sql_sanitize_text(real_name)]', '[be_random_name]','[gender]',
											'[age]', '[sql_sanitize_text(species)]', '[sql_sanitize_text(language)]',
											'[r_hair]', '[g_hair]', '[b_hair]',
											'[r_facial]', '[g_facial]', '[b_facial]',
											'[s_tone]', '[r_skin]', '[g_skin]', '[b_skin]',
											'[r_markings]', '[g_markings]', '[b_markings]',
											'[r_headacc]', '[g_headacc]', '[b_headacc]',
											'[sql_sanitize_text(h_style)]', '[sql_sanitize_text(f_style)]', '[sql_sanitize_text(m_style)]', '[sql_sanitize_text(ha_style)]',
											'[r_eyes]', '[g_eyes]', '[b_eyes]',
											'[underwear]', '[undershirt]',
											'[backbag]', '[b_type]', '[alternate_option]',
											'[job_support_high]', '[job_support_med]', '[job_support_low]',
											'[job_medsci_high]', '[job_medsci_med]', '[job_medsci_low]',
											'[job_engsec_high]', '[job_engsec_med]', '[job_engsec_low]',
											'[job_karma_high]', '[job_karma_med]', '[job_karma_low]',
											'[sql_sanitize_text(html_encode(flavor_text))]', '[sql_sanitize_text(html_encode(med_record))]', '[sql_sanitize_text(html_encode(sec_record))]', '[sql_sanitize_text(html_encode(gen_record))]',
											'[playertitlelist]',
											'[disabilities]', '[organlist]', '[rlimblist]', '[nanotrasen_relation]', '[speciesprefs]',
											'[socks]', '[body_accessory]')

"}
)

	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR during character slot saving. Error : \[[err]\]\n")
		message_admins("SQL ERROR during character slot saving. Error : \[[err]\]\n")
		return
	return 1

/*
/datum/preferences/proc/random_character(client/C)
	var/DBQuery/query = dbcon.NewQuery("SELECT slot FROM [format_table_name("characters")] WHERE ckey='[C.ckey]' ORDER BY slot")

	while(query.NextRow())
	var/list/saves = list()
	for(var/i=1, i<=MAX_SAVE_SLOTS, i++)
		if(i==text2num(query.item[1]))
			saves += i

	if(!saves.len)
		load_character(C)
		return 0
	load_character(C,pick(saves))
	return 1*/

/datum/preferences/proc/SetChangelog(client/C,hash)
	lastchangelog=hash
	winset(C, "rpane.changelog", "background-color=none;font-style=")
	var/DBQuery/query = dbcon.NewQuery("UPDATE [format_table_name("player")] SET lastchangelog='[lastchangelog]' WHERE ckey='[C.ckey]'")
	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR during lastchangelog updating. Error : \[[err]\]\n")
		message_admins("SQL ERROR during lastchangelog updating. Error : \[[err]\]\n")
		to_chat(C, "Couldn't update your last seen changelog, please try again later.")
		return
	return 1
