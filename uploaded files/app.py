import os
from flask import Flask, render_template, request, redirect, url_for
from werkzeug.utils import secure_filename

app = Flask(__name__)

# Configurar la carpeta donde se subirán los archivos
app.config['UPLOAD_FOLDER'] = "./Archivos PDF"

# Verificar que la carpeta de subida exista, si no, crearla
if not os.path.exists(app.config['UPLOAD_FOLDER']):
    os.makedirs(app.config['UPLOAD_FOLDER'])

@app.route("/")
def upload_file():
    files = os.listdir(app.config['UPLOAD_FOLDER'])  # Obtener la lista de archivos subidos
    return render_template('prueba.html', files=files)

@app.route("/upload", methods=['POST'])
def uploader():
    if request.method == 'POST':
        f = request.files['archivo']
        filename = secure_filename(f.filename)
        f.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))
        return redirect(url_for('upload_file'))

@app.route("/delete/<filename>", methods=['POST'])
def delete_file(filename):
    file_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
    if os.path.exists(file_path):
        os.remove(file_path)
    return redirect(url_for('upload_file'))

if __name__ == '__main__':
    app.run(debug=True)
