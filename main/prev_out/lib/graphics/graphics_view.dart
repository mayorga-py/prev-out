import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:prev_out/appbar.dart';


class GraphicsApp extends StatefulWidget {
  const GraphicsApp({super.key});

  @override
  State<GraphicsApp> createState() => _GraphicsAppState();
}

class _GraphicsAppState extends State<GraphicsApp> {
  List<dynamic>? jsonData;

  Future<void> _pickFileJson() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null) {
      var filePath = result.files.single.path;
      if (filePath != null) {
        await _readJsonFile(filePath);
      }
    }
  }

  Future<void> _readJsonFile(String filePath) async {
    try {
      String jsonString = await File(filePath).readAsString();
      setState(() {
        jsonData = jsonDecode(jsonString)["Sheet1"];
      });
    } catch (e) {
      print("Error al leer el archivo JSON: $e");
    }
  }

  double _toDouble(dynamic value) {
    return value is int ? value.toDouble() : (value as double? ?? 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ElevatedButton(
            onPressed: _pickFileJson,
            child: const Text("Seleccionar archivo JSON"),
          ),
          if (jsonData != null) ...[
            const SizedBox(height: 20),
            SectionTitle("Porcentaje de estudiantes con problemas o padecimientos"),
            PieChartWidget(
              data: {
                "Con problema (rojo)": jsonData!.where((e) => e["Problema o padecimiento"] == 1).length.toDouble(),
                "Sin problema (verde)": jsonData!.where((e) => e["Problema o padecimiento"] == 0).length.toDouble(),
              },
              colors: [Colors.redAccent, Colors.greenAccent],
            ),
            const SizedBox(height: 20),
            SectionTitle("Distribución del ingreso mensual familiar"),
            HistogramWidget(
              data: jsonData!.map((e) => _toDouble(e["Ingresos mensuales familiares"])).toList(),
              bins: 10,
              barColor: Colors.purpleAccent,
            ),
            SectionTitle("Distribución de estudiantes que trabajan"),
            PieChartWidget(
              data: {
                "Trabaja (azul)": jsonData!.where((e) => e["Trabaja"] == 1).length.toDouble(),
                "No trabaja (naranja)": jsonData!.where((e) => e["Trabaja"] == 0).length.toDouble(),
              },
              colors: [Colors.blueAccent, Colors.orangeAccent],
            ),
            const SizedBox(height: 20),

            const SizedBox(height: 20),
            SectionTitle("Relación entre trayecto a la universidad y probabilidad baja (%)"),
            ScatterPlotWidget(
              data: jsonData!.map((e) => [_toDouble(e["Minutos de trayecto a la universidad"]), _toDouble(e["Probabilidad Baja (%)"])]).toList(),
              pointColor: Colors.tealAccent,
            ),
            const SizedBox(height: 20),
            SectionTitle("Distribución de la probabilidad baja (%)"),
            HistogramWidget(
              data: jsonData!.map((e) => _toDouble(e["Probabilidad Baja (%)"])).toList(),
              bins: 100,
              barColor: Colors.indigoAccent,
            ),
          ],
        ],
      ),
    );
  }
}


// Componente reutilizable para títulos de sección
class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle(this.title, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// Gráfica de pastel
class PieChartWidget extends StatelessWidget {
  final Map<String, double> data;
  final List<Color> colors;

  const PieChartWidget({required this.data, required this.colors, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final total = data.values.reduce((a, b) => a + b);
    final sections = data.entries.map((entry) {
      final percentage = (entry.value / total) * 100;
      return PieChartSectionData(
        value: entry.value,
        title: '${entry.key}\n${percentage.toStringAsFixed(1)}%',
        color: colors[data.keys.toList().indexOf(entry.key)],
        radius: 80,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 0, 0)),
      );
    }).toList();

    return Column(
      children: [
        const Text(
          "Distribución de Datos",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 300,
          child: PieChart(PieChartData(sections: sections, centerSpaceRadius: 50)),
        ),
      ],
    );
  }
}

// Histograma
class HistogramWidget extends StatelessWidget {
  final List<double> data;
  final int bins;
  final Color barColor;

  const HistogramWidget({required this.data, required this.bins, required this.barColor, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final min = data.reduce((a, b) => a < b ? a : b);
    final max = data.reduce((a, b) => a > b ? a : b);
    final binWidth = (max - min) / bins;

    final histogram = List.generate(bins, (i) {
      final lower = min + i * binWidth;
      final upper = lower + binWidth;
      final count = data.where((value) => value >= lower && value < upper).length;
      return count.toDouble();
    });

    return SizedBox(
      height: 300,
      child: BarChart(BarChartData(
        barGroups: histogram.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [BarChartRodData(toY: entry.value, color: barColor)],
          );
        }).toList(),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
        ),
        gridData: FlGridData(show: true),
      )),
    );
  }
}

// Gráfica de dispersión
class ScatterPlotWidget extends StatelessWidget {
  final List<List<double>> data;
  final Color pointColor;

  const ScatterPlotWidget({required this.data, required this.pointColor, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: ScatterChart(
        ScatterChartData(
          scatterSpots: data.map((point) {
            return ScatterSpot(
              point[0], // Coordenada X
              point[1], // Coordenada Y
            );
          }).toList(),
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
          ),
          scatterTouchData: ScatterTouchData(
            touchTooltipData: ScatterTouchTooltipData( // Color del tooltip
            ),
          ),
        ),
      ),
    );
  }
}

class GroupedBarChartWidget extends StatelessWidget {
  final Map<String, List<double>> data;
  final List<Color> barColors;

  const GroupedBarChartWidget({
    Key? key,
    required this.data,
    required this.barColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categories = data.keys.toList();
    final maxGroupSize = data.values.map((list) => list.length).reduce((a, b) => a > b ? a : b);

    return AspectRatio(
      aspectRatio: 1.5,
      child: BarChart(
        BarChartData(
          barGroups: List.generate(
            maxGroupSize,
            (index) => BarChartGroupData(
              x: index,
              barRods: List.generate(
                categories.length,
                (categoryIndex) => BarChartRodData(
                  toY: index < data[categories[categoryIndex]]!.length
                      ? data[categories[categoryIndex]]![index]
                      : 0,
                  color: barColors[categoryIndex],
                  width: 10,
                ),
              ),
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  if (value.toInt() >= 0 && value.toInt() < categories.length) {
                    return Text(categories[value.toInt()]);
                  }
                  return const Text('');
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

