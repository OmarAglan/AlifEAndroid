import "package:code_forge/code_forge.dart";
import "package:flutter/material.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "../../../../constants.dart";
import "../../../../core/theme/colors.dart";
import "../../../../core/theme/material.dart";

class SearchView extends StatelessWidget {
  const SearchView({super.key, required this.findController});
  final FindController findController;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: kAnimationDuration,
      curve: kCurveEaseInOut,
      padding: const EdgeInsets.symmetric(
        horizontal: kMediumPadding,
      ).copyWith(bottom: kMediumPadding),
      child: Row(
        spacing: kSmallPadding,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                _BaseInput(
                  icon: LucideIcons.search,
                  actions: [
                    _ActionButton(
                      icon: LucideIcons.regex,
                      isActive: findController.isRegex,
                      onPressed: findController.toggleRegex,
                    ),
                    _ActionButton(
                      icon: LucideIcons.wholeWord,
                      isActive: findController.matchWholeWord,
                      onPressed: findController.toggleMatchWholeWord,
                    ),
                    _ActionButton(
                      icon: LucideIcons.caseUpper,
                      isActive: findController.caseSensitive,
                      onPressed: findController.toggleCaseSensitive,
                    ),
                    _ActionButton(
                      icon: LucideIcons.replace,
                      isActive: findController.isReplaceMode,
                      onPressed: findController.toggleReplaceMode,
                    ),
                  ],
                  child: TextField(
                    autofocus: true,
                    focusNode: findController.findInputFocusNode,
                    decoration: InputDecoration(
                      hint: Text(
                        "${l10n.search}...",
                        style: TextStyle(color: context.secondary),
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    onChanged: findController.find,
                  ),
                ),
                if (findController.isReplaceMode)
                  _BaseInput(
                    icon: LucideIcons.replace,
                    actions: [
                      _ActionButton(
                        icon: LucideIcons.replace,
                        onPressed: findController.replace,
                      ),
                      _ActionButton(
                        icon: LucideIcons.replaceAll,
                        onPressed: findController.replaceAll,
                      ),
                    ],
                    child: TextField(
                      focusNode: findController.replaceInputFocusNode,
                      controller: findController.replaceInputController,
                      decoration: InputDecoration(
                        hint: Text(
                          "${l10n.replaceWith}...",
                          style: TextStyle(color: context.secondary),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      onSubmitted: (_) => findController.replace(),
                    ),
                  )
                else if (findController.matchCount > 0)
                  _NavigationControls(
                    findController: findController,
                    axis: Axis.horizontal,
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

class _BaseInput extends StatelessWidget {
  const _BaseInput({
    required this.icon,
    required this.child,
    required this.actions,
  });
  final IconData icon;
  final Widget child;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return MyMaterial(
      theme: MyMaterialTheme.border,
      padding: const EdgeInsets.symmetric(horizontal: kSmallPadding),
      child: Row(
        spacing: kSmallPadding,
        children: [
          Icon(icon, color: context.secondary, size: kMediumFont),
          Expanded(child: child),
          ...actions,
        ],
      ),
    );
  }
}

class _NavigationControls extends StatelessWidget {
  const _NavigationControls({required this.findController, required this.axis});
  final FindController findController;
  final Axis axis;

  @override
  Widget build(BuildContext context) {
    return MyMaterial(
      theme: MyMaterialTheme.border,
      padding: axis == Axis.horizontal
          ? const EdgeInsets.symmetric(horizontal: kSmallPadding)
          : EdgeInsets.zero,
      child: Flex(
        direction: axis,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _ActionButton(
            icon: LucideIcons.chevronUp,
            onPressed: findController.previous,
          ),
          Text(
            "${findController.currentMatchIndex + 1}/${findController.matchCount}",
            style: TextStyle(
              fontSize: kSoSmallFont,
              fontWeight: FontWeight.bold,
              color: context.primary,
            ),
          ),
          _ActionButton(
            icon: LucideIcons.chevronDown,
            onPressed: findController.next,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    this.isActive = false,
    required this.onPressed,
  });
  final IconData icon;
  final bool isActive;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      constraints: const BoxConstraints(),
      icon: Icon(
        icon,
        size: kMediumFont,
        color: isActive ? context.primary : context.secondary.withOpacity(0.6),
      ),
      onPressed: onPressed,
    );
  }
}
