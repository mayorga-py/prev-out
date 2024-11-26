import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder, StandardScaler
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import LSTM, Dense, Dropout

# Cargar los datos desde el archivo Excel
file_path = "GEN 17_SD2020_LIMPIO.xlsx"  # Cambia esto al path real de tu archivo
data = pd.read_excel(file_path)

# Renombrar la columna 'PROGRAMA EDUCATIVO' a 'Carrera'
data.rename(columns={"PROGRAMA EDUCATIVO": "Carrera"}, inplace=True)

# Mapeo de valores entre GEN17 y GEN21
value_mapping = {
    'PYMES': 'ADMINISTRACION Y GESTION'
}

# Aplicar el mapeo a la columna Carrera
data['Carrera'] = data['Carrera'].replace(value_mapping)

# Convertir las columnas categóricas a numéricas
label_encoder_Carrera = LabelEncoder()
data['Carrera'] = label_encoder_Carrera.fit_transform(data['Carrera'])

# Convertir "SI"/"NO" a 1 y 0 en las columnas categóricas
categorical_columns = ["UPQ Primera opción", "Hijos", "Problema o padecimiento"]
for col in categorical_columns:
    data[col] = data[col].map({"SI": 1, "NO": 0})

# Reemplazar '#N/D' con un valor numérico, por ejemplo, -1
data.replace('#N/D', -1, inplace=True)

# Convertir columnas que deberían ser numéricas, pero que podrían haber sido leídas como objetos/strings
numeric_columns = ["Razonamiento matemático", "Razonamiento abstracto", "R. Verbal", "R. Espacial", "Informática",
                   "Cálculo", "Comunicación", "Mecánico", "Servicio", "Finanzas", "Ingreso mensual de padre",
                   "Ingreso mensual de madre", "Ingresos mensuales familiares", 'Minutos de trayecto a la universidad']

for col in numeric_columns:
    data[col] = pd.to_numeric(data[col], errors='coerce')

# Llenar valores faltantes en las columnas numéricas con la media
numeric_columns = data.select_dtypes(include=[np.number]).columns
data[numeric_columns] = data[numeric_columns].fillna(data[numeric_columns].mean())

# Aumentar el valor de la variable para darle más importancia
data['Minutos de trayecto a la universidad'] *= 2

# Crear la columna "BAJA" que será el objetivo (1 si hubo baja, 0 si no)
data['BAJA'] = data[['BAJA 1ER. CUATRI', 'BAJA 2DO. CUATRI', 'BAJA 3ER. CUATRI']].apply(lambda x: 1 if any(x != -1) else 0, axis=1)

# Seleccionar características (X) y objetivo (y)
X = data[['Carrera', "Razonamiento matemático", "Razonamiento abstracto", "R. Verbal", "R. Espacial", "Informática",
          "Cálculo", "Comunicación", "Mecánico", "Servicio", "Finanzas", "Ingreso mensual de padre",
          "Ingreso mensual de madre", "Ingresos mensuales familiares", 'Minutos de trayecto a la universidad',
          'UPQ Primera opción', 'Hijos', 'Problema o padecimiento']]

y = data['BAJA']

# Escalar características
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# Dividir los datos en conjuntos de entrenamiento y prueba
X_train, X_test, y_train, y_test = train_test_split(X_scaled, y, test_size=0.2, random_state=42)

# Crear el modelo LSTM
model = Sequential()
model.add(LSTM(50, activation='relu', input_shape=(X_train.shape[1], 1)))
model.add(Dropout(0.2))
model.add(Dense(1, activation='sigmoid'))

model.compile(optimizer='adam', loss='binary_crossentropy', metrics=['accuracy'])

# Redimensionar los datos para LSTM
X_train_reshaped = np.reshape(X_train, (X_train.shape[0], X_train.shape[1], 1))
X_test_reshaped = np.reshape(X_test, (X_test.shape[0], X_test.shape[1], 1))

# Entrenar el modelo
model.fit(X_train_reshaped, y_train, epochs=50, batch_size=32, validation_data=(X_test_reshaped, y_test))

# Evaluar el modelo
loss, accuracy = model.evaluate(X_test_reshaped, y_test)
print(f'Accuracy: {accuracy*100:.2f}%')

# Predecir con nuevos datos
new_data_path = "GEN 19_SD2022_Prueba.xlsx"  # Cambia esto al path real de tu archivo
new_data = pd.read_excel(new_data_path)

# Mapeo de las columnas (ajustado para "Programa Educativo")
column_mapping = {
    "Folio": "Matricula",
    "Programa Educativo": "Carrera",
    "Razonamiento matemático": "Razonamiento matemático",
    "Razonamiento abstracto": "Razonamiento abstracto",
    "R. Verbal": "R. Verbal",
    "R. Espacial": "R. Espacial",
    "Informática": "Informática",
    "Cálculo": "Cálculo",
    "Comunicación": "Comunicación",
    "Mecánico": "Mecánico",
    "Servicio": "Servicio",
    "Finanzas": "Finanzas",
    "Trabaja": "Trabaja",
    "Ingreso mensual de padre": "Ingreso mensual de padre",
    "Ingreso mensual de madre": "Ingreso mensual de madre",
    "Ingresos mensuales familiares": "Ingresos mensuales familiares",
    "Minutos de trayecto a la universidad": "Minutos de trayecto a la universidad",
    "UPQ Primera opción": "UPQ Primera opción",
    "Hijos": "Hijos",
    "Problema o padecimiento": "Problema o padecimiento"
}

# Renombrar las columnas en new_data para que coincidan con las columnas originales
new_data.rename(columns=column_mapping, inplace=True)

# Aplicar el mapeo de valores a la columna "Carrera"
if 'Carrera' in new_data.columns:
    new_data['Carrera'] = new_data['Carrera'].replace(value_mapping)
else:
    print("La columna 'Carrera' no se encuentra en los datos nuevos.")
    print("Columnas disponibles:", new_data.columns)

# Continuar con el procesamiento solo si la columna "Carrera" existe
if 'Carrera' in new_data.columns:
    new_data['Carrera'] = label_encoder_Carrera.transform(new_data['Carrera'])
    new_data.replace('#N/D', -1, inplace=True)

    # Convertir "SI"/"NO" a 1 y 0 en las columnas categóricas
    for col in categorical_columns:
        new_data[col] = new_data[col].map({"SI": 1, "NO": 0})

    # Convertir columnas que deberían ser numéricas, pero que podrían haber sido leídas como objetos/strings
    numeric_columns_new = ["Razonamiento matemático", "Razonamiento abstracto", "R. Verbal", "R. Espacial", "Informática",
                           "Cálculo", "Comunicación", "Mecánico", "Servicio", "Finanzas", "Ingreso mensual de padre",
                           "Ingreso mensual de madre", "Ingresos mensuales familiares", 'Minutos de trayecto a la universidad']
    for col in numeric_columns_new:
        new_data[col] = pd.to_numeric(new_data[col], errors='coerce')

    # Llenar valores faltantes en las columnas numéricas con la media
    numeric_columns_new = new_data.select_dtypes(include=[np.number]).columns
    new_data[numeric_columns_new] = new_data[numeric_columns_new].fillna(new_data[numeric_columns_new].mean())

    # Seleccionar las características necesarias para la predicción
    X_new = new_data[['Carrera', 'Razonamiento matemático', 'Razonamiento abstracto', 'R. Verbal', 'R. Espacial',
                      'Informática', 'Cálculo', 'Comunicación', 'Mecánico', 'Servicio', 'Finanzas',
                      'Ingreso mensual de padre', 'Ingreso mensual de madre', 'Ingresos mensuales familiares',
                      'Minutos de trayecto a la universidad', 'UPQ Primera opción', 'Hijos', 'Problema o padecimiento']]

    X_new_scaled = scaler.transform(X_new)

    # Verificar si hay NaNs en X_new_scaled
    if np.isnan(X_new_scaled).any():
        print("Advertencia: Hay valores NaN en X_new_scaled. Revisa el preprocesamiento de los datos.")

    # Redimensionar los datos para LSTM
    X_new_reshaped = np.reshape(X_new_scaled, (X_new_scaled.shape[0], X_new_scaled.shape[1], 1))

    # Realizar la predicción
    predictions = model.predict(X_new_reshaped)

    # Convertir las predicciones a porcentaje (0% a 100%) y aplanarlas
    predictions_percentage = (predictions.flatten()) * 100

    # Añadir las predicciones a la columna 'Probabilidad de Baja (%)'
    new_data['Probabilidad de Baja (%)'] = predictions_percentage

    # Guardar el archivo de salida con las predicciones
    output_path = "predicciones_GEN21.xlsx"
    new_data.to_excel(output_path, index=False)
    print(f"Predicciones guardadas en: {output_path}")