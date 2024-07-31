# female
tic(msg = "cc_covid_female")
cdm$cc1_covid_female <- cdm$cc1_covid |>
  requireSex(
    sex = c("Female"),
    name = "cc1_covid_female"
  ) |>
  newCohortTable(
    cohortSetRef = settings(cdm$cc1_covid) |>
      mutate(cohort_name = "cc1_covid_female"),
    .softValidation = TRUE
  )
toc(log = TRUE)

# male
tic(msg = "cc_covid_male")
cdm$cc1_covid_male <- cdm$cc1_covid |>
  requireSex(
    sex = c("Male"),
    name = "cc1_covid_male"
  ) |>
  newCohortTable(
    cohortSetRef = settings(cdm$cc1_covid) |>
      mutate(cohort_name = "cc1_covid_male"),
    .softValidation = TRUE
  )
toc(log = TRUE)

# female < 50
tic(msg = "cc_covid_female_0_to_50")
cdm$cc1_covid_female_0_to_50 <- cdm$cc1_covid |>
  requireDemographics(
    ageRange = list(c(0,50)),
    sex = c("Female"),
    name = "cc1_covid_female_0_to_50"
  ) |>
  newCohortTable(
    cohortSetRef = settings(cdm$cc1_covid) |>
      mutate(cohort_name = "cc1_covid_female_0_to_50"),
    .softValidation = TRUE
  )
toc(log = TRUE)

# female > 50
tic(msg = "cc_covid_female_51_to_150")
cdm$cc1_covid_female_51_to_150 <- cdm$cc1_covid |>
  requireDemographics(
    ageRange = list(c(51, 150)),
    sex = c("Female"),
    name = "cc1_covid_female_51_to_150"
  ) |>
  newCohortTable(
    cohortSetRef = settings(cdm$cc1_covid) |>
      mutate(cohort_name = "cc1_covid_female_51_to_150"),
    .softValidation = TRUE
  )
toc(log = TRUE)

# male < 50
tic(msg = "cc_covid_male_0_to_50")
cdm$cc1_covid_male_0_to_50 <- cdm$cc1_covid |>
  requireDemographics(
    ageRange = list(c(0,50)),
    sex = c("Male"),
    name = "cc1_covid_male_0_to_50"
  ) |>
  newCohortTable(
    cohortSetRef = settings(cdm$cc1_covid) |>
      mutate(cohort_name = "cc1_covid_male_0_to_50"),
    .softValidation = TRUE
  )
toc(log = TRUE)

# male > 50
tic(msg = "cc_covid_male_51_to_150")
cdm$cc1_covid_male_51_to_150 <- cdm$cc1_covid |>
  requireDemographics(
    ageRange = list(c(51, 150)),
    sex = c("Male"),
    name = "cc1_covid_male_51_to_150"
  ) |>
  newCohortTable(
    cohortSetRef = settings(cdm$cc1_covid) |>
      mutate(cohort_name = "cc1_covid_male_51_to_150"),
    .softValidation = TRUE
  )
toc(log = TRUE)

