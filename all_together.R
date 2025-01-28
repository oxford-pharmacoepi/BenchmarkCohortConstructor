benchmarkCohortConstructor <- function(cdm) {
  # TODO check inputs

  # Read JSONs of cohorts to create ----
  jsons <- CDMConnector::readCohortSet(here::here("JSONCohorts")) |>
    dplyr::filter(.data$cohort_name != "first_depression")

  # Instantiate or read Atlas ----
  cli::cli_inform(c("*" = "Instantiating JSONs"))
  for (json in jsons$cohort_name_snakecase) {
    tictoc::tic(msg = paste0("atlas_", json))
    cdm <- CDMConnector::generateCohortSet(
      cdm = cdm,
      cohortSet = jsons |> dplyr::filter(.data$cohort_name_snakecase == .env$json),
      name = paste0("atlas_", json),
      computeAttrition = TRUE,
      overwrite = TRUE
    )
    tictoc::toc(log = TRUE)
  }

  # Get codelist ----
  concept_sets <- c(
    "inpatient_visit", "beta_blockers", "symptoms_for_transverse_myelitis",
    "asthma_therapy", "fluoroquinolone_systemic",
    "congenital_or_genetic_neutropenia_leukopenia_or_agranulocytosis",
    "endometriosis", "chronic_obstructive_lung_disease", "essential_hypertension",
    "asthma", "neutropenia_agranulocytosis_or_unspecified_leukopenia",
    "dementia", "schizophrenia_not_including_paraphenia", "psychotic_disorder",
    "bipolar_disorder", "major_depressive_disorder", "transverse_myelitis",
    "schizoaffective_disorder", "endometriosis_related_laproscopic_procedures",
    "long_acting_muscarinic_antagonists_lamas", "neutrophilia", "covid_19",
    "sars_cov_2_test", "neutrophil_absolute_count",
    "mncs_abdominal_aortic_aneurysm_repair", "mncs_above_knee_amputation",
    "mncs_adrenalectomy", "mncs_appendectomy", "mncs_below_knee_amputation",
    "mncs_breast_reconstruction", "mncs_celiac_artery_revascularization",
    "mncs_cerebrovascular_surgery", "mncs_cholecystectomy",
    "mncs_complex_visceral_resection_liver", "mncs_complex_visceral_resection_oesophagus",
    "mncs_complex_visceral_resection_pancreas_biliary", "mncs_craniotomy",
    "mncs_head_neck_resection", "mncs_hysterectomy_opherectomy",
    "mncs_iliac_femoral_bypass", "mncs_internal_fixation_femur", "mncs_knee_arthroplasty",
    "mncs_lobectomy", "mncs_lymph_node_dissection", "mncs_major_hip_pelvic_surgery",
    "mncs_mytoreductive_surgery", "mncs_peripheral_vascular_lower_limb_arterial_bypass",
    "mncs_pneumonectomy", "mncs_radical_hysterectomy", "mncs_radical_prostatectomy",
    "mncs_renal_artery_revascularization", "mncs_sb_colon_rectal", "mncs_splenectomy",
    "mncs_stomach_surgery", "mncs_thoracic_resection", "mncs_thoracic_vascular_surgery",
    "mncs_transurethral_prostatectomy", "mncs_ureteric_kidney_bladder_surgery"
  )
  codes_cdm <- CodelistGenerator::codesFromCohort(here("JSONCohorts"), cdm)
  codes <- as.list(rep(100001L, length(concept_sets))) # mock concept as pleace-holder
  for (nm in names(codes_cdm)) {
    codes[nm] <- codes_cdm[nm]
  }
  base <- c(codes[])
  measurement <- codes[]
  require <- codes[]

  # CohortConstructor by definition ----
  tictoc::tic(msg = paste0("cc1_asthma_no_copd"))
  cdm <- getAsthma(cdm, codes)
  tictoc::toc(log = TRUE)
  tictoc::tic(msg = paste0("cc1_beta_blockers_hypertension"))
  cdm <- getBetaBlockers(cdm, codes)
  tictoc::toc(log = TRUE)
  tictoc::tic(msg = paste0("cc1_covid"))
  cdm <- getCovid(cdm, codes)
  tictoc::toc(log = TRUE)
  tictoc::tic(msg = paste0("cc1_covid_female"))
  cdm <- getCovidStrata(
    cdm, codes, sex = "Female", ageRange = NULL, name = "cc1_covid_female"
  )
  tictoc::toc(log = TRUE)
  tictoc::tic(msg = paste0("cc1_covid_female_0_to_50"))
  cdm <- getCovidStrata(
    cdm, codes, sex = "Female", ageRange = list(c(0, 50)), name = "cc1_covid_female_0_to_50"
  )
  tictoc::toc(log = TRUE)
  tictoc::tic(msg = paste0("cc1_covid_female_51_to_150"))
  cdm <- getCovidStrata(
    cdm, codes, sex = "Female", ageRange = list(c(51, 150)), name = "cc1_covid_female_51_to_150"
  )
  tictoc::toc(log = TRUE)
  tictoc::tic(msg = paste0("cc1_covid_male"))
  cdm <- getCovidStrata(
    cdm, codes, sex = "Male", ageRange = NULL, name = "cc1_covid_male"
  )
  tictoc::toc(log = TRUE)
  tictoc::tic(msg = paste0("cc1_covid_male_0_to_50"))
  cdm <- getCovidStrata(
    cdm, codes, sex = "Male", ageRange = list(c(0, 50)), name = "cc1_covid_male_0_to_50"
  )
  tictoc::toc(log = TRUE)
  tictoc::tic(msg = paste0("cc1_covid_male_51_to_150"))
  cdm <- getCovidStrata(
    cdm, codes, sex = "Male", ageRange = list(c(51, 150)), name = "cc1_covid_male_51_to_150"
  )
  tictoc::toc(log = TRUE)
  tictoc::tic(msg = paste0("cc1_endometriosis_procedure"))
  cdm <- getEndometriosisProcedure(cdm, codes)
  tictoc::toc(log = TRUE)
  tictoc::tic(msg = paste0("cc1_hospitalisation"))
  cdm <- getHospitalisation(cdm, codes)
  tictoc::toc(log = TRUE)
  tictoc::tic(msg = paste0("cc1_major_non_cardiac_surgery"))
  cdm <- getMajorNonCardiacSurgery(cdm, codes)
  tictoc::toc(log = TRUE)
  tictoc::tic(msg = paste0("cc1_neutropenia_leukopenia"))
  cdm <- getNeutropeniaLeukopenia(cdm, codes)
  tictoc::toc(log = TRUE)
  tictoc::tic(msg = paste0("cc1_new_fluoroquinolone"))
  cdm <- getNewFluoroquinolone(cdm, codes)
  tictoc::toc(log = TRUE)
  tictoc::tic(msg = paste0("cc1_transverse_myelitis"))
  cdm <- getTransverseMyelitis(cdm, codes)
  tictoc::toc(log = TRUE)

  # CohortConstructor by concept ----
  tictoc::tic(msg = paste0("cc_set_no_strata"))
  cdm <- getCohortConstructorSet(cdm, codes)
  tictoc::toc(log = TRUE)
  tictoc::tic(msg = paste0("cc_set_strata"))
  cdm <- getCohortConstructorSet(cdm, codes)
  tictoc::toc(log = TRUE)

  # Evaluate cohorts ----

  # Use SQL indexes ----

  # Format time results ----
  results <- tic.log(format = FALSE) |> purrr::map_df(~as_tibble(.x))
}

# functions ----
getId <- function(cohort, cohort_names) {
  settings(cohort) |>
    dplyr::filter(.data$cohort_name %in% .env$cohort_names) |>
    dplyr::pull("cohort_definition_id")
}

getCohortConstructorSet <- function(cdm, codes) {

}

getAsthma <- function(cdm, codes) {
  cdm <- conceptCohort(
    cdm = cdm,
    conceptSet = codes[c("asthma", "asthma_therapy")],
    name = "cc1_asthma_no_copd",
    exit = "event_end_date",
    overlap = "merge",
    useSourceFields = FALSE,
    subsetCohort = NULL,
    subsetCohortId = NULL
  )

  cdm$cc_asthma <- cdm$cc_asthma |>
    # age to asthma therapy
    requireAge(
      ageRange = list(c(0, 54)),
      cohort = getId(cdm$cc_asthma, "asthma_therapy"),
      indexDate = "cohort_start_date"
    ) |>
    # previous asthma therapy concepts
    requireConceptIntersect(
      conceptSet = codes["asthma_therapy"],
      window = list(c(-365, -180)),
      intersections = c(1, Inf),
      cohortId = getId(cdm$cc_asthma, "asthma_therapy"),
      indexDate = "cohort_start_date",
      targetStartDate = "event_start_date",
      targetEndDate = NULL,
      inObservation = FALSE,
      censorDate = NULL
    ) |>
    # union all entries
    unionCohorts(
      cohortId = NULL,
      gap = 0,
      cohortName = "cc1_asthma_no_copd",
      keepOriginalCohorts = FALSE
    ) |>
    # get first entry
    requireIsFirstEntry() |>
    # NO chronic_obstructive_lung_disease
    requireConceptIntersect(
      conceptSet = codes["chronic_obstructive_lung_disease"],
      window = list(c(-Inf, 0)),
      intersections = 0,
      cohortId = NULL,
      indexDate = "cohort_start_date",
      targetStartDate = "event_start_date",
      targetEndDate = NULL,
      inObservation = TRUE,
      censorDate = NULL
    ) |>
    # NO long_acting_muscarinic_antagonists_lamas
    requireConceptIntersect(
      conceptSet = codes["long_acting_muscarinic_antagonists_lamas"],
      window = list(c(-Inf, 0)),
      intersections = 0,
      cohortId = NULL,
      indexDate = "cohort_start_date",
      targetStartDate = "event_start_date",
      targetEndDate = NULL,
      inObservation = TRUE,
      censorDate = NULL
    )
  return(cdm)
}

getBetaBlockers <- function(cdm, codes) {
  cdm <- conceptCohort(
    cdm = cdm,
    conceptSet = codes["beta_blockers"],
    name = "cc1_beta_blockers_hypertension"
  ) |>
    collapseCohorts(gap = 90) |>
    requireIsFirstEntry() |>
    requirePriorObservation(minPriorObservation = 365) |>
    requireConceptIntersect(
      conceptSet = codes["essential_hypertension"],
      window = list(c(-Inf, 0)),
      intersections = c(1, Inf),
      cohortId = NULL,
      indexDate = "cohort_start_date",
      targetStartDate = "event_start_date",
      targetEndDate = NULL
    )
  cdm$cc1_beta_blockers_hypertension <- cdm$cc1_beta_blockers_hypertension |>
    omopgenerics::newCohortTable(
      cohortSetRef = settings(cdm$cc1_beta_blockers_hypertension) |>
        dplyr::mutate("cohort_name" = "cc1_beta_blockers_hypertension"),
      .softValidation = TRUE
    )
  return(cdm)
}

getCovid <- function(cdm, codes, name = "cc1_covid") {
  cdm[[name]] <- conceptCohort(
    cdm = cdm,
    conceptSet = codes[c("covid_19")],
    name = name
  )
  cdm$temp_cc1_covid_test_positive <- measurementCohort(
    cdm = cdm,
    conceptSet = codes["sars_cov_2_test"],
    name = "temp_cc1_covid_test_positive",
    valueAsConcept = c(4126681, 45877985, 9191, 45884084, 4181412, 45879438)
  )
  cdm$temp_cc1_covid_test_negative <- measurementCohort(
    cdm = cdm,
    conceptSet = codes["sars_cov_2_test"],
    name = "temp_cc1_covid_test_negative",
    valueAsConcept = c(9189, 9190, 9191, 4132135, 3661867, 45878583, 45880296, 45884086)
  )
  cdm[[name]] <- cdm[[name]] |>
    requireCohortIntersect(
      targetCohortTable = "temp_cc1_covid_test_negative",
      targetCohortId = 1,
      targetEndDate = NULL,
      window = list(c(-3,3)),
      intersections = 0
    )
  cdm <- omopgenerics::bind(cdm[[name]], cdm$temp_cc1_covid_test_positive, name = name)
  cdm[[name]] <-  cdm[[name]] |>
    CohortConstructor::unionCohorts(cohortName = name) |>
    requireInDateRange(dateRange = c(as.Date("2019-12-02"), NA))
  return(cdm)
}

getCovidStrata <- function(cdm, codes, sex, ageRange, name) {
  cdm <- getCovid(cdm, codes, name = name)
  cdm[[name]] <- cdm[[name]] |>
    requireDemographics(
      ageRange = ageRange,
      sex = sex
    )
  return(cdm)
}

getEndometriosisProcedure <- function(cdm, codes) {

}
