# overlap and timing
cdm <- omopgenerics::bind(
  cdm$atlas_asthma_no_copd,
  cdm$atlas_beta_blockers_hypertension,
  cdm$atlas_covid,
  cdm$atlas_endometriosis_procedure,
  cdm$atlas_first_depression,
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
  cdm$cc_asthma_no_copd,
  cdm$cc_beta_blockers_hypertension,
  cdm$cc_covid,
  cdm$cc_endometriosis_procedure,
  cdm$cc_first_depression,
  cdm$cc_hospitalisation,
  cdm$cc_major_non_cardiac_surgery,
  cdm$cc_neutropenia_leukopenia,
  cdm$cc_new_fluoroquinolone,
  cdm$cc_transverse_myelitis,
  cdm$cc_covid_female,
  cdm$cc_covid_female_0_to_50,
  cdm$cc_covid_female_51_to_150,
  cdm$cc_covid_male,
  cdm$cc_covid_male_0_to_50,
  cdm$cc_covid_male_51_to_150,
  name = "benchmark_cohorts"
)

overlap <- summariseCohortOverlap(cdm$benchmark_cohorts)
timing <- summariseCohortTiming(cdm$benchmark_cohorts)

omopgenerics::bind(overlap, timing) |>
  omopgenerics::exportSummarisedResult(path = output_folder)
