cdm$cc1_endometriosis_procedure <- conceptCohort(
  cdm = cdm,
  conceptSet = codes[c("endometriosis_related_laproscopic_procedures", "endometriosis")],
  name = "cc1_endometriosis_procedure"
)

cdm$cc1_endometriosis_procedure <- cdm$cc1_endometriosis_procedure |>
  requireCohortIntersect(
    targetCohortTable = "cc1_endometriosis_procedure",
    window = list(c(-30, 30)),
    intersections = c(1, Inf),
    cohortId = getIds(cdm$cc1_endometriosis_procedure, "endometriosis_related_laproscopic_procedures"),
    targetCohortId = getIds(cdm$cc1_endometriosis_procedure, "endometriosis"),
    targetEndDate = NULL
  ) |>
  # 2 or more entrometiosis diagnosed
  requireCohortIntersect(
    targetCohortTable = "cc1_endometriosis_procedure",
    window = list(c(0, Inf)),
    intersections = c(2, Inf),
    cohortId = getIds(cdm$cc1_endometriosis_procedure, "endometriosis_related_laproscopic_procedures"),
    targetCohortId = getIds(cdm$cc1_endometriosis_procedure, "endometriosis"),
    targetEndDate = NULL
  ) |>
  subsetCohorts(cohortId = getIds(cdm$cc1_endometriosis_procedure, "endometriosis_related_laproscopic_procedures")) |>
  requireDemographics(
    ageRange = list(c(15, 49)),
    sex = "Female"
  ) |>
  requireIsFirstEntry() |>
  exitAtObservationEnd()

cdm$cc1_endometriosis_procedure <- cdm$cc1_endometriosis_procedure |>
  newCohortTable(
    cohortSetRef = settings(cdm$cc1_endometriosis_procedure) |>
      mutate(cohort_name = "cc1_endometriosis_procedure"),
    .softValidation = TRUE
  )
