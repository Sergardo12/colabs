import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/app_sizes.dart';
import '../bloc/service_request_bloc.dart';
import '../bloc/service_request_event.dart';
import '../bloc/service_request_state.dart';
import '../models/service_request_model.dart';

class MyRequestDetailPage extends StatefulWidget {
  final ServiceRequestModel request;

  const MyRequestDetailPage({
    super.key,
    required this.request,
  });

  @override
  State<MyRequestDetailPage> createState() => _MyRequestDetailPageState();
}

class _MyRequestDetailPageState extends State<MyRequestDetailPage> {
  final MapController         _mapController  = MapController();
  final TextEditingController _directionCtrl  = TextEditingController();
  final TextEditingController _descCtrl       = TextEditingController();
  final Dio                   _nominatimDio   = Dio();

  bool    _isRequestMode  = false;
  bool    _loadingAddress = false;
  String  _lastQuery      = '';
  LatLng  _pinLocation    = const LatLng(-12.046, -77.042);

  @override
  void initState() {
    super.initState();
    _directionCtrl.text = widget.request.direction;
    _descCtrl.text      = '';

    final loc = widget.request.location;
    if (loc != null) {
      final coords = loc['coordinates'] as List;
      _pinLocation = LatLng(
        (coords.last  as num).toDouble(),
        (coords.first as num).toDouble(),
      );
    }
  }

  @override
  void dispose() {
    _directionCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _activateRequestMode() {
    setState(() => _isRequestMode = true);
    Future.delayed(const Duration(milliseconds: 300), () {
      _mapController.move(_pinLocation, 14);
    });
  }

  Future<void> _getAddressFromCoords(LatLng point) async {
    setState(() => _loadingAddress = true);
    try {
      final response = await _nominatimDio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'lat': point.latitude,
          'lon': point.longitude,
          'format': 'json',
        },
        options: Options(headers: {
          'Accept-Language': 'es',
          'User-Agent': 'ColabsApp/1.0 (contacto@colabs.pe)',
        }),
      );
      final address = response.data['display_name'] as String?;
      if (address != null && mounted) {
        setState(() {
          _directionCtrl.text = address;
          _loadingAddress     = false;
        });
      }
    } catch (_) {
      setState(() => _loadingAddress = false);
    }
  }

  Future<void> _onDirectionChanged(String query) async {
    if (query.length < 3) return;
    _lastQuery = query;
    await Future.delayed(const Duration(milliseconds: 600));
    if (_lastQuery != query || !mounted) return;
    try {
      final response = await _nominatimDio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q':            query,
          'format':       'json',
          'limit':        1,
          'countrycodes': 'pe',
          'viewbox':      '-81.3,-18.4,-68.6,-0.0',
          'bounded':      '1',
        },
        options: Options(headers: {
          'Accept-Language': 'es',
          'User-Agent': 'ColabsApp/1.0 (contacto@colabs.pe)',
        }),
      );
      final results = response.data as List<dynamic>;
      if (results.isNotEmpty && mounted) {
        final first = results.first as Map<String, dynamic>;
        final point = LatLng(
          double.parse(first['lat'] as String),
          double.parse(first['lon'] as String),
        );
        setState(() => _pinLocation = point);
        _mapController.move(point, 14);
      }
    } catch (_) {}
  }

  void _onSubmit() {
    if (_directionCtrl.text.trim().isEmpty) {
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

    final profileColabId = widget.request.acceptedProposal?.profileColabId;

    context.read<ServiceRequestBloc>().add(
      CreateRequestRequested(
        lat:            _pinLocation.latitude,
        lng:            _pinLocation.longitude,
        direction:      _directionCtrl.text.trim(),
        occupationId:   widget.request.occupation.id,
        description:    _descCtrl.text.trim(),
        profileColabId: profileColabId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colab = widget.request.acceptedProposal?.colab;

    return BlocListener<ServiceRequestBloc, ServiceRequestState>(
      listener: (context, state) {
        if (state is ServiceRequestCreated) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:         Text('¡Solicitud enviada al colaborador! 🎉'),
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
          title: const Text('Detalle del servicio'),
          backgroundColor: Colors.transparent,
          elevation:       0,
        ),
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            // Mapa de fondo
            Positioned.fill(
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _pinLocation,
                  initialZoom:   14,
                  interactionOptions: InteractionOptions(
                    flags: _isRequestMode
                        ? InteractiveFlag.all
                        : InteractiveFlag.none,
                  ),
                  onMapEvent: _isRequestMode
                      ? (event) {
                          if (event is MapEventMove ||
                              event is MapEventMoveEnd) {
                            setState(() {
                              _pinLocation = _mapController.camera.center;
                            });
                          }
                          if (event is MapEventMoveEnd) {
                            _getAddressFromCoords(_pinLocation);
                          }
                        }
                      : null,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.colabs.colabs_frontend',
                    keepBuffer: 1,
                    panBuffer:  0,
                  ),
                  if (!_isRequestMode)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point:  _pinLocation,
                          width:  40,
                          height: 40,
                          child:  const Icon(
                            Icons.location_pin,
                            color: Color(0xFF1E41BC),
                            size:  40,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // Pin fijo en centro — solo en modo solicitud
            if (_isRequestMode)
              const Positioned.fill(
                child: IgnorePointer(
                  child: Align(
                    alignment: Alignment(0, -0.3),
                    child: Icon(
                      Icons.location_pin,
                      color: Color(0xFF1E41BC),
                      size:  48,
                    ),
                  ),
                ),
              ),

            // Card flotante
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
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.paddingL,
                    AppSizes.paddingM,
                    AppSizes.paddingL,
                    AppSizes.paddingL,
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
                                color: Colors.grey.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSizes.paddingM),

                          // Info colaborador
                          if (colab != null) ...[
                            Row(
                              children: [
                                CircleAvatar(
                                  radius:           24,
                                  backgroundColor:   const Color(0xFF1E41BC)
                                      .withValues(alpha: 0.1),
                                  backgroundImage:   colab.imageProfile != null
                                      ? NetworkImage(colab.imageProfile!)
                                      : null,
                                  child: colab.imageProfile == null
                                      ? const Icon(Icons.person,
                                          color: Color(0xFF1E41BC), size: 24)
                                      : null,
                                ),
                                const SizedBox(width: AppSizes.paddingM),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${colab.name} ${colab.lastName}',
                                        style: const TextStyle(
                                          fontSize:   15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        widget.request.occupation.name,
                                        style: const TextStyle(
                                          color:    Color(0xFF1E41BC),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (widget.request.acceptedProposal != null)
                                  Text(
                                    'S/. ${widget.request.acceptedProposal!.amount}',
                                    style: const TextStyle(
                                      fontSize:   15,
                                      fontWeight: FontWeight.bold,
                                      color:      Color(0xFF1E41BC),
                                    ),
                                  ),
                              ],
                            ),
                            const Divider(height: AppSizes.paddingL),
                          ],

                          // Modo detalle
                          if (!_isRequestMode) ...[
                            _DetailRow(
                              icon:  Icons.location_on_outlined,
                              value: widget.request.direction,
                            ),
                            const SizedBox(height: AppSizes.paddingS),
                            _DetailRow(
                              icon:  Icons.description_outlined,
                              value: widget.request.description,
                            ),
                            const SizedBox(height: AppSizes.paddingL),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Volver'),
                                  ),
                                ),
                                if (widget.request.status == 'completed') ...[
                                  const SizedBox(width: AppSizes.paddingM),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _activateRequestMode,
                                      icon:  const Icon(Icons.refresh,
                                          size: 18),
                                      label: const Text('Volver a solicitar'),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],

                          // Modo solicitud
                          if (_isRequestMode) ...[
                            TextField(
                              controller: _directionCtrl,
                              onChanged:  _onDirectionChanged,
                              decoration: InputDecoration(
                                hintText:   'Dirección del servicio',
                                prefixIcon: const Icon(
                                    Icons.location_on_outlined),
                                suffixIcon: _loadingAddress
                                    ? const SizedBox(
                                        width:  20,
                                        height: 20,
                                        child:  Padding(
                                          padding: EdgeInsets.all(12),
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(height: AppSizes.paddingM),
                            TextField(
                              controller: _descCtrl,
                              maxLines:   2,
                              decoration: const InputDecoration(
                                hintText: 'Describe qué necesitas',
                              ),
                            ),
                            const SizedBox(height: AppSizes.paddingS),
                            const Text(
                              'El precio final puede variar según el alcance del trabajo',
                              style: TextStyle(
                                color:    Color(0xFF6B7280),
                                fontSize: 11,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSizes.paddingM),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => setState(
                                        () => _isRequestMode = false),
                                    child: const Text('Cancelar'),
                                  ),
                                ),
                                const SizedBox(width: AppSizes.paddingM),
                                Expanded(
                                  child: BlocBuilder<ServiceRequestBloc,
                                      ServiceRequestState>(
                                    builder: (context, state) {
                                      final isLoading =
                                          state is ServiceRequestCreating;
                                      return ElevatedButton(
                                        onPressed:
                                            isLoading ? null : _onSubmit,
                                        child: isLoading
                                            ? const SizedBox(
                                                width:  20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : const Text('Enviar solicitud'),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String   value;

  const _DetailRow({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF1E41BC), size: 18),
        const SizedBox(width: AppSizes.paddingS),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 13)),
        ),
      ],
    );
  }
}