import os
import numpy as np
import matplotlib.pyplot as plt
import cv2
import json
import glob
import pandas as pd

from Mask.config import Config
import Mask.utils as utils
import Mask.model as modellib
import Mask.visualize as visualize

np.set_printoptions(threshold=np.inf)

# Path of the trained model
dir_path = os.path.dirname(os.path.realpath(__file__))
MODEL_DIR = os.path.join(dir_path, "models")

MODEL_PATH = input("Insert the path of your trained model [ Like models/moles.../mask_rcnn_moles_0030.h5 ]: ").strip()
if not os.path.isfile(MODEL_PATH):
    raise Exception(f"{MODEL_PATH} does not exist")

# Path of Data that contains Descriptions and Images
path_data = input("Insert the path of Data [ Link /home/../ISIC-Archive-Downloader/Data/ ] : ").rstrip("\\/")
if not os.path.exists(path_data):
    raise Exception(f"{path_data} does not exist")

# Load CSV Labels
csv_path = os.path.join(path_data, "Labels", "ISIC-2017_Test_V2_Part3_GroundTruth.csv")
if not os.path.exists(csv_path):
    raise Exception(f"CSV file not found: {csv_path}")

df = pd.read_csv(csv_path)

# Convert to dictionary for quick lookup
label_dict = {}
for _, row in df.iterrows():
    image_id = row["image_id"]
    if row["melanoma"] == 1:
        label_dict[image_id] = "malignant"
    elif row["seborrheic_keratosis"] == 1:
        label_dict[image_id] = "seborrheic_keratosis"
    else:
        label_dict[image_id] = "benign"

print(f"✅ Loaded {len(label_dict)} labels from CSV")

class CocoConfig(Config):
    ''' 
    MolesConfig:
        Contains the configuration for the dataset + those in Config
    '''
    NAME = "moles"
    NUM_CLASSES = 1 + 3  # background + (malignant, seborrheic_keratosis, benign)
    IMAGE_MIN_DIM = 128
    IMAGE_MAX_DIM = 128
    GPU_COUNT = 1
    IMAGES_PER_GPU = 1
    DETECTION_MAX_INSTANCES = 3


# Create an instance of config
config = CocoConfig()

# Load the trained model
model = modellib.MaskRCNN(mode="inference", model_dir=MODEL_DIR, config=config)
model.load_weights(MODEL_PATH, by_name=True)

# Background + (malignant, seborrheic_keratosis, benign)
class_names = ["BG", "malignant", "seborrheic_keratosis", "benign"]

# Process images
image_folder = os.path.join(path_data, "Images")

for filename in os.listdir(image_folder):
    if not filename.endswith(".jpg"):
        continue

    image_id = filename.replace(".jpg", "")
    image_path = os.path.join(image_folder, filename)

    # Read image
    img = cv2.imread(image_path)

    # Check if image exists
    if img is None or img.size == 0:
        print(f"❌ Error: Image not found or empty at {image_path}")
        continue  # Skip this file

    # Resize image
    img = cv2.resize(img, (128, 128))

    # Get ground truth label
    ground_truth_label = label_dict.get(image_id, "Unknown")

    print(f"\n🖼 Image: {image_id}, Ground Truth Label: {ground_truth_label}")

    # Predict
    r = model.detect([img])[0]
    print(f"🔍 Predicted class IDs for {image_id}: {r['class_ids']}")

    # Convert class IDs to readable names
    predicted_labels = [class_names[class_id] if class_id < len(class_names) else "Unknown" for class_id in r["class_ids"]]
    print(f"🎯 Model Predicted Labels: {predicted_labels}")

    # Debugging prediction shapes
    print(f"🔢 Boxes: {r['rois'].shape[0]}, 🎭 Masks: {r['masks'].shape[-1]}, 🆔 Class IDs: {len(r['class_ids'])}")

    # Skip visualization if prediction count mismatches
    if r['rois'].shape[0] != r['masks'].shape[-1] or r['rois'].shape[0] != len(r['class_ids']):
        print(f"⚠ Skipping visualization due to shape mismatch.")
        continue

    # Display results
    visualize.display_instances(
        img, r['rois'], r['masks'], r['class_ids'], class_names, r['scores']
    )
