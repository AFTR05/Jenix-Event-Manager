import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jenix_event_manager/src/core/helpers/jenix_colors_app.dart';
import 'package:jenix_event_manager/src/inject/riverpod_presentation.dart';
import 'package:jenix_event_manager/src/inject/states_providers/login_provider.dart';
import 'package:jenix_event_manager/src/presentation/ui/pages/main/events/utils/events_utils.dart';
import 'package:jenix_event_manager/src/presentation/ui/pages/main/events/widgets/event_card_widget.dart';
import 'package:jenix_event_manager/src/presentation/ui/pages/main/events/widgets/events_empty_state.dart';
import 'package:jenix_event_manager/src/presentation/ui/pages/main/events/widgets/events_header_widget.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    final eventController = ref.read(eventControllerProvider);
    final user = ref.read(loginProviderProvider);
    final token = user?.accessToken ?? '';

    try {
      // Agregar timeout de 15 segundos para evitar carga infinita
      await eventController.fetchAll(token).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('La carga tardó demasiado tiempo');
        },
      );
      
      if (mounted) {
        setState(() => _isLoading = false);
      }
    } on TimeoutException {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'La carga tardó demasiado. Intenta nuevamente.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Error al cargar eventos: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final eventController = ref.read(eventControllerProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isDark ? JenixColorsApp.backgroundDark : JenixColorsApp.backgroundWhite,
      body: StreamBuilder(
        stream: eventController.eventsStream,
        builder: (context, snapshot) {
          // Mostrar error si existe
          if (_hasError) {
            return CustomScrollView(
              slivers: [
                EventsHeaderWidget(
                  eventCount: 0,
                  isDark: isDark,
                ),
                SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red.withOpacity(0.7),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error al cargar',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: isDark ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _errorMessage,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _loadEvents,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reintentar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: JenixColorsApp.primaryBlue,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          // Mostrar carga inicial
          if (_isLoading && eventController.cache.isEmpty) {
            return CustomScrollView(
              slivers: [
                EventsHeaderWidget(
                  eventCount: 0,
                  isDark: isDark,
                ),
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            JenixColorsApp.primaryBlue,
                          ),
                          strokeWidth: 3,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Cargando eventos...',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
          final streamData = snapshot.data ?? eventController.cache;
          final events = EventsUtils.getActiveEvents(streamData);

          return RefreshIndicator(
            onRefresh: _loadEvents,
            color: JenixColorsApp.primaryBlue,
            child: CustomScrollView(
              slivers: [
                // Header elegante
                EventsHeaderWidget(
                  eventCount: events.length,
                  isDark: isDark,
                ),

                // Lista de eventos o estado vacío
                if (events.isEmpty)
                  SliverToBoxAdapter(
                    child: EventsEmptyState(isDark: isDark),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width > 600 ? size.width * 0.1 : 12,
                      vertical: 12,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final event = events[index];
                          final nextEvent = index < events.length - 1 ? events[index + 1] : null;
                          final showDateSeparator =
                              EventsUtils.isDatesSeparator(event, nextEvent) &&
                                  index < events.length - 1;

                          return Column(
                            children: [
                              EventCardWidget(
                                event: event,
                                isDark: isDark,
                                size: size,
                              ),
                              if (showDateSeparator)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  child: Divider(
                                    color: JenixColorsApp.primaryBlue.withOpacity(0.2),
                                    thickness: 1,
                                  ),
                                ),
                            ],
                          );
                        },
                        childCount: events.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
