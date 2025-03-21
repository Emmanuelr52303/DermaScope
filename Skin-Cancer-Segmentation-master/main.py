import cv2
import numpy as np
import json
import os
import matplotlib.pyplot as plt
import pandas as pd

from Mask.config import Config
import Mask.utils as utils
import Mask.model as modellib
import Mask.visualize as visualize

dir_path = os.path.dirname(os.path.realpath(__file__))
MODEL_DIR = dir_path + "/models/"
COCO_MODEL_PATH = dir_path + "/Mask/mask_rcnn_coco.h5"
if not os.path.isfile(COCO_MODEL_PATH):
    raise Exception("You have to download mask_rcnn_coco.h5 inside Mask folder \n\
    You can find it here: https://github.com/matterport/Mask_RCNN/releases/download/v2.0/mask_rcnn_coco.h5")

class MolesConfig(Config):
    NAME = "moles"
    GPU_COUNT = 1 
    IMAGES_PER_GPU = 1 
    NUM_CLASSES = 1 + 3  # background + (malignant, benign, seborrheic keratosis)
    IMAGE_MIN_DIM = 128
    IMAGE_MAX_DIM = 128

    # Hyperparameters
    LEARNING_RATE = 0.001
    STEPS_PER_EPOCH = 100
    VALIDATION_STEPS = 5

class Metadata:
    ''' 
    Metadata:
        Contains everything about an image
        - Mask
        - Image
        - Label (malignant, benign, seborrheic keratosis)
    '''
    def __init__(self, label, dataset, img, mask):
        self.label = label
        self.dataset = dataset
        self.img = img
        self.mask = mask
        self.type = label  # Assign label directly

class MoleDataset(utils.Dataset):
    def load_shapes(self, dataset, height, width):
        ''' Add the 3 classes of skin cancer and metadata inside the model '''
        self.add_class("moles", 1, "malignant")
        self.add_class("moles", 2, "benign")
        self.add_class("moles", 3, "seborrheic_keratosis")
        
        for i, info in enumerate(dataset):
            height, width, channels = info.img.shape
            self.add_image(source="moles", image_id=i, path=None,
                           width=width, height=height,
                           img=info.img, shape=(info.type, channels, (height, width)),
                           mask=info.mask, extra=info)

    def load_image(self, image_id):
        return self.image_info[image_id]["img"]

    def image_reference(self, image_id):
        if self.image_info[image_id]["source"] == "moles":
            return self.image_info[image_id]["shape"]
        else:
            super(self.__class__).image_reference(self, image_id)

    def load_mask(self, image_id):
        ''' Load the mask and return mask and the class of the image '''
        info = self.image_info[image_id]
        shapes = info["shape"]
        mask = info["mask"].astype(np.uint8)
        class_ids = np.array([self.class_names.index(shapes[0])])
        return mask, class_ids.astype(np.int32)

config = MolesConfig()
all_info = []

# Get dataset path from user input
path_data = input("Insert the path of Data [ Link /home/../ISIC-Archive-Downloader/Data/ ] : ")
if not os.path.exists(path_data):
    raise Exception(path_data + " Does not exist")

# Define CSV Path
csv_path = os.path.join(path_data, "Labels", "ISIC-2017_Training_Part3_GroundTruth.csv")

# Check if CSV file exists
if not os.path.exists(csv_path):
    raise FileNotFoundError(f"CSV file not found: {csv_path}")

# Load Labels from CSV
df = pd.read_csv(csv_path)
label_dict = {}

for _, row in df.iterrows():
    image_id = row["image_id"]
    if row["melanoma"] == 1:
        label_dict[image_id] = "malignant"
    elif row["seborrheic_keratosis"] == 1:
        label_dict[image_id] = "seborrheic_keratosis"
    else:
        label_dict[image_id] = "benign"

print(f"Loaded {len(label_dict)} labels from CSV")

# Load images, masks, and descriptions
for filename in os.listdir(os.path.join(path_data, "Descriptions")):
    if not filename.endswith(".json"):
        continue

    filename = filename.replace("_features.json", "").replace(".json", "")

    json_path = os.path.join(path_data, "Descriptions", filename + "_features.json")
    img_path = os.path.join(path_data, "Images", filename + ".jpg")
    mask_path = os.path.join(path_data, "Segmentation", filename + "_segmentation.png")

    if not all(os.path.exists(p) for p in [json_path, img_path, mask_path]):
        print(f"Missing Data for {filename}")
        continue

    if filename not in label_dict:
        print(f"Skipping {filename}: Label missing from CSV")
        continue

    img = cv2.imread(img_path)
    if img is None:
        continue
    img = cv2.resize(img, (128, 128))

    mask = cv2.imread(mask_path, cv2.IMREAD_GRAYSCALE)
    if mask is None:
        continue
    mask = cv2.resize(mask, (128, 128))
    mask = np.expand_dims(mask, axis=-1)  # Ensure (H, W, 1)

    info = Metadata(label_dict[filename], "ISIC-2017", img, mask)
    all_info.append(info)

print(f"Total images loaded into `all_info`: {len(all_info)}")

# Split Data
percentual = (len(all_info) * 30) // 100
np.random.shuffle(all_info)
train_data = all_info[:-percentual]
val_data = all_info[-percentual:]

dataset_train = MoleDataset()
dataset_train.load_shapes(train_data, config.IMAGE_SHAPE[0], config.IMAGE_SHAPE[1])
dataset_train.prepare()

dataset_val = MoleDataset()
dataset_val.load_shapes(val_data, config.IMAGE_SHAPE[0], config.IMAGE_SHAPE[1])
dataset_val.prepare()

print(f"Loaded {len(dataset_train.image_ids)} images into training dataset.")

model = modellib.MaskRCNN(mode="training", config=config, model_dir=MODEL_DIR)
model.load_weights(COCO_MODEL_PATH, by_name=True,
                   exclude=["mrcnn_class_logits", "mrcnn_bbox_fc",
                            "mrcnn_bbox", "mrcnn_mask"])

model.train(dataset_train, dataset_val,
            learning_rate=config.LEARNING_RATE,
            epochs=30,
            layers='heads')

model.train(dataset_train, dataset_val,
            learning_rate=config.LEARNING_RATE / 10,
            epochs=90,
            layers="all")

print("Training finished!")
