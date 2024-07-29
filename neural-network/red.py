import pandas as pd
import numpy as np
import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import SimpleRNN, Dense

file_path = 'Gen 18_SD2021.xlsx'
df = pd.read_excel(file_path)

data = df['R. Verbal'].values
data = (data - np.mean(data)) / np.std(data)
sequence_length = 10 
X = []
y = []

"""
#       ______    _____
#      /\/\/\/\   | “o \
#    <|\/\/\/\/|_/ /___/
#     |___________/
#     |_|_|  /_/_/

"""

for i in range(len(data) - sequence_length):
    X.append(data[i:i + sequence_length])
    y.append(data[i + sequence_length])

X = np.array(X)
y = np.array(y)

X = X.reshape((X.shape[0], X.shape[1], 1))

model = Sequential()
model.add(SimpleRNN(50, activation='relu', input_shape=(sequence_length, 1)))
model.add(Dense(1))

model.compile(optimizer='adam', loss='mse')

model.fit(X, y, epochs=100, batch_size=32)

predictions = model.predict(X)

mean_prediction = np.mean(predictions)
std_prediction = np.std(predictions)

print(f"Mean Prediction: {mean_prediction}")
print(f"Standard Deviation of Predictions: {std_prediction}")

