import os
import numpy as np
import pandas as pd
from flask import Flask, render_template, request, redirect, url_for, send_file, jsonify
from werkzeug.utils import secure_filename
from tensorflow.keras.models import Sequential, load_model
from tensorflow.keras.layers import LSTM, Dense, Dropout
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder, StandardScaler

app = Flask(__name__)
app.config['UPLOAD_FOLDER'] = "./Archivos PDF"

if not os.path.exists(app.config['UPLOAD_FOLDER']):
    os.makedirs(app.config['UPLOAD_FOLDER'])

# Modelo y escalador globales
model_file_path = 'modelo_entrenado.h5'
scaler = StandardScaler()

# Cargar o entrenar el modelo
try:
    model = load_model(model_file_path)
    print("Modelo cargado exitosamente.")
except:
    print("Modelo no encontrado. Creando y entrenando uno nuevo.")
    # Cargar y procesar datos para el entrenamiento
    def load_and_process_data(file_path, generation, column_mapping):
        data = pd.read_excel(file_path)
        if generation in column_mapping:
            data.rename(columns={k: v for k, v in column_mapping[generation].items() if k in data.columns}, inplace=True)
        if "PROGRAMA EDUCATIVO" in data.columns:
            label_encoder = LabelEncoder()
            data['PROGRAMA EDUCATIVO'] = label_encoder.fit_transform(data['PROGRAMA EDUCATIVO'].replace(column_mapping[generation]))
        data.replace('#N/D', -1, inplace=True)
        numeric_columns = data.select_dtypes(include=[np.number]).columns
        data[numeric_columns] = data[numeric_columns].fillna(data[numeric_columns].mean())
        if {'BAJA 1ER. CUATRI', 'BAJA 2DO. CUATRI', 'BAJA 3ER. CUATRI'}.issubset(data.columns):
            data['BAJA'] = data[['BAJA 1ER. CUATRI', 'BAJA 2DO. CUATRI', 'BAJA 3ER. CUATRI']].apply(
                lambda x: 1 if any(val in ['BT', 'BV', 'BAC'] for val in x) else 0, axis=1)
        else:
            data['BAJA'] = 0
        return data

    train_files = [("GEN 17_SD2020_LIMPIO.xlsx", "gen17"),
                   ("GEN 18_SD2021_LIMPIO.xlsx", "gen18"),
                   ("GEN 19_SD2022_LIMPIO.xlsx", "gen19")]
    column_mapping = {
        "gen17": {"PROGRAMA EDUCATIVO": "PROGRAMA EDUCATIVO", "PYMES": "ADMINISTRACION Y GESTION"},
        "gen18": {"PROGRAMA EDUCATIVO": "PROGRAMA EDUCATIVO", "PYMES": "ADMINISTRACION Y GESTION"},
        "gen19": {"Programa Educativo": "PROGRAMA EDUCATIVO", "PYMES": "ADMINISTRACION Y GESTION"}
    }
    train_data = pd.concat([load_and_process_data(file, gen, column_mapping) for file, gen in train_files], ignore_index=True)
    X_train = train_data.drop(columns=['BAJA'])
    y_train = train_data['BAJA']
    X_train_scaled = scaler.fit_transform(X_train)
    X_train, X_val, y_train, y_val = train_test_split(X_train_scaled, y_train, test_size=0.2, random_state=42)
    X_train_reshaped = np.reshape(X_train, (X_train.shape[0], X_train.shape[1], 1))
    X_val_reshaped = np.reshape(X_val, (X_val.shape[0], X_val.shape[1], 1))
    model = Sequential()
    model.add(LSTM(50, activation='relu', input_shape=(X_train.shape[1], 1)))
    model.add(Dropout(0.2))
    model.add(Dense(1, activation='sigmoid'))
    model.compile(optimizer='adam', loss='binary_crossentropy', metrics=['accuracy'])
    model.fit(X_train_reshaped, y_train, epochs=50, batch_size=32, validation_data=(X_val_reshaped, y_val))
    model.save(model_file_path)
    print(f"Modelo guardado en {model_file_path}")

# Rutas de Flask
@app.route("/")
def upload_file():
    files = os.listdir(app.config['UPLOAD_FOLDER'])
    prediction_files = [f for f in files if f.startswith("predicciones_")]
    return render_template('prueba.html', files=files, prediction_files=prediction_files)

@app.route("/upload", methods=['POST'])
def uploader():
    file = request.files['archivo']
    filename = secure_filename(file.filename)
    file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))
    return redirect(url_for('upload_file'))

@app.route("/delete/<filename>", methods=['POST'])
def delete_file(filename):
    file_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
    if os.path.exists(file_path):
        os.remove(file_path)
    return redirect(url_for('upload_file'))

@app.route("/predict", methods=['POST'])
def predict():
    file = request.files['archivo']
    filename = secure_filename(file.filename)
    file_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
    file.save(file_path)
    data = pd.read_excel(file_path)
    X_data_scaled = scaler.transform(data)
    X_data_reshaped = np.reshape(X_data_scaled, (X_data_scaled.shape[0], X_data_scaled.shape[1], 1))
    predictions = model.predict(X_data_reshaped) * 100
    data['Probabilidad Baja (%)'] = predictions
    prediction_file = os.path.join(app.config['UPLOAD_FOLDER'], "predicciones_" + filename)
    data.to_excel(prediction_file, index=False)
    return redirect(url_for('upload_file'))

@app.route("/download/<filename>")
def download_file(filename):
    file_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
    if os.path.exists(file_path):
        return send_file(file_path, as_attachment=True)
    else:
        return jsonify({"error": "El archivo no existe"}), 404


if __name__ == "__main__":
    app.run(debug=True)
