# female
tic(msg = "cc_covid_female")
cdm$cc1_covid_female <- cdm$cc1_covid |>
  requireSex(
    sex = c("Female"),
    name = "cc1_covid_female"
  )
toc(log = TRUE)

# male
tic(msg = "cc_covid_male")
cdm$cc1_covid_male <- cdm$cc1_covid |>
  requireSex(
    sex = c("Male"),
    name = "cc1_covid_male"
  )
toc(log = TRUE)

# female < 50
tic(msg = "cc_covid_female_0_to_50")
cdm$cc1_covid_female_0_to_50 <- cdm$cc1_covid |>
  requireDemographics(
    ageRange = list(c(0,50)),
    sex = c("Female"),
    name = "cc1_covid_female_0_to_50"
  )
toc(log = TRUE)

# female > 50
tic(msg = "cc_covid_female_51_to_150")
cdm$cc1_covid_female_51_to_150 <- cdm$cc1_covid |>
  requireDemographics(
    ageRange = list(c(51, 150)),
    sex = c("Female"),
    name = "cc1_covid_female_51_to_150"
  )
toc(log = TRUE)

# male < 50
tic(msg = "cc_covid_male_0_to_50")
cdm$cc1_covid_male_0_to_50 <- cdm$cc1_covid |>
  requireDemographics(
    ageRange = list(c(0,50)),
    sex = c("Male"),
    name = "cc1_covid_male_0_to_50"
  )
toc(log = TRUE)

# male > 50
tic(msg = "cc_covid_male_51_to_150")
cdm$cc1_covid_male_51_to_150 <- cdm$cc1_covid |>
  requireDemographics(
    ageRange = list(c(51, 150)),
    sex = c("Male"),
    name = "cc1_covid_male_51_to_150"
  )
toc(log = TRUE)

