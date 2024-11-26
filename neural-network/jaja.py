import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder, StandardScaler
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import LSTM, Dense, Dropout
from tensorflow.keras.models import load_model

# Cargar los datos desde el archivo Excel
file_path = "a.xlsx"  # Cambia esto al path real de tu archivo
data = pd.read_excel(file_path)

# Paso 1: Preprocesamiento de datos

# Convertir las columnas categóricas a numéricas
label_encoder_carrera = LabelEncoder()
data['Carrera'] = label_encoder_carrera.fit_transform(data['Carrera'])

# Reemplazar '#N/D' con un valor numérico, por ejemplo, -1
data.replace('#N/D', -1, inplace=True)

# Crear la columna "BAJA" que será el objetivo (1 si hubo baja, 0 si no)
data['BAJA'] = data[['BAJA 1ER CUATRI', 'BAJA 2DO CUATRI', 'BAJA 3ER CUATRI']].apply(lambda x: 1 if any(x != -1) else 0, axis=1)

# Seleccionar características (X) y objetivo (y)
X = data[['Carrera', 'MINUTOS DE TRANSLADO', 'R. Verbal', 'R. Espacial']]
# Aumentar el valor de la variable para darle más importancia
data['MINUTOS DE TRANSLADO'] *= 2

y = data['BAJA']

# Escalar características
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# Dividir los datos en conjuntos de entrenamiento y prueba
X_train, X_test, y_train, y_test = train_test_split(X_scaled, y, test_size=0.2, random_state=42)

# Paso 2: Crear el modelo LSTM

model = Sequential()
model.add(LSTM(50, activation='relu', input_shape=(X_train.shape[1], 1)))
model.add(Dropout(0.2))
model.add(Dense(1, activation='sigmoid'))

model.compile(optimizer='adam', loss='binary_crossentropy', metrics=['accuracy'])

# Paso 3: Entrenar el modelo

# Redimensionar los datos para LSTM
X_train_reshaped = np.reshape(X_train, (X_train.shape[0], X_train.shape[1], 1))
X_test_reshaped = np.reshape(X_test, (X_test.shape[0], X_test.shape[1], 1))

# Entrenar el modelo
model.fit(X_train_reshaped, y_train, epochs=50, batch_size=32, validation_data=(X_test_reshaped, y_test))

# Guardar el modelo entrenado
model.save("train_model.h5")

# Evaluar el modelo
loss, accuracy = model.evaluate(X_test_reshaped, y_test)
print(f'Accuracy: {accuracy*100:.2f}%')

# Paso 4: Predecir con nuevos datos

# Cargar el nuevo archivo Excel con los datos de los estudiantes que se quieren predecir
new_data_path = "b.xlsx"  # Cambia esto al path real de tu archivo
new_data = pd.read_excel(new_data_path)

# Preprocesar los datos igual que antes
new_data['Carrera'] = label_encoder_carrera.transform(new_data['Carrera'])
new_data.replace('#N/D', -1, inplace=True)

# Seleccionar las características necesarias para la predicción
X_new = new_data[['Carrera', 'MINUTOS DE TRANSLADO', 'R. Verbal', 'R. Espacial']]
X_new_scaled = scaler.transform(X_new)

# Redimensionar los datos para LSTM
X_new_reshaped = np.reshape(X_new_scaled, (X_new_scaled.shape[0], X_new_scaled.shape[1], 1))
# Cargar el modelo guardado para realizar predicciones
model = load_model("train_model.h5")   

# Realizar la predicción
predictions = model.predict(X_new_reshaped)

# Convertir las predicciones a porcentaje (0% a 100%)
predictions_percentage = predictions * 100

# Añadir las predicciones al DataFrame original
new_data['Probabilidad Baja (%)'] = predictions_percentage

# Guardar los resultados a un nuevo archivo Excel
new_data.to_excel("predicciones_bajas_con_porcentaje.xlsx", index=False)

print("Predicciones guardadas en predicciones_bajas_con_porcentaje.xlsx")
