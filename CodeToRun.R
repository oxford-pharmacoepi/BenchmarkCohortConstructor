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
library(CodelistGenerator)
library(CirceR)
library(SqlRender)
library(odbc)
library(RPostgres)
library(clock)

database_name <- "GOLD"

# Connection details
server_dbi <- Sys.getenv("DB_SERVER_DBI_gd")
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
cdm_database_schema <- "public_100k"
results_database_schema <- "results"

# cohort stem where cohorts will be instantiated
table_stem <- "cc"

cdm <- cdmFromCon(
  con = db,
  cdmSchema = cdm_database_schema,
  writeSchema = c("schema" = results_database_schema, "prefix" = tolower(table_stem)),
  cdmName = database_name,
  .softValidation = TRUE
)

runAtlas <- FALSE
runCohortConstructorByCohort <- TRUE
runCohortConstructorSet <- FALSE
runEvaluateCohorts <- FALSE

# Run study
source(here("RunStudy.R"))
