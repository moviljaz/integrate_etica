import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui' as ui;
import 'dart:async';

void main() {
  runApp(const JazteaApp());
}

class JazteaApp extends StatelessWidget {
  const JazteaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jaztea - IntegraTÉ con ÉTICA',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Roboto',
      ),
      home: const JazteaHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class JazteaHomePage extends StatefulWidget {
  const JazteaHomePage({super.key});

  @override
  State<JazteaHomePage> createState() => _JazteaHomePageState();
}

class _JazteaHomePageState extends State<JazteaHomePage> {
  // Controlador para hacer scroll
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Función para abrir WhatsApp - Mejorada para web
  Future<void> _launchWhatsApp() async {
    const phoneNumber = '3327448418';
    
    try {
      if (kIsWeb) {
        // Para web, usar WhatsApp Web
        final Uri whatsappUri = Uri.parse('https://web.whatsapp.com/send?phone=$phoneNumber');
        await launchUrl(whatsappUri, mode: LaunchMode.platformDefault);
      } else {
        // Para móvil, usar la aplicación de WhatsApp
        final Uri whatsappUri = Uri.parse('https://wa.me/$phoneNumber');
        if (await canLaunchUrl(whatsappUri)) {
          await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
        } else {
          // Fallback a marcador telefónico
          await _launchPhone(phoneNumber);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al abrir WhatsApp: $e');
      }
      // Fallback a marcador telefónico
      await _launchPhone(phoneNumber);
    }
  }

  // Función para abrir marcador telefónico - Mejorada para web
  Future<void> _launchPhone(String phoneNumber) async {
    try {
      final Uri phoneUri = Uri.parse('tel:$phoneNumber');
      
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri, mode: LaunchMode.platformDefault);
      } else if (kIsWeb) {
        // En web, mostrar el número para que el usuario lo copie
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Número de teléfono: $phoneNumber'),
              action: SnackBarAction(
                label: 'Copiar',
                onPressed: () {
                  // Nota: En web, el usuario tendrá que copiar manualmente
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al abrir teléfono: $e');
      }
    }
  }

  // Función para abrir sitio web - Mejorada para web
  Future<void> _launchWebsite() async {
    try {
      final Uri websiteUri = Uri.parse('https://www.sedamx.com/eticajaztea');
      
      if (await canLaunchUrl(websiteUri)) {
        await launchUrl(
          websiteUri, 
          mode: kIsWeb ? LaunchMode.platformDefault : LaunchMode.externalApplication
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al abrir sitio web: $e');
      }
    }
  }

  // Función para abrir cliente de correo - Mejorada para web
  Future<void> _launchEmail() async {
    try {
      final Uri emailUri = Uri.parse('mailto:eticajaztea@sedamx.com');
      
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri, mode: LaunchMode.platformDefault);
      } else if (kIsWeb) {
        // En web, mostrar el email para que el usuario lo copie
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email: eticajaztea@sedamx.com'),
              duration: Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al abrir correo: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
    
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            // Imagen del flyer clickeable
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height, // Altura completa de la pantalla
              color: Colors.black, // Fondo negro para los bordes
              child: Stack(
                children: [
                  // Imagen original centrada
                  Center(
                    child: Image.asset(
                      'assets/integrate.jpg',
                      fit: BoxFit.contain, // Mantiene la imagen completa
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  // Overlay clickeable
                  Positioned.fill(
                    child: _buildClickableImageOverlay(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Método para crear area clickeable sobre la imagen
  Widget _buildClickableImageOverlay() {
    return FutureBuilder<ui.Image>(
      future: _getImageInfo(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink(); // Mientras carga la imagen
        }
        
        final imageInfo = snapshot.data!;
        final realImageAspectRatio = imageInfo.width / imageInfo.height;
        
        return LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final screenHeight = constraints.maxHeight;
            final screenAspectRatio = screenWidth / screenHeight;
            
            double imageWidth, imageHeight, offsetX, offsetY;
            
            if (screenAspectRatio > realImageAspectRatio) {
              // Pantalla más ancha que la imagen - bordes a los lados
              imageHeight = screenHeight;
              imageWidth = imageHeight * realImageAspectRatio;
              offsetX = (screenWidth - imageWidth) / 2;
              offsetY = 0;
            } else {
              // Pantalla más alta que la imagen - bordes arriba/abajo
              imageWidth = screenWidth;
              imageHeight = imageWidth / realImageAspectRatio;
              offsetX = 0;
              offsetY = (screenHeight - imageHeight) / 2;
            }
            
            return Stack(
              children: [
                // Área clickeable posicionada relativa a la imagen real
                Positioned(
                  left: offsetX + (imageWidth * -0.00), // Más a la izquierda (sobresale un poco)
                  bottom: offsetY + (imageHeight * 0.13), // 15% desde abajo de la imagen
                  width: imageWidth * 0.61, // 61% del ancho de la imagen
                  height: imageHeight * 0.20, // 20% del alto de la imagen
                  child: GestureDetector(
                    onTap: _showContactOptions,
                    child: Material(
                      color: kDebugMode 
                        ? Colors.green.withOpacity(0.2) // Más visible en debug
                        : Colors.transparent, // Invisible en producción
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        onTap: _showContactOptions,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            border: kDebugMode 
                              ? Border.all(color: Colors.green, width: 2)
                              : null,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: kDebugMode 
                            ? const Center(
                                child: Text(
                                  'ÁREA CLICKEABLE',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              )
                            : const SizedBox.expand(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Método para obtener las dimensiones reales de la imagen
  Future<ui.Image> _getImageInfo() async {
    final AssetImage assetImage = AssetImage('assets/integrate.jpg');
    final ImageStream stream = assetImage.resolve(ImageConfiguration.empty);
    final Completer<ui.Image> completer = Completer<ui.Image>();
    
    late ImageStreamListener listener;
    listener = ImageStreamListener((ImageInfo imageInfo, bool synchronousCall) {
      completer.complete(imageInfo.image);
      stream.removeListener(listener);
    });
    
    stream.addListener(listener);
    return completer.future;
  }

  // Método para mostrar opciones de contacto
  void _showContactOptions() {
    // Debug: Imprimir que el click fue detectado
    if (kDebugMode) {
      print('🎯 Click detectado en área clickeable');
    }
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Column(
            children: [
              Icon(
                Icons.contact_support,
                color: Color(0xFF4CAF50),
                size: 40,
              ),
              SizedBox(height: 12),
              Text(
                'Para contactarnos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4CAF50),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Haz click en cualquier medio de comunicación',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCompactContactButton(
                  icon: Icons.chat,
                  text: '3327448418',
                  subtitle: 'WhatsApp',
                  color: const Color(0xFF25D366),
                  onTap: () {
                    Navigator.pop(context);
                    _launchWhatsApp();
                  },
                ),
                
                const SizedBox(height: 10),
                
                _buildCompactContactButton(
                  icon: Icons.phone,
                  text: '800 890 81 80',
                  subtitle: 'Línea gratuita',
                  color: const Color(0xFF2196F3),
                  onTap: () {
                    Navigator.pop(context);
                    _launchPhone('8008908180');
                  },
                ),
                
                const SizedBox(height: 10),
                
                _buildCompactContactButton(
                  icon: Icons.language,
                  text: 'sedamx.com/eticajaztea',
                  subtitle: 'Sitio web',
                  color: const Color(0xFFFF9800),
                  onTap: () {
                    Navigator.pop(context);
                    _launchWebsite();
                  },
                ),
                
                const SizedBox(height: 10),
                
                _buildCompactContactButton(
                  icon: Icons.email,
                  text: 'eticajaztea@sedamx.com',
                  subtitle: 'Correo electrónico',
                  color: const Color(0xFFE91E63),
                  onTap: () {
                    Navigator.pop(context);
                    _launchEmail();
                  },
                ),
              ],
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 8, bottom: 8),
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: Colors.red,
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: const Text(
                  'Cerrar',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Versión compacta para pantallas pequeñas
  Widget _buildCompactContactButton({
    required IconData icon,
    required String text,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12), // Menos padding
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8), // Más pequeño
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20, // Icono más pequeño
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 14, // Texto más pequeño
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11, // Más pequeño
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 14, // Más pequeño
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactButton({
    required IconData icon,
    required String text,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
