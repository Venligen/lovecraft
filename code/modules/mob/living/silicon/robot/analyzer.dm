//
//Robotic Component Analyser, basically a health analyser for robots
//
/obj/item/device/robotanalyzer
	name = "cyborg analyzer"
	icon_state = "robotanalyzer"
	item_state = "analyzer"
	desc = "A hand-held scanner able to diagnose robotic injuries."
	flags = CONDUCT
	slot_flags = SLOT_BELT
	throwforce = 3
	w_class = ITEM_SIZE_SMALL
	throw_speed = 5
	throw_range = 10
	origin_tech = list(TECH_MAGNET = 2, TECH_BIO = 1, TECH_ENGINEERING = 2)
	matter = list(MATERIAL_STEEL = 500, MATERIAL_GLASS = 200)
	var/mode = 1;


/obj/item/device/robotanalyzer/do_surgery(mob/living/M, mob/living/user)
	if(user.a_intent != I_HELP) //in case it is ever used as a surgery tool
		return ..()
	do_scan(M, user) //default surgery behaviour is just to scan as usual
	return 1


/obj/item/device/robotanalyzer/attack(mob/living/M as mob, mob/living/user as mob)
	do_scan(M, user)

/obj/item/device/robotanalyzer/proc/do_scan(mob/living/M as mob, mob/living/user as mob)
	//TODO: DNA3 clown_block
	/*
	if((CLUMSY in user.mutations) && prob(50))
		user << text("\red You try to analyze the floor's vitals!")
		for(var/mob/O in viewers(M, null))
			O.show_message("\red [user] has analyzed the floor's vitals!", 1)
		user.show_message(SPAN_NOTE("Analyzing Results for The floor:\n\t Overall Status: Healthy"), 1)
		user.show_message(SPAN_NOTE("\t Damage Specifics: [0]-[0]-[0]-[0]"), 1)
		user.show_message(SPAN_NOTE("Key: Suffocation/Toxin/Burns/Brute"), 1)
		user.show_message(SPAN_NOTE("Body Temperature: ???"), 1)
		return
	*/

	var/scan_type
	if(isrobot(M))
		scan_type = "robot"
	else if(ishuman(M))
		scan_type = "prosthetics"
	else
		user << "\red You can't analyze non-robotic things!"
		return

	user.visible_message(SPAN_NOTE("\The [user] has analyzed [M]'s components."),SPAN_NOTE("You have analyzed [M]'s components."))
	switch(scan_type)
		if("robot")
			var/BU = M.getFireLoss() > 50 	? 	"<b>[M.getFireLoss()]</b>" 		: M.getFireLoss()
			var/BR = M.getBruteLoss() > 50 	? 	"<b>[M.getBruteLoss()]</b>" 	: M.getBruteLoss()
			user.show_message(SPAN_NOTE("Analyzing Results for [M]:\n\t Overall Status: [M.stat > UNCONSCIOUS ? "fully disabled" : "[M.health - M.halloss]% functional"]"))
			user.show_message("\t Key: <font color='#FFA500'>Electronics</font>/<font color='red'>Brute</font>", 1)
			user.show_message("\t Damage Specifics: <font color='#FFA500'>[BU]</font> - <font color='red'>[BR]</font>")
			if(M.tod && M.stat == DEAD)
				user.show_message(SPAN_NOTE("Time of Disable: [M.tod]"))
			var/mob/living/silicon/robot/H = M
			var/list/damaged = H.get_damaged_components(1,1,1)
			user.show_message(SPAN_NOTE("Localized Damage:"),1)
			if(length(damaged)>0)
				for(var/datum/robot_component/org in damaged)
					var/installed = (org.installed == -1) ? "<font color='red'><b>DESTROYED</b></font>" : null
					var/FR = (org.electronics_damage > 0) ? "<font color='#FFA500'>[org.electronics_damage]</font>" : null
					var/BL = (org.brute_damage > 0) ? "<font color='red'>[org.brute_damage]</font>" : null
					var/toggled = (org.toggled) ? "Toggled ON" : "<font color='red'>Toggled OFF</font>"
					var/powered = (org.powered)	?	"Power ON"		:	"<font color='red'>Power OFF</font>"
					user.show_message(SPAN_NOTE("\t [capitalize(org)]: [installed] [FR] - [BL] - [toggled] - [powered]"),1)
			else
				user.show_message(SPAN_NOTE("\t Components are OK."),1)
			if(H.emagged && prob(5))
				user.show_message("\red \t ERROR: INTERNAL SYSTEMS COMPROMISED",1)
			user.show_message(SPAN_NOTE("Operating Temperature: [M.bodytemperature-T0C]&deg;C ([M.bodytemperature*1.8-459.67]&deg;F)"), 1)

		if("prosthetics")

			var/mob/living/carbon/human/H = M
			user << SPAN_NOTE("Analyzing Results for \the [H]:")
			if(H.isSynthetic())
				user << "System instability: <font color='green'>[H.getToxLoss()]</font>"
			user << "Key: <font color='#FFA500'>Electronics</font>/<font color='red'>Brute</font>"
			user << SPAN_NOTE("External prosthetics:")
			var/organ_found
			if(H.internal_organs.len)
				for(var/obj/item/organ/external/E in H.organs)
					if(!(E.robotic >= ORGAN_ROBOT))
						continue
					organ_found = 1
					user << "[E.name]: <font color='red'>[E.brute_dam]</font> <font color='#FFA500'>[E.burn_dam]</font>"
			if(!organ_found)
				user << "No prosthetics located."
			user << "<hr>"
			user << SPAN_NOTE("Internal prosthetics:")
			organ_found = null
			if(H.internal_organs.len)
				for(var/obj/item/organ/O in H.internal_organs)
					if(!(O.robotic >= ORGAN_ROBOT))
						continue
					organ_found = 1
					user << "[O.name]: <font color='red'>[O.damage]</font>"
			if(!organ_found)
				user << "No prosthetics located."

	src.add_fingerprint(user)
	return
