/obj/item/reagent_containers/blood
	name = "BloodPack"
	var/base_name = "BloodPack"
	desc = "Contains blood used for transfusion."
	icon = 'icons/obj/bloodpack.dmi'
	icon_state = "empty"
	volume = 200

	var/blood_type = null
	var/label_text = ""

/obj/item/reagent_containers/blood/New()
	..()
	if(blood_type != null)
		name = "BloodPack [blood_type]"
		reagents.add_reagent("blood", 200, list("donor"=null,"viruses"=null,"blood_DNA"=null,"blood_type"=blood_type,"resistances"=null,"trace_chem"=null))
		update_icon()

/obj/item/reagent_containers/blood/on_reagent_change()
	update_icon()
	update_name_label()

/obj/item/reagent_containers/blood/update_icon()
	var/percent = round((reagents.total_volume / volume) * 100)
	switch(percent)
		if(0 to 9)
			icon_state = "empty"
		if(10 to 50)
			icon_state = "half"
		if(51 to INFINITY)
			icon_state = "full"

/obj/item/reagent_containers/blood/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/pen) || istype(I, /obj/item/flashlight/pen))
		var/tmp_label = sanitize(input(user, "Enter a label for [name]","Label",label_text))
		if(length(tmp_label) > MAX_NAME_LEN)
			to_chat(user, "<span class='warning'>The label can be at most [MAX_NAME_LEN] characters long.</span>")
		else
			to_chat(user, "<span class='notice'>You set the label to \"[tmp_label]\".</span>")
			label_text = tmp_label
			update_name_label()

/obj/item/reagent_containers/blood/proc/update_name_label()
	if(reagents.total_volume == 0)
		base_name = "Empty BloodPack"
		desc = "Seems pretty useless... Maybe if there were a way to fill it?"
	else
		base_name = "BloodPack"
		desc = "Contains blood used for transfusion."
	if(label_text == "")
		name = base_name
	else
		name = "[base_name] ([label_text])"

/obj/item/reagent_containers/blood/random/New()
	blood_type = pick("A+", "A-", "B+", "B-", "O+", "O-")
	..()

/obj/item/reagent_containers/blood/APlus
	blood_type = "A+"
	label_text = "A+"

/obj/item/reagent_containers/blood/AMinus
	blood_type = "A-"
	label_text = "A-"

/obj/item/reagent_containers/blood/BPlus
	blood_type = "B+"
	label_text = "B+"

/obj/item/reagent_containers/blood/BMinus
	blood_type = "B-"
	label_text = "B-"

/obj/item/reagent_containers/blood/OPlus
	blood_type = "O+"
	label_text = "O+"

/obj/item/reagent_containers/blood/OMinus
	blood_type = "O-"
	label_text = "O-"

/obj/item/reagent_containers/blood/empty
	name = "Empty BloodPack"
	desc = "Seems pretty useless... Maybe if there were a way to fill it?"
	icon_state = "empty"