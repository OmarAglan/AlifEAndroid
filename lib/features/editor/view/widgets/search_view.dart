import "package:code_forge/code_forge.dart";
import "package:flutter/material.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";

import "../../../../constants.dart";
import "../../../../data/ide_data.dart";

class SearchView extends StatelessWidget {
  const SearchView({
    super.key,
    required this.data,
    required this.findController,
  });

  final IdeData data;
  final FindController findController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kLargePadding),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              autofocus: true,
              focusNode: findController.findInputFocusNode,
              decoration: InputDecoration(
                hintText: "${l10n.search}...",
                border: InputBorder.none,
              ),
              onChanged: (value) => findController.find(value),
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.x, size: kLargeFont),
            constraints: const BoxConstraints(),
            onPressed: () => data.toggleSearch(),
          ),
        ],
      ),
    );
  }
}
