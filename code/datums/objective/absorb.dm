/datum/objective/absorb

/datum/objective/absorb/find_target()
	gen_amount_goal()


/datum/objective/absorb/New(owner, lover_goal, upper_goal)
	..()
	gen_amount_goal(lover_goal, upper_goal)

/datum/objective/absorb/proc/gen_amount_goal(var/lowbound = 4, var/highbound = 6)
	target_amount = rand(lowbound, highbound)
	if(ticker)
		var/needed_count = 1 //autowin
		if (ticker.current_state == GAME_STATE_SETTING_UP)
			for(var/mob/new_player/P in player_list)
				if(P.client && P.ready && P.mind!=owner)
					needed_count ++
		else if(ticker.current_state == GAME_STATE_PLAYING)
			for(var/mob/living/carbon/human/P in player_list)
				if(P.client && !(P.mind.changeling) && P.mind != owner)
					needed_count ++
		target_amount = min(target_amount, needed_count)

	update_explanation()
	return target_amount

/datum/objective/absorb/check_completion()
	if(owner && owner.changeling && owner.changeling.absorbed_dna && (owner.changeling.absorbedcount >= target_amount))
		return TRUE
	else
		return FALSE

/datum/objective/absorb/update_explanation()
	explanation_text = "Absorb [target_amount] compatible genomes."

/datum/objective/absorb/get_panel_entry()
	return "Absorb <a href='?src=\ref[src];set_amount=Compatible genomes'>[target_amount]</a> compatible genomes."