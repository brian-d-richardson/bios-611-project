################################################################
################################################################

# Title: TDF Figure Generation

# Author: Brian Richardson

# Date: 11/28/2022

# Purpose: Generate figures for the Bios 611 project

################################################################################################################################

### Prepare work space

rm(list=ls())

library(ggplot2)
library(tidyr)
library(dplyr)


### load data

riders <- read.csv("derived-data/TDF_Riders_History_Clean.csv")
stages <- read.csv("derived-data/TDF_Stages_History_Clean.csv")


### examine data

tail(stages, 5)
tail(riders, 5)


### Plot number of stages per year

stages %>% 
  group_by(year) %>% 
  count() %>% 
  ggplot(aes(x = year, y = n)) +
  geom_line() +
  ggtitle("Number of Tour de France Stages Over Time") +
  xlab("Year") +
  ylab("Number of Stages") -> stages_per_year_plot

ggsave(plot = stages_per_year_plot,
       filename = "figures/stages_per_year_plot.png",
       units = "cm", width = 16, height = 10)

stages_per_year_plot


### Plot number of stages per year

riders %>% 
  # only 3 riders from 1966 are in this data set, which is incorrect
  filter(year != 1966) %>% 
  group_by(year) %>% 
  count() %>% 
  ggplot(aes(x = year, y = n)) +
  geom_line() +
  ggtitle("Number of Riders per Year Over Time") +
  xlab("Year") +
  ylab("Number of Riders") -> riders_per_year_plot

ggsave(plot = riders_per_year_plot,
       filename = "figures/riders_per_year_plot.png",
       units = "cm", width = 16, height = 10)

riders_per_year_plot


### Examine common starting and ending locations

loc.labs <- c("Start Location", "End Location")
names(loc.labs) <- c("start_loc", "end_loc")

stages %>% 
  select(start_loc, end_loc) %>% 
  pivot_longer(cols = c(start_loc, end_loc),
               names_to = "start_end",
               values_to = "loc") %>% 
  mutate(start_end = factor(start_end,
                            levels = c("start_loc", "end_loc"))) %>% 
  group_by(start_end, loc) %>% 
  count() %>% 
  filter(n >= 25) %>% 
  ggplot(aes(y = reorder(loc, (-n)), x = n)) +
  geom_bar(stat='identity') +
  facet_wrap(~ start_end,
             labeller = labeller(start_end = loc.labs)) +
  ggtitle("Popular Tour de France Starting and Ending Locations") +
  xlab("Frequency from 1903 - 2021") +
  ylab("Location") -> locations_plot

ggsave(plot = locations_plot,
       filename = "figures/locations_plot.png",
       units = "cm", width = 16, height = 14)

locations_plot

### Count wins by team

# There is no "winner" from 1999 to 2005, since Lance Armstrong won those races and was later disqualified.

riders = riders %>% 
  mutate(winner = rank == 1,
         winner2 = ifelse(year >= 1999 & year <= 2005, rank == 2, rank == 1))

team_wins = riders %>% 
  group_by(team) %>% 
  summarise(n.win = sum(winner)) %>% 
  arrange(desc(n.win))

team_wins %>% 
  filter(n.win > 1) %>% 
  ggplot(aes(y = reorder(team, (-n.win)), x = n.win)) +
  geom_bar(stat='identity') +
  ggtitle("Number of Tour de France Wins by Team",
          subtitle = "Among Teams with Multiple Wins; from 1903 - 2021") +
  xlab("Number of Wins") +
  ylab("Team") -> team_wins_plot

ggsave(plot = team_wins_plot,
       filename = "figures/team_wins_plot.png",
       units = "cm", width = 16, height = 10)

team_wins_plot

# add a variables for total hours, average km/hr, indicator for year winner
# filter to years >= 1919, when time data becomes reliable

riders2 = riders %>% 
  filter(year >= 1919) %>% 
  mutate(totalhours = totalseconds / 3600,
         avg_speed = distance_km / totalhours)

rider_wins = riders2 %>% 
  group_by(rider) %>% 
  summarise(n.win = sum(winner)) %>% 
  arrange(desc(n.win))

rider_wins %>% 
  filter(n.win > 1) %>% 
  ggplot(aes(y = reorder(rider, (-n.win)), x = n.win)) +
  geom_bar(stat='identity') +
  ggtitle("Number of Tour de France Wins by Rider",
          subtitle = "Among Riders with Multiple Wins; from 1903 - 2021") +
  xlab("Number of Wins") +
  ylab("Rider") -> rider_wins_plot

ggsave(plot = rider_wins_plot,
       filename = "figures/rider_wins_plot.png",
       units = "cm", width = 16, height = 12)

rider_wins_plot


### Plot total distance ridden for each rider for each year

ggplot(riders2, aes(x = year, y = distance_km)) +
  geom_line() +
  theme(legend.position = "none") +
  ggtitle("Total Distance Ridden from 1919 - 2021") +
  xlab("Year") +
  ylab("Total Distance (km)") -> distance_over_time_plot

ggsave(plot = distance_over_time_plot,
       filename = "figures/distance_over_time_plot.png",
       units = "cm", width = 16, height = 10)

distance_over_time_plot


### Plot total hours ridden for each rider for each year

ggplot(riders2, aes(x = year, group = year, y = totalhours)) +
  geom_boxplot() +
  theme(legend.position = "none") +
  ggtitle("Total Hours Ridden by Rider from 1919 - 2021") +
  xlab("Year") +
  ylab("Riding Time (Hours)") -> riding_time_over_time_plot

ggsave(plot = riding_time_over_time_plot,
       filename = "figures/riding_time_over_time_plot.png",
       units = "cm", width = 16, height = 10)

riding_time_over_time_plot


### Plot average speed over years and overlay with average speed of winners

ggplot(riders2, aes(x = year, y = avg_speed)) +
  geom_boxplot(aes(group = year)) +
  geom_smooth(formula = "y ~ x",
              aes(color = winner2),
              method = "loess", span = 0.5, se = F) +
  ggtitle("Average Speed by Rider from 1919 - 2021",
          subtitle = "Overall and among Winners; with LOESS Curve") +
  xlab("Year") +
  ylab("Average Speed (km/hr)") +
  scale_color_manual(values = c("#FF33CC", "#66CC33"),
                     labels = c("Average", "Winners")) +
  guides(color = guide_legend("")) -> avg_speed_over_time_plot

ggsave(plot = avg_speed_over_time_plot,
       filename = "figures/avg_speed_over_time_plot.png",
       units = "cm", width = 16, height = 10)

avg_speed_over_time_plot


### Plot average speed over years and overlay with average speed of winners around the period of Lance Armstrong's "wins"

ggplot(filter(riders2, year >= 1992 & year <= 2012 & avg_speed > 30),
       aes(x = year, y = avg_speed)) +
  geom_rect(data = NULL, xmin = 1998.5, xmax = 2005.5, ymin = -Inf, ymax = Inf,
            fill = "#FF9999", color = "#FF9999", alpha = 0.1) +
  geom_text(aes(x = 2002, y = 37.5, label = "Period of Lance Armstrong's\nIllegitimate Wins"), size = 2.5) +
  #geom_jitter(color = "black", alpha = 0.2, size = 0.9) +
  geom_boxplot(aes(group = year)) +
  geom_smooth(formula = "y ~ x",
              aes(color = winner2),
              method = "loess", span = 0.5, se = F) +
  ggtitle("Average Speed by Rider from 1992 - 2012",
          subtitle = "Overall and among Winners; with LOESS Curve") +
  xlab("Year") +
  ylab("Average Speed (km/hr)") +
  scale_color_manual(values = c("#FF33CC", "#66CC33"),
                     labels = c("Average", "Winners")) +
  guides(color = guide_legend("")) -> avg_speed_over_time_plot_dope

ggsave(plot = avg_speed_over_time_plot_dope,
       filename = "figures/avg_speed_over_time_plot_dope.png",
       units = "cm", width = 16, height = 10)

avg_speed_over_time_plot_dope


### Plot ranking of riders who compete in multiple tours

# count number of tours by rider
riders3 = riders %>%
  group_by(rider) %>% 
  arrange(by = year) %>% 
  summarise(n.tours = n())

# select tour number and rank (relative to first tour) for each rider
riders4 = riders %>% 
  right_join(riders3, by = "rider") %>% 
  group_by(rider) %>% 
  arrange(-n.tours, rider) %>% 
  mutate(ones = 1,
         tour.counter = cumsum(ones),
         rank1 = first(rank),
         rel.rank = rank - rank1) %>% 
  select(rider, n.tours, tour.counter, rel.rank)

# plot change in rank over time (filter to riders who compete in >= 6 tours)
riders4 %>%
  filter(n.tours >= 6) %>% 
  ggplot(aes(x = tour.counter, y = rel.rank)) +
  geom_line(aes(group = rider), alpha = .2) +
  geom_smooth(formula = "y ~ x", color = "#FF33CC", fill = "#FF33CC",
              method = "loess", span = 0.5, se = T) +
  geom_hline(yintercept = 0,
             color = "#66CC33", linetype = "dashed") +
  xlab("Tour Number") +
  ylab("Relative Rank") +
  ggtitle("Rider Ranks Relative to Rank at First Tour",
          subtitle = "with LOESS Curve and 95% Confidence Band") -> rel_ranks_plot

ggsave(plot = rel_ranks_plot,
       filename = "figures/rel_ranks_plot.png",
       units = "cm", width = 18, height = 10)

rel_ranks_plot


  