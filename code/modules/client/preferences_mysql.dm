/datum/preferences/proc/load_preferences(client/C)

	var/DBQuery/query = dbcon.NewQuery("SELECT ooccolor,UI_style,UI_style_color,UI_style_alpha,be_special,default_slot,toggles,sound,randomslot,volume FROM erro_player WHERE ckey='[C.ckey]'")
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
		be_special = text2num(query.item[5])
		default_slot = text2num(query.item[6])
		toggles = text2num(query.item[7])
		sound = text2num(query.item[8])
		randomslot = text2num(query.item[9])
		volume = text2num(query.item[10])

	//Sanitize
	ooccolor		= sanitize_hexcolor(ooccolor, initial(ooccolor))
//	lastchangelog	= sanitize_text(lastchangelog, initial(lastchangelog))
	UI_style		= sanitize_inlist(UI_style, list("White", "Midnight"), initial(UI_style))
	be_special		= sanitize_integer(be_special, 0, 65535, initial(be_special))
	default_slot	= sanitize_integer(default_slot, 1, MAX_SAVE_SLOTS, initial(default_slot))
	toggles			= sanitize_integer(toggles, 0, 65535, initial(toggles))
	sound			= sanitize_integer(sound, 0, 65535, initial(toggles))
	UI_style_color	= sanitize_hexcolor(UI_style_color, initial(UI_style_color))
	UI_style_alpha	= sanitize_integer(UI_style_alpha, 0, 255, initial(UI_style_alpha))
	randomslot		= sanitize_integer(randomslot, 0, 1, initial(randomslot))
	volume			= sanitize_integer(volume, 0, 100, initial(volume))
	return 1

/datum/preferences/proc/save_preferences(client/C)

	var/DBQuery/query = dbcon.NewQuery("UPDATE erro_player SET ooccolor='[ooccolor]',UI_style='[UI_style]',UI_style_color='[UI_style_color]',UI_style_alpha='[UI_style_alpha]',be_special='[be_special]',default_slot='[default_slot]',toggles='[toggles]',sound='[sound]',randomslot='[randomslot]',volume='[volume]' WHERE ckey='[C.ckey]'")
	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR during saving player preferences. Error : \[[err]\]\n")
		message_admins("SQL ERROR during saving player preferences. Error : \[[err]\]\n")
		return
	return 1

/datum/preferences/proc/load_character(client/C,slot)

	if(!slot)	slot = default_slot
	slot = sanitize_integer(slot, 1, MAX_SAVE_SLOTS, initial(default_slot))
	if(slot != default_slot)
		default_slot = slot
		var/DBQuery/firstquery = dbcon.NewQuery("UPDATE erro_player SET default_slot=[slot] WHERE ckey='[C.ckey]'")
		firstquery.Execute()

	var/DBQuery/query = dbcon.NewQuery("SELECT * FROM characters WHERE ckey='[C.ckey]' AND slot='[slot]'")
	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR during character slot loading. Error : \[[err]\]\n")
		message_admins("SQL ERROR during character slot loading. Error : \[[err]\]\n")
		return

	while(query.NextRow())
		//Character
		metadata = query.item[4]
		real_name = query.item[5]
		be_random_name = text2num(query.item[6])
		gender = query.item[7]
		age = text2num(query.item[8])
		species = query.item[9]
		language = query.item[10]

		//colors to be consolidated into hex strings (requires some work with dna code)
		r_hair = text2num(query.item[11])
		g_hair = text2num(query.item[12])
		b_hair = text2num(query.item[13])
		r_facial = text2num(query.item[14])
		g_facial = text2num(query.item[15])
		b_facial = text2num(query.item[16])
		s_tone = text2num(query.item[17])
		r_skin = text2num(query.item[18])
		g_skin = text2num(query.item[19])
		b_skin = text2num(query.item[20])
		h_style = query.item[21]
		f_style = query.item[22]
		r_eyes = text2num(query.item[23])
		g_eyes = text2num(query.item[24])
		b_eyes = text2num(query.item[25])
		underwear = text2num(query.item[26])
		undershirt = text2num(query.item[27])
		backbag = text2num(query.item[28])
		b_type = query.item[29]


		//Jobs
		alternate_option = text2num(query.item[30])
		job_support_high = text2num(query.item[31])
		job_support_med = text2num(query.item[32])
		job_support_low = text2num(query.item[33])
		job_medsci_high = text2num(query.item[34])
		job_medsci_med = text2num(query.item[35])
		job_medsci_low = text2num(query.item[36])
		job_engsec_high = text2num(query.item[37])
		job_engsec_med = text2num(query.item[38])
		job_engsec_low = text2num(query.item[39])
		job_karma_high = text2num(query.item[40])
		job_karma_med = text2num(query.item[41])
		job_karma_low = text2num(query.item[42])

		//Miscellaneous
		flavor_text = query.item[43]
		med_record = query.item[44]
		sec_record = query.item[45]
		gen_record = query.item[46]
		be_special = text2num(query.item[47])
		disabilities = text2num(query.item[48])
		player_alt_titles = params2list(query.item[49])
		organ_data = params2list(query.item[50])

		nanotrasen_relation = query.item[51]

	//Sanitize
	metadata		= sanitize_text(metadata, initial(metadata))
	real_name		= reject_bad_name(real_name)
	if(isnull(species)) species = "Human"
	if(isnull(language)) language = "None"
	if(isnull(nanotrasen_relation)) nanotrasen_relation = initial(nanotrasen_relation)
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
	h_style			= sanitize_inlist(h_style, hair_styles_list, initial(h_style))
	f_style			= sanitize_inlist(f_style, facial_hair_styles_list, initial(f_style))
	r_eyes			= sanitize_integer(r_eyes, 0, 255, initial(r_eyes))
	g_eyes			= sanitize_integer(g_eyes, 0, 255, initial(g_eyes))
	b_eyes			= sanitize_integer(b_eyes, 0, 255, initial(b_eyes))
	underwear		= sanitize_integer(underwear, 1, underwear_m.len, initial(underwear))
	undershirt		= sanitize_integer(undershirt, 1, undershirt_t.len, initial(undershirt))
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
	be_special = sanitize_integer(be_special, 0, 65535, initial(be_special))

//	if(isnull(disabilities)) disabilities = 0
	if(!player_alt_titles) player_alt_titles = new()
	if(!organ_data) src.organ_data = list()

	return 1

/datum/preferences/proc/save_character(client/C)
	var/organlist
	var/playertitlelist
	if(!isemptylist(organ_data))
		organlist = list2params(organ_data)
	if(!isemptylist(player_alt_titles))
		playertitlelist = list2params(player_alt_titles)

	var/DBQuery/firstquery = dbcon.NewQuery("SELECT slot FROM characters WHERE ckey='[C.ckey]' ORDER BY slot")
	firstquery.Execute()
	while(firstquery.NextRow())
		if(text2num(firstquery.item[1]) == default_slot)
			var/DBQuery/query = dbcon.NewQuery("UPDATE characters SET OOC_Notes='[sql_sanitize_text(metadata)]',real_name='[sql_sanitize_text(real_name)]',name_is_always_random='[be_random_name]',gender='[gender]',age='[age]',species='[sql_sanitize_text(species)]',language='[sql_sanitize_text(language)]',hair_red='[r_hair]',hair_green='[g_hair]',hair_blue='[b_hair]',facial_red='[r_facial]',facial_green='[g_facial]',facial_blue='[b_facial]',skin_tone='[s_tone]',skin_red='[r_skin]',skin_green='[g_skin]',skin_blue='[b_skin]',hair_style_name='[sql_sanitize_text(h_style)]',facial_style_name='[sql_sanitize_text(f_style)]',eyes_red='[r_eyes]',eyes_green='[g_eyes]',eyes_blue='[b_eyes]',underwear='[underwear]',undershirt='[undershirt]',backbag='[backbag]',b_type='[b_type]',alternate_option='[alternate_option]',job_support_high='[job_support_high]',job_support_med='[job_support_med]',job_support_low='[job_support_low]',job_medsci_high='[job_medsci_high]',job_medsci_med='[job_medsci_med]',job_medsci_low='[job_medsci_low]',job_engsec_high='[job_engsec_high]',job_engsec_med='[job_engsec_med]',job_engsec_low='[job_engsec_low]',job_karma_high='[job_karma_high]',job_karma_med='[job_karma_med]',job_karma_low='[job_karma_low]',flavor_text='[sql_sanitize_text(flavor_text)]',med_record='[sql_sanitize_text(med_record)]',sec_record='[sql_sanitize_text(sec_record)]',gen_record='[sql_sanitize_text(gen_record)]',player_alt_titles='[sql_sanitize_text(playertitlelist)]',be_special='[be_special]',disabilities='[disabilities]',organ_data='[organlist]',nanotrasen_relation='[nanotrasen_relation]' WHERE ckey='[C.ckey]' AND slot='[default_slot]'")
			if(!query.Execute())
				var/err = query.ErrorMsg()
				log_game("SQL ERROR during character slot saving. Error : \[[err]\]\n")
				message_admins("SQL ERROR during character slot saving. Error : \[[err]\]\n")
				return
			return 1
	var/DBQuery/query = dbcon.NewQuery("INSERT INTO characters (ckey,slot,OOC_Notes,real_name,name_is_always_random,gender,age,species,language,hair_red,hair_green,hair_blue,facial_red,facial_green,facial_blue,skin_tone,skin_red,skin_green,skin_blue,hair_style_name,facial_style_name,eyes_red,eyes_green,eyes_blue,underwear,undershirt,backbag,b_type,alternate_option,job_support_high,job_support_med,job_support_low,job_medsci_high,job_medsci_med,job_medsci_low,job_engsec_high,job_engsec_med,job_engsec_low,job_karma_high,job_karma_med,job_karma_low,flavor_text,med_record,sec_record,gen_record,player_alt_titles,be_special,disabilities,organ_data,nanotrasen_relation) VALUES ('[C.ckey]','[default_slot]','[sql_sanitize_text(metadata)]','[sql_sanitize_text(real_name)]','[be_random_name]','[gender]','[age]','[sql_sanitize_text(species)]','[sql_sanitize_text(language)]','[r_hair]','[g_hair]','[b_hair]','[r_facial]','[g_facial]','[b_facial]','[s_tone]','[r_skin]','[g_skin]','[b_skin]','[sql_sanitize_text(h_style)]','[sql_sanitize_text(f_style)]','[r_eyes]','[g_eyes]','[b_eyes]','[underwear]','[undershirt]','[backbag]','[b_type]','[alternate_option]','[job_support_high]','[job_support_med]','[job_support_low]','[job_medsci_high]','[job_medsci_med]','[job_medsci_low]','[job_engsec_high]','[job_engsec_med]','[job_engsec_low]','[job_karma_high]','[job_karma_med]','[job_karma_low]','[sql_sanitize_text(flavor_text)]','[sql_sanitize_text(med_record)]','[sql_sanitize_text(sec_record)]','[sql_sanitize_text(gen_record)]','[playertitlelist]','[be_special]','[disabilities]','[organlist]','[nanotrasen_relation]')")
	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR during character slot saving. Error : \[[err]\]\n")
		message_admins("SQL ERROR during character slot saving. Error : \[[err]\]\n")
		return
	return 1

/datum/preferences/proc/random_character(client/C)
	var/DBQuery/query = dbcon.NewQuery("SELECT slot FROM characters WHERE ckey='[C.ckey]' ORDER BY slot")

	while(query.NextRow())
	var/list/saves = list()
	for(var/i=1, i<=MAX_SAVE_SLOTS, i++)
		if(i==text2num(query.item[1]))
			saves += i

	if(!saves.len)
		load_character(C)
		return 0
	load_character(C,pick(saves))
	return 1