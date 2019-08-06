#!/usr/bin/env python3.7

import pandas as pd

excel_file = pd.ExcelFile("/Additional_data_vpHMMs.xlsx")

excel_df = excel_file.parse("Sheet1")

excel_df["Number"] = excel_df["Number"].apply(lambda x: "ViPhOG" + str(x) + ".faa")

taxa_dict = {}

for i in range(len(excel_df)):
    taxa_dict[excel_df["Number"][i]] = excel_df["Associated"][i]
