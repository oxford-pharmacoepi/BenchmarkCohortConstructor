cdm$cc1_covid <- conceptCohort(
  cdm = cdm,
  conceptSet = codes[c("covid_19")],
  name = "cc1_covid"
)

cdm$cc1_covid_test_positive <- measurementCohort(
  cdm = cdm,
  conceptSet = codes["sars_cov_2_test"],
  name = "cc1_covid_test_positive",
  valueAsConcept = c(4126681, 45877985, 9191, 45884084, 4181412, 45879438)
)

cdm$cc1_covid_test_negative <- measurementCohort(
  cdm = cdm,
  conceptSet = codes["sars_cov_2_test"],
  name = "cc1_covid_test_negative",
  valueAsConcept = c(9189, 9190, 9191, 4132135, 3661867, 45878583, 45880296, 45884086)
)

cdm$cc1_covid <- cdm$cc1_covid |>
  requireCohortIntersect(
    targetCohortTable = "cc1_covid_test_negative",
    targetCohortId = 1,
    window = list(c(-3,3)),
    intersections = 0
  )

cdm <- omopgenerics::bind(cdm$cc1_covid, cdm$cc1_covid_test_positive, name = "cc1_covid")

cdm$cc1_covid <-  cdm$cc1_covid |>
  CohortConstructor::unionCohorts() |>
  requireInDateRange(dateRange = c(as.Date("2019-12-02"), NA))
