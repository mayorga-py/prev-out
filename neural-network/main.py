import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline
import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense

# Cargar datos
df = pd.read_excel('datos_estudiantes.xlsx')

# Limpieza de datos
df = df.dropna()

# Variables categóricas
categorical_features = ['estado_civil', 'padecimiento']
numeric_features = ['salario', 'monto_familiar', 'tiempo_translado']

# Preprocesamiento
preprocessor = ColumnTransformer(
    transformers=[
        ('num', StandardScaler(), numeric_features),
        ('cat', OneHotEncoder(), categorical_features)
    ])

X = df[numeric_features + categorical_features]
y = df['probabilidad_baja']

# Dividir los datos
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Crear pipeline de preprocesamiento
preprocessor = preprocessor.fit(X_train)

# Transformar los datos
X_train = preprocessor.transform(X_train)
X_test = preprocessor.transform(X_test)

# Definir el modelo
model = Sequential([
    Dense(64, activation='relu', input_shape=(X_train.shape[1],)),
    Dense(32, activation='relu'),
    Dense(1, activation='sigmoid')
])

# Compilar el modelo
model.compile(optimizer='adam', loss='binary_crossentropy', metrics=['accuracy'])

# Entrenar el modelo
model.fit(X_train, y_train, epochs=50, batch_size=32, validation_split=0.2)

# Evaluar el modelo
loss, accuracy = model.evaluate(X_test, y_test)
print(f'Precisión: {accuracy}')
