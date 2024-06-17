# prepare codelists ----

inpatient_visit <- c()
howoften_beta_blockers <- c()
asthma_therapy <- c()
howoften_fluoroquinolone_systemic <- c()
congenital_or_genetic_neutropenia_leukopenia_or_agranulocytosis <- c()
endometriosis <- c()
chronic_obstructive_lung_disease <- c()
essential_hypertension <- c()
asthma <- c()
neutropenia_agranulocytosis_or_unspecified_leukopenia <-  c()
dementia <- c()
schizophrenia_not_including_paraphenia <-  c()
psychotic_disorder <- c()
bipolar_disorder <- c()
major_depressive_disorder <- c()
schizoaffective_disorder <- c()
endometriosis_related_laproscopic_procedures <- c()
long_acting_muscarinic_antagonists_lamas <- c()
neutrophilia <- c()
covid_19 <- c()
major_non_cardiac_surgery <- c()




info(logger, <-   Read codes from json <- )
codes <- codesFromCohort(here( <- JSONCohorts <- ), cdm)
majorNonCardiacSurgery <- codesFromCohort(here( <- JSONCohorts/major_non_cardiac_surgery.json <- ), cdm)
codes <- codes[!names(codes) %in% names(majorNonCardiacSurgery)]
codes <- c(codes, list( <- major_non_cardiac_surgery <-  c()= unname(unlist(majorNonCardiacSurgery))))
names(codes) <- gsub( <-  c()<-   , <-   _ <- , tolower(names(codes)))
# <-   howoften_inpatient_or_er_visit <-  c()== <-   inpatient_or_inpatient/er_visit <-
# <-   pneumonectomy <-  c()== <-   lobectomy <-
codes <- codes[!names(codes) %in% c( <- howoften_inpatient_or_er_visit <- , <-   lobectomy <- )]
names(codes)[names(codes) == <-   endometriosis_related_laproscopic_procedures_(prevalent_procedures_for_1_endo_dx_cohort) <- ] <-   c() <-   endometriosis_related_laproscopic_procedures <-
