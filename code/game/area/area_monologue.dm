//This whole file is made for monologues
//It is a crime against good programming practices
//A lot of the monologues (mostly edited) are ported from the 2016 release of Goonstation
//This whole file is under the CC-BY-NC-SA 3.0 license
//Link to the license can be obtained in the file LICENSING.md

/area/shuttle/escape_pod1/centcom/get_monologue(var/datum/species/S)
	if(S.name == "Vox")
		return "Is was finally overs, monologue_vox. Voxxy needed rest and triple citrus. The next shift would start soon..."
	else
		return "Central Command. I was tired as hell but I could afford to be tired now... I needed it to be morning. I wanted to hear doors opening, cars start, and human voices talking about the Space Olympics. I wanted to make sure there were still folks out there facing life with nothing up their sleeves but their arms. They didn't know it yet, but they had a better shot at happiness and a fair shake than they did yesterday."

/area/maintenance/get_monologue(var/datum/species/S)
	if(S.name == "Vox")
		return "Maintenance. Dark hallways never scares Voxxy. Is has to know where to move, but when is moves smart is not get skrek."
	else
		return "The dark maintenance corridoors of this place were always the same, home to the most shady characters you could ever imagine. Walk down the right back alley on the station and you can find anything."

/area/maintenance/disposal/get_monologue(var/datum/species/S)
	if(S.name == "Vox")
		return "Disposals. Many shinies. And corpses."
	else
		return "Disposal. Usually bloodied, full of grey-suited corpses and broken windows. Down here, you can hear the quiet moaning of the station itself. It's like it's mourning. Mourning better days long gone, like assistants through these pipes."

/area/hallway/get_monologue(var/datum/species/S)
	if(S.name == "Vox")
		return "The dustlungs go about their bussiness while Voxxy watches. They never understoods what is all about. monologue_vox."
	else
		return "The halls of the station assault my nostrils like a week old meal left festering in the sink. A thug around every corner, and reason enough themselves to keep my gun in my hand."

/area/hallway/secondary/exit/get_monologue(var/datum/species/S)
	if(S.name == "Vox")
		return "Escape. Best way to get off the station, but Voxxy could not leave just yet."
	else
		return "The only way off this hellhole and it's the one place I don't want to be, but sometimes you have to show your friends that you're worth a damn. Sometimes that means dying, sometimes it means killing a whole lot of people to escape alive."

/area/hallway/secondary/entry/get_monologue(var/datum/species/S)
	if(S.name == "Vox")
		return "NSS Cyberiad. Skreks and dustlungs everywhere Voxxy can see, but Voxxy still loves the place. Voxxy riskies too much to let it go now."
	else
		return "The entrance to the station. You will never find a more wretched hive of scum and villainy. I must be cautious."

/area/bridge/get_monologue(var/datum/species/S)
	if(S.name == "Vox")
		return "Voxxy no like Command. Skrek comdoms who think they can order Voxxy around. Quill will appreciate one day..."
	else
		return "The bridge. The home of the Captain and Head of Personnel. I tried to tell myself I was the sturdy leg in our little triangle. I was worried it was true."

/area/crew_quarters/get_monologue(var/datum/species/S)
	if(S.name == "Vox")
		return "Voxxy likes eating here, but Voxxy doesn't like the blood."
	else
		return "A place to eat, but not an appealing one. I've heard rumours about this place, and if there's one thing I know, it's that it's not normal to eat people."

/area/crew_quarters/bar/get_monologue(var/datum/species/S)
	if(S.name == "Vox")
		return "The bar, so here is where the outcasts of the meat is go to. They is just wasting their life here getting intoxicateds."
	else
		return "The station bar, full of the best examples of lowlifes and drunks I'll ever find. I need a drink though, and there are no better places to find a beer than here."

/area/chapel/get_monologue(var/datum/species/S)
	if(S.name == "Vox")
		return "Voxxy was too busy to look at Chapel decorations. Were skrek as always, monologue_vox. "
	else
		return "The self-pontificating bastard who calls himself our chaplain conducts worship here. If you can call the summoning of an angry god who pelts us with toolboxes, bolts of lightning, and occasionally rips our bodies in twain 'worship'."

/area/engine/get_monologue(var/datum/species/S)
	if(S.name == "Vox")
		return "Engineerings. Dustlungs working to keep the station runnings, but Voxxy saw too much blood here."
	else
		return "The churning, hellish heart of the station that just can't help missing the beat. Full of the dregs of society, and not the right place to be caught unwanted. I better watch my back."

/area/medical/get_monologue(var/datum/species/S)
	if(S.name == "Vox")
		return "Medbay. Voxxy doesn't trust the dustlungs here, but triple citrus is noes cure bulletholes."
	else
		return "Medical. In truth it's full of the biggest bunch of cut throats on the station, most would rather cut you up than sow you up, but ifI've got a slug in my ass, I don't have much choice."

/area/security/get_monologue(var/datum/species/S)
	if(S.name == "Vox")
		return "Voxxy trusts Security. They is skrek, but is good skrek to fight along."
	else
		return "I had dreams of being security before I got into the detective game. I wanted to meet stimulating and interesting people of an ancient space culture, and kill them. I wanted to be the first kid on my ship to get a confirmed kill."

/area/security/detectives_office/get_monologue(var/datum/species/S)
	if(S.name == "Vox")
		return "Is Voxxy office. Is safe places. Safe places for a shift like this, monologue_vox."
	else
		return "As I looked out the door of my office, I realised it was a night when you didn't know your friends but strangers looked familiar. A night like this, the smartest thing to do is nothing: stay home. It was like the wind carried people along with it. But I had to get out there."

/area/quartermaster/get_monologue(var/datum/species/S)
	if(S.name == "Vox")
		return "Is miners and techies. Voxxy do not trust them, but Voxxy needs ammo sometimes too."
	else
		return "Cargo. The trustworthy department on the whole goddamn Station. I wouldn't trust them to look after my coat, let alone the crates of heavy ordnance these geniuses handle. Still, I have to get the ammo somewhere..."

/area/hydroponics/get_monologue(var/datum/species/S)
	if(S.name == "Vox")
		return "Botany, monologue_vox. Is drugs and crime, mostly. But maybe that's what station needs, ech..."
	else
		return "A gang of space farmers growing psilocybin mushrooms, ambrosia, and of course those goddamned george melons. A shady bunch, whose wiles had earned them the trust of many. The Chef. The Barman. But not me. No, their charms don't work on a man of values and principles."
