/obj/item/weapon/photo
	name = "photo"
	icon = 'icons/obj/items.dmi'
	icon_state = "photo"
	item_state = "clipboard"
	w_class = 1.0
	var/icon/img	//Big photo image
	var/scribble	//Scribble on the back

/obj/item/weapon/photo/attack_self(var/mob/user as mob)
		..()
		examine()

/obj/item/weapon/photo/attackby(obj/item/weapon/P as obj, mob/user as mob)
	if (istype(P, /obj/item/weapon/pen) || istype(P, /obj/item/toy/crayon))
		var/txt = scrub_input(usr, "What would you like to write on the back?", "Photo Writing", null)  as text
		txt = copytext(txt, 1, 128)
		if ((loc == usr && usr.stat == 0))
			scribble = txt

	..()

/obj/item/weapon/photo/examine()
	set src in oview(2)
	..()
	if (scribble)
		usr << "\blue you see something written on photo's back. "
	usr << browse_rsc(src.img, "tmp_photo.png")
	usr << browse("<html><head><title>Photo</title></head>" \
		+ "<body style='overflow:hidden'>" \
		+ "<div> <img src='tmp_photo.png' width = '180'" \
		+ "[scribble ? "<div> Writings on the back:<br><i>[scribble]</i>" : ]"\
		+ "</body></html>", "window=book;size=200x[scribble ? 400 : 200]")
	onclose(usr, "[name]")

	return
/obj/item/weapon/photo/verb/rename()
	set name = "Rename photo"
	set category = "Object"
	set src in usr

	var/n_name = input(usr, "What would you like to label the photo?", "Photo Labelling", src.name)  as text
	n_name = copytext(n_name, 1, 32)
	//	loc.loc check is for allowing photos attached to clipboards to be renamed
	if (( (src.loc == usr || (src.loc.loc && src.loc.loc == usr)) && usr.stat == 0))
		name = "photo[(n_name ? text("- '[n_name]'") : null)]"
	add_fingerprint(usr)
	return

