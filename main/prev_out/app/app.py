from flask import Flask, request, jsonify, render_template
import pandas as pd
import tensorflow as tf
from werkzeug.utils import secure_filename
import os

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

UPLOAD_FOLDER = './services/uploads/'
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

# Cargar el modelo entrenado
model = tf.keras.models.load_model('./services/model/train_model.h5')
print("Modelo cargado con éxito")

@app.route('/services/predict', methods=['POST'])
def predict():
    print("Ruta /services/predict llamada")
    
    if 'file' not in request.files:
        print("No file part")
        return jsonify({'error': 'No file part'}), 400

    file = request.files['file']

    if file.filename == '':
        print("No selected file")
        return jsonify({'error': 'No selected file'}), 400

    if file:
        filename = secure_filename(file.filename)
        file_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(file_path)
        print("Archivo guardado en:", file_path)

        # Leer el archivo Excel
        df = pd.read_excel(file_path)
        print("Datos cargados:", df.head())

        # Preprocesar los datos
        # X = preprocess_data(df)
        X = df  # Asegúrate de que X tenga la forma correcta
        predictions = model.predict(X)
        print("Predicciones realizadas")

        # Convertir los resultados en una lista
        results = predictions.tolist()

        # Eliminar el archivo después de la predicción
        os.remove(file_path)

        return jsonify(results)

if __name__ == '__main__':
    if not os.path.exists(UPLOAD_FOLDER):
        os.makedirs(UPLOAD_FOLDER)
    app.run(host='0.0.0.0', port=8080, debug=True)  # Cambia el puerto a 8080
