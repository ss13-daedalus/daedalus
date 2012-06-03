//how to place label:
//1: set label in labeller
//2: pick up label object
//3: click on label with the hand the label is in
//4: place label on something
//how to remove label
//1: use labeller on item
//2: select label to remove (if there is >1 label anyway, if there is only one it will just remove that one)
/obj/item/weapon/hand_labeler
	icon = 'icons/obj/items.dmi'
	icon_state = "labeler"
	item_state = "flight"
	name = "Hand labeler"

/obj/item/weapon/hand_labeler/afterattack(atom/A as obj|mob, mob/user as mob)
	if(A==loc)      // if placing the labeller into something (e.g. backpack)
		return      // don't remove any labels
	if(!A.labels)
		return
	if(A.labels.len == 1)
		var/t = A.labels[1]
		A.name = copytext(A.name,1,lentext(A.name) - (lentext(t) + 2))
		A.labels -= t
		return
	if(A.labels.len > 1)
		var/t = input(user, "Which label do you want to remove?") as null|anything in A.labels
		var/i = 1
		for(, i <= labels.len, i++) //find the thing of the label to remove
			if(A.labels[i] == t)
				break
		if(i != A.labels.len) //if we arent removing the last label
			var/k = 0
			for(var/j = i+1, j <= A.labels.len, j++)
				k += lentext(A.labels[j]) + 3 // 3 = " (" + ")"
			var/labelend = lentext(A.name) - (k-1)
			var/labelstart = labelend - (lentext(t)+3)
			A.name = addtext(copytext(A.name,1,labelstart),copytext(A.name,labelend,0))
			A.labels -= t
			return
		if(i == A.labels.len) //if this is the last label we don't need to find the length of the stuff infront of it
			var/labelstart = lentext(A.name) - (lentext(t)+3)
			A.name = copytext(A.name,1,labelstart)
			A.labels -= t
			return
		user << "\red Something broke. Please report this (that you were trying to remove a label and what the full name of the item was) to an admin or something."

/atom/var/list/labels

/obj/item/weapon/hand_labeler/attack_self(mob/user as mob)
	var/str = input(usr,"Label text?","Set label","")
	if(!str || !length(str))
		usr << "\red Invalid text."
		return
	if(length(str) > 64)
		usr << "\red Text too long."
		return
	var/obj/item/weapon/label/A = new/obj/item/weapon/label
	A.label = str
	A.loc = user.loc
	A.name += " - '[str]'"

