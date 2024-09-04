cdm$temp_cc1_asthma_base <- conceptCohort(
  cdm = cdm,
  conceptSet = codes[c(
    "asthma_therapy", "asthma", "chronic_obstructive_lung_disease",
    "long_acting_muscarinic_antagonists_lamas"
  )],
  name = "temp_cc1_asthma_base"
)

cdm$temp_cc1_asthma_base <- cdm$temp_cc1_asthma_base  |>
  requireAge(ageRange = list(c(0,54)), cohortId = getIds(cdm$temp_cc1_asthma_base, "asthma_therapy")) |>
  requireCohortIntersect(
    targetCohortTable = "temp_cc1_asthma_base",
    window = c(-365, -180),
    intersections = c(1, Inf),
    cohortId = getIds(cdm$temp_cc1_asthma_base, "asthma_therapy"),
    targetCohortId = getIds(cdm$temp_cc1_asthma_base, "asthma_therapy"),
    targetEndDate = NULL
  )

cdm$cc1_asthma_no_copd <- cdm$temp_cc1_asthma_base |>
  CohortConstructor::unionCohorts(
    cohortId = getIds(cdm$temp_cc1_asthma_base, c("asthma_therapy", "asthma")),
    name = "cc1_asthma_no_copd",
    cohortName = "cc1_asthma_no_copd"
  ) |>
  requireIsFirstEntry() |>
  requireCohortIntersect(
    targetCohortTable = "temp_cc1_asthma_base",
    targetCohortId = getIds(cdm$temp_cc1_asthma_base, "chronic_obstructive_lung_disease"),
    window = list(c(-Inf,0)),
    intersections = 0
  ) |>
  requireCohortIntersect(
    targetCohortTable = "temp_cc1_asthma_base",
    targetCohortId = getIds(cdm$temp_cc1_asthma_base, "long_acting_muscarinic_antagonists_lamas"),
    window = list(c(-Inf,0)),
    intersections = 0
  )
