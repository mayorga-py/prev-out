import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder, StandardScaler
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import LSTM, Dense, Dropout

# Configurar archivo y generación para entrenamiento y predicción
train_file_path = "GEN 17_SD2020_LIMPIO.xlsx"  # Archivo de entrenamiento
predict_file_path = "GEN 19_SD2022_Prueba.xlsx"  # Archivo de predicción
train_generation = "gen17"  # Generación para entrenamiento
predict_generation = "gen19"  # Generación para predicción

# Mapeos específicos por generación
column_mapping = {
    "gen17": {"PROGRAMA EDUCATIVO": "PROGRAMA EDUCATIVO", "PYMES": "ADMINISTRACION Y GESTION"},
    "gen19": {"Programa Educativo": "PROGRAMA EDUCATIVO", "PYMES": "ADMINISTRACION Y GESTION"},
    "gen21": {"Carrera": "PROGRAMA EDUCATIVO", "PYMES": "ADMINISTRACION Y GESTION"}
}

# Función para cargar y procesar los datos
def load_and_process_data(file_path, generation):
    data = pd.read_excel(file_path)

    # Renombrar columnas según el mapeo de la generación
    if generation in column_mapping:
        data.rename(columns={k: v for k, v in column_mapping[generation].items() if k in data.columns}, inplace=True)
    
    # Reemplazar valores específicos en 'PROGRAMA EDUCATIVO'
    if "PROGRAMA EDUCATIVO" in data.columns:
        data['PROGRAMA EDUCATIVO'] = data['PROGRAMA EDUCATIVO'].replace(column_mapping[generation])
    
    # Convertir las columnas categóricas a numéricas
    label_encoder = LabelEncoder()
    if "PROGRAMA EDUCATIVO" in data.columns:
        data['PROGRAMA EDUCATIVO'] = label_encoder.fit_transform(data['PROGRAMA EDUCATIVO'])
    
    # Reemplazar '#N/D' y otros valores no válidos
    data.replace(['#N/D', 'N/D'], np.nan, inplace=True)

    # Convertir columnas numéricas
    numeric_columns = ["Razonamiento matemático", "Razonamiento abstracto", "R. Verbal", "R. Espacial", "Informática",
                       "Cálculo", "Comunicación", "Mecánico", "Servicio", "Finanzas", "Ingreso mensual de padre",
                       "Ingreso mensual de madre", "Ingresos mensuales familiares", 'Minutos de trayecto a la universidad']
    
    for col in numeric_columns:
        if col in data.columns:
            data[col] = pd.to_numeric(data[col], errors='coerce')
    
    # Llenar valores faltantes en las columnas numéricas con la media
    data[numeric_columns] = data[numeric_columns].fillna(data[numeric_columns].mean())
    
    # Crear columna de objetivo "BAJA"
    if {'BAJA 1ER. CUATRI', 'BAJA 2DO. CUATRI', 'BAJA 3ER. CUATRI'}.issubset(data.columns):
        data['BAJA'] = data[['BAJA 1ER. CUATRI', 'BAJA 2DO. CUATRI', 'BAJA 3ER. CUATRI']].apply(
            lambda x: 1 if any(val in ['BT', 'BV', 'BAC'] for val in x) else 0, axis=1)
    else:
        data['BAJA'] = 0  # Default for prediction data if 'BAJA' columns are missing
    
    return data

# Cargar y procesar datos de entrenamiento
train_data = load_and_process_data(train_file_path, train_generation)

# Seleccionar características (X) y objetivo (y) para el modelo
X_train = train_data[['PROGRAMA EDUCATIVO', "Razonamiento matemático", "Razonamiento abstracto", "R. Verbal", 
                     "R. Espacial", "Informática", "Cálculo", "Comunicación", "Mecánico", "Servicio", 
                     "Finanzas", "Ingreso mensual de padre", "Ingreso mensual de madre", 
                     "Ingresos mensuales familiares", 'Minutos de trayecto a la universidad']]
y_train = train_data['BAJA']

# Escalar características
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)

# Dividir los datos en entrenamiento y validación
X_train, X_val, y_train, y_val = train_test_split(X_train_scaled, y_train, test_size=0.2, random_state=42)

# Redimensionar los datos para LSTM
X_train_reshaped = np.reshape(X_train, (X_train.shape[0], X_train.shape[1], 1))
X_val_reshaped = np.reshape(X_val, (X_val.shape[0], X_val.shape[1], 1))

# Crear el modelo LSTM
model = Sequential()
model.add(LSTM(50, activation='relu', input_shape=(X_train.shape[1], 1)))
model.add(Dropout(0.2))
model.add(Dense(1, activation='sigmoid'))

model.compile(optimizer='adam', loss='binary_crossentropy', metrics=['accuracy'])

# Entrenar el modelo
model.fit(X_train_reshaped, y_train, epochs=50, batch_size=32, validation_data=(X_val_reshaped, y_val))

# Evaluar el modelo
loss, accuracy = model.evaluate(X_val_reshaped, y_val)
print(f'Accuracy: {accuracy*100:.2f}%')

# Cargar y procesar datos de predicción
predict_data = load_and_process_data(predict_file_path, predict_generation)

# Seleccionar características para la predicción y escalar con el mismo scaler
X_predict = predict_data[['PROGRAMA EDUCATIVO', 'Razonamiento matemático', 'Razonamiento abstracto', 'R. Verbal', 
                          'R. Espacial', 'Informática', 'Cálculo', 'Comunicación', 'Mecánico', 'Servicio', 
                          'Finanzas', 'Ingreso mensual de padre', 'Ingreso mensual de madre', 
                          'Ingresos mensuales familiares', 'Minutos de trayecto a la universidad']]
X_predict_scaled = scaler.transform(X_predict)
X_predict_reshaped = np.reshape(X_predict_scaled, (X_predict_scaled.shape[0], X_predict_scaled.shape[1], 1))

# Realizar la predicción
predictions = model.predict(X_predict_reshaped)

# Convertir las predicciones a porcentaje
predictions_percentage = predictions * 100

# Añadir las predicciones al DataFrame original
predict_data['Probabilidad Baja (%)'] = predictions_percentage

# Guardar los resultados en un archivo Excel
predict_data.to_excel("predicciones_bajas.xlsx", index=False)
print("Predicciones guardadas en el archivo 'predicciones_bajas.xlsx'.")

