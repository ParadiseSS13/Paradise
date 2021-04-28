/proc/generate_code_phrase()//Proc da palabras en español
	var/code_phrase = ""
	var/words = 4 //Numero de palabras para Antag
	var/nouns[] = list("amor","odio","enojo","paz","orgullo","simpatia","valentia","lealtad","honestidad","integridad","compasion","caridad","éxito","coraje","amable","habilidad","belleza","brillantez","dolor","miseria","creencias","atrevido","justicia","verdad","fe","libertad","conocimiento","pensamiento","informacion","cultura","confianza","dedicacion","progreso","educacion","hospitalidad","ocio","problema","amistades", "relajacion")
	var/drinks[] = list("vodka and tonic","gin fizz","bahama mama","manhattan","black Russian","whiskey soda","long island tea","margarita","cafe"," manly dwarf","crema irlandesa","doctor's delight","beepksy smash","tequila sunrise","brave bull","gargle blaster","bloody mary","whiskey cola","white russian","vodka martini","martini","cuba libre","kahlua","vodka","vino","moonshine")
	for(words,words>0,words--)
		switch(rand(1,2))
			if(1)
				code_phrase += pick(nouns)
				code_phrase += " - "
			if(2)
				code_phrase += pick(drinks)
				code_phrase += " - "
	return code_phrase
