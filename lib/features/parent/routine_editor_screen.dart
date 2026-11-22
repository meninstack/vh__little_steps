import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/routine_names.dart';
import '../../core/theme.dart';
import '../../data/card_catalog.dart';
import '../../data/card_resolver.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_controller.dart';
import '../../widgets/card_art.dart';
import 'card_picker_screen.dart';

/// Where a parent names a routine, picks its icon, and orders its tasks.
class RoutineEditorScreen extends ConsumerStatefulWidget {
  const RoutineEditorScreen({super.key, required this.routineId});

  final String routineId;

  @override
  ConsumerState<RoutineEditorScreen> createState() =>
      _RoutineEditorScreenState();
}

class _RoutineEditorScreenState extends ConsumerState<RoutineEditorScreen> {
  TextEditingController? _name;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_name != null) return;
    // A starter routine shows its translated name so there is something to
    // edit; a brand-new routine starts blank.
    final routine = ref
        .read(appControllerProvider)
        .routineById(widget.routineId);
    final l10n = AppLocalizations.of(context);
    _name = TextEditingController(
      text:
          routine == null || (routine.name.isEmpty && routine.presetKey == null)
          ? ''
          : routineDisplayName(routine, l10n),
    );
  }

  @override
  void dispose() {
    _name?.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(Routine routine) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteRoutine),
        content: Text(
          l10n.deleteRoutineConfirm(routineDisplayName(routine, l10n)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    Navigator.of(context).pop();
    ref.read(appControllerProvider.notifier).deleteRoutine(routine.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final data = ref.watch(appControllerProvider);
    final controller = ref.read(appControllerProvider.notifier);
    final routine = data.routineById(widget.routineId);

    // The routine was just deleted and this screen is on its way out.
    if (routine == null) return const Scaffold();

    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _name,
          maxLength: 24,
          textCapitalization: TextCapitalization.sentences,
          onChanged: (value) =>
              controller.renameRoutine(routine.id, value.trim()),
          decoration: InputDecoration(
            labelText: l10n.routineNameLabel,
            hintText: l10n.newRoutine,
          ),
        ),
        const SizedBox(height: 8),
        Text(l10n.routineIconLabel, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        // One row that scrolls sideways, so the tasks below stay on screen.
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: 10,
            children: [
              for (final iconId in routineIconIds)
                _IconChoice(
                  iconId: iconId,
                  selected: routine.iconId == iconId,
                  onTap: () => controller.setRoutineIcon(routine.id, iconId),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: Text(l10n.tasksHeader, style: theme.textTheme.titleLarge),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  fullscreenDialog: true,
                  builder: (_) => CardPickerScreen(routineId: routine.id),
                ),
              ),
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.addCards),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          routine.items.isEmpty ? l10n.editorEmptyRoutine : l10n.reorderHint,
          style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.inkSoft),
        ),
        const SizedBox(height: 12),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editRoutine),
        actions: [
          IconButton(
            onPressed: () => _confirmDelete(routine),
            tooltip: l10n.deleteRoutine,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ReorderableListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              buildDefaultDragHandles: false,
              header: header,
              itemCount: routine.items.length,
              onReorderItem: (oldIndex, newIndex) =>
                  controller.moveItem(routine.id, oldIndex, newIndex),
              itemBuilder: (context, index) {
                final item = routine.items[index];
                final card = resolveCard(data, item.cardId, languageCode);
                return Padding(
                  key: ValueKey(item.id),
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: cardTint(card.group),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
                      child: Row(
                        children: [
                          CardArt(card: card, size: 44),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              card.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                controller.removeItem(routine.id, item.id),
                            tooltip: l10n.removeTask,
                            icon: const Icon(Icons.close_rounded),
                          ),
                          ReorderableDragStartListener(
                            index: index,
                            child: const Padding(
                              padding: EdgeInsets.all(12),
                              child: Icon(Icons.drag_handle_rounded),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _IconChoice extends StatelessWidget {
  const _IconChoice({
    required this.iconId,
    required this.selected,
    required this.onTap,
  });

  final String iconId;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      label: iconId,
      excludeSemantics: true,
      child: Material(
        color: Colors.white,
        shape: CircleBorder(
          side: BorderSide(
            color: selected ? AppColors.primary : AppColors.outline,
            width: selected ? 3 : 1.5,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: SvgPicture.asset(
              routineIconAsset(iconId),
              width: 36,
              height: 36,
            ),
          ),
        ),
      ),
    );
  }
}
