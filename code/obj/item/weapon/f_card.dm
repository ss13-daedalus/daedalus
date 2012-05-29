// FINGERPRINT CARD

/obj/item/weapon/f_card/examine()
	set src in view(2)

	..()
	usr << text("\blue There are [] on the stack!", src.amount)
	usr << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", src.name, display()), text("window=[]", src.name))
	onclose(usr, "[src.name]")
	return

/obj/item/weapon/f_card/proc/display()
	if(!fingerprints)	return
	if (!istype(src.fingerprints, /list))
		src.fingerprints = params2list(src.fingerprints)
	if (length(src.fingerprints))
		var/dat = "<B>Fingerprints on Card</B><HR>"
		for(var/i = 1, i < (src.fingerprints.len + 1), i++)
			var/list/L = params2list(src.fingerprints[i])
			dat += text("[]<BR>", L["1"])
			//Foreach goto(41)
		return dat
	else
		return "<B>There are no fingerprints on this card.</B>"
	return

/obj/item/weapon/f_card/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/weapon/f_card))
		if ((src.fingerprints || W.fingerprints))
			return
		if (src.amount == 10)
			return
		if (W:amount + src.amount > 10)
			src.amount = 10
			W:amount = W:amount + src.amount - 10
		else
			src.amount += W:amount
			//W = null
			del(W)
		src.add_fingerprint(user)
		if (W)
			W.add_fingerprint(user)
	else
		if (istype(W, /obj/item/weapon/pen))
			var/t = input(user, "Card Label:", text("[]", src.name), null)  as text
			if (user.equipped() != W)
				return
			if ((!in_range(src, usr) && src.loc != user))
				return
			t = copytext(sanitize(t),1,MAX_MESSAGE_LEN)
			if (t)
				src.name = text("FPrintC- '[]'", t)
			else
				src.name = "Finger Print Card"
			W.add_fingerprint(user)
			src.add_fingerprint(user)
	return

/obj/item/weapon/f_card/add_fingerprint()

	..()
	if (!istype(usr, /mob/living/silicon))
		if (fingerprints)
			if (src.amount > 1)
				var/obj/item/weapon/f_card/F = new /obj/item/weapon/f_card(get_turf(src))
				F.amount = --src.amount
				amount = 1
			icon_state = "fingerprint1"
	return
