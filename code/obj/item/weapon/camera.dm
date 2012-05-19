/obj/item/weapon/camera
	name = "camera"
	icon = 'icons/obj/items.dmi'
	desc = "A Polaroid camera. It has 30 photos left."
	icon_state = "camera"
	item_state = "electropack"
	w_class = 2.0
	flags = 466.0
	m_amt = 2000
	throwforce = 5
	throw_speed = 4
	throw_range = 10
	var/pictures_max = 30
	var/pictures_left = 30
	var/can_use = 1

/obj/item/weapon/camera/attack(mob/living/carbon/human/M as mob, mob/user as mob)
	return

/obj/item/weapon/camera/proc/get_icon(turf/the_turf as turf)
	//Bigger icon base to capture those icons that were shifted to the next tile
	//i.e. pretty much all wall-mounted machinery
	var/icon/res = icon('icons/effects/96x96.dmi',"")

	var/icon/turficon = build_composite_icon(the_turf)
	res.Blend(turficon,ICON_OVERLAY,32,32)

	var/atoms[] 	= list()
	for(var/atom/A in the_turf)
		if(A.invisibility) continue
		atoms.Add(A)

	//Sorting icons based on levels
	var/gap = atoms.len
	var/swapped = 1
	while (gap > 1 || swapped)
		swapped = 0
		if (gap > 1)
			gap = round(gap / 1.247330950103979)
		if (gap < 1)
			gap = 1
		for (var/i = 1; gap + i <= atoms.len; i++)
			var/atom/l = atoms[i]		//Fucking hate
			var/atom/r = atoms[gap+i]	//how lists work here
			if (l.layer > r.layer)		//no "atoms[i].layer" for me
				atoms.Swap(i, gap + i)
				swapped = 1

	for (var/i; i <= atoms.len; i++)
		var/atom/A = atoms[i]
		if (A)
			var/icon/img = build_composite_icon(A)
			if(istype(img, /icon))
				res.Blend(img,ICON_OVERLAY,32+A.pixel_x,32+A.pixel_y)
	return res

/obj/item/weapon/camera/attack_self(var/mob/user as mob)
	..()
	if (can_use)
		can_use = 0
		icon_state = "camera_off"
		usr << "\red You turn the camera off."
	else
		can_use = 1
		icon_state = "camera"
		usr << "\blue You turn the camera on."

/obj/item/weapon/camera/proc/get_mobs(turf/the_turf as turf)
	var/mob_detail
	for(var/mob/living/carbon/A in the_turf)
		if(A.invisibility) continue
		var/holding = null
		if(A.l_hand || A.r_hand)
			if(A.l_hand) holding = "They are holding \a [A.l_hand]"
			if(A.r_hand)
				if(holding)
					holding += " and \a [A.r_hand]"
				else
					holding = "They are holding \a [A.r_hand]"

		if(!mob_detail)
			mob_detail = "You can see [A] on the photo[A:health < 75 ? " - [A] looks hurt":""].[holding ? " [holding]":"."]. "
		else
			mob_detail += "You can also see [A] on the photo[A:health < 75 ? " - [A] looks hurt":""].[holding ? " [holding]":"."]."
	return mob_detail

/obj/item/weapon/camera/afterattack(atom/target as mob|obj|turf|area, mob/user as mob, flag)
	if (!can_use || !pictures_left || ismob(target.loc)) return

	var/x_c = target.x - 1
	var/y_c = target.y + 1
	var/z_c	= target.z

	var/icon/temp = icon('icons/effects/96x96.dmi',"")
	var/icon/black = icon('icons/turf/space.dmi', "black")
	var/mobs = ""
	for (var/i = 1; i <= 3; i++)
		for (var/j = 1; j <= 3; j++)
			var/turf/T = locate(x_c,y_c,z_c)

			var/mob/dummy = new(T)	//Go go visibility check dummy
			if(dummy in viewers(world.view, user))
				temp.Blend(get_icon(T),ICON_OVERLAY,31*(j-1-1),31 - 31*(i-1))
			else
				temp.Blend(black,ICON_OVERLAY,31*(j-1),62 - 31*(i-1))
			mobs += get_mobs(T)
			del dummy	//Alas, nameless creature
			x_c++
		y_c--
		x_c = x_c - 3

	var/obj/item/weapon/photo/P = new/obj/item/weapon/photo( get_turf(src) )
	var/icon/small_img = icon(temp)
	var/icon/ic = icon('icons/obj/items.dmi',"photo")
	small_img.Scale(8,8)
	ic.Blend(small_img,ICON_OVERLAY,10,13)
	P.icon = ic
	P.img = temp
	P.desc = mobs
	P.pixel_x = rand(-10,10)
	P.pixel_y = rand(-10,10)
	playsound(src.loc, pick('sound/items/polaroid1.ogg','sound/items/polaroid2.ogg'), 75, 1, -3)

	pictures_left--
	src.desc = "A Polaroid camera. It has [pictures_left] photos left."
	user << "\blue [pictures_left] photos left."
	can_use = 0
	icon_state = "camera_off"
	spawn(50)
		can_use = 1
		icon_state = "camera"

/obj/item/weapon/camera/attackby(A as obj, mob/user as mob)
	if (istype(A, /obj/item/weapon/camera_film))
		if (src.pictures_left >= pictures_max)
			user << "\blue It's already full!"
			return 1
		else
			del(A)
			src.pictures_left = src.pictures_max
			src.desc = "A polaroid camera. It has [pictures_left] photos left."
			user << text("\blue You reload the camera film!",)
			user.update_clothing()
		return 1
	return
