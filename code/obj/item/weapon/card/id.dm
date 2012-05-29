// ID CARDS

/obj/item/weapon/card/id/var/money = 2000

/obj/item/weapon/card/id/examine()
	..()
	read()

/obj/item/weapon/card/id/New()
	..()
	spawn(30)
	if(istype(loc, /mob/living/carbon/human))
		blood_type = loc:dna:b_type
		dna_hash = loc:dna:unique_enzymes
		fingerprint_hash = md5(loc:dna:uni_identity)

/obj/item/weapon/card/id/attack_self(mob/user as mob)
	for(var/mob/O in viewers(user, null))
		O.show_message(text("[] shows you: \icon[] []: assignment: []", user, src, src.name, src.assignment), 1)

	src.add_fingerprint(user)
	return

/obj/item/weapon/card/id/attack_hand(mob/user as mob)
	var/obj/item/weapon/storage/wallet/WL
	if( istype(loc, /obj/item/weapon/storage/wallet) )
		WL = loc
	..()
	if(WL)
		WL.update_icon()

/obj/item/weapon/card/id/verb/read()
	set name = "Read ID Card"
	set category = "Object"
	set src in usr

	usr << text("\icon[] []: The current assignment on the card is [].", src, src.name, src.assignment)
	usr << "The blood type on the card is [blood_type]."
	usr << "The DNA hash on the card is [dna_hash]."
	usr << "The fingerprint hash on the card is [fingerprint_hash]."
	return
/obj/item/weapon/card/id/syndicate/var/mob/registered_user = null
/obj/item/weapon/card/id/syndicate/attack_self(mob/user as mob)
	if(!registered_user)
		registered_name = input(user, "What name would you like to put on this card?", "Agent card name", ishuman(user) ? user.real_name : user.name)
		assignment = input(user, "What occupation would you like to put on this card?\nNote: This will not grant any access levels other than Maintenance.", "Agent card job assignment", "Assistant")
		name = "[src.registered_name]'s ID Card ([src.assignment])"
		user << "\blue You successfully forge the ID card."
		registered_user = user
	else if(registered_user == user)
		switch(alert("Would you like to display the ID, or retitle it?","Choose.","Rename","Show"))
			if("Rename")
				registered_name = input(user, "What name would you like to put on this card?", "Agent card name", ishuman(user) ? user.real_name : user.name)
				assignment = input(user, "What occupation would you like to put on this card?\nNote: This will not grant any access levels other than Maintenance.", "Agent card job assignment", "Assistant")
				name = "[src.registered_name]'s ID Card ([src.assignment])"
				user << "\blue You successfully forge the ID card."
				return
			if("Show")
				..()
	else
		..()
