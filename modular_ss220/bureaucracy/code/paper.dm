/obj/item/paper
	var/paper_width_big = 600
	var/paper_height_big = 700
	var/small_paper_cap = 1024
	var/force_big = FALSE

/obj/item/paper/updateinfolinks()
	. = ..()
	update_size()

/obj/item/paper/proc/update_size()
	if(force_big || length(info) > small_paper_cap)
		become_big()
	else
		reset_size()

/obj/item/paper/proc/become_big()
	paper_width = paper_width_big
	paper_height = paper_height_big

/obj/item/paper/proc/reset_size()
	paper_width = initial(paper_width)
	paper_height = initial(paper_height)

/obj/item/paper/central_command
	name = "Бумага с ЦК"
	info = ""

/obj/item/paper/central_command/New(sign_name = "Стэнди Мэроу")
	..()
	var/SS220_pen_code_header = "\[grid\]\[row\]\[cell\]     \[logo\]\[cell\]\[small\]Форма Nano Trasen NT-\[b\]CC\[/b\]-RES\[/small\]ᅠᅠᅠᅠᅠ\[small\]Время: \[time\]\[/small\] \
										\[small\]Станция — \[b\]Центральное командование\[/b\]\[/small\]ᅠᅠ ᅠ\[small\]Год: [GLOB.game_year]\[/small\] \
										\[br\]\[i\]\[large\]\[b\] ᅠ\[field\] \[b\]\[/large\]\[/i\]\[/grid\]\[hr\] \
										\[center\]Приветствую экипаж и руководство \[station\]!\[/center\]\[br\]\[br\]"
	header = pencode_to_html(SS220_pen_code_header, sign=FALSE)

	var/SS220_pen_code_footer = "\[br\]\[small\]\[i\]\[br\]Подпись: \[signfont\][sign_name]\[/signfont\]\[/i\], в должности: \[i\]Nanotrasen Navy Officer\[field\].\[/i\]\[/small\]\[br\]\[hr\]\[small\] *Несоблюдение указаний, содержащихся в данном документе, считается нарушением политики компании; Дисциплинарное взыскание за нарушения может быть применено на месте или в конце смены в Центральном командовании;\[br\]*Получатель(и) данного меморандума подтверждает(ют), что он(она/они) несут ответственность за любой ущерб, который может возникнуть в результате игнорирования приведенных здесь директив или рекомендаций;\[br\]*Все отчеты должны храниться конфиденциально их предполагаемым получателем и любой соответствующей стороной. Несанкционированное распространение данного меморандума может привести к дисциплинарным взысканиям.\[/small\]"
	footer = pencode_to_html(SS220_pen_code_footer, sign=FALSE)
