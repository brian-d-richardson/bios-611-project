################################################################################
################################################################################

# TDF Exploration

# Brian Richardson

# 09/14/2022

# In this program we do exploratory data analysis on the TDF data

################################################################################
################################################################################

################################################################################
# Prepare workspace
################################################################################

rm(list=ls())

library(ggplot2)
library(tidyr)
library(dplyr)
library(stringr)

################################################################################
# Load data
################################################################################

riders <- read.csv("source-data/TDF_Riders_History.csv")

stages <- read.csv("source-data/TDF_Stages_History.csv")

################################################################################
# Clean stages data
################################################################################

# change to tibble
stages <- as_tibble(stages)

# choose better column names
colnames(stages) <- colnames(stages) %>% 
  tolower()

# check for duplicate stages in a single year
stages %>%
  group_by(year, stage) %>% 
  summarise(n.dups = n()) %>% 
  filter(n.dups > 1)

# create variables for stage number, start location, and end location
stages <- stages %>% 
  mutate(separate(stages, stage, into = c("stage_no", "start_loc", "end_loc"),
                  sep = c(":| >"))) %>% 
  mutate_at(.vars = c("stage_no", "start_loc", "end_loc"),
            factor)

# Examine all variables for inconsistencies
summary(stages)

################################################################################
# Clean riders data
################################################################################

# change to tibble
riders <- as_tibble(riders)

# choose better column names
colnames(riders) <- colnames(riders) %>%
  tolower() %>%
  gsub(pattern = "[.][.]", replacement = "_") %>% 
  gsub(pattern = "[.]", replacement = "_") %>% 
  gsub(pattern = "[_]$", replacement = "")

# Check for duplicate riders in a single year
riders %>% 
  group_by(year, rider) %>% 
  summarise(n.dups = n()) %>% 
  filter(n.dups > 1)

riders %>% 
  filter(rider == "VICENTE TRUEBA" & year == 1930)

riders %>% 
  filter(rider == "JOSE TRUEBA" & year == 1930)

# VICENTE TRUEBA has two entries in the year 1930, one placed 24th and one placed 36th.
# From https://en.wikipedia.org/wiki/1930_Tour_de_France#Final_standings, VICENTE TRUEBA
# actually placed 24th, and JOSE TRUEBA placed 36th. The original riders data set is
# missing JOSE TRUEBA. We will make this substitution.

riders$rider[riders$rider == "VICENTE TRUEBA" &
               riders$year == 1930 &
               riders$rank == 36] <- "JOSE TRUEBA"

# Change some character variables to factor
riders <- riders %>% 
  mutate_at(.vars = c("rider", "team", "resulttype"),
            factor)

summary(riders)

################################################################################
# Save cleaned data
################################################################################

write.csv(stages, "derived-data/TDF_Stages_History_Clean.csv", row.names = F)

write.csv(riders, "derived-data/TDF_Riders_History_Clean.csv", row.names = F)

