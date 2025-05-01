# -*- coding: utf-8 -*-
"""
Updated on: 2025-04-30
Author: dipen
"""

import os
import numpy as np
import cv2
import tensorflow as tf

# Load the MobileNetV2 model
MODEL_FILE = "mobilenet_skin_classifier.h5"
if not os.path.exists(MODEL_FILE):
    raise FileNotFoundError(f"❌ Model not found at {MODEL_FILE}")

model = tf.keras.models.load_model(MODEL_FILE)

# Define the class names (same order as used during training)
class_names = ["malignant", "seborrheic_keratosis", "benign"]

def classify_image(image_path):
    """
    Classifies a skin lesion image using the trained MobileNetV2 classifier.
    Prints the predicted class and confidence score.
    """
    if not os.path.exists(image_path):
        print(f"❌ Image not found at {image_path}")
        return

    # Load image
    img = cv2.imread(image_path)
    if img is None:
        print(f"❌ Could not read image: {image_path}")
        return

    # Preprocess: resize, normalize, expand dims
    img = cv2.resize(img, (224, 224))
    img = img / 255.0
    img = np.expand_dims(img, axis=0)  # Shape: (1, 224, 224, 3)

    # Run inference
    predictions = model.predict(img)[0]
    pred_index = np.argmax(predictions)
    pred_label = class_names[pred_index]
    confidence = predictions[pred_index]

    # Output results
    print(f"\n🔍 Prediction: {pred_label}")
    print(f"📊 Confidence: {confidence * 100:.2f}%")

# Example Usage
image_path = r"C:/Users/Juanm/Documents/Senior Design/DermoLight/Skin-Cancer-Segmentation-master/ISIC-Archive-Downloader-2017/Data/Test/Single/IMG_9420.jpeg"
classify_image(image_path)
