#script to import latest ONS mid-year population estimates for England geographies
#to be called in main `pipeline.R` script
#functions loaded in main pipeline

#

load("population_data_20_08_2024.RData")

#1. England national population for 2019 to 2024, total

eng_nat_pop <- get_eng_nat_pop()

#2. England national population for 2019 to 2024, by age




