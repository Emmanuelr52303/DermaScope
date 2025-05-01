import os
import numpy as np
import cv2
import pandas as pd
import shutil
import tensorflow as tf
import matplotlib.pyplot as plt
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.applications import MobileNetV2
from tensorflow.keras import layers, models
from tensorflow.keras.callbacks import CSVLogger

print(tf.__version__)

# --- CONFIGURATION ---
IMAGE_SIZE = 224
BATCH_SIZE = 32
EPOCHS = 15
OUTPUT_DIR = "classification_dataset"

# --- STEP 1: Load CSV Labels ---
path_data = input("Insert the path of Data [e.g., /home/../ISIC-Archive-Downloader/Data/]: ").strip()
if not os.path.exists(path_data):
    raise Exception(f"{path_data} does not exist.")

csv_path = os.path.join(path_data, "Labels", "ISIC-2017_Training_Part3_GroundTruth.csv")
if not os.path.exists(csv_path):
    raise FileNotFoundError(f"CSV file not found: {csv_path}")

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

print(f"✅ Loaded {len(label_dict)} labels.")

# --- STEP 2: Load Images and Assign Labels ---
all_data = []
img_dir = os.path.join(path_data, "Images")

for fname in os.listdir(img_dir):
    if not fname.endswith(".jpg"):
        continue
    img_id = fname.replace(".jpg", "")
    if img_id not in label_dict:
        continue

    label = label_dict[img_id]
    img_path = os.path.join(img_dir, fname)
    img = cv2.imread(img_path)
    if img is None:
        continue

    img = cv2.resize(img, (IMAGE_SIZE, IMAGE_SIZE))
    all_data.append((img, label))

print(f"📸 Loaded {len(all_data)} images.")

# --- STEP 3: Save to Classification Folder Structure ---
np.random.shuffle(all_data)
split_index = int(len(all_data) * 0.7)
train_data = all_data[:split_index]
val_data = all_data[split_index:]

for label in ["malignant", "seborrheic_keratosis", "benign"]:
    os.makedirs(os.path.join(OUTPUT_DIR, "train", label), exist_ok=True)
    os.makedirs(os.path.join(OUTPUT_DIR, "val", label), exist_ok=True)

def save_images(data, subset):
    for i, (img, label) in enumerate(data):
        out_path = os.path.join(OUTPUT_DIR, subset, label, f"{label}_{i}.jpg")
        cv2.imwrite(out_path, img)

save_images(train_data, "train")
save_images(val_data, "val")
print(f"🗂 Images saved in classification_dataset folder.")

# --- STEP 4: Image Data Generators ---
train_gen = ImageDataGenerator(rescale=1./255, rotation_range=10, zoom_range=0.1, horizontal_flip=True)
val_gen = ImageDataGenerator(rescale=1./255)

train_data_gen = train_gen.flow_from_directory(
    os.path.join(OUTPUT_DIR, "train"),
    target_size=(IMAGE_SIZE, IMAGE_SIZE),
    batch_size=BATCH_SIZE,
    class_mode='categorical'
)

val_data_gen = val_gen.flow_from_directory(
    os.path.join(OUTPUT_DIR, "val"),
    target_size=(IMAGE_SIZE, IMAGE_SIZE),
    batch_size=BATCH_SIZE,
    class_mode='categorical'
)

# --- STEP 5: Build MobileNetV2 Model ---
base_model = MobileNetV2(input_shape=(IMAGE_SIZE, IMAGE_SIZE, 3), include_top=False, weights='imagenet')
base_model.trainable = False

model = models.Sequential([
    base_model,
    layers.GlobalAveragePooling2D(),
    layers.Dense(128, activation='relu'),
    layers.Dropout(0.3),
    layers.Dense(3, activation='softmax')
])

model.compile(optimizer='adam', loss='categorical_crossentropy', metrics=['accuracy'])
model.summary()

# --- STEP 6: Train Model with Logging ---
csv_logger = CSVLogger('training_log.csv', append=True)
history = model.fit(
    train_data_gen,
    validation_data=val_data_gen,
    epochs=EPOCHS,
    verbose=1,
    callbacks=[csv_logger]
)
model.save("mobilenet_skin_classifier.h5")
print("✅ Model training complete and saved as mobilenet_skin_classifier.h5")

# --- STEP 7: Plot Training Metrics ---
plt.figure(figsize=(8, 6))
plt.plot(history.history['accuracy'], label='Training Accuracy')
plt.plot(history.history['val_accuracy'], label='Validation Accuracy')
plt.title('Model Accuracy Over Epochs')
plt.xlabel('Epoch')
plt.ylabel('Accuracy')
plt.legend()
plt.grid(True)
plt.show()

plt.figure(figsize=(8, 6))
plt.plot(history.history['loss'], label='Training Loss')
plt.plot(history.history['val_loss'], label='Validation Loss')
plt.title('Model Loss Over Epochs')
plt.xlabel('Epoch')
plt.ylabel('Loss')
plt.legend()
plt.grid(True)
plt.show()

# --- STEP 8: Convert to TFLite ---
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()
with open("model.tflite", "wb") as f:
    f.write(tflite_model)

print("✅ Converted to TensorFlow Lite model: model.tflite")