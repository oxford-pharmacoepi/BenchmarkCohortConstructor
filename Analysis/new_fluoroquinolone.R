cdm$cc1_new_fluoroquinolone <- conceptCohort(
  cdm = cdm,
  conceptSet = codes["howoften_fluoroquinolone_systemic"],
  name = "cc1_new_fluoroquinolone"
) |>
  collapseCohorts(gap = 30) |>
  requireIsFirstEntry() |>
  requirePriorObservation(minPriorObservation = 365)

cdm$cc1_new_fluoroquinolone <- cdm$cc1_new_fluoroquinolone |>
  newCohortTable(
    cohortSetRef = settings(cdm$cc1_new_fluoroquinolone) |>
      mutate(cohort_name = "cc1_new_fluoroquinolone"),
    .softValidation = TRUE
  )
