import pandas as pd

# Cargar el archivo Excel
archivo_excel = "Gen 21_SD2023_LIMPIO.xlsx"  # Cambia esto por la ruta de tu archivo
hoja = "ColumnasConservadas (2)"   # Cambia esto por el nombre de la hoja (si tiene varias)
df = pd.read_excel(archivo_excel, sheet_name=hoja)

# Elimina "UP" del inicio de los IDs (suponiendo que están en la columna 'ID')
df['Clave de acceso'] = df['Clave de acceso'].str.replace('UPQ', '', regex=False)

# Guardar los cambios en un nuevo archivo Excel
archivo_salida = "archivo_limpiozzzzzzzzzzzzzz.xlsx"
df.to_excel(archivo_salida, index=False)

print(f"Archivo procesado y guardado como {archivo_salida}")
