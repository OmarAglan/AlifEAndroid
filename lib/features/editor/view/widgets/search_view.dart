import "package:code_forge/code_forge.dart";
import "package:flutter/material.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";

import "../../../../constants.dart";
import "../../../../core/theme/colors.dart";
import "../../../../core/theme/material.dart";

class SearchView extends StatelessWidget {
  final FindController findController;
  const SearchView({super.key, required this.findController});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.only(
        right: kMediumPadding,
        left: kMediumPadding,
        bottom: kMediumPadding,
      ),
      child: Row(
        spacing: kSmallPadding,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SearchInputRow(findController: findController),
                AnimatedCrossFade(
                  firstChild:
                      (findController.matchCount > 0 &&
                          !findController.isReplaceMode)
                      ? Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: _NavigationControls(
                            findController: findController,
                            axis: Axis.horizontal,
                          ),
                        )
                      : const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: _ReplaceInputRow(findController: findController),
                  ),
                  crossFadeState: findController.isReplaceMode
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 250),
                ),
              ],
            ),
          ),
          if (findController.matchCount > 0 && findController.isReplaceMode)
            _NavigationControls(
              findController: findController,
              axis: Axis.vertical,
            ),
        ],
      ),
    );
  }
}

class _SearchInputRow extends StatelessWidget {
  final FindController findController;
  const _SearchInputRow({required this.findController});

  @override
  Widget build(BuildContext context) {
    return MyMaterial(
      theme: MyMaterialTheme.border,
      child: Row(
        children: [
          Icon(LucideIcons.search, color: context.secondary, size: 18),
          const SizedBox(width: kSmallPadding),
          Expanded(
            child: TextField(
              autofocus: true,
              focusNode: findController.findInputFocusNode,
              decoration: InputDecoration(
                hintText: "${l10n.search}...",
                border: InputBorder.none,
                isDense: true,
                hintStyle: const TextStyle(fontSize: kSmallFont),
              ),
              onChanged: (value) => findController.find(value),
            ),
          ),
          _ActionButton(
            icon: LucideIcons.regex,
            isActive: findController.isRegex,
            onPressed: () => findController.toggleRegex(),
          ),
          _ActionButton(
            icon: LucideIcons.wholeWord,
            isActive: findController.matchWholeWord,
            onPressed: () => findController.toggleMatchWholeWord(),
          ),
          _ActionButton(
            icon: LucideIcons.caseUpper,
            isActive: findController.caseSensitive,
            onPressed: () => findController.toggleCaseSensitive(),
          ),
          _ActionButton(
            icon: LucideIcons.replace,
            isActive: findController.isReplaceMode,
            onPressed: () => findController.toggleReplaceMode(),
          ),
        ],
      ),
    );
  }
}

class _ReplaceInputRow extends StatelessWidget {
  final FindController findController;
  const _ReplaceInputRow({required this.findController});

  @override
  Widget build(BuildContext context) {
    return MyMaterial(
      theme: MyMaterialTheme.border,
      child: Row(
        children: [
          Icon(LucideIcons.replace, color: context.secondary, size: 18),
          const SizedBox(width: kSmallPadding),
          Expanded(
            child: TextField(
              focusNode: findController.replaceInputFocusNode,
              controller: findController.replaceInputController,
              decoration: const InputDecoration(
                hintText: "استبدال بـ...",
                border: InputBorder.none,
                hintStyle: TextStyle(fontSize: kSmallFont),
                isDense: true,
              ),
              onSubmitted: (val) => findController.replace(),
            ),
          ),
          _ActionButton(
            icon: LucideIcons.replace,
            onPressed: () => findController.replace(),
          ),
          _ActionButton(
            icon: LucideIcons.replaceAll,
            onPressed: () => findController.replaceAll(),
          ),
        ],
      ),
    );
  }
}

class _NavigationControls extends StatelessWidget {
  final FindController findController;
  final Axis axis;
  const _NavigationControls({
    required this.findController,
    this.axis = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    return MyMaterial(
      theme: MyMaterialTheme.border,
      padding: axis == Axis.horizontal
          ? const EdgeInsets.symmetric(horizontal: kSmallPadding)
          : const EdgeInsets.all(0),
      child: Flex(
        direction: axis,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: axis == Axis.horizontal
            ? MainAxisSize.max
            : MainAxisSize.min,
        children: [
          _ActionButton(
            icon: LucideIcons.chevronUp,
            onPressed: () => findController.previous(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: axis == Axis.vertical
                          ? const Offset(0, 0.2)
                          : const Offset(0.2, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: Text(
                "${findController.currentMatchIndex + 1}/${findController.matchCount}",
                key: ValueKey<int>(findController.currentMatchIndex),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: context.primary,
                ),
              ),
            ),
          ),
          _ActionButton(
            icon: LucideIcons.chevronDown,
            onPressed: () => findController.next(),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    this.isActive = false,
    required this.onPressed,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.8),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: IconButton(
          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          padding: EdgeInsets.zero,
          icon: Icon(
            widget.icon,
            size: 16,
            color: widget.isActive
                ? context.primary
                : context.secondary.withOpacity(0.6),
          ),
          onPressed: widget.onPressed,
        ),
      ),
    );
  }
}
