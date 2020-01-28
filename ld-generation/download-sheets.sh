#!/usr/bin/env bash

SHEET="https://docs.google.com/spreadsheets/d/1FO2EaYYH9TGQ6bAcdEME-G2LgNY513KlR0bsF6-hNFk"

SHEETNAME[0]="Steps"
SHEETNAME[1]="States"
SHEETNAME[2]="Shapes"
SHEETNAME[3]="States-Shapes"
SHEETNAME[4]="Shapes-Constraints"
SHEETNAME[5]="Steps-Descriptions"

for i in "${SHEETNAME[@]}"
do
    curl -L "${SHEET}/gviz/tq?tqx=out:csv&sheet=${i}" > "${i}.csv"
    perl -0777 -p -i -e "s/([^\"])([\r\n]+)/\1 /g" ${i}.csv
    rm ${i}.csv.bak
done
