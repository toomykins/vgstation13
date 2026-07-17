// ============================================================================
// Migrated effects: old /datum/disease content ported into the virus2 system.
// Each effect here reproduces the behaviour of a legacy /datum/disease so that
// content survives once the old system (code/datums/disease.dm) is retired.
// All are restricted = 2 (never mutate in randomly, hidden from encyclopedia)
// and are meant to be assigned directly to a crafted/predefined disease.
// ============================================================================

// --- Rapid Petrification (was /datum/disease/petrification) -----------------
// Legacy behaviour: non-contagious, 100%/tick stage advance, escalating pain
// then Stun, then turn_into_statue() at the final stage. Cured by acids.
// The acid cure is preserved via a reagent check (magnitis is the precedent
// for reagent-gated effects), since virus2 has no per-disease reagent cure.

#define PETRIFICATION_ACID_CURED(M) (M.reagents && (M.reagents.has_reagent(SACID) || M.reagents.has_reagent(PACID) || M.reagents.has_reagent(ACIDSPIT) || M.reagents.has_reagent(ACIDTEA)))

/datum/disease2/effect/petrification_warning
	name = "Calcification Syndrome"
	desc = "The infected's tissue stiffens; movement becomes slow and painful."
	stage = 2
	badness = EFFECT_DANGER_HINDRANCE
	restricted = 2
	chance = 10
	max_chance = 25

/datum/disease2/effect/petrification_warning/activate(var/mob/living/mob)
	if(PETRIFICATION_ACID_CURED(mob)) // acid dissolves the petrifying agent
		if(virus)
			virus.cure(mob)
		return
	if(prob(50))
		mob.simple_message("<span class='userdanger'>You are slowing down. Moving is extremely painful for you.</span>",\
			"<span class='notice'>You feel like Michelangelo di Lodovico Buonarroti Simoni trapped in a foreign body.</span>")
		mob.pain_shock_stage += 100
	else
		mob.simple_message("<span class='userdanger'>Your skin starts losing color and cracking. Your body becomes numb.</span>",\
			"<span class='notice'>You decide to channel your inner Italian sculptor to create a beautiful statue.</span>")
		mob.Stun(3)

/datum/disease2/effect/petrification
	name = "Rapid Petrification"
	desc = "UNKNOWN"
	stage = 4
	badness = EFFECT_DANGER_DEADLY
	restricted = 2

/datum/disease2/effect/petrification/activate(var/mob/living/mob)
	if(PETRIFICATION_ACID_CURED(mob))
		if(virus)
			virus.cure(mob)
		return
	if(mob.turn_into_statue(1))
		mob.simple_message("<span class='userdanger'>Your body turns to stone.</span>",\
			"<span class='notice'>You've created a masterwork statue of David!</span>")
		if(virus)
			virus.cure(mob)

#undef PETRIFICATION_ACID_CURED


// ============================================================================
// Contagious symptom diseases. Each old /datum/disease becomes ONE effect that
// switches on the parent disease's stage, reproducing the legacy stage_act()
// exactly: same messages, emotes, damage and stage thresholds. chance = 100 so
// activate() runs every processing tick like the old stage_act did, and the
// internal prob() rolls are copied verbatim. None of these were curable = 1 in
// the old system, so (faithfully) none self-cure by reagent - only the explicit
// rest/random cures the originals had are reproduced.
// ============================================================================

// --- The Flu (was /datum/disease/flu) ---------------------------------------
/datum/disease2/effect/flu
	name = "The Flu"
	desc = "H13N1 flu virion. Aches, coughing and general malaise."
	stage = 1
	badness = EFFECT_DANGER_ANNOYING
	restricted = 2
	chance = 100
	max_chance = 100

/datum/disease2/effect/flu/activate(var/mob/living/carbon/mob)
	switch(virus ? virus.stage : 0)
		if(2, 3)
			var/rest_prob = (virus.stage == 2) ? 20 : 15
			if(mob.lying && prob(rest_prob))
				to_chat(mob, "<span class='notice'>You feel better.</span>")
				virus.stage = max(1, virus.stage - 1)
				return
			if(prob(1))
				mob.emote("sneeze")
			if(prob(1))
				mob.audible_cough()
			if(prob(1))
				to_chat(mob, "<span class='warning'>Your muscles ache.</span>")
				if(prob(20))
					mob.take_organ_damage(1)
			if(prob(1))
				to_chat(mob, "<span class='warning'>Your stomach hurts.</span>")
				if(prob(20))
					mob.adjustToxLoss(1)
					mob.updatehealth()

// --- The Cold (was /datum/disease/cold) -------------------------------------
// NOTE: legacy stage-3 escalation into the flu is reproduced once a predefined
// flu /datum/disease2/disease exists to hand off to (wiring step). Marked TODO.
/datum/disease2/effect/cold
	name = "The Cold"
	desc = "XY-rhinovirus. Sneezing, sore throat; may worsen into the flu."
	stage = 1
	badness = EFFECT_DANGER_ANNOYING
	restricted = 2
	chance = 100
	max_chance = 100

/datum/disease2/effect/cold/activate(var/mob/living/carbon/mob)
	switch(virus ? virus.stage : 0)
		if(2)
			if(mob.lying && prob(40))
				to_chat(mob, "<span class='notice'>You feel better.</span>")
				virus.cure(mob)
				return
			if(prob(1) && prob(5))
				to_chat(mob, "<span class='notice'>You feel better.</span>")
				virus.cure(mob)
				return
			if(prob(1))
				mob.emote("sneeze")
			if(prob(1))
				mob.audible_cough()
			if(prob(1))
				to_chat(mob, "<span class='warning'>Your throat feels sore.</span>")
			if(prob(1))
				to_chat(mob, "<span class='warning'>Mucous runs down the back of your throat.</span>")
		if(3)
			if(mob.lying && prob(25))
				to_chat(mob, "<span class='notice'>You feel better.</span>")
				virus.cure(mob)
				return
			if(prob(1) && prob(1))
				to_chat(mob, "<span class='notice'>You feel better.</span>")
				virus.cure(mob)
				return
			if(prob(1))
				mob.emote("sneeze")
			if(prob(1))
				mob.audible_cough()
			if(prob(1))
				to_chat(mob, "<span class='warning'>Your throat feels sore.</span>")
			if(prob(1))
				to_chat(mob, "<span class='warning'>Mucous runs down the back of your throat.</span>")
			// TODO(wiring): if(prob(1) && prob(50)) hand off to predefined flu disease2, then virus.cure(mob)

// --- The Cold, ICE9 strain (was /datum/disease/cold9) -----------------------
/datum/disease2/effect/cold9
	name = "The Cold (ICE9)"
	desc = "ICE9-rhinovirus. Like the common cold, but leaves the body stiff and cold."
	stage = 1
	badness = EFFECT_DANGER_ANNOYING
	restricted = 2
	chance = 100
	max_chance = 100

/datum/disease2/effect/cold9/activate(var/mob/living/carbon/mob)
	switch(virus ? virus.stage : 0)
		if(2)
			mob.bodytemperature--
			if(prob(1) && prob(10))
				to_chat(mob, "<span class='notice'>You feel better.</span>")
				virus.cure(mob)
				return
			if(prob(1))
				mob.emote("sneeze")
			if(prob(1))
				mob.audible_cough()
			if(prob(1))
				to_chat(mob, "<span class='warning'>Your throat feels sore.</span>")
			if(prob(5))
				to_chat(mob, "<span class='warning'>You feel stiff.</span>")
		if(3)
			mob.bodytemperature -= 2
			if(prob(1))
				mob.emote("sneeze")
			if(prob(1))
				mob.audible_cough()
			if(prob(1))
				to_chat(mob, "<span class='warning'>Your throat feels sore.</span>")
			if(prob(10))
				to_chat(mob, "<span class='warning'>You feel stiff.</span>")

// --- Spanish inquisition Flu (was /datum/disease/fluspanish) -----------------
// NOTE: the legacy stage_act was mis-declared on /datum/disease/inquisition and
// never actually ran. This port reproduces what it was *meant* to do (fever burn).
/datum/disease2/effect/fluspanish
	name = "Spanish Inquisition Flu"
	desc = "1nqu1s1t10n flu virion. The victim burns in their own skin."
	stage = 1
	badness = EFFECT_DANGER_HARMFUL
	restricted = 2
	chance = 100
	max_chance = 100

/datum/disease2/effect/fluspanish/activate(var/mob/living/carbon/mob)
	switch(virus ? virus.stage : 0)
		if(2)
			mob.bodytemperature++
			if(prob(5))
				mob.emote("sneeze")
			if(prob(5))
				mob.audible_cough()
			if(prob(1))
				to_chat(mob, "<span class='warning'>You're burning in your own skin!</span>")
				mob.take_organ_damage(0, 5)
		if(3)
			mob.bodytemperature += 2
			if(prob(5))
				mob.emote("sneeze")
			if(prob(5))
				mob.audible_cough()
			if(prob(5))
				to_chat(mob, "<span class='warning'>You're burning in your own skin!</span>")
				mob.take_organ_damage(0, 5)

// --- GBS (was /datum/disease/gbs) -------------------------------------------
// curable = 0 in the original: the listed Synaptizine+Sulfur cure never actually
// fired. Reproduced faithfully - no reagent cure, only the lethal progression.
/datum/disease2/effect/gbs
	name = "GBS"
	desc = "Gravitokinetic Bipotential SADS+. Escalating toxin buildup, then the body tears itself apart."
	stage = 1
	badness = EFFECT_DANGER_DEADLY
	restricted = 2
	chance = 100
	max_chance = 100

/datum/disease2/effect/gbs/activate(var/mob/living/carbon/mob)
	switch(virus ? virus.stage : 0)
		if(2)
			if(prob(45))
				mob.adjustToxLoss(5)
				mob.updatehealth()
			if(prob(1))
				mob.emote("sneeze")
		if(3)
			if(prob(5))
				mob.audible_cough()
			else if(prob(5))
				mob.emote("gasp", null, null, TRUE)
			if(prob(10))
				to_chat(mob, "<span class='warning'>You're starting to feel very weak...</span>")
		if(4)
			if(prob(10))
				mob.audible_cough()
			mob.adjustToxLoss(5)
			mob.updatehealth()
		if(5)
			to_chat(mob, "<span class='warning'>Your body feels as if it's trying to rip itself open...</span>")
			if(prob(50))
				mob.gib()

// --- Fake GBS (was /datum/disease/fake_gbs) ---------------------------------
// The harmless impostor: looks like GBS, does nothing lethal.
/datum/disease2/effect/fake_gbs
	name = "GBS"
	desc = "Gravitokinetic Bipotential SADS-. Mimics GBS but is ultimately harmless."
	stage = 1
	badness = EFFECT_DANGER_ANNOYING
	restricted = 2
	chance = 100
	max_chance = 100

/datum/disease2/effect/fake_gbs/activate(var/mob/living/carbon/mob)
	switch(virus ? virus.stage : 0)
		if(2)
			if(prob(1))
				mob.emote("sneeze")
		if(3)
			if(prob(5))
				mob.audible_cough()
			else if(prob(5))
				mob.emote("gasp", null, null, TRUE)
			if(prob(10))
				to_chat(mob, "<span class='warning'>You're starting to feel very weak...</span>")
		if(4)
			if(prob(10))
				mob.audible_cough()
		if(5)
			if(prob(10))
				mob.audible_cough()

// --- Brainrot (was /datum/disease/brainrot) ---------------------------------
// curable = 0: alkysine never actually cured it. Faithful port keeps the capped
// brain damage (<=98 guard) and collapse behaviour, no reagent cure.
/datum/disease2/effect/brainrot
	name = "Brainrot"
	desc = "Cryptococcus Cosmosis. Rots the brain - fever, necrosis, collapse."
	stage = 1
	badness = EFFECT_DANGER_HARMFUL
	restricted = 2
	chance = 100
	max_chance = 100

/datum/disease2/effect/brainrot/activate(var/mob/living/carbon/mob)
	switch(virus ? virus.stage : 0)
		if(2)
			if(prob(2))
				mob.emote("blink")
			if(prob(2))
				mob.emote("yawn")
			if(prob(2))
				to_chat(mob, "<span class='warning'>Your don't feel like yourself.</span>")
			if(prob(5))
				mob.adjustBrainLoss(1)
				mob.updatehealth()
		if(3)
			if(prob(2))
				mob.emote("stare", null, null, TRUE)
			if(prob(2))
				mob.emote("drool", null, null, TRUE)
			if(prob(10) && mob.getBrainLoss() <= 98)
				mob.adjustBrainLoss(2)
				mob.updatehealth()
				if(prob(2))
					to_chat(mob, "<span class='warning'>Your try to remember something important...but can't.</span>")
		if(4)
			if(prob(2))
				mob.emote("stare", null, null, TRUE)
			if(prob(2))
				mob.emote("drool", null, null, TRUE)
			if(prob(15) && mob.getBrainLoss() <= 98)
				mob.adjustBrainLoss(3)
				mob.updatehealth()
				if(prob(2))
					to_chat(mob, "<span class='warning'>Strange buzzing fills your head, removing all thoughts.</span>")
			if(prob(3))
				to_chat(mob, "<span class='warning'>You lose consciousness...</span>")
				for(var/mob/O in viewers(mob, null))
					O.show_message("[mob] suddenly collapses", 1)
				mob.Paralyse(rand(5, 10))
				if(prob(1))
					mob.emote("snore", null, null, TRUE)
			if(prob(15))
				mob.stuttering += 3

// --- The Rhumba Beat (was /datum/disease/rhumba_beat) -----------------------
// Keeps the original ckey=="rosham" self-cure gag for fidelity.
/datum/disease2/effect/rhumba_beat
	name = "The Rhumba Beat"
	desc = "An irresistible beat builds inside until the body cannot contain it."
	stage = 1
	badness = EFFECT_DANGER_DEADLY
	restricted = 2
	chance = 100
	max_chance = 100

/datum/disease2/effect/rhumba_beat/activate(var/mob/living/carbon/mob)
	if(mob.ckey == "rosham")
		virus.cure(mob)
		return
	switch(virus ? virus.stage : 0)
		if(2)
			if(prob(45))
				mob.adjustToxLoss(5)
				mob.updatehealth()
			if(prob(1))
				to_chat(mob, "<span class='warning'>You feel strange...</span>")
		if(3)
			if(prob(5))
				to_chat(mob, "<span class='warning'>You feel the urge to dance...</span>")
			else if(prob(5))
				mob.emote("gasp", null, null, TRUE)
			else if(prob(10))
				to_chat(mob, "<span class='warning'>You feel the need to chick chicky boom...</span>")
		if(4)
			if(prob(10))
				mob.emote("gasp", null, null, TRUE)
				to_chat(mob, "<span class='warning'>You feel a burning beat inside...</span>")
			if(prob(20))
				mob.adjustToxLoss(5)
				mob.updatehealth()
		if(5)
			to_chat(mob, "<span class='warning'>Your body is unable to contain the Rhumba Beat...</span>")
			if(prob(50))
				mob.gib()
