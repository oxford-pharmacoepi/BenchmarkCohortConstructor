# cdm$cc1_first_depression <- conceptCohort(
#   cdm = cdm,
#   conceptSet = codes[c(
#     "major_depressive_disorder", "bipolar_disorder", "schizoaffective_disorder",
#     "schizophrenia_not_including_paraphenia", "dementia", "psychotic_disorder"
#   )],
#   name = "cc1_first_depression"
# )
#
# cdm$cc1_first_depression <- cdm$cc1_first_depression |>
#   requireIsFirstEntry(cohortId = 1) |>
#   requireCohortIntersect(
#     targetCohortTable = "cc1_first_depression",
#     window = list(c(-Inf, 0)),
#     intersections = 0,
#     cohortId = 1,
#     targetCohortId = 2,
#     targetEndDate = NULL
#   ) |>
#   requireCohortIntersect(
#     targetCohortTable = "cc1_first_depression",
#     window = list(c(-Inf, 0)),
#     intersections = 0,
#     cohortId = 1,
#     targetCohortId = 3,
#     targetEndDate = NULL
#   ) |>
#   requireCohortIntersect(
#     targetCohortTable = "cc1_first_depression",
#     window = list(c(-Inf, 0)),
#     intersections = 0,
#     cohortId = 1,
#     targetCohortId = 4,
#     targetEndDate = NULL
#   ) |>
#   requireCohortIntersect(
#     targetCohortTable = "cc1_first_depression",
#     window = list(c(-Inf, 0)),
#     intersections = 0,
#     cohortId = 1,
#     targetCohortId = 5,
#     targetEndDate = NULL
#   ) |>
#   requireCohortIntersect(
#     targetCohortTable = "cc1_first_depression",
#     window = list(c(-Inf, 0)),
#     intersections = 0,
#     cohortId = 1,
#     targetCohortId = 6,
#     targetEndDate = NULL
#   ) |>
#   subsetCohorts(cohortId = 1) |>
#   exitAtObservationEnd()
