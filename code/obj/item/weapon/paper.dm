// PAPER

/obj/item/weapon/paper/New()
	..()
	src.pixel_y = rand(-8, 8)
	src.pixel_x = rand(-9, 9)
	spawn(2)
		if(src.info)
			src.overlays += "paper_words"
		return

/obj/item/weapon/paper/process()
	if(iteration < 5)
		var/turf/location = src.loc
		if(istype(location, /mob/))
			var/mob/M = location
			if(M.l_hand == src || M.r_hand == src)
				location = get_turf(M)
		if (istype(location, /turf))
			location.hotspot_expose(700, 5)
		iteration++
	else
		for(var/mob/M in viewers(5, get_turf(src)))
			M << "\red \the [src] burns up."
		if(istype(src.loc,/mob))
			var/mob/M = src.loc
			M.total_luminosity -= 8
		else
			src.sd_SetLuminosity(0)
		processing_objects.Remove(src)
		del(src)

/obj/item/weapon/paper/update_icon() //derp.
	if(src.info)
		src.overlays += "paper_words"
	if(src.burning)
		src.overlays += "paper_fire"
	return


/obj/item/weapon/paper/pickup(mob/user)
	if(burning)
		src.sd_SetLuminosity(0)
		user.total_luminosity += 8

/obj/item/weapon/paper/dropped(mob/user)
	if(burning)
		user.total_luminosity -= 8
		src.sd_SetLuminosity(8)

/obj/item/weapon/paper/examine()
	set src in view()

	..()
	if (!( istype(usr, /mob/living/carbon/human) || istype(usr, /mob/dead/observer) || istype(usr, /mob/living/silicon) ))
		// actually strip formatting, so stars doesn't screw up
		var/t = dd_replacetext(src.info, "\n", "")
		t = dd_replacetext(t, "\[b\]", "")
		t = dd_replacetext(t, "\[/b\]", "")
		t = dd_replacetext(t, "\[i\]", "")
		t = dd_replacetext(t, "\[/i\]", "")
		t = dd_replacetext(t, "\[u\]", "")
		t = dd_replacetext(t, "\[/u\]", "")
		usr << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", src.name, stars(t)), text("window=[]", src.name))
		onclose(usr, "[src.name]")
	else
		// if people want lazy bb-code
		var/t = dd_replacetext(src.info, "\n", "<BR>")
		t = dd_replacetext(t, "\[b\]", "<B>")
		t = dd_replacetext(t, "\[/b\]", "</B>")
		t = dd_replacetext(t, "\[i\]", "<I>")
		t = dd_replacetext(t, "\[/i\]", "</I>")
		t = dd_replacetext(t, "\[u\]", "<U>")
		t = dd_replacetext(t, "\[/u\]", "</U>")
		t = text("<font face=calligrapher>[]</font>", t)
		usr << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", src.name, t), text("window=[]", src.name))
		onclose(usr, "[src.name]")
	return


/obj/item/weapon/paper/verb/rename()
	set name = "Rename paper"
	set category = "Object"
	set src in usr

	if ((usr.mutations & CLUMSY) && prob(50))
		usr << text("\red You cut yourself on the paper.")
		return
	var/n_name = input(usr, "What would you like to label the paper?", "Paper Labelling", null)  as text
	n_name = copytext(n_name, 1, 32)
	if ((src.loc == usr && usr.stat == 0))
		src.name = n_name && n_name != "" ? n_name : "Untitled paper"
	src.add_fingerprint(usr)
	return

/obj/item/weapon/paper/attack_self(mob/living/user as mob)
	examine()
	return

/obj/item/weapon/paper/attack_ai(var/mob/living/silicon/ai/user as mob)
	var/dist
	if (istype(user) && user.current) //is AI
		dist = get_dist(src, user.current)
	else //cyborg or AI not seeing through a camera
		dist = get_dist(src, user)
	if (dist < 2)
		usr << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", src.name, src.info), text("window=[]", src.name))
		onclose(usr, "[src.name]")
	else
		usr << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", src.name, stars(src.info)), text("window=[]", src.name))
		onclose(usr, "[src.name]")
	return

/obj/item/weapon/paper/attackby(obj/item/weapon/P as obj, mob/user as mob)
	..()
	if (istype(P, /obj/item/weapon/pen))
		if(src.stamped != null && src.stamped.len > 0)
			user << "\blue This paper has been stamped and can no longer be edited."
			return

		for(var/mob/O in viewers(user))
			O.show_message("\blue [user] starts writing on the paper with [P].", 1)
		var/t = "[src.info]"
		do
			t = input(user, "What text do you wish to add?", text("[]", src.name), t)  as message
			if ((!in_range(src, usr) && src.loc != user && !( istype(src.loc, /obj/item/weapon/clipboard) ) && src.loc.loc != user && user.equipped() != P))
				return

			if(lentext(t) >= MAX_PAPER_MESSAGE_LEN)
				var/cont = input(user, "Your message is too long! Would you like to continue editing it?", "", "yes") in list("yes", "no")
				if(cont == "no")
					break
		while(lentext(t) > MAX_PAPER_MESSAGE_LEN)


		if ((!in_range(src, usr) && src.loc != user && !( istype(src.loc, /obj/item/weapon/clipboard) ) && src.loc.loc != user && user.equipped() != P))
			return

		// check for exploits
		for(var/tag in paper_blacklist)
			if(findtext(t,"<"+tag))
				user << "\blue You think to yourself, \"Hm.. this is only paper...\""
				return

		if(!overlays.Find("paper_words"))
			src.overlays += "paper_words"

		src.info = t
	else
		if(is_burn(P))
			for(var/mob/M in viewers(5, get_turf(src)))
				M << "\red [user] sets \the [src] on fire."
			user.total_luminosity += 8
			burning = 1
			processing_objects.Add(src)
			update_icon()
			return
		if(istype(P, /obj/item/weapon/stamp))
			if ((!in_range(src, usr) && src.loc != user && !( istype(src.loc, /obj/item/weapon/clipboard) ) && src.loc.loc != user && user.equipped() != P))
				return
			if(!src.infoold)
				src.infoold = src.info
			src.info += text("<BR><i>This paper has been stamped with the [].</i><BR>", P.name)
			switch(P.type)
				if(/obj/item/weapon/stamp/captain)
					src.overlays += "paper_stamped_cap"
				if(/obj/item/weapon/stamp/hop)
					src.overlays += "paper_stamped_hop"
				if(/obj/item/weapon/stamp/hos)
					src.overlays += "paper_stamped_hos"
				if(/obj/item/weapon/stamp/ce)
					src.overlays += "paper_stamped_ce"
				if(/obj/item/weapon/stamp/rd)
					src.overlays += "paper_stamped_rd"
				if(/obj/item/weapon/stamp/cmo)
					src.overlays += "paper_stamped_cmo"
				if(/obj/item/weapon/stamp/denied)
					src.overlays += "paper_stamped_denied"
				if(/obj/item/weapon/stamp/clown)
					src.overlays += "paper_stamped_clown"
				if(/obj/item/weapon/stamp/centcom)
					src.overlays += "paper_stamped_cent"
				else
					src.overlays += "paper_stamped"
			if(!stamped)
				stamped = new
			stamped += P.type

			user << "\blue You stamp the paper with your rubber stamp."

		if(istype(P, /obj/item/weapon/stamp_eraser))
			if ((!in_range(src, usr) && src.loc != user && !( istype(src.loc, /obj/item/weapon/clipboard) ) && src.loc.loc != user && user.equipped() != P))
				return
			src.info = src.infoold
			src.infoold = null
			for(var/i, i <= stamped.len, i++)
				switch(stamped[i])
					if(/obj/item/weapon/stamp/captain)
						src.overlays -= "paper_stamped_cap"
					if(/obj/item/weapon/stamp/hop)
						src.overlays -= "paper_stamped_hop"
					if(/obj/item/weapon/stamp/hos)
						src.overlays -= "paper_stamped_hos"
					if(/obj/item/weapon/stamp/ce)
						src.overlays -= "paper_stamped_ce"
					if(/obj/item/weapon/stamp/rd)
						src.overlays -= "paper_stamped_rd"
					if(/obj/item/weapon/stamp/cmo)
						src.overlays -= "paper_stamped_cmo"
					if(/obj/item/weapon/stamp/denied)
						src.overlays -= "paper_stamped_denied"
					if(/obj/item/weapon/stamp/clown)
						src.overlays -= "paper_stamped_clown"
					else
						src.overlays -= "paper_stamped"
			stamped = list()
			user << "\blue You sucessfully remove those pesky stamps."

	/*
	else
		if (istype(P, /obj/item/weapon/welding_tool))
			var/obj/item/weapon/welding_tool/W = P
			if ((W.welding && W.weldfuel > 0))
				for(var/mob/O in viewers(user, null))
					O.show_message(text("\red [] burns [] with the welding tool!", user, src), 1, "\red You hear a small burning noise", 2)
					//Foreach goto(323)
				spawn( 0 )
					src.burn(1800000.0)
					return
		else
			if (istype(P, /obj/item/device/igniter))
				for(var/mob/O in viewers(user, null))
					O.show_message(text("\red [] burns [] with the igniter!", user, src), 1, "\red You hear a small burning noise", 2)
					//Foreach goto(406)
				spawn( 0 )
					src.burn(1800000.0)
					return
			else
				if (istype(P, /obj/item/weapon/wire_cutters))
					for(var/mob/O in viewers(user, null))
						O.show_message(text("\red [] starts cutting []!", user, src), 1)
						//Foreach goto(489)
					sleep(50)
					if (((src.loc == src || get_dist(src, user) <= 1) && (!( user.stat ) && !( user.restrained() ))))
						for(var/mob/O in viewers(user, null))
							O.show_message(text("\red [] cuts [] to pieces!", user, src), 1)
							//Foreach goto(580)
						//SN src = null
						del(src)
						return
	*/ //TODO: FIX
	src.add_fingerprint(user)
	return





