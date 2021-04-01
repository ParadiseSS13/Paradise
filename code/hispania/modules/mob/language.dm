/datum/language/zombie
    name = "Zombie"
    desc = "A language annoying."
    ask_verb = "Cry"
    exclaim_verbs = ("shouts")
    colour = "zombie"
    key = "zo"
    flags = RESTRICTED
    syllables = list("BRaGh", "aGarG", "AaAGUR", "GUrRH")

/datum/language/murghal
	name = "Yakar"
	desc = "The most widespread Murghal language, made up of screeches, tongue tickings and growls."
	speech_verb = "ticks"
	ask_verb = "ticks"
	exclaim_verbs = ("screeches")
	colour = "yakar"
	key = "y"
	flags = RESTRICTED
	syllables = list("ask","are","tik","qur","cut","chik","wak","grr","ras","ak","ek","ik","zix","tak","tek","tik","kala","kili","rink","ruk","skrra", "ska","ske","nix","nokt")

/datum/language/murghal/get_random_name()
	var/new_name = "[pick(list("Vasi","Lisk","Lich","Sika","Naika","Eva","Kirana","Taura","Tairana","Laski","Nikera", "Oki", "Mika"))]"
	new_name += " [pick(list("Mink","Lira","Kartis","TikTik","Kirakakai","Kali","Xixek","Ukik","Kondra","Beki"))]"
	return new_name
