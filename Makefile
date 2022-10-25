# clean source data and output derived data
derived-data/TDF_Stages_History_Clean.csv derived-data/TDF_Riders_History_Clean.csv:\
 source-data/TDF_Riders_History.csv\
 source-data/TDF_Stages_History.csv\
 tdf-cleaning.R
	Rscript tdf-cleaning.R

# produce report
tdf-exploration.pdf:\
 derived-data/TDF_Riders_History_Clean.csv\
 derived-data/TDF_Stages_History_Clean.csv\
 tdf-exploration.Rmd
	R -e "rmarkdown::render(\"tdf-exploration.Rmd\", output_format=\"pdf_document\")"