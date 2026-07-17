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
