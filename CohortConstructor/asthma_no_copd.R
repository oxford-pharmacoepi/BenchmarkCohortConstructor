cdm$cc1_asthma_base <- conceptCohort(
  cdm = cdm,
  conceptSet = codes[c(
    "asthma_therapy", "asthma",  "chronic_obstructive_lung_disease",
    "long-acting_muscarinic_antagonists_(lamas)"
  )],
  name = "cc1_asthma_base"
)

cdm$cc1_asthma_base <- cdm$cc1_asthma_base |>
  requireAge(ageRange = list(c(0,54)), cohortId = 1) |>
  requireCohortIntersect(
    targetCohortTable = "cc1_asthma_base",
    window = c(-365, -180),
    intersections = c(1, Inf),
    cohortId = 1,
    targetCohortId = 1
  )

cdm$cc1_asthma_no_copd <- cdm$cc1_asthma_base |>
  unionCohorts(cohortId = 1:2, name = "cc1_asthma_no_copd", cohortName = "cc1_asthma_no_copd") |>
  requireIsFirstEntry() |>
  requireCohortIntersect(
    targetCohortTable = "cc1_asthma_base",
    targetCohortId = 3,
    window = list(c(-Inf,0)),
    intersections = 0
  ) |>
  requireCohortIntersect(
    targetCohortTable = "cc1_asthma_base",
    targetCohortId = 4,
    window = list(c(-Inf,0)),
    intersections = 0
  )
