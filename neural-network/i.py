import numpy as np
import pandas as pd
import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import LSTM, Dense
import matplotlib.pyplot as plt
from sklearn.preprocessing import MinMaxScaler

# Generamos datos de ejemplo
df = pd.read_excel('gen 18_SD2021.xlsx')
data = pd.read_excel('gen 18_SD2021.xlsx')
data = data['R. Verbal'].values 

# Normalizar los datos
scaler = MinMaxScaler(feature_range=(0, 1))
data = scaler.fit_transform(data.reshape(-1, 1))

# Creamos secuencias a partir de los datos
def create_dataset(data, time_step=10):
    X, y = [], []
    for i in range(len(data) - time_step - 1):
        X.append(data[i:(i + time_step)])
        y.append(data[i + time_step])
    return np.array(X), np.array(y)

time_step = 10
X, y = create_dataset(data, time_step)

# Ajustamos los datos para que tengan la forma que la red espera
X = X.reshape(X.shape[0], X.shape[1], 1)

# Dividimos los datos en entrenamiento y prueba
train_size = int(len(X) * 0.67)
test_size = len(X) - train_size
X_train, X_test = X[0:train_size], X[train_size:len(X)]
y_train, y_test = y[0:train_size], y[train_size:len(y)]

# Definimos el modelo
model = Sequential()
model.add(LSTM(50, return_sequences=True, input_shape=(time_step, 1)))
model.add(LSTM(50, return_sequences=False))
model.add(Dense(1))

# Compilamos el modelo (decimos cómo entrenarlo)
model.compile(optimizer='adam', loss='mean_squared_error')

# Entrenamos el modelo
model.fit(X, y, epochs=100, batch_size=32, verbose=1)

# Hacemos predicciones con los datos de prueba
train_predict = model.predict(X_train)
test_predict = model.predict(X_test)

# Desnormalizamos las predicciones
train_predict = scaler.inverse_transform(train_predict)
test_predict = scaler.inverse_transform(test_predict)
y_train = scaler.inverse_transform(y_train.reshape(-1, 1))
y_test = scaler.inverse_transform(y_test.reshape(-1, 1))


# Visualizamos los datos reales y las predicciones
plt.figure(figsize=(12, 6))
plt.plot(scaler.inverse_transform(data), label='Datos Reales')
plt.plot(np.arange(time_step, len(train_predict) + time_step), train_predict, label='Predicciones de Entrenamiento')
plt.plot(np.arange(len(train_predict) + (2 * time_step), len(train_predict) + (2 * time_step) + len(test_predict)), test_predict, label='Predicciones de Prueba')
plt.legend()
plt.show()

# Guardar el modelo
model.save('modelo_lstm.h5')
