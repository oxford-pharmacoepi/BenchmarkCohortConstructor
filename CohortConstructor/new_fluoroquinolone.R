cdm$cc1_new_fluoroquinolone <- conceptCohort(
  cdm = cdm,
  conceptSet = codes["[howoften]_fluoroquinolone_systemic"],
  name = "cc1_new_fluoroquinolone"
) |>
  requirePriorObservation(minPriorObservation = 365) |>
  collapseCohorts(gap = 30) |>
  requireIsFirstEntry()
