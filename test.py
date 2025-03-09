import os
import numpy as np
import matplotlib.pyplot as plt
import cv2
import json
import glob

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


class CocoConfig(Config):
    ''' 
    MolesConfig:
        Contains the configuration for the dataset + those in Config
    '''
    NAME = "moles"
    NUM_CLASSES = 1 + 3  # background + (malignant, benign)
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

# Background + (malignant, benign)
class_names = ["BG", "malignant", "benign"]

# Find the largest number of images downloaded
all_desc_path = glob.glob(os.path.join(path_data, "Descriptions", "ISIC_*"))

for filename in os.listdir(os.path.join(path_data, "Descriptions")):
    json_path = os.path.join(path_data, "Descriptions", filename)

    # Load JSON file safely
    try:
        with open(json_path, "r") as f:
            data = json.load(f)
    except Exception as e:
        print(f"Error reading JSON file {filename}: {e}")
        continue

    # Get the corresponding image filename
    # Extract the base image filename by removing "_features.json"
    image_filename = filename.replace("_features.json", "") + ".jpg"
    image_path = os.path.join(path_data, "Images", image_filename)

    # Read image
    img = cv2.imread(image_path)

    # Check if image exists
    if img is None or img.size == 0:
        print(f"Error: Image not found or empty at {image_path}")
        continue  # Skip this file

    # Resize image to 128x128
    img = cv2.resize(img, (128, 128))

    # Print ground truth class
    if "meta" in data and "clinical" in data["meta"] and "benign_malignant" in data["meta"]["clinical"]:
        print(f"Ground Truth: {data['meta']['clinical']['benign_malignant']}")

    # Predict the mask, bounding box, and class of the image
    r = model.detect([img])[0]
    print("Predicted class IDs:", r["class_ids"])


    for i, class_id in enumerate(r["class_ids"]):
        if class_id >= len(class_names):
            print(f"Warning: Unexpected class_id {class_id} (out of range). Skipping this instance.")
            continue  # Skip this instance

        visualize.display_instances(
            img, r['rois'], r['masks'], r['class_ids'], class_names, r['scores']
    )


    # Display results
    # visualize.display_instances(img, r['rois'], r['masks'], r['class_ids'], class_names, r['scores'])
