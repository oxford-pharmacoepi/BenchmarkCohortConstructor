cdm$temp_cc1_neutropenia_leukopenia_concepts <- conceptCohort(
  cdm = cdm,
  conceptSet = codes[c(
    "neutropenia_agranulocytosis_or_unspecified_leukopenia",
    "congenital_or_genetic_neutropenia_leukopenia_or_agranulocytosis",
    "neutrophilia"
  )],
  name = "temp_cc1_neutropenia_leukopenia_concepts"
)

cdm$temp_cc1_neutropenia_leukopenia_measurement <- measurementCohort(
  cdm = cdm,
  conceptSet = codes["neutrophil_absolute_count"],
  name = "temp_cc1_neutropenia_leukopenia_measurement",
  valueAsNumber = list(
    "9444" = c(0.01, 1.499), "8848" = c(0.01, 1.499), "8816" = c(0.01, 1.499),
    "8961" = c(0.01, 1.499), "44777588" = c(0.01, 1.499),
    "8784" = c(10, 1499), "8647" = c(10, 1499)
  )
)

cdm$temp_cc1_normal_neutrophil <- measurementCohort(
  cdm = cdm,
  conceptSet = codes["neutrophil_absolute_count"],
  name = "temp_cc1_normal_neutrophil",
  valueAsNumber = list(
    "9444" = c(4, 8.25), "8848" = c(4, 8.25), "8816" = c(4, 8.25),
    "8961" = c(4, 8.25), "44777588" = c(4, 8.25),
    "8784" = c(4000, 8250), "8647" = c(4000, 8250)
  )
)

cdm$cc1_neutropenia_leukopenia <- cdm$temp_cc1_neutropenia_leukopenia_concepts |>
  subsetCohorts(
    cohortId = getIds(cdm$temp_cc1_neutropenia_leukopenia_concepts, "neutropenia_agranulocytosis_or_unspecified_leukopenia"),
    name = "cc1_neutropenia_leukopenia"
  )

cdm <- bind(
  cdm$cc1_neutropenia_leukopenia, cdm$temp_cc1_neutropenia_leukopenia_measurement,
  name = "cc1_neutropenia_leukopenia"
)

cdm$cc1_neutropenia_leukopenia <- cdm$cc1_neutropenia_leukopenia |>
  CohortConstructor::unionCohorts(cohortName = "cc1_neutropenia_leukopenia") |>
  # No congenital or genetic neutropenia, leukopenia or agranulocytosis
  requireCohortIntersect(
    targetCohortTable = "temp_cc1_neutropenia_leukopenia_concepts",
    window = list(c(-Inf, 7)),
    intersections = 0,
    targetCohortId = getIds(cdm$temp_cc1_neutropenia_leukopenia_concepts, "congenital_or_genetic_neutropenia_leukopenia_or_agranulocytosis"),
    targetEndDate = NULL
  ) |>
  # No Neutrophilia on index date
  requireCohortIntersect(
    targetCohortTable = "temp_cc1_neutropenia_leukopenia_concepts",
    window = list(c(0,0)),
    intersections = 0,
    targetCohortId = getIds(cdm$temp_cc1_neutropenia_leukopenia_concepts, "neutrophilia"),
    targetEndDate = NULL
  ) |>
  # No Normal Neutrophil count on index date
  requireCohortIntersect(
    targetCohortTable = "temp_cc1_normal_neutrophil",
    window = list(c(0,0)),
    intersections = 0,
    targetCohortId = 1,
    targetEndDate = NULL
  )

# exit date: end date but censor at normal counts
cdm$cc1_neutropenia_leukopenia <- cdm$cc1_neutropenia_leukopenia |>
  addCohortIntersectDate(
    targetCohortTable = "temp_cc1_normal_neutrophil",
    window = list(c(0,Inf)),
    nameStyle = "normal_count_date",
    name = "cc1_neutropenia_leukopenia"
  ) |>
  exitAtFirstDate(dateColumns = c("cohort_end_date", "normal_count_date"), returnReason = FALSE)
