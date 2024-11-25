import os
from flask import Flask, render_template, request, redirect, send_file, url_for
from werkzeug.utils import secure_filename

app = Flask(__name__)

app.config['UPLOAD_FOLDER'] = "./Archivos PDF"

if not os.path.exists(app.config['UPLOAD_FOLDER']):
    os.makedirs(app.config['UPLOAD_FOLDER'])

@app.route("/")
def upload_file():
    files = os.listdir(app.config['UPLOAD_FOLDER'])
    return render_template('prueba.html', files=files)

@app.route("/upload", methods=['POST'])
def uploader():
    if request.method == 'POST':
        f = request.files['archivo']
        filename = secure_filename(f.filename)
        f.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))
        return redirect(url_for('upload_file'))

@app.route("/download/<filename>", methods=['GET'])
def downloader(filename):
    file_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
    return send_file(file_path, as_attachment=True)

@app.route("/delete/<filename>", methods=['POST'])
def delete_file(filename):
    file_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
    if os.path.exists(file_path):
        os.remove(file_path)
        print('Se eliminó correctamente')
    return redirect(url_for('upload_file'))

if __name__ == '__main__':
    app.run(debug=True, port=5120)
