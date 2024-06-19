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
    cohortId = 1,
    targetCohortId = 2
  ) |>
  # 2 or more entrometiosis diagnosed
  requireCohortIntersect(
    targetCohortTable = "cc1_endometriosis_procedure",
    window = list(c(0, Inf)),
    intersections = c(2, Inf),
    cohortId = 1,
    targetCohortId = 2
  ) |>
  subsetCohorts(cohortId = 1) |>
  requireIsFirstEntry() |>
  requireDemographics(
    ageRange = list(c(15, 49)),
    sex = "Female"
  ) |>
  exitAtObservationEnd()
