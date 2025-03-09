# -*- coding: utf-8 -*-
"""
Created on Mon Feb 24 10:44:10 2025

@author: dipen
"""

import pandas as pd

# csv_path = "C:/Users/dipen/Documents/St.Marys/Super_Senior/Senior_Design/MachineLearning/Skin-Cancer-Segmentation-master/ISIC-Archive-Downloader-2017/Data/Labels/ISIC-2017_Training_Part3_GroundTruth.csv"
csv_path = "C:/Users/dipen/Documents/St.Marys/Super_Senior/Senior_Design/MachineLearning/Skin-Cancer-Segmentation-master/ISIC-Archive-Downloader-2017/Data//Test/Labels/ISIC-2017_Test_V2_Part3_GroundTruth.csv"

# Load CSV
df = pd.read_csv(csv_path)

# Convert to dictionary for quick lookup
label_dict = {}
for index, row in df.iterrows():
    image_id = row["image_id"]  # The image name without extension
    if row["melanoma"] == 1:
        label_dict[image_id] = "malignant"
    elif row["seborrheic_keratosis"] == 1:
        label_dict[image_id] = "seborrheic_keratosis"
    else:
        label_dict[image_id] = "benign"

print(f"✅ Loaded {len(label_dict)} labels from CSV")
