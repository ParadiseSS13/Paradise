/obj/machinery/computer/decryption
	name="Data-Decryption Console"
	desc="This console is used to analyse and decrypt data found from various sources"
	icon = 'icons/obj/computer.dmi'
	icon_screen = "dna"
	icon_keyboard = "med_key"
	density = 1
	var/obj/item/weapon/book/databook/databook=null
	// Currently loaded databook.
	var/init = 1

	var/A
	var/unsolvedA = "None selected"

	var/B
	var/unsolvedB = "None selected"

	var/C
	var/unsolvedC = "None selected"

	var/D
	var/unsolvedD = "None selected"

	var/E
	var/unsolvedE = "None selected"


/obj/machinery/computer/decryption/New()
	..()

/obj/machinery/computer/decryption/attack_hand(mob/user)
	if(..())
		return
	ui_interact(user)



/obj/machinery/computer/decryption/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/book/databook))
		if(databook)
			user << "There already is a book inside."
			return
		else
			user.drop_item(W)
			W.loc = src
			databook = W
			user << "You load [W] into [src]."
			return


/obj/machinery/computer/decryption/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)

	var/data[0]

	data["bookTitle"]="Nothing"

	if(databook)
		data["bookTitle"]=databook.name
		data["keyA"]=databook.keyfragA
		data["keyB"]=databook.keyfragB
		data["keyC"]=databook.keyfragC
		data["keyD"]=databook.keyfragD
		data["keyE"]=databook.keyfragE
		data["unsolvedA"]=unsolvedA
		data["unsolvedB"]=unsolvedB
		data["unsolvedC"]=unsolvedC
		data["unsolvedD"]=unsolvedD
		data["unsolvedE"]=unsolvedE
	else
		data["keyA"]=0
		data["keyB"]=0
		data["keyC"]=0
		data["keyD"]=0
		data["keyE"]=0
		data["unsolvedA"]=""
		data["unsolvedB"]=""
		data["unsolvedC"]=""
		data["unsolvedD"]=""
		data["unsolvedE"]=""


	data["init"]= 1
	if(init == 0)
		data["init"]=0



	if (data["init"]== 1)
		data["selectedkeyA"]="None."
	if(A)
		data["selectedkeyA"]=A


	if (data["init"]== 1)
		data["selectedkeyB"]="None."
	if(B)
		data["selectedkeyB"]=B


	if (data["init"]== 1)
		data["selectedkeyC"]="None."
	if(C)
		data["selectedkeyC"]=C


	if (data["init"]== 1)
		data["selectedkeyD"]="None."
	if(D)
		data["selectedkeyD"]=D


	if (data["init"]== 1)
		data["selectedkeyE"]="None."
	if(E)
		data["selectedkeyE"]=E

    // update the ui with data if it exists, returns null if no ui is passed/found or if force_open is 1/true
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "Decryption.tmpl", "Decryption", 550, 855)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)



/obj/machinery/computer/decryption/Topic(href, href_list)
	if(..())
		return 1


	if(href_list["eject_book"])

		databook.loc = get_turf(src)
		databook = null


	if(href_list["change_alpha"])
		unsolvedA = input("Select cypher key fragment Alpha","Key fragment Alpha",A) in databook.keyfraglist

	if(href_list["change_beta"])
		unsolvedB = input("Select cypher key fragment Beta","Key fragment Beta",B) in databook.keyfraglist

	if(href_list["change_gamma"])
		unsolvedC = input("Select cypher key fragment Gamma","Key fragment Gamma",C) in databook.keyfraglist

	if(href_list["change_delta"])
		unsolvedD = input("Select cypher key fragment Delta","Key fragment Delta",D) in databook.keyfraglist

	if(href_list["change_epsilon"])
		unsolvedE = input("Select cypher key fragment Epsilon","Key fragment Epsilon",E) in databook.keyfraglist

	if(href_list["solve"])
		if(unsolvedA==""||unsolvedB== ""||unsolvedC== ""||unsolvedD== ""||unsolvedE == "")
			init = 1
		else
			init = 0
			A = unsolvedA
			B = unsolvedB
			C = unsolvedC
			D = unsolvedD
			E = unsolvedE
			if(A==databook.keyfragA&&B==databook.keyfragB&&C==databook.keyfragC&&D==databook.keyfragD&&E==databook.keyfragE)
				//Right now, we have no functional loot, so it gives cookies, and more books to solve.
				new /obj/item/weapon/reagent_containers/food/snacks/cookie(src.loc)
				new /obj/effect/spawner/lootdrop/databooks(src.loc)
				qdel(databook)
				databook=null

	usr.set_machine(src)
	src.add_fingerprint(usr)
