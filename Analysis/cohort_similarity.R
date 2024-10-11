# Prepare cohorts ----
info(logger, " - 1. Prepare cohorts")
info(logger, "   1.1 Atlas Cohorts")
cdm <- omopgenerics::bind(
  cdm$atlas_asthma_no_copd,
  cdm$atlas_beta_blockers_hypertension,
  cdm$atlas_covid,
  cdm$atlas_endometriosis_procedure,
  cdm$atlas_hospitalisation,
  cdm$atlas_major_non_cardiac_surgery,
  cdm$atlas_neutropenia_leukopenia,
  cdm$atlas_new_fluoroquinolone,
  cdm$atlas_transverse_myelitis,
  cdm$atlas_covid_female,
  cdm$atlas_covid_female_0_to_50,
  cdm$atlas_covid_female_51_to_150,
  cdm$atlas_covid_male,
  cdm$atlas_covid_male_0_to_50,
  cdm$atlas_covid_male_51_to_150,
  name = "atlas"
)

if (useFirstDepression) {
  cdm <- omopgenerics::bind(cdm$atlas, cdm$atlas_first_depression, name = "atlas")
}

cdm$atlas <- cdm$atlas |>
  newCohortTable(
    cohortSetRef = settings(cdm$atlas) |> mutate(cohort_name = paste0("atlas_", cohort_name)),
    .softValidation = TRUE
  )

info(logger, "   1.2 CC set Cohorts")
cdm <- omopgenerics::bind(
  cdm$cc_asthma_no_copd,
  cdm$cc_beta_blockers_hypertension,
  cdm$cc_covid,
  cdm$cc_endometriosis_procedure,
  cdm$cc_hospitalisation,
  cdm$cc_major_non_cardiac_surgery,
  cdm$cc_neutropenia_leukopenia,
  cdm$cc_new_fluoroquinolone,
  cdm$cc_transverse_myelitis,
  cdm$cc_covid_strata,
  name = "cc_set"
)

if (useFirstDepression) {
  cdm <- omopgenerics::bind(cdm$cc_set, cdm$cc_first_depression, name = "cc_set")
}

info(logger, "   1.3 CC separately Cohorts")
cdm <- omopgenerics::bind(
  cdm$cc1_asthma_no_copd,
  cdm$cc1_beta_blockers_hypertension,
  cdm$cc1_covid,
  cdm$cc1_endometriosis_procedure,
  cdm$cc1_hospitalisation,
  cdm$cc1_major_non_cardiac_surgery,
  cdm$cc1_neutropenia_leukopenia,
  cdm$cc1_new_fluoroquinolone,
  cdm$cc1_transverse_myelitis,
  cdm$cc1_covid_female,
  cdm$cc1_covid_female_0_to_50,
  cdm$cc1_covid_female_51_to_150,
  cdm$cc1_covid_male,
  cdm$cc1_covid_male_0_to_50,
  cdm$cc1_covid_male_51_to_150,
  name = "cc_separately"
)

if (useFirstDepression) {
  cdm <- omopgenerics::bind(cdm$cc_separately, cdm$cc1_first_depression, name = "cc_separately")
}

info(logger, "   1.4 Bind all")
cdm <- omopgenerics::bind(
  cdm$cc_set,
  cdm$cc_separately,
  cdm$atlas,
  name = "benchmark_cohorts"
)

cohortDetails <- list()
cohortDetails$atlas <- summary(cdm$atlas)
cohortDetails$cc_set <- summary(cdm$cc_set)
cohortDetails$cc_separately <- summary(cdm$cc_separately)
omopgenerics::bind(cohortDetails) |>
  omopgenerics::exportSummarisedResult(
    path = output_folder, fileName = paste0("cohort_details_", database_name, ".csv")
  )

# Summarise overlap and density ----
info(logger, "Summarise overlap")
overlap <- summariseCohortOverlap(cdm$benchmark_cohorts)
info(logger, "Summarise timing")
timing <- summariseCohortTiming(cdm$benchmark_cohorts, density = TRUE)

omopgenerics::bind(overlap, timing) |>
  omopgenerics::exportSummarisedResult(
    path = output_folder, fileName = paste0("cohort_comparison_", database_name, ".csv")
  )
