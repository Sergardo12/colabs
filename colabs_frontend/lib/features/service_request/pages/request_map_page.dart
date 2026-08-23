import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../profile/models/occupation_model.dart';
import '../bloc/request_map_bloc.dart';
import '../bloc/request_map_event.dart';
import '../bloc/request_map_state.dart';
import '../bloc/service_request_bloc.dart';
import '../bloc/service_request_event.dart';
import '../bloc/service_request_state.dart';

class RequestMapPage extends StatefulWidget {
  const RequestMapPage({super.key});

  @override
  State<RequestMapPage> createState() => _RequestMapPageState();
}

class _RequestMapPageState extends State<RequestMapPage> {
  final MapController         _mapController    = MapController();
  final TextEditingController  _directionCtrl   = TextEditingController();
  final TextEditingController  _descCtrl        = TextEditingController();

  LatLng _pinLocation = const LatLng(-12.046, -77.042); // Lima por defecto
  OccupationItem?      _selectedOccupation;
  bool                 _loadingLocation = true;
  final Dio _nominatimDio = Dio();
  bool _loadingAddress = false;
  List<Map<String, dynamic>> _suggestions = [];
  bool _showSuggestions = false;
  String _lastQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<RequestMapBloc>().add(const OccupationsLoadRequested());
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _directionCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() => _loadingLocation = false);
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      setState(() {
        _pinLocation    = LatLng(position.latitude, position.longitude);
        _loadingLocation = false;
      });
      _mapController.move(_pinLocation, 15);
    } catch (_) {
      setState(() => _loadingLocation = false);
    }
  }

  Future<void> _getAddressFromCoords(LatLng point) async {
    setState(() => _loadingAddress = true);
    try {
      final response = await _nominatimDio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'lat':    point.latitude,
          'lon':    point.longitude,
          'format': 'json',
        },
        options: Options(
          headers: {
            'Accept-Language': 'es',
            'User-Agent': 'ColabsApp/1.0 (contacto@colabs.pe)',
          },
        ),
      );
      final address = response.data['display_name'] as String?;
      if (address != null && mounted) {
        setState(() {
          _directionCtrl.text = address;
          _loadingAddress      = false;
        });
      }
    } catch (e) {
      setState(() => _loadingAddress = false);
    }
  }

  Future<void> _onDirectionChanged(String query) async {
    if (query.length < 3) {
      setState(() {
        _suggestions     = [];
        _showSuggestions = false;
      });
      return;
    }

    _lastQuery = query;
    await Future.delayed(const Duration(milliseconds: 600));
    if (_lastQuery != query || !mounted) return;

    try {
      final response = await _nominatimDio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q':            query,
          'format':       'json',
          'limit':        5,
          'countrycodes': 'pe',
          'viewbox':      '-81.3,-18.4,-68.6,-0.0',
          'bounded':      '1',
          'addressdetails': '1',
        },
        options: Options(
          headers: {
            'Accept-Language': 'es',
            'User-Agent':      'ColabsApp/1.0 (contacto@colabs.pe)',
          },
        ),
      );
      final results = response.data as List<dynamic>;
      if (mounted && _lastQuery == query) {
        setState(() {
          _suggestions     = results.cast<Map<String, dynamic>>();
          _showSuggestions = results.isNotEmpty;
        });
      }
    } catch (_) {}
  }

  void _onSuggestionTap(Map<String, dynamic> suggestion) {
    final lat     = double.parse(suggestion['lat'] as String);
    final lon     = double.parse(suggestion['lon'] as String);
    final address = suggestion['display_name'] as String;
    final point   = LatLng(lat, lon);

    setState(() {
      _pinLocation     = point;
      _showSuggestions = false;
      _suggestions     = [];
      _directionCtrl.text = address;
    });
    _mapController.move(point, 15);
  }

  void _showOccupationPicker() {
    final state = context.read<RequestMapBloc>().state;
    final occupations = state is RequestMapOccupationsLoaded
        ? state.occupations
        : <OccupationItem>[];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '¿Qué servicio necesitas?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: occupations.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No hay ocupaciones disponibles'),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: occupations.length,
                    itemBuilder: (_, index) {
                      final o = occupations[index];
                      return ListTile(
                        leading: const Icon(Icons.build_outlined, size: 20),
                        title: Text(o.name),
                        trailing: _selectedOccupation?.id == o.id
                            ? const Icon(Icons.check, color: Color(0xFF1E41BC))
                            : null,
                        onTap: () {
                          setState(() => _selectedOccupation = o);
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _onSubmit() {
    if (_selectedOccupation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una ocupación')),
      );
      return;
    }
    if (_directionCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa la dirección')),
      );
      return;
    }
    if (_descCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Describe qué necesitas')),
      );
      return;
    }

    context.read<ServiceRequestBloc>().add(
      CreateRequestRequested(
        lat:          _pinLocation.latitude,
        lng:          _pinLocation.longitude,
        direction:    _directionCtrl.text.trim(),
        occupationId: _selectedOccupation!.id,
        description:  _descCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ServiceRequestBloc, ServiceRequestState>(
      listener: (context, state) {
        if (state is ServiceRequestCreated) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:         Text('¡Solicitud enviada! Buscando colaboradores...'),
              backgroundColor: Color(0xFF4CAF50),
            ),
          );
        }
        if (state is ServiceRequestError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:         Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('¿Dónde necesitas el servicio?'),
        ),
        body: Stack(
          children: [
            // Mapa ocupa toda la pantalla
            Positioned.fill(
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _pinLocation,
                  initialZoom:   13,
                  maxZoom:       18,
                  minZoom:       5,
                  interactionOptions: const InteractionOptions(
                    enableMultiFingerGestureRace: false,
                    flags: InteractiveFlag.all,
                  ),
                  onMapEvent: (event) {
                    if (event is MapEventMove ||
                        event is MapEventMoveEnd) {
                      setState(() {
                        _pinLocation = _mapController.camera.center;
                      });
                    }
                    if (event is MapEventMoveEnd) {
                      _getAddressFromCoords(_pinLocation);
                    }
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.colabs.colabs_frontend',
                    maxZoom:              18,
                    keepBuffer:           1,
                    panBuffer:            0,
                  ),
                ],
              ),
            ),

            // Pin fijo en el centro
            Positioned.fill(
              child: IgnorePointer(
                child: Align(
                  alignment: const Alignment(0, -0.3),
                  child: Icon(
                    Icons.location_pin,
                    color: Color(0xFF1E41BC),
                    size:  48,
                  ),
                ),
              ),
            ),

            // Botón de ubicación actual
            Positioned(
              right:  16,
              bottom: 380,
              child: FloatingActionButton.small(
                heroTag:         'location',
                onPressed:       _getCurrentLocation,
                backgroundColor: Colors.white,
                child: const Icon(
                  Icons.my_location,
                  color: Color(0xFF1E41BC),
                ),
              ),
            ),

            // Formulario flotante
            Positioned(
              left:   0,
              right:  0,
              bottom: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:      Color(0x1A000000),
                      blurRadius: 20,
                      offset:     Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      16, 12, 16,
                      MediaQuery.of(context).viewInsets.bottom + 16,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.55,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                        // Handle
                        Center(
                          child: Container(
                            width:  40,
                            height: 4,
                            decoration: BoxDecoration(
                              color:        Colors.grey.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Selector de ocupación
                        GestureDetector(
                          onTap: () => _showOccupationPicker(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical:   14,
                            ),
                            decoration: BoxDecoration(
                              color:        const Color(0xFFF5F7FA),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.build_outlined,
                                      color: Color(0xFF6B7280)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _selectedOccupation?.name ??
                                        '¿Qué servicio necesitas?',
                                    style: TextStyle(
                                      color: _selectedOccupation != null
                                          ? const Color(0xFF1A1A2E)
                                          : const Color(0xFF6B7280),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.keyboard_arrow_down,
                                      color: Color(0xFF6B7280)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Dirección con sugerencias
                        Column(
                          children: [
                            TextField(
                              controller:      _directionCtrl,
                              onChanged:       _onDirectionChanged,
                              textInputAction: TextInputAction.search,
                              decoration: InputDecoration(
                                hintText:   'Dirección exacta',
                                prefixIcon: const Icon(Icons.location_on_outlined),
                                suffixIcon: _loadingAddress
                                    ? const SizedBox(
                                        width:  20,
                                        height: 20,
                                        child:  Padding(
                                          padding: EdgeInsets.all(12),
                                          child:   CircularProgressIndicator(
                                              strokeWidth: 2),
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                            if (_showSuggestions)
                              Container(
                                constraints:
                                    const BoxConstraints(maxHeight: 150),
                                decoration: BoxDecoration(
                                  color:        Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color:      Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset:     const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount:  _suggestions.length,
                                  itemBuilder: (context, index) {
                                    final suggestion = _suggestions[index];
                                    return Material(
                                      color: Colors.transparent,
                                      child: ListTile(
                                        leading: const Icon(
                                            Icons.location_on_outlined,
                                            size: 18),
                                        title: Text(
                                          suggestion['display_name'] as String,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                        onTap: () =>
                                            _onSuggestionTap(suggestion),
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Descripción — obligatoria
                        TextField(
                          controller: _descCtrl,
                          maxLines:   2,
                          decoration: const InputDecoration(
                            hintText: 'Describe qué necesitas — ayuda al colaborador a cotizar mejor',
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Disclaimer
                        const Text(
                          'El precio final puede variar según el alcance del trabajo',
                          style: TextStyle(
                            color:    Color(0xFF6B7280),
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),

                        // Botón solicitar
                        BlocBuilder<ServiceRequestBloc, ServiceRequestState>(
                          builder: (context, state) {
                            final isLoading = state is ServiceRequestCreating;
                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _onSubmit,
                                child: isLoading
                                    ? const SizedBox(
                                        width:  20,
                                        height: 20,
                                        child:  CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color:       Colors.white,
                                        ),
                                      )
                                    : const Text('Solicitar servicio'),
                              ),
                            );
                          },
                        ),
                      ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Loading de ubicación
            if (_loadingLocation)
              const Positioned.fill(
                child: ColoredBox(
                  color: Color(0x80FFFFFF),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
