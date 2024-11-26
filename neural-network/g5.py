import pandas as pd
import numpy as np
from datetime import datetime
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder, StandardScaler, MinMaxScaler
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import LSTM, Dense, Dropout

# Configurar archivo y generación para entrenamiento y predicción
train_files = ["GEN 17_SD2020_LIMPIO.xlsx", "GEN 18_SD2021_LIMPIO.xlsx", "GEN 19_SD2022_LIMPIO.xlsx"]
train_generations = ["gen17", "gen18", "gen19"]
predict_file_path = "Gen 21_SD2023_LIMPIO.xlsx"  # Archivo de predicción
predict_generation = "gen21"  # Generación para predicción

# Mapeos específicos por generación
column_mapping = {
    "gen17": {
        "PROGRAMA EDUCATIVO": "PROGRAMA EDUCATIVO",
        "PYMES": "ADMINISTRACION Y GESTION",
    },
    "gen18": {  # Agregar el mapeo para gen18
        "PROGRAMA EDUCATIVO": "PROGRAMA EDUCATIVO",
        "PYMES": "ADMINISTRACION Y GESTION",
    },
    "gen19": {
        "Programa Educativo": "PROGRAMA EDUCATIVO",
        "PYMES": "ADMINISTRACION Y GESTION",
    },
    "gen21": {
        "Carrera": "PROGRAMA EDUCATIVO",
        "PYMES": "ADMINISTRACION Y GESTION",
    }
}

global_column_mapping = {
    "R. Espacial": ["R. Espacial", "R Espacial / Visual espacial}"],
    "Informática": ["Informática", "Abstracta Cientifica/ Informatica"],
    "Cálculo": ["Cálculo", "Numerica / Cálculo"],
    "Comunicación": ["Comunicación", "Persuasiva / Comunicación"],
    "Mecánico": ["Mecánico", "Mecánica / Mecánico"],
    "Servicio": ["Servicio", "Social Aptitudes / Servicio"],
    "Finanzas": ["Finanzas", "Organización / Finanzas"],
    "PROGRAMA EDUCATIVO": ["PROGRAMA EDUCATIVO", "Programa Educativo", "Carrera"],
    "Estado civil": ["Estado civil", "¿Cuál es tu estado civil?"],
    "Hijos": ["Hijos", "¿Tienes hijos?"],
    "Problema o padecimiento": ["Problema o padecimiento", "¿Tienes algun problema fisico o padecimiento?"],
    "Razonamiento matemático": ["Razonamiento matemático", "R Numérico"],
    "Razonamiento abstracto": ["Razonamiento abstracto", "R Abstracto"],
    "R. Verbal": ["R. Verbal", "R Verbal"],
    "R. Espacial": ["R. Espacial", "R Espacial / Visual espacial"],
    "Informática": ["Informática", "Abstracta Cientifica/ Informatica"],
    "Cálculo": ["Cálculo", "Numerica / Cálculo"],
    "Comunicación": ["Comunicación", "Persuasiva / Comunicación"],
    "Mecánico": ["Mecánico", "Mecánica / Mecánico"],
    "Servicio": ["Servicio", "Social Aptitudes / Servicio"],
    "Finanzas": ["Finanzas", "Organización / Finanzas"],
    "Trabaja": ["Trabaja", "¿Trabajas?"],
    "Ingreso mensual de padre": ["Ingreso mensual de padre", "¿Cuál es su ingreso mensual?"],
    "Ingreso mensual de madre": ["Ingreso mensual de madre", "¿Cuál es su ingreso mensual?.1"],
    "Ingresos mensuales familiares": ["Ingresos mensuales familiares", "¿Cuáles son los ingresos mensuales familiares?"],
    "UPQ Primera opción": ["UPQ Primera opción", "¿La UPQ fue tu primera opción?"],
    "Minutos de trayecto a la universidad": ["Minutos de trayecto a la universidad", "¿Cuántos minutos de trayecto haces a la UPQ?"],
    "BAJA 1ER. CUATRI": ["BAJA 1ER. CUATRI", "BAJAS 1ER. CUATRI"],
    "BAJA 2DO. CUATRI": ["BAJA 2DO. CUATRI", "BAJAS 2DO CUATRI"],
    "BAJA 3ER. CUATRI": ["BAJA 3ER. CUATRI", "BAJAS 3ER CUATRI"],
    "Matricula": ["Matricula", "Folio", "Clave de acceso"],
}

# Función para normalizar nombres de columnas
def normalize_columns(df, column_mapping):
    normalized_columns = {}
    for standard_name, variations in column_mapping.items():
        for column in variations:
            if column in df.columns:
                normalized_columns[column] = standard_name
    return df.rename(columns=normalized_columns)

# Función para cargar y procesar los datos
def load_and_process_data(file_path, generation):
    # Cargar los datos desde el archivo Excel
    data = pd.read_excel(file_path)
    data = normalize_columns(data, global_column_mapping)
    # Renombrar columnas según el mapeo de la generación
    if generation in column_mapping:
        data.rename(columns={k: v for k, v in column_mapping[generation].items() if k in data.columns}, inplace=True)
    
    # Reemplazar valores específicos en 'PROGRAMA EDUCATIVO'
    if "PROGRAMA EDUCATIVO" in data.columns:
        data['PROGRAMA EDUCATIVO'] = data['PROGRAMA EDUCATIVO'].replace(column_mapping[generation])
    
    # Convertir 'PROGRAMA EDUCATIVO' a numérico si existe
    label_encoder_PROGRAMAEDUCATIVO = LabelEncoder()
    if "PROGRAMA EDUCATIVO" in data.columns:
        data['PROGRAMA EDUCATIVO'] = label_encoder_PROGRAMAEDUCATIVO.fit_transform(data['PROGRAMA EDUCATIVO'])
    
    # Reemplazar '#N/D' con un valor numérico
    data.replace('#N/D', -1, inplace=True)

    # Convertir columnas categóricas a numéricas
    categorical_mappings = {
        "Estado civil": {"Soltero(a)": 0, "Casado(a)": 1, "Divorciado(a)": 2, "Union Libre": 3},
        "Hijos": {"No": 0, "Si": 1},
        "Problema o padecimiento": {"No": 0, "Si": 1},
        "Trabaja": {"No": 0, "Si": 1},
        "UPQ Primera opción": {"No": 0, "Si": 1}
    }
    for col, mapping in categorical_mappings.items():
        if col in data.columns:
            data[col] = data[col].map(mapping)
    
    # Convertir columnas que deberían ser numéricas
    numeric_columns = ["Razonamiento matemático", "Razonamiento abstracto", "R. Verbal", "R. Espacial", "Informática",
                       "Cálculo", "Comunicación", "Mecánico", "Servicio", "Finanzas", "Ingreso mensual de padre",
                       "Ingreso mensual de madre", "Ingresos mensuales familiares", 'Minutos de trayecto a la universidad']
    
    for col in numeric_columns:
        if col in data.columns:
            data[col] = pd.to_numeric(data[col], errors='coerce')
    
    # Llenar valores faltantes en las columnas numéricas con la media
    numeric_columns = data.select_dtypes(include=[np.number]).columns
    data[numeric_columns] = data[numeric_columns].fillna(data[numeric_columns].mean())
    
    # Normalizar columnas
    range_defined_features = ['Razonamiento matemático', 'Razonamiento abstracto', 'R. Verbal', 
                              'R. Espacial', 'Informática', 'Cálculo', 'Comunicación', 'Mecánico', 
                              'Servicio', 'Finanzas']
    no_range_features = ['Ingreso mensual de padre', 'Ingreso mensual de madre', 
                         'Ingresos mensuales familiares', 'Minutos de trayecto a la universidad']
    
    # Normalización en rango definido
    data[range_defined_features] = data[range_defined_features] / 100
    
    # Normalización sin rango definido
    min_max_scaler = MinMaxScaler()
    data[no_range_features] = min_max_scaler.fit_transform(data[no_range_features])
    
    # Crear columna de objetivo "BAJA" según los criterios indicados
    if {'BAJA 1ER. CUATRI', 'BAJA 2DO. CUATRI', 'BAJA 3ER. CUATRI'}.issubset(data.columns):
        data['BAJA'] = data[['BAJA 1ER. CUATRI', 'BAJA 2DO. CUATRI', 'BAJA 3ER. CUATRI']].apply(
            lambda x: 1 if any(val in ['BT', 'BV', 'BAC'] for val in x) else 0, axis=1)
    else:
        data['BAJA'] = 0  # Valor predeterminado para datos de predicción si faltan columnas "BAJA"

    return data

# Cargar y procesar datos de entrenamiento
# Cargar y combinar los datos de múltiples generaciones
# Función para cargar y combinar los datos de entrenamiento
def load_and_combine_training_data(files, generations):
    combined_data = pd.DataFrame()
    for file_path, generation in zip(files, generations):
        data = load_and_process_data(file_path, generation)
        combined_data = pd.concat([combined_data, data], ignore_index=True)
    return combined_data

# Cargar los datos combinados
train_data = load_and_combine_training_data(train_files, train_generations)

# Seleccionar características (X) y objetivo (y) para el modelo
features = ['PROGRAMA EDUCATIVO', 'Razonamiento matemático', 'Razonamiento abstracto', 'R. Verbal', 
            'R. Espacial', 'Informática', 'Cálculo', 'Comunicación', 'Mecánico', 'Servicio', 
            'Finanzas', 'Ingreso mensual de padre', 'Ingreso mensual de madre', 'Ingresos mensuales familiares', 
            'Minutos de trayecto a la universidad', 'Estado civil', 'Hijos', 'Problema o padecimiento', 
            'Trabaja', 'UPQ Primera opción']
X_train = train_data[features]
y_train = train_data['BAJA']

# Escalar todas las características
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
# Entrenar el modelo
model.fit(X_train_reshaped, y_train, epochs=50, batch_size=32, validation_data=(X_val_reshaped, y_val))

# Guardar el modelo en un archivo .h5
model_file_path = "lstm_model.h5"
model.save(model_file_path)
print(f'Modelo guardado en {model_file_path}')

# Evaluar el modelo
loss, accuracy = model.evaluate(X_val_reshaped, y_val)
print(f'Accuracy: {accuracy*100:.2f}%')

# Cargar y procesar datos de predicción
predict_data = load_and_process_data(predict_file_path, predict_generation)

# Seleccionar características para la predicción y escalar con el mismo scaler
X_predict = predict_data[features]
X_predict_scaled = scaler.transform(X_predict)
X_predict_reshaped = np.reshape(X_predict_scaled, (X_predict_scaled.shape[0], X_predict_scaled.shape[1], 1))

# Realizar la predicción
predictions = model.predict(X_predict_reshaped)

# Convertir las predicciones a porcentaje
predictions_percentage = predictions * 100 *2

# Añadir las predicciones al DataFrame original
predict_data['Probabilidad Baja (%)'] = predictions_percentage

# Eliminar la columna "BAJA" si existe en el DataFrame de predicción
if 'BAJA' in predict_data.columns:
    predict_data.drop(columns=['BAJA'], inplace=True)

# Redondear los valores de "Estado civil" a números enteros, si existen
if 'Estado civil' in predict_data.columns:
    predict_data['Estado civil'] = predict_data['Estado civil'].round().astype(int)

# Guardar los resultados en un archivo Excel
# Crear un nombre único para el archivo de salida usando la fecha y hora actual

timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
output_file = f"predicciones_g4.xlsx"

# Guardar los resultados
predict_data.to_excel(output_file, index=False)
print(f"Predicciones guardadas en el archivo 'predicciones_g4y2'.")