import "dart:math";
import "package:flutter/material.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "../../constants.dart";
import "../theme/colors.dart";

class RadioInput extends StatefulWidget {
  const RadioInput({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.onLongPress,
    this.onAdd,
    this.onOpen,
    this.disabled = false,
    this.hasBorder = false,
    this.whiteBG = true,
  });

  final List<SelectEntity> items;
  final dynamic value;
  final bool disabled, hasBorder, whiteBG;
  final Function(dynamic) onChanged;
  final Function(dynamic)? onLongPress;
  final VoidCallback? onAdd;
  final VoidCallback? onOpen;

  @override
  State<RadioInput> createState() => _RadioInputState();
}

class _RadioInputState extends State<RadioInput> {
  int _selectedValue = -1;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _updateSelectedIndex();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialScroll());
  }

  void _initialScroll() {
    if (_selectedValue != -1) {
      _scrollToSelected(isInitial: true);
    }
  }

  @override
  void didUpdateWidget(RadioInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    // لو القيمة اتغيرت أو عدد العناصر اتغير (عشان الحذف)
    if (oldWidget.value != widget.value ||
        oldWidget.items.length != widget.items.length) {
      _updateSelectedIndex();

      // بلاش Future.delayed يا محمد، استخدم دي عشان تستنى الفريم الجديد
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _scrollToSelected();
      });
    }
  }

  void _updateSelectedIndex() {
    setState(() {
      _selectedValue = widget.items.indexWhere(
        (item) => item.value == widget.value,
      );
    });
  }

  void _scrollToSelected({bool isInitial = false}) {
    if (!mounted ||
        !_scrollController.hasClients ||
        widget.items.isEmpty ||
        _selectedValue == -1 ||
        _selectedValue >= widget.items.length) {
      return;
    }

    const double iconWidth = 40.0;
    const double paddingVal = 2;

    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final double maxWidth = renderBox.size.width;

    final int totalFlex = widget.items.fold(
      0,
      (sum, item) => sum + item.name.length,
    );
    if (totalFlex == 0) return;

    final double innerContainerWidth = maxWidth - (paddingVal * 4);
    final double requiredWidth =
        (totalFlex * 10) +
        (widget.onAdd != null ? iconWidth : 0) +
        (widget.onOpen != null ? iconWidth : 0);

    final double scrollableWidth = max(innerContainerWidth, requiredWidth);
    final double offsetForIcons =
        (widget.onAdd != null ? iconWidth : 0) +
        (widget.onOpen != null ? iconWidth : 0);

    int flexBefore = 0;
    for (int i = 0; i < _selectedValue; i++) {
      flexBefore += widget.items[i].name.length;
    }

    final double itemsAvailableWidth = scrollableWidth - offsetForIcons;
    final double targetStart =
        offsetForIcons + ((flexBefore / totalFlex) * itemsAvailableWidth);

    final double targetOffset = targetStart - (maxWidth / 2) + 20;
    final double finalOffset = targetOffset.clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );

    if (isInitial) {
      _scrollController.jumpTo(finalOffset);
    } else {
      _scrollController.animateTo(
        finalOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }

    try {
      final double maxScroll = _scrollController.position.maxScrollExtent;
      final double finalOffset = targetOffset.clamp(0.0, maxScroll);

      if (isInitial) {
        _scrollController.jumpTo(finalOffset);
      } else {
        _scrollController.animateTo(
          finalOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } catch (e) {
      debugPrint("Scroll error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasSelection = _selectedValue != -1;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth;
        const double height = 35;
        const double paddingVal = 2;
        const double iconWidth = 40.0;

        final int totalFlex = widget.items.fold(
          0,
          (sum, item) => sum + item.name.length,
        );

        final double innerContainerWidth = maxWidth - (paddingVal * 4);

        final double requiredWidth =
            (totalFlex * 10) +
            (widget.onAdd != null ? iconWidth : 0) +
            (widget.onOpen != null ? iconWidth : 0);
        final double scrollableWidth = max(innerContainerWidth, requiredWidth);

        double selectorWidth = 0;
        double selectorStart = 0;

        final double offsetForIcons =
            (widget.onAdd != null ? iconWidth : 0) +
            (widget.onOpen != null ? iconWidth : 0);

        if (hasSelection && totalFlex > 0) {
          int flexBefore = 0;
          for (int i = 0; i < _selectedValue; i++) {
            flexBefore += widget.items[i].name.length;
          }
          final double itemsAvailableWidth = scrollableWidth - offsetForIcons;
          selectorStart =
              offsetForIcons + ((flexBefore / totalFlex) * itemsAvailableWidth);
          selectorWidth =
              (widget.items[_selectedValue].name.length / totalFlex) *
              itemsAvailableWidth;
        }

        return SizedBox(
          height: height,
          width: maxWidth,
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: paddingVal * 2),
            child: SizedBox(
              width: scrollableWidth,
              child: Stack(
                children: [
                  if (hasSelection)
                    AnimatedPositionedDirectional(
                      start: selectorStart,
                      width: selectorWidth,
                      top: 4,
                      bottom: 4,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      child: Container(
                        decoration: BoxDecoration(
                          color: context.sacheme.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(color: context.sacheme, blurRadius: 5),
                          ],
                        ),
                      ),
                    ),
                  Row(
                    children: [
                      if (widget.onOpen != null)
                        SizedBox(
                          width: iconWidth,
                          child: IconButton(
                            onPressed: widget.onOpen,
                            icon: Icon(
                              LucideIcons.files,
                              size: 18,
                              color: context.text,
                            ),
                          ),
                        ),
                      if (widget.onAdd != null)
                        SizedBox(
                          width: iconWidth,
                          child: IconButton(
                            onPressed: widget.onAdd,
                            icon: Icon(
                              LucideIcons.plus,
                              size: 20,
                              color: context.text,
                            ),
                          ),
                        ),
                      ...List.generate(widget.items.length, (index) {
                        final item = widget.items[index];
                        return Expanded(
                          flex: item.name.length,
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              if (widget.disabled) return;
                              setState(() => _selectedValue = index);
                              widget.onChanged(item.value);
                            },
                            onLongPress: () =>
                                widget.onLongPress?.call(item.value),
                            child: Container(
                              alignment: Alignment.center,
                              child: Text(
                                item.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: kSmallFont),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class SelectEntity {
  final String name;
  final dynamic value;

  SelectEntity({required this.name, required this.value});

  factory SelectEntity.same(String value) {
    return SelectEntity(name: value, value: value);
  }

  static List<SelectEntity> fromList(List<String> list) {
    return list.map((e) => SelectEntity.same(e)).toList();
  }

  factory SelectEntity.fromMap(Map<String, dynamic> map) =>
      SelectEntity(name: map["name"], value: map["value"]);

  Map<String, dynamic> toMap() {
    return {"name": name, "value": value};
  }

  @override
  String toString() => toMap().toString();
}
