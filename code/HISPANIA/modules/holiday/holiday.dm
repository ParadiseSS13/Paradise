#define ANNIVERSARY_HISPANIA_FILE "data/anniversary_of_hispania.txt"

/datum/holiday/hispania
	name = "Anniversary of Hispania"
	begin_day = 20
	begin_month = APRIL
	var/anniversary

/datum/holiday/hispania/celebrate()
	if(length(file(ANNIVERSARY_HISPANIA_FILE)) != null)		// Si el archivo no existe
		anniversary = file2text(ANNIVERSARY_HISPANIA_FILE)
		if((text2num(time2text(world.realtime, "YY")) - 16) > text2num(anniversary)) // Si el año actual - 16 (año en el que se fundó Hispania) es mayor al año de aniversario, entonces aniversario++
			fdel(ANNIVERSARY_HISPANIA_FILE)
			anniversary = text2num(anniversary)
			anniversary++
			text2file("[anniversary]", ANNIVERSARY_HISPANIA_FILE)
		else
			return
	else
		var/current_anniversary = (text2num(time2text(world.realtime, "YY")) - 16) - 1
		text2file("[current_anniversary]", ANNIVERSARY_HISPANIA_FILE)
		return

/datum/holiday/hispania/greet()
	return {"¡Hoy Hispania está de cumpleaños!

Desde hace [anniversary] años hemos estado creciendo y aprendiendo juntos para hacer de esta pequeña casita del árbol un lugar acogedor y divertido para todos. Hemos tenido nuestros altos y bajos, pero sin duda el esfuerzo entre todos ha dado sus frutos, y ahora más que nunca parece que estamos bien encaminados.

Por eso queremos agradecer a nuestros usuarios, desde el más viejo hasta el más nuevo, por formar parte de esta comunidad y por hacerla lo que es hoy. Gracias a todo el que ha aportado a nuestro código, al que se ha tomado el tiempo de crear una ficha de personaje, al que ha posteado una guía en nuestro foro, al que ha respondido dudas o ayudado a algún nuevo usuario a dar sus primeros pasos por el juego. Gracias a todo el que se ha tomado el tiempo de jugar con nosotros.

Celebremos hoy no solo al servidor, sino a cada uno de sus integrantes.

¡Feliz cumpleaños, Hispania!"}