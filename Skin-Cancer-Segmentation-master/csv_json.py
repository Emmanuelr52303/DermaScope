# -*- coding: utf-8 -*-
"""
Created on Fri Feb 14 10:48:45 2025

@author: dipen
"""
import pandas as pd
import os
import json

# ✅ Set your paths
csv_file = "C:/Users/dipen/Documents/St.Marys/Super_Senior/Senior_Design/MachineLearning/Skin-Cancer-Segmentation-master/ISIC-Archive-Downloader-master/Data/Descriptions/ISIC_2020_Training_GroundTruth.csv"
output_folder = "C:/Users/dipen/Documents/St.Marys/Super_Senior/Senior_Design/MachineLearning/Skin-Cancer-Segmentation-master/ISIC-Archive-Downloader-master/Data/Descriptions_JSON/"

# ✅ Create output folder if it doesn't exist
os.makedirs(output_folder, exist_ok=True)

# ✅ Read the CSV file
df = pd.read_csv(csv_file)

# ✅ Convert each row into an individual JSON file
for index, row in df.iterrows():
    filename = f"{row['image_name']}.json"  # Create JSON file for each image
    file_path = os.path.join(output_folder, filename)

    # ✅ Convert row to JSON format (structured as needed)
    metadata = {
        "patient_id": row["patient_id"],
        "sex": row["sex"],
        "age_approx": row["age_approx"],
        "anatom_site_general_challenge": row["anatom_site_general_challenge"],
        "diagnosis": row["diagnosis"],
        "benign_malignant": row["benign_malignant"],
        "target": row["target"]
    }

    # ✅ Save as a JSON file
    with open(file_path, 'w') as json_file:
        json.dump(metadata, json_file, indent=4)

print("✅ CSV conversion complete! JSON files are stored in:", output_folder)
