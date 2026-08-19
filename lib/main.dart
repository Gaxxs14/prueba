import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lector Zebra',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ZebraScannerScreen(),
    );
  }
}

class ZebraScannerScreen extends StatefulWidget {
  const ZebraScannerScreen({super.key});

  @override
  State<ZebraScannerScreen> createState() => _ZebraScannerScreenState();
}

class _ZebraScannerScreenState extends State<ZebraScannerScreen> {
  final FlutterDataWedge _dataWedge = FlutterDataWedge();
  StreamSubscription<ScanResult>? _scanSubscription;

  String _codigoLeido = "Presiona el botón de escaneo de tu Zebra";
  String _tipoCodigo = "";
  final List<String> _historial = [];

  @override
  void initState() {
    super.initState();
    _iniciarLectorZebra();
  }

  Future<void> _iniciarLectorZebra() async {
    try {
      // 1. Inicializar el perfil de escáner en el teléfono Zebra
      await _dataWedge.initialize();

      // 2. Escuchar cuando el lector láser nativo lea un código
      _scanSubscription = _dataWedge.onScanResult.listen((ScanResult result) {
        setState(() {
          _codigoLeido = result.data;
          _tipoCodigo = result.labelType;
          _historial.insert(0, "${result.data} (${result.labelType})");
        });
      });
    } catch (e) {
      debugPrint("Error iniciando Zebra DataWedge: $e");
    }
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lector Nativo Zebra', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[800],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tarjeta grande del código actual
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue[200]!, width: 2),
              ),
              child: Column(
                children: [
                  const Icon(Icons.qr_code_scanner, size: 48, color: Colors.blue),
                  const SizedBox(height: 12),
                  const Text(
                    'CÓDIGO ESCANEADO:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    _codigoLeido,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  if (_tipoCodigo.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Tipo: $_tipoCodigo',
                      style: TextStyle(fontSize: 13, color: Colors.blue[800], fontWeight: FontWeight.w600),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Encabezado de historial
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Historial de lecturas',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (_historial.isNotEmpty)
                  TextButton(
                    onPressed: () => setState(() => _historial.clear()),
                    child: const Text('Borrar lista', style: TextStyle(color: Colors.red)),
                  ),
              ],
            ),
            const Divider(),

            // Lista de códigos escaneados
            Expanded(
              child: _historial.isEmpty
                  ? const Center(
                      child: Text(
                        'Apunta con el escáner del teléfono y presiona el gatillo/botón amarillo.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _historial.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue[100],
                              child: Text('${_historial.length - index}', style: TextStyle(color: Colors.blue[900], fontWeight: FontWeight.bold)),
                            ),
                            title: Text(
                              _historial[index],
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
