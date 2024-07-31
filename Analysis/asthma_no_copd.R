cdm$temp_cc1_asthma_base <- conceptCohort(
  cdm = cdm,
  conceptSet = codes[c(
    "asthma_therapy", "asthma",  "chronic_obstructive_lung_disease",
    "long_acting_muscarinic_antagonists_lamas"
  )],
  name = "temp_cc1_asthma_base"
)

cdm$temp_cc1_asthma_base <- cdm$temp_cc1_asthma_base  |>
  requireAge(ageRange = list(c(0,54)), cohortId = 1) |>
  requireCohortIntersect(
    targetCohortTable = "temp_cc1_asthma_base",
    window = c(-365, -180),
    intersections = c(1, Inf),
    cohortId = 1,
    targetCohortId = 1,
    targetEndDate = NULL
  )

cdm$cc1_asthma_no_copd <- cdm$temp_cc1_asthma_base |>
  CohortConstructor::unionCohorts(
    cohortId = 1:2,
    name = "cc1_asthma_no_copd",
    cohortName = "cc1_asthma_no_copd"
  ) |>
  requireIsFirstEntry() |>
  requireCohortIntersect(
    targetCohortTable = "temp_cc1_asthma_base",
    targetCohortId = 3,
    window = list(c(-Inf,0)),
    intersections = 0
  ) |>
  requireCohortIntersect(
    targetCohortTable = "temp_cc1_asthma_base",
    targetCohortId = 4,
    window = list(c(-Inf,0)),
    intersections = 0
  )
