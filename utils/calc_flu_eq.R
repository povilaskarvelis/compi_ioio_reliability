# --------------------------------------------------------------------
# Function to calculate fluoxetine equivalent dose of antidepressant 
# medication based on Table 1 (primary analysis) of 
# Hayasaka, et al. (2015). Dose equivalents of antidepressants: 
# evidence-based recommendations from randomized controlled trials. 
# J Affect Disord. 180, 179–184, 
# https://doi.org/10.1016/j.jad.2015.03.021 (2015).
# --------------------------------------------------------------------
# Required are medication name (string), dose in mg (numeric)
# days(numeric)
# Input example:
# medication = 'Sertraline'
# days = 14
# dose = 20
# Example: calc_flu_eq(medication = 'Sertraline',dose = 100, days = 5)
# --------------------------------------------------------------------


calc_flu_eq <- function(medication = string(), 
                        dose = numeric(), 
                        days = numeric()){
        
        # Antidepressants for wich equivalent dose is available
        names = c('Agomelatine',
                  'Amitriptyline',
                  'Bupropion',
                  'Clomipramine',
                  'Desipramine',
                  'Dothiepin',
                  'Doxepin',
                  'Escitalopram',
                  'Fluvoxamine',
                  'Imipramine',
                  'Lofepramine',
                  'Maprotiline',
                  'Mianserin',
                  'Mirtazapine',
                  'Moclobemide',
                  'Nefazodone',
                  'Nortriptyline',
                  'Paroxetine',
                  'Reboxetine',
                  'Sertraline',
                  'Trazodone',
                  'Venlafaxine')
        
        # Equivalent dose for 40mg Fluoxetine
        flu_equ = c(53.2,
                    122.3,
                    348.5,
                    116.1,
                    196.3,
                    154.8,
                    140.1,
                    18,
                    143.3,
                    137.2,
                    250.2,
                    118,
                    101.1,
                    50.9,
                    575.2,
                    535.2,
                    100.9,
                    34,
                    11.5,
                    98.5,
                    401.4,
                    149.4)
        
        # Find medication in list of medications
        idx = grepl(medication,names)
        
        # Compute equivalent dose
        if (sum(idx) == 0){
                warning('Medication information is not available. Returning NA!')
                flu_equ_dose = NA
        }else{
                flu_equ_dose = days*dose/flu_equ[idx]*40   
        }
        
        return(flu_equ_dose)
}