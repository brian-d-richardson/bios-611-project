# create directories
.created-dirs:
	mkdir -p derived-data
	mkdir -p figures
	touch .created-dirs

# clean source data and output derived data
derived-data/TDF_Stages_History_Clean.csv derived-data/TDF_Riders_History_Clean.csv:\
 .created-dirs\
 source-data/TDF_Riders_History.csv\
 source-data/TDF_Stages_History.csv\
 tdf-cleaning.R
	Rscript tdf-cleaning.R

# produce figures
figures/locations_plot.png\
figures/riders_per_year_plot.png\
figures/riding_time_over_time_plot.png\
figures/stages_per_year_plot.png\
figures/team_wins_plot.png\
figures/rider_wins_plot.png\
figures/avg_speed_over_time_plot.png\
figures/avg_speed_over_time_plot_dope.png\
figures/distance_over_time_plot.png:\
 .created-dirs\
 derived-data/TDF_Riders_History_Clean.csv\
 derived-data/TDF_Stages_History_Clean.csv\
 tdf-figures.R
	Rscript tdf-figures.R

# produce report
tdf-report.html:\
 .created-dirs\
 figures/locations_plot.png\
 figures/riders_per_year_plot.png\
 figures/riding_time_over_time_plot.png\
 figures/stages_per_year_plot.png\
 figures/team_wins_plot.png\
 figures/rider_wins_plot.png\
 figures/avg_speed_over_time_plot.png\
 figures/avg_speed_over_time_plot_dope.png\
 figures/distance_over_time_plot.png\
 tdf-report.Rmd
	R -e "rmarkdown::render(\"tdf-report.Rmd\", output_format=\"html_document\")"