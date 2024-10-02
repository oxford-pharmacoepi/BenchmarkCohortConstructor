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

database_name <- "..."

# Connection details
server_dbi <- Sys.getenv("...")
user <- Sys.getenv("...")
password <- Sys.getenv("...")
port <- Sys.getenv("...")
host <- Sys.getenv("...")

db <- dbConnect(
  "...",
  dbname = server_dbi,
  port = port,
  host = host,
  user = user,
  password = password
)
cdm_database_schema <- "..."
results_database_schema <- "..."

# study prefix
table_stem <- "..."

runAtlas <- TRUE
runCohortConstructorByCohort <- TRUE
runCohortConstructorSet <- TRUE
runEvaluateCohorts <- TRUE
runGetOMOPDetails <- TRUE
runEvaluateIndex <- TRUE

# Run study
source(here("RunStudy.R"))
