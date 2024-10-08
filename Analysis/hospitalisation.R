cdm$cc1_hospitalisation <- conceptCohort(
  cdm = cdm,
  conceptSet = codes["inpatient_visit"],
  name = "cc1_hospitalisation"
)

cdm$cc1_hospitalisation <- cdm$cc1_hospitalisation |>
  collapseCohorts(gap = 1) |>
  mutate(end_1 = as.Date(add_days(.data$cohort_end_date, 1L))) |>
  addFutureObservation(futureObservationType = "date", name = "cc1_hospitalisation") |>
  exitAtFirstDate(dateColumns = c("end_1", "future_observation"), returnReason = FALSE) |>
  newCohortTable(
    cohortSetRef = settings(cdm$cc1_hospitalisation) |>
      mutate(cohort_name = "cc1_hospitalisation"),
    .softValidation = TRUE
  )
