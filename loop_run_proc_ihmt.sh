#!/bin/bash
# loop over subjects/sessions list to run ihmt_proc on all preschool subjects included in metabolites & microstructure paper

while read i; do
    sh run_proc_ihmt.sh ${i}
    done < subjects.txt