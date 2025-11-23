import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:jenix_event_manager/src/core/helpers/jenix_colors_app.dart';
import 'package:jenix_event_manager/src/domain/entities/event_entity.dart';

class EventDetailsScreen extends ConsumerStatefulWidget {
  final EventEntity event;

  const EventDetailsScreen({
    required this.event,
    super.key,
  });

  @override
  ConsumerState<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends ConsumerState<EventDetailsScreen> {
  bool isRegistered = false;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark 
        ? JenixColorsApp.darkBackground 
        : JenixColorsApp.backgroundLightGray;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(isDark),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildEventHeader(isDark),
                    const SizedBox(height: 24),
                    _buildEventInfo(isDark),
                    const SizedBox(height: 24),
                    _buildDescription(isDark),
                    const SizedBox(height: 24),
                    _buildLocationAndTime(isDark),
                    const SizedBox(height: 24),
                    _buildCapacity(isDark),
                    const SizedBox(height: 32),
                    _buildActionButton(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(bool isDark) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: JenixColorsApp.primaryBlue,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: CircleAvatar(
          backgroundColor: JenixColorsApp.backgroundWhite.withOpacity(0.2),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                JenixColorsApp.primaryBlue,
                JenixColorsApp.primaryBlueLight,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (widget.event.urlImage != null && widget.event.urlImage!.isNotEmpty && !widget.event.urlImage!.toLowerCase().contains('por defecto'))
                _buildImageWidget(widget.event.urlImage!)
              else
                Container(
                  color: JenixColorsApp.primaryBlue,
                  child: Center(
                    child: Icon(
                      Icons.event_rounded,
                      size: 80,
                      color: JenixColorsApp.backgroundWhite.withOpacity(0.3),
                    ),
                  ),
                ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.6),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventHeader(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: JenixColorsApp.primaryBlue.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            widget.event.state,
            style: TextStyle(
              color: JenixColorsApp.primaryBlue,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.event.name,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: isDark ? JenixColorsApp.backgroundWhite : JenixColorsApp.darkColorText,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.event.organizationArea,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? JenixColorsApp.lightGray : JenixColorsApp.subtitleColor,
          ),
        ),
      ],
    );
  }

  Widget _buildEventInfo(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            icon: Icons.access_time_rounded,
            label: 'Hora',
            value: '${widget.event.beginHour ?? '--:--'} - ${widget.event.endHour ?? '--:--'}',
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInfoCard(
            icon: Icons.location_on_rounded,
            label: 'Ubicación',
            value: widget.event.room.type,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark 
            ? JenixColorsApp.darkGray.withOpacity(0.3)
            : JenixColorsApp.infoLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: JenixColorsApp.primaryBlue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: JenixColorsApp.primaryBlue,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark 
                      ? JenixColorsApp.lightGray 
                      : JenixColorsApp.subtitleColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark 
                  ? JenixColorsApp.backgroundWhite 
                  : JenixColorsApp.darkColorText,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Descripción',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isDark ? JenixColorsApp.backgroundWhite : JenixColorsApp.darkColorText,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.event.description,
          style: TextStyle(
            fontSize: 14,
            color: isDark 
                ? JenixColorsApp.lightGray 
                : JenixColorsApp.secondaryTextColor,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationAndTime(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark 
            ? JenixColorsApp.darkGray.withOpacity(0.3)
            : JenixColorsApp.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark 
              ? JenixColorsApp.darkGray.withOpacity(0.5)
              : JenixColorsApp.lightGrayBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow(
            icon: Icons.calendar_today_rounded,
            label: 'Inicio',
            value: '${widget.event.initialDate.day}/${widget.event.initialDate.month}/${widget.event.initialDate.year}',
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            icon: Icons.calendar_today_rounded,
            label: 'Fin',
            value: '${widget.event.finalDate.day}/${widget.event.finalDate.month}/${widget.event.finalDate.year}',
            isDark: isDark,
          ),
          if (widget.event.responsablePerson != null) ...[
            const SizedBox(height: 12),
            _buildDetailRow(
              icon: Icons.person_rounded,
              label: 'Responsable',
              value: widget.event.responsablePerson?.name ?? 'N/A',
              isDark: isDark,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: JenixColorsApp.primaryBlue,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark 
                      ? JenixColorsApp.lightGray 
                      : JenixColorsApp.subtitleColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark 
                      ? JenixColorsApp.backgroundWhite 
                      : JenixColorsApp.darkColorText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCapacity(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: JenixColorsApp.primaryBlue.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: JenixColorsApp.primaryBlue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.group_rounded,
            size: 24,
            color: JenixColorsApp.primaryBlue,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Capacidad',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark 
                        ? JenixColorsApp.lightGray 
                        : JenixColorsApp.subtitleColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Máximo ${widget.event.maxAttendees} participantes',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: JenixColorsApp.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: JenixColorsApp.primaryBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '0/${widget.event.maxAttendees}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: JenixColorsApp.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleRegistration,
        style: ElevatedButton.styleFrom(
          backgroundColor: isRegistered 
              ? JenixColorsApp.primaryBlue.withOpacity(0.3)
              : JenixColorsApp.primaryBlue,
          disabledBackgroundColor: JenixColorsApp.primaryBlue.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: JenixColorsApp.backgroundWhite,
                  strokeWidth: 2,
                ),
              )
            : Text(
                isRegistered ? 'Ya estás inscrito' : 'Inscribirse al evento',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isRegistered 
                      ? JenixColorsApp.primaryBlue
                      : JenixColorsApp.backgroundWhite,
                ),
              ),
      ),
    );
  }

  Future<void> _handleRegistration() async {
    setState(() => isLoading = true);

    try {
      // TODO: Integrar con EventController para inscribirse
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() => isRegistered = true);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('¡Te inscribiste al evento exitosamente!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Widget _buildImageWidget(String imageUrl) {
    // Detectar si es una URL de red o ruta local
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      // Es una URL de red
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderImage();
        },
      );
    } else if (imageUrl.startsWith('file://')) {
      // Es una ruta local con prefijo file://
      return Image.file(
        File(imageUrl.replaceFirst('file://', '')),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderImage();
        },
      );
    } else {
      // Ruta local sin prefijo
      return Image.file(
        File(imageUrl),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderImage();
        },
      );
    }
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: JenixColorsApp.primaryBlue,
      child: const Icon(Icons.image_not_supported, color: Colors.white),
    );
  }
}
