library(DBI)
library(here)
library(zip)
library(dbplyr)
library(dplyr)
library(CDMConnector)
library(tidyr)
library(readr)
library(CohortConstructor)
library(log4r)
library(tictoc)
library(PatientProfiles)
library(CohortCharacteristics)

database_name <- "PHARMETRICS"

# Connection details
server_dbi <- Sys.getenv("DB_SERVER_DBI_ph")
user <- Sys.getenv("DB_USER")
password <- Sys.getenv("DB_PASSWORD")
port <- Sys.getenv("DB_PORT")
host <- Sys.getenv("DB_HOST")

db <- dbConnect(
  RPostgres::Postgres(),
  dbname = server_dbi,
  port = port,
  host = host,
  user = user,
  password = password
)

cdm_database_schema <- "public"
results_database_schema <- "results"

# cohort stem where cohorts will be instantiated
table_stem <- "coco"

cdm <- cdmFromCon(
  con = db,
  cdmSchema = cdm_database_schema,
  writeSchema = c("schema" = results_database_schema, "prefix" = tolower(table_stem)),
  cdmName = database_name,
  .softValidation = TRUE
)

# Jobs to run
runAtlasComparison <- TRUE
runCohortConstructorTest <- FALSE

# Results folder
output_folder <- here(paste0("Results_", cdmName(cdm), "_", gsub("-", "", Sys.Date())))
if (!dir.exists(output_folder)) {
  dir.create(output_folder)
}

# Run study
## comparison
if (runAtlasComparison) {
  source(here("AtlasComparison.R"))
}
# test CC in RWD
if (runCohortConstructorTest) {
  if (!runAtlasComparison) {
    cdm <- cdmFromCon(
      con = db,
      cdmSchema = cdm_database_schema,
      writeSchema = c("schema" = results_database_schema, "prefix" = tolower(table_stem)),
      cohortTables = "base",
      cdmName = database_name,
      .softValidation = TRUE
    )
  }
  source(here("CohortConstructorTests.R"))
}

output_folder <- basename(output_folder)
zip(
  zipfile = paste0(output_folder, ".zip"),
  files = list.files(output_folder, full.names = TRUE)
)
