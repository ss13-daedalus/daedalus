/obj/item/weapon/label
	icon = 'icons/obj/items.dmi'
	icon_state = "label"
	name = "Label"
	w_class = 2
	var/label = ""
	var/backing = 1 //now with added being able to be put on table-ness!

/obj/item/weapon/label/afterattack(atom/A, mob/user as mob)
	if(!backing)
		if(!label || !length(label))
			user << "\red This label doesn't have any text! How did this happen?!?"
			return
		if(length(A.name) + length(label) > 64) //this needs to be made bigger too. maybe number of labels instead of a fixed length
			user << "\red Label too big."
			return
		if(ishuman(A))
			user << "\red You can't label humans."
			return
		if(!A.labels)
			A.labels = new()
		for(var/i = 1, i < A.labels.len, i++)
			if(label == A.labels[i])
				user << "\red [A] already has that label!"
				return

		for(var/mob/M in viewers())
			M << "\blue [user] puts a label on [A]."
		A.name = "[A.name] ([label])"
		A.labels += label
		del(src)

/obj/item/weapon/label/attack_self(mob/user as mob)	//here so you can put them on tables and stuff more easily to stop them from being all over the floor until you want to use them
	if(backing)
		backing = 0
		user << "\blue You remove the backing from the label." //now it will stick to things
