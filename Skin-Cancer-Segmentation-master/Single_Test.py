# -*- coding: utf-8 -*-
"""
Created on Wed Mar  5 20:31:13 2025

@author: dipen
"""

import os
import numpy as np
import cv2
import matplotlib.pyplot as plt
from Mask.config import Config
import Mask.model as modellib
import Mask.visualize as visualize

# Set paths for the trained model
MODEL_PATH = r"C:\Users\dipen\Documents\St.Marys\Super_Senior\Senior_Design\MachineLearning\Skin-Cancer-Segmentation-master\models\moles20250228T2328\mask_rcnn_moles_0090.h5"  # Update this with your actual model path

# Verify if model exists
if not os.path.exists(MODEL_PATH):
    raise Exception(f"❌ Model not found at {MODEL_PATH}")

# Define the class names for predictions
class_names = ["BG", "malignant", "seborrheic_keratosis", "benign"]

# Configuration for inference
class InferenceConfig(Config):
    NAME = "moles"
    NUM_CLASSES = 1 + 3  # background + (malignant, seborrheic_keratosis, benign)
    IMAGE_MIN_DIM = 128
    IMAGE_MAX_DIM = 128
    GPU_COUNT = 1
    IMAGES_PER_GPU = 1
    DETECTION_MIN_CONFIDENCE = 0.5  # Confidence threshold for predictions

config = InferenceConfig()

# Load the model in inference mode
model = modellib.MaskRCNN(mode="inference", model_dir="models", config=config)
model.load_weights(MODEL_PATH, by_name=True)

def classify_image(image_path):
    """
    Function to classify a mole image using the pre-trained model.
    """
    if not os.path.exists(image_path):
        print(f"❌ Image not found at {image_path}")
        return
    
    # Load and preprocess the image
    img = cv2.imread(image_path)
    if img is None:
        print(f"❌ Could not read image {image_path}")
        return
    
    # Convert BGR to RGB (since OpenCV loads images in BGR format)
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    
    # Resize image to match model requirements
    img_resized = cv2.resize(img, (128, 128))

    # Predict using the model
    results = model.detect([img_resized])[0]

    # Extract prediction details
    class_ids = results["class_ids"]
    scores = results["scores"]
    
    print("\n🔍 Predicted Class IDs:", class_ids)
    print("📊 Confidence Scores:", scores)

    # Convert class IDs to labels
    predicted_labels = [class_names[i] for i in class_ids] if class_ids else ["No prediction"]
    
    print(f"🎯 Classification Result: {predicted_labels}")

    # Visualize results
    visualize.display_instances(img_resized, results['rois'], results['masks'], results['class_ids'], class_names, results['scores'])

# Example Usage: Change to your image path
image_path = r"C:\Users\dipen\Documents\St.Marys\Super_Senior\Senior_Design\MachineLearning\Skin-Cancer-Segmentation-master\ISIC-Archive-Downloader-2017\Data\Test\Single\IMG_9420.jpeg"
classify_image(image_path)
