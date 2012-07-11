// CLIPBOARD

/obj/item/weapon/clipboard/attack_self(mob/user as mob)
	var/dat = "<B>Clipboard</B><BR>"
	if (src.pen)
		dat += text("<A href='?src=\ref[];pen=1'>Remove Pen</A><BR><HR>", src)
	dat += "<table>"
	for(var/obj/item/weapon/W in src)
		dat += "<tr>"
		if( istype( W, /obj/item/weapon/paper ) )
			var/obj/item/weapon/paper/P = W
			dat += text( "<td><a href='?src=\ref[];read=\ref[]'>[]</A></td><td>	\
							<A href='?src=\ref[];write=\ref[]'>Write</A></td><td>		\
							<A href='?src=\ref[];rname=\ref[]'>Rename</A></td><td>	\
							<A href='?src=\ref[];remove=\ref[]'>Remove</A><BR></td>",\
							src, P, P.name, src, P, src, P, src, P)
		if( istype( W, /obj/item/weapon/photo ) )
			var/obj/item/weapon/photo/P = W
			dat += text("<td><A href='?src=\ref[];read=\ref[]'>[]</A></td><td>	\
							<A href='?src=\ref[];rname=\ref[]'>Rename</A></td><td>	\
							<A href='?src=\ref[];remove=\ref[]'>Remove</A><BR></td>",\
							src, P, P.name, src, P, src, P)
		dat += "</tr>"
	dat += "</table>"
	user << browse(dat, "window=clipboard")
	onclose(user, "clipboard")
	return

/obj/item/weapon/clipboard/Topic(href, href_list)
	..()
	if ((usr.stat || usr.restrained()))
		return
	if (usr.contents.Find(src))
		usr.machine = src
		if (href_list["pen"])
			if (src.pen)
				if ((usr.hand && !( usr.l_hand )))
					usr.l_hand = src.pen
					src.pen.loc = usr
					src.pen.layer = 20
					src.pen = null
					usr.update_clothing()
				else
					if (!( usr.r_hand ))
						usr.r_hand = src.pen
						src.pen.loc = usr
						src.pen.layer = 20
						src.pen = null
						usr.update_clothing()
				if (src.pen)
					src.pen.add_fingerprint(usr)
				src.add_fingerprint(usr)
		if (href_list["remove"])
			var/obj/item/P = locate(href_list["remove"])
			if ((P && P.loc == src))
				if ((usr.hand && !( usr.l_hand )))
					usr.l_hand = P
					P.loc = usr
					P.layer = 20
					usr.update_clothing()
				else
					if (!( usr.r_hand ))
						usr.r_hand = P
						P.loc = usr
						P.layer = 20
						usr.update_clothing()
				P.add_fingerprint(usr)
				src.add_fingerprint(usr)
		if (href_list["rname"])
			var/obj/item/I = locate(href_list["rname"])
			if(( I && I.loc == src ))
				if( istype( I, /obj/item/weapon/paper ) )
					var/obj/item/weapon/paper/P = I
					P.rename()
				if( istype( I, /obj/item/weapon/photo ) )
					var/obj/item/weapon/photo/P = I
					P.rename()
			src.add_fingerprint( usr )
		if (href_list["write"])
			var/obj/item/P = locate(href_list["write"])
			if ((P && P.loc == src))
				if (istype(usr.r_hand, /obj/item/weapon/pen))
					P.attackby(usr.r_hand, usr)
				else
					if (istype(usr.l_hand, /obj/item/weapon/pen))
						P.attackby(usr.l_hand, usr)
					else
						if (istype(src.pen, /obj/item/weapon/pen))
							P.attackby(src.pen, usr)
			src.add_fingerprint(usr)
		if (href_list["read"])
			var/obj/item/I = locate(href_list["read"])
			if ((I && I.loc == src))
				if (istype(I, /obj/item/weapon/paper))
					var/obj/item/weapon/paper/P = I
					if (!( istype(usr, /mob/living/carbon/human) ))
						usr << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", P.name, stars(P.info)), text("window=[]", P.name))
						onclose(usr, "[P.name]")
					else
						var/t = dd_replacetext(P.info, "\n", "<BR>")
						usr << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", P.name, t), text("window=[]", P.name))
						onclose(usr, "[P.name]")
				if (istype(I, /obj/item/weapon/photo))
					var/obj/item/weapon/photo/P = I
					usr << browse_rsc(P.img, "tmp_photo.png")
					usr << browse("<html><head><title>Photo</title></head>" \
						+ "<body style='overflow:hidden'>" \
						+ "<div> <img src='tmp_photo.png' width = '180'" \
						+ "[P.scribble ? "<div> Writings on the back:<br><i>[P.scribble]</i>" : ]"\
						+ "</body></html>", "window=book;size=200x[P.scribble ? 400 : 200]")
					onclose(usr, "[P.name]")
		if (ismob(src.loc))
			var/mob/M = src.loc
			if (M.machine == src)
				spawn( 0 )
					src.attack_self(M)
					return
	return

/obj/item/weapon/clipboard/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/item/weapon/clipboard/attack_hand(mob/user as mob)

	if ((locate(/obj/item/weapon/paper, src) && (!( user.equipped() ) && (user.l_hand == src || user.r_hand == src))))
		var/obj/item/weapon/paper/P
		for(P in src)
			break
		if (P)
			if (user.hand)
				user.l_hand = P
			else
				user.r_hand = P
			P.loc = user
			P.layer = 20
			P.add_fingerprint(user)
			user.update_clothing()
		src.add_fingerprint(user)
	else
		return ..()
	return

/obj/item/weapon/clipboard/attackby(obj/item/weapon/P as obj, mob/user as mob)
	..()
	if (istype(P, /obj/item/weapon/paper) || istype(P, /obj/item/weapon/photo))
		if (src.contents.len < 15)
			user.drop_item()
			P.loc = src
		else
			user << "\blue Not enough space!"
	else
		if (istype(P, /obj/item/weapon/pen))
			if (!src.pen)
				user.drop_item()
				P.loc = src
				src.pen = P
		else
			return
	src.update()
	return

/obj/item/weapon/clipboard/proc/update()
	src.icon_state = text("[src.name][][]", (locate(/obj/item/weapon/paper, src) ? "1" : "0"), (locate(/obj/item/weapon/pen, src) ? "1" : "0"))
	return


/obj/item/weapon/clipboard/MouseDrop(obj/over_object as obj) //Quick clipboard fix. -Agouri
	if (ishuman(usr) || ismonkey(usr)) //Can monkeys even place items in the pocket slots? Leaving this in just in case~
		var/mob/M = usr
		if (!( istype(over_object, /obj/screen) ))
			return ..()
		if ((!( M.restrained() ) && !( M.stat ) /*&& M.pocket == src*/))
			if (over_object.name == "r_hand")
				if (!( M.r_hand ))
					M.u_equip(src)
					M.r_hand = src
			else
				if (over_object.name == "l_hand")
					if (!( M.l_hand ))
						M.u_equip(src)
						M.l_hand = src
			M.update_clothing()
			src.add_fingerprint(usr)
			return //

/obj/item/weapon/clipboard/New()

	..()
	for(var/i = 1, i <= 3, i++)
		var/obj/item/weapon/paper/P = new /obj/item/weapon/paper(src)
		P.loc = src
	src.pen = new /obj/item/weapon/pen(src)
	src.update()
	return
