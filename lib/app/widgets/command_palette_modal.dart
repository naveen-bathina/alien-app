import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myalien/app/theme/app_tokens.dart';

class CommandPaletteAction {
  const CommandPaletteAction({
    required this.title,
    required this.icon,
    required this.onSelect,
    this.shortcut,
    this.category = 'Navigation',
  });

  final String title;
  final IconData icon;
  final VoidCallback onSelect;
  final String? shortcut;
  final String category;
}

/// Global command palette (Cmd/Ctrl + K) for rapid SaaS navigation and actions.
class CommandPaletteModal extends StatefulWidget {
  const CommandPaletteModal({
    required this.actions,
    super.key,
  });

  final List<CommandPaletteAction> actions;

  static Future<void> show(
    BuildContext context, {
    required List<CommandPaletteAction> actions,
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => CommandPaletteModal(actions: actions),
    );
  }

  @override
  State<CommandPaletteModal> createState() => _CommandPaletteModalState();
}

class _CommandPaletteModalState extends State<CommandPaletteModal> {
  final TextEditingController _searchCtrl = TextEditingController();
  int _selectedIndex = 0;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    final query = _searchCtrl.text.trim().toLowerCase();

    final filtered = widget.actions.where((a) {
      if (query.isEmpty) return true;
      return a.title.toLowerCase().contains(query) ||
          a.category.toLowerCase().contains(query);
    }).toList();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 440),
        child: Material(
          color: tokens.bgElevated,
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          elevation: 16,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusLg),
            side: BorderSide(color: tokens.borderLow),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Search Input Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded,
                        size: 20, color: tokens.textMuted),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        autofocus: true,
                        style: TextStyle(
                          color: tokens.textPrimary,
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Type a command or search...',
                          hintStyle: TextStyle(
                            color: tokens.textMuted,
                            fontSize: 15,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          filled: false,
                        ),
                        onChanged: (_) => setState(() => _selectedIndex = 0),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: tokens.bgSubtle,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: tokens.borderLow),
                      ),
                      child: Text(
                        'ESC',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: tokens.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: tokens.borderLow),

              // Action List
              Flexible(
                child: filtered.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          'No matching commands found.',
                          style: TextStyle(color: tokens.textMuted, fontSize: 13),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        shrinkWrap: true,
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          final isSelected = index == _selectedIndex;

                          return InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                              item.onSelect();
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? tokens.bgSubtle
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(
                                    AppTokens.radiusMd),
                              ),
                              child: Row(
                                children: [
                                  Icon(item.icon,
                                      size: 18,
                                      color: isSelected
                                          ? AppTokens.brandPrimary
                                          : tokens.textSecondary),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      style: TextStyle(
                                        color: tokens.textPrimary,
                                        fontSize: 14,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  if (item.shortcut != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: tokens.bgBase,
                                        borderRadius:
                                            BorderRadius.circular(4),
                                        border: Border.all(
                                            color: tokens.borderLow),
                                      ),
                                      child: Text(
                                        item.shortcut!,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: tokens.textMuted,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
