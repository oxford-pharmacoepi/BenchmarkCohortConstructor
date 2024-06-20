# Prepare Atlas ----
info(logger, "Prepare atlas cohorts")

cdm <- omopgenerics::bind(
  cdm$atlas_asthma_no_copd,
  cdm$atlas_beta_blockers_hypertension,
  cdm$atlas_covid,
  cdm$atlas_endometriosis_procedure,
  # cdm$atlas_first_depression,
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

cdm$atlas <- cdm$atlas |>
  newCohortTable(
    cohortSetRef = settings(cdm$atlas) |> mutate(cohort_name = paste0("atlas_", cohort_name))
  )

# Prepare CC ----
info(logger, "Prepare CC cohorts")

## names ----
### cc_asthma_no_copd
if (nrow(settings(cdm$cc_asthma_no_copd)) > 0) {
  cdm$cc_asthma_no_copd <- cdm$cc_asthma_no_copd |>
    newCohortTable(
      cohortSetRef = settings(cdm$cc_asthma_no_copd) |> mutate(cohort_name = "cc_asthma_no_copd")
    )
}

### cc_neutropenia_leukopenia
if (nrow(settings(cdm$cc_neutropenia_leukopenia)) > 0) {
  cdm$cc_neutropenia_leukopenia <- cdm$cc_neutropenia_leukopenia |>
    newCohortTable(
      cohortSetRef = settings(cdm$cc_neutropenia_leukopenia) |> mutate(cohort_name = "cc_neutropenia_leukopenia")
    )
}

### cc_neutropenia_leukopenia
if (nrow(settings(cdm$cc_transverse_myelitis)) > 0) {
  cdm$cc_transverse_myelitis <- cdm$cc_transverse_myelitis |>
    newCohortTable(
      cohortSetRef = settings(cdm$cc_neutropenia_leukopenia) |> mutate(cohort_name = "cc_transverse_myelitis")
    )
}

### cc_beta_blockers_hypertension
if (nrow(settings(cdm$cc_beta_blockers_hypertension)) > 0) {
  cdm$cc_beta_blockers_hypertension <- cdm$cc_beta_blockers_hypertension |>
    newCohortTable(
      cohortSetRef = tibble(cohort_definition_id = getIds(cdm$cc_base, "howoften_beta_blockers"), cohort_name = "cc_beta_blockers_hypertension")
    )
}

### cc_endometriosis_procedure
if (nrow(settings(cdm$cc_endometriosis_procedure)) > 0) {
  cdm$cc_endometriosis_procedure <- cdm$cc_endometriosis_procedure |>
    newCohortTable(
      cohortSetRef = tibble(cohort_definition_id = getIds(cdm$cc_base, "endometriosis"), cohort_name = "cc_endometriosis_procedure")
    )
}

# ### cc_first_depression
# if (nrow(settings(cdm$cc_first_depression)) > 0) {
#   cdm$cc_first_depression <- cdm$cc_first_depression |>
#     newCohortTable(
#       cohortSetRef = tibble(cohort_definition_id = getIds(cdm$cc_base, "major_depressive_disorder"), cohort_name = "cc_first_depression")
#     )
# }

### cc_hospitalisation
if (nrow(settings(cdm$cc_hospitalisation)) > 0) {
  cdm$cc_hospitalisation <- cdm$cc_hospitalisation |>
    newCohortTable(
      cohortSetRef = tibble(cohort_definition_id = getIds(cdm$cc_base, "inpatient_visit"), cohort_name = "cc_hospitalisation")
    )
}

### cc_major_non_cardiac_surgery
if (nrow(settings(cdm$cc_major_non_cardiac_surgery)) > 0) {
  cdm$cc_major_non_cardiac_surgery <- cdm$cc_major_non_cardiac_surgery |>
    newCohortTable(
      cohortSetRef = tibble(cohort_definition_id = getIds(cdm$cc_base, "major_non_cardiac_surgery"), cohort_name = "cc_major_non_cardiac_surgery")
    )
}

### cc_new_fluoroquinolone
if (nrow(settings(cdm$cc_new_fluoroquinolone)) > 0) {
  cdm$cc_new_fluoroquinolone <- cdm$cc_new_fluoroquinolone |>
    newCohortTable(
      cohortSetRef = tibble(cohort_definition_id = getIds(cdm$cc_base, "howoften_fluoroquinolone_systemic"), cohort_name = "cc_new_fluoroquinolone"),
    )
}

cdm <- omopgenerics::bind(
  cdm$cc_asthma_no_copd,
  cdm$cc_beta_blockers_hypertension,
  cdm$cc_covid,
  cdm$cc_endometriosis_procedure,
  # cdm$cc_first_depression,
  cdm$cc_hospitalisation,
  cdm$cc_major_non_cardiac_surgery,
  cdm$cc_neutropenia_leukopenia,
  cdm$cc_new_fluoroquinolone,
  cdm$cc_transverse_myelitis,
  cdm$cc_covid_strata,
  name = "cc"
)

cdm <- omopgenerics::bind(
  cdm$cc,
  cdm$atlas,
  name = "benchmark_cohorts"
)

info(logger, "Summarise overlap")
overlap <- summariseCohortOverlap(cdm$benchmark_cohorts)
info(logger, "Summarise timing")
timing <- summariseCohortTiming(cdm$benchmark_cohorts)

omopgenerics::bind(overlap, timing) |>
  omopgenerics::exportSummarisedResult(path = output_folder)
