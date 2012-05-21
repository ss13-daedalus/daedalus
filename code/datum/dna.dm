
/datum/dna
	var/unique_enzymes = null
	var/struc_enzymes = null
	var/uni_identity = null
	var/original_name = "Unknown"
	var/b_type = "A+"

/datum/dna/proc/check_integrity(var/mob/living/carbon/character)
	if(character && ishuman(character))
		if(length(uni_identity) != 39)
			//Lazy.
			var/mob/living/carbon/human/character2 = character
			var/temp
			var/hair = 0
			var/beard

			// determine DNA fragment from hairstyle
			// :wtc:
			// If the character2 doesn't have initialized hairstyles / beardstyles, initialize it for them!
			if(!character2.hair_style)
				character2.hair_style = new/datum/sprite_accessory/hair/short

			if(!character2.facial_hair_style)
				character2.facial_hair_style = new/datum/sprite_accessory/facial_hair/shaved

			var/list/styles = typesof(/datum/sprite_accessory/hair) - /datum/sprite_accessory/hair
			var/hrange = round(4095 / styles.len)

			if(character2.hair_style)
				var/style = styles.Find(character2.hair_style.type)
				if(style)
					hair = style * hrange - rand(1,hrange-1)

			// Beard dna code - mostly copypasted from hair code to allow for more dynamic facial hair style additions
			var/list/face_styles = typesof(/datum/sprite_accessory/facial_hair) - /datum/sprite_accessory/facial_hair
			var/f_hrange = round(4095 / face_styles.len)

			var/f_style = face_styles.Find(character2.facial_hair_style.type)
			if(f_style)
				beard = f_style * f_hrange - rand(1,f_hrange-1)
			else
				beard = 0

			temp = add_zero2(num2hex((character2.r_hair),1), 3)
			temp += add_zero2(num2hex((character2.b_hair),1), 3)
			temp += add_zero2(num2hex((character2.g_hair),1), 3)
			temp += add_zero2(num2hex((character2.r_facial),1), 3)
			temp += add_zero2(num2hex((character2.b_facial),1), 3)
			temp += add_zero2(num2hex((character2.g_facial),1), 3)
			temp += add_zero2(num2hex(((character2.s_tone + 220) * 16),1), 3)
			temp += add_zero2(num2hex((character2.r_eyes),1), 3)
			temp += add_zero2(num2hex((character2.g_eyes),1), 3)
			temp += add_zero2(num2hex((character2.b_eyes),1), 3)

			var/gender

			if (character2.gender == MALE)
				gender = add_zero2(num2hex((rand(1,(2050+BLOCKADD))),1), 3)
			else
				gender = add_zero2(num2hex((rand((2051+BLOCKADD),4094)),1), 3)

			temp += gender
			temp += add_zero2(num2hex((beard),1), 3)
			temp += add_zero2(num2hex((hair),1), 3)

			uni_identity = temp
		if(length(struc_enzymes)!= 81)
			var/mutstring = ""
			for(var/i = 1, i <= 26, i++)
				mutstring += add_zero2(num2hex(rand(1,1024)),3)

			struc_enzymes = mutstring
		if(length(unique_enzymes) != 32)
			unique_enzymes = md5(character.real_name)
		if(original_name == "Unknown")
			original_name = character.real_name
	else if(character && ismonkey(character))
		uni_identity = "00600200A00E0110148FC01300B009"
		struc_enzymes = "43359156756131E13763334D1C369012032164D4FE4CD61544B6C03F251B6C60A42821D26BA3B0FD6"
		unique_enzymes = md5(character.name)
				//////////blah
		var/gendervar
		if (character.gender == "male")
			gendervar = add_zero2(num2hex((rand(1,2049)),1), 3)
		else
			gendervar = add_zero2(num2hex((rand(2051,4094)),1), 3)
		uni_identity += gendervar
		uni_identity += "12C"
		uni_identity += "4E2"
		b_type = "A+"
		original_name = character.real_name
	else
		if(length(uni_identity) != 39) uni_identity = "00600200A00E0110148FC01300B0095BD7FD3F4"
		if(length(struc_enzymes)!= 81) struc_enzymes = "43359156756131E13763334D1C369012032164D4FE4CD61544B6C03F251B6C60A42821D26BA3B02D6"

//	reg_dna[unique_enzymes] = character.real_name

/datum/dna/proc/ready_dna(mob/living/carbon/human/character)

	var/temp
	var/hair
	var/beard

	// determine DNA fragment from hairstyle
	// :wtc:

	var/list/styles = typesof(/datum/sprite_accessory/hair) - /datum/sprite_accessory/hair
	var/hrange = round(4095 / styles.len)

	var/style = styles.Find(character.hair_style.type)
	if(style)
		hair = style * hrange - rand(1,hrange-1)
	else
		hair = 0

	// Beard dna code - mostly copypasted from hair code to allow for more dynamic facial hair style additions
	var/list/face_styles = typesof(/datum/sprite_accessory/facial_hair) - /datum/sprite_accessory/facial_hair
	var/f_hrange = round(4095 / face_styles.len)

	var/f_style = face_styles.Find(character.facial_hair_style.type)
	if(f_style)
		beard = f_style * f_hrange - rand(1,f_hrange-1)
	else
		beard = 0

	temp = add_zero2(num2hex((character.r_hair),1), 3)
	temp += add_zero2(num2hex((character.b_hair),1), 3)
	temp += add_zero2(num2hex((character.g_hair),1), 3)
	temp += add_zero2(num2hex((character.r_facial),1), 3)
	temp += add_zero2(num2hex((character.b_facial),1), 3)
	temp += add_zero2(num2hex((character.g_facial),1), 3)
	temp += add_zero2(num2hex(((character.s_tone + 220) * 16),1), 3)
	temp += add_zero2(num2hex((character.r_eyes),1), 3)
	temp += add_zero2(num2hex((character.g_eyes),1), 3)
	temp += add_zero2(num2hex((character.b_eyes),1), 3)

	var/gender

	if (character.gender == MALE)
		gender = add_zero2(num2hex((rand(1,(2050+BLOCKADD))),1), 3)
	else
		gender = add_zero2(num2hex((rand((2051+BLOCKADD),4094)),1), 3)

	temp += gender
	temp += add_zero2(num2hex((beard),1), 3)
	temp += add_zero2(num2hex((hair),1), 3)

	uni_identity = temp

	var/mutstring = ""
	for(var/i = 1, i <= 26, i++)
		mutstring += add_zero2(num2hex(rand(1,1024)),3)

	struc_enzymes = mutstring

	unique_enzymes = md5(character.real_name)
	original_name = character.real_name
	reg_dna[unique_enzymes] = character.real_name

/////////////////////////// DNA DATUM

