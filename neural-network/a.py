import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder, StandardScaler
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import LSTM, Dense, Dropout

# Definir el archivo y la generación
file_path = "GEN 17_SD2020_LIMPIO.xlsx"  # Cambia esto al path real de tu archivo
generation = "gen17"  # Cambia a "gen17" o la generación que corresponda

# Cargar los datos desde el archivo Excel
data = pd.read_excel(file_path)

# Definir mapeos específicos según la generación
column_mapping = {
    "gen17": {
        "PROGRAMA EDUCATIVO": "PROGRAMA EDUCATIVO",
        "PYMES": "ADMINISTRACION Y GESTION",
    },
    "gen19": {
        "Programa Educativo": "PROGRAMA EDUCATIVO",  # Cambio en mayúsculas y minúsculas
        "PYMES": "ADMINISTRACION Y GESTION",
    },
    "gen21": {
        "Carrera": "PROGRAMA EDUCATIVO",
        "PYMES": "ADMINISTRACION Y GESTION",
    }
}

# Renombrar columnas según el mapeo de la generación
if generation in column_mapping:
    data.rename(columns={k: v for k, v in column_mapping[generation].items() if k in data.columns}, inplace=True)

# Reemplazar valores específicos
if "PROGRAMA EDUCATIVO" in data.columns:
    data["PROGRAMA EDUCATIVO"].replace(column_mapping[generation], inplace=True)
else:
    print("Advertencia: La columna 'PROGRAMA EDUCATIVO' no se encontró en los datos.")


# El resto de tu código permanece igual...

# Convertir las columnas categóricas a numéricas
label_encoder_PROGRAMAEDUCATIVO = LabelEncoder()
data['PROGRAMA EDUCATIVO'] = label_encoder_PROGRAMAEDUCATIVO.fit_transform(data['PROGRAMA EDUCATIVO'])

# Reemplazar '#N/D' con un valor numérico, por ejemplo, -1
data.replace('#N/D', -1, inplace=True)

# Convertir columnas que deberían ser numéricas, pero que podrían haber sido leídas como objetos/strings
numeric_columns = ["Razonamiento matemático", "Razonamiento abstracto", "R. Verbal", "R. Espacial", "Informática",
                   "Cálculo", "Comunicación", "Mecánico", "Servicio", "Finanzas", "Ingreso mensual de padre",
                   "Ingreso mensual de madre", "Ingresos mensuales familiares", 'Minutos de trayecto a la universidad']

# Convertir a números
for col in numeric_columns:
    data[col] = pd.to_numeric(data[col], errors='coerce')

# Llenar valores faltantes en las columnas numéricas con la media
numeric_columns = data.select_dtypes(include=[np.number]).columns
data[numeric_columns] = data[numeric_columns].fillna(data[numeric_columns].mean())

# Crear la columna "BAJA" que será el objetivo (1 si hubo baja, 0 si no)
data['BAJA'] = data[['BAJA 1ER. CUATRI', 'BAJA 2DO. CUATRI', 'BAJA 3ER. CUATRI']].apply(lambda x: 1 if any(x != -1) else 0, axis=1)

# Seleccionar características (X) y objetivo (y)
X = data[['PROGRAMA EDUCATIVO', "Razonamiento matemático", "Razonamiento abstracto", "R. Verbal", "R. Espacial", "Informática",
          "Cálculo", "Comunicación", "Mecánico", "Servicio", "Finanzas", "Ingreso mensual de padre",
          "Ingreso mensual de madre", "Ingresos mensuales familiares", 'Minutos de trayecto a la universidad']]

# Aumentar el valor de la variable para darle más importancia
data['Minutos de trayecto a la universidad'] *= 2

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

# Evaluar el modelo
loss, accuracy = model.evaluate(X_test_reshaped, y_test)
print(f'Accuracy: {accuracy*100:.2f}%')

# Paso 4: Predecir con nuevos datos

# Cargar el nuevo archivo Excel con los datos de los estudiantes que se quieren predecir
new_data_path = "GEN 19_SD2022_Prueba.xlsx"  # Cambia esto al path real de tu archivo
new_data = pd.read_excel(new_data_path)

# Convertir todos los nombres de columna en new_data a mayúsculas para evitar errores de KeyError
new_data.columns = [col.upper() for col in new_data.columns]

# Renombrar columnas en los nuevos datos y reemplazar valores si es necesario
new_data.rename(columns={k.upper(): v for k, v in column_mapping[generation].items() if k.upper() in new_data.columns}, inplace=True)


# Verificar si la columna 'PROGRAMA EDUCATIVO' existe antes de aplicar el LabelEncoder
if "PROGRAMA EDUCATIVO" in new_data.columns:
    new_data["PROGRAMA EDUCATIVO"].replace(column_mapping[generation], inplace=True)
    new_data['PROGRAMA EDUCATIVO'] = label_encoder_PROGRAMAEDUCATIVO.transform(new_data['PROGRAMA EDUCATIVO'])
else:
    print("Advertencia: La columna 'PROGRAMA EDUCATIVO' no se encontró en los datos de new_data.")

# Continuar con el resto del preprocesamiento
new_data.replace('#N/D', -1, inplace=True)

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
X_new = new_data[['PROGRAMA EDUCATIVO', 'Razonamiento matemático', 'Razonamiento abstracto', 'R. Verbal', 'R. Espacial', 
                 'Informática', 'Cálculo', 'Comunicación', 'Mecánico', 'Servicio', 'Finanzas', 
                 'Ingreso mensual de padre', 'Ingreso mensual de madre', 'Ingresos mensuales familiares', 
                 'Minutos de trayecto a la universidad']]
X_new_scaled = scaler.transform(X_new)

# Redimensionar los datos para LSTM
X_new_reshaped = np.reshape(X_new_scaled, (X_new_scaled.shape[0], X_new_scaled.shape[1], 1))

# Realizar la predicción
predictions = model.predict(X_new_reshaped)

# Convertir las predicciones a porcentaje (0% a 100%)
predictions_percentage = predictions * 100

# Añadir las predicciones al DataFrame original
new_data['Probabilidad Baja (%)'] = predictions_percentage

# Guardar los resultados a un nuevo archivo Excel
new_data.to_excel("predicciones_bajas_con_porcentaje.xlsx", index=False)

print("Predicciones guardadas en predicciones_bajas_con_porcentaje.xlsx")