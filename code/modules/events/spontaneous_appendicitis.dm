/datum/event/spontanenous_appendicitis/can_start(var/list/active_with_role)
	if(active_with_role["Medical"] > 1)
		return 50
	return 0

/datum/event/spontaneous_appendicitis/start()
	for(var/mob/living/carbon/human/H in shuffle(living_mob_list)) if(H.client && H.stat != DEAD)
		var/foundAlready = 0	//don't infect someone that already has the virus
		for(var/datum/disease/D in H.viruses)
			foundAlready = 1
		if(H.stat == 2 || foundAlready)
			continue
		if(H.z == map.zCentCom) //Don't infect people on the centcom z-level
			continue

		var/datum/disease/D = new /datum/disease/appendicitis
		D.holder = H
		D.affected_mob = H
		H.viruses += D
		break
