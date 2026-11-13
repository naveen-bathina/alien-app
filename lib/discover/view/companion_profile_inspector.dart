import 'package:flutter/material.dart';
import 'package:myalien/app/constants/app_strings.dart';
import 'package:myalien/app/view/app_image.dart';
import 'package:myalien/hangout/view/schedule_hangout_sheet.dart';
import 'package:myalien/home/models/profile_model.dart';

/// Compact inspector card of a companion profile used in desktop dual-pane view
class CompanionProfileInspector extends StatefulWidget {
  const CompanionProfileInspector({
    required this.profile,
    super.key,
    this.onAction,
  });

  final Profile profile;
  final void Function(String action)? onAction;

  @override
  State<CompanionProfileInspector> createState() =>
      _CompanionProfileInspectorState();
}

class _CompanionProfileInspectorState extends State<CompanionProfileInspector> {
  int _photoIndex = 0;

  Future<void> _showBookingSheet() async {
    final hangout = await ScheduleHangoutSheet.show(
      context,
      profile: widget.profile,
    );
    if (!mounted || hangout == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Hangout scheduled with ${widget.profile.name}!',
        ),
        backgroundColor: const Color(0xFF6C4AB6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final photos = profile.photos.isNotEmpty
        ? profile.photos
        : (profile.photoUrl != null ? [profile.photoUrl!] : <String>[]);
    final currentPhoto =
        photos.isNotEmpty ? photos[_photoIndex % photos.length] : null;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE2DDF4)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Photo header with arrows
          Expanded(
            flex: 4,
            child: Stack(
              fit: StackFit.expand,
              children: [
                AppImage(
                  source: currentPhoto,
                  fit: BoxFit.cover,
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                ),
                if (photos.length > 1) ...[
                  Positioned(
                    left: 8,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_rounded,
                            color: Colors.white),
                        onPressed: _photoIndex > 0
                            ? () => setState(() => _photoIndex--)
                            : null,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: IconButton(
                        icon: const Icon(Icons.arrow_forward_ios_rounded,
                            color: Colors.white),
                        onPressed: _photoIndex < photos.length - 1
                            ? () => setState(() => _photoIndex++)
                            : null,
                      ),
                    ),
                  ),
                ],
                Positioned(
                  left: 16,
                  bottom: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${profile.name}, ${profile.age}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (profile.isVerified)
                            const Icon(
                              Icons.verified_rounded,
                              color: Color(0xFF6C4AB6),
                              size: 22,
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded,
                              color: Colors.white70, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            profile.location,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Text('🪙', style: TextStyle(fontSize: 12)),
                                const SizedBox(width: 4),
                                Text(
                                  '${profile.coinsPerHour} / hr',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Bio & Actions
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About Companion',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF1E1E2D),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    profile.bio.isNotEmpty
                        ? profile.bio
                        : 'No bio provided yet.',
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: _showBookingSheet,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                      backgroundColor: const Color(0xFF6C4AB6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.calendar_month_rounded, size: 18),
                    label: const Text(
                      'Schedule Hangout',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
