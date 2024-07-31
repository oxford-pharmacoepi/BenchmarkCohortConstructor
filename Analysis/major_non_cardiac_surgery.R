cdm$cc1_major_non_cardiac_surgery <- conceptCohort(
  cdm = cdm,
  conceptSet = codes[c("major_non_cardiac_surgery")],
  name = "cc1_major_non_cardiac_surgery"
) |>
  requireIsFirstEntry() |>
  requireAge(ageRange = list(c(18, 150))) |>
  exitAtObservationEnd()

cdm$cc1_major_non_cardiac_surgery <- cdm$cc1_major_non_cardiac_surgery |>
  newCohortTable(
    cohortSetRef = settings(cdm$cc1_major_non_cardiac_surgery) |>
      mutate(cohort_name = "cc1_major_non_cardiac_surgery"),
    .softValidation = TRUE
  )
