import "dart:math";
import "package:flutter/material.dart";

import "../../constants.dart";
import "../theme/colors.dart";

class RadioInput extends StatefulWidget {
  const RadioInput({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.onLongPress,
    this.disabled = false,
    this.hasBorder = false,
    this.whiteBG = true,
  });

  final List<SelectEntity> items;
  final dynamic value;
  final bool disabled, hasBorder, whiteBG;
  final Function(dynamic) onChanged;
  final Function(dynamic)? onLongPress;

  @override
  State<RadioInput> createState() => _RadioInputState();
}

class _RadioInputState extends State<RadioInput> {
  late int _selectedValue;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _updateSelectedIndex();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollToSelected(isInitial: true),
    );
  }

  @override
  void didUpdateWidget(RadioInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value ||
        oldWidget.items.length != widget.items.length) {
      _updateSelectedIndex();
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
    }
  }

  void _updateSelectedIndex() {
    _selectedValue = widget.items.indexWhere(
      (item) => item.value == widget.value,
    );
  }

  // حسابات الـ Layout في مكان واحد عشان منكررش الكود
  Map<String, double> _calculateLayout(double maxWidth) {
    const double paddingVal = 2;
    final int totalFlex = widget.items.fold(
      0,
      (sum, item) => sum + item.name.length,
    );
    if (totalFlex == 0) {
      return {"totalFlex": 0, "scrollableWidth": 0, "start": 0, "width": 0};
    }

    final double innerWidth = maxWidth - (paddingVal * 4);
    final double scrollableWidth = max(innerWidth, totalFlex * 10.0);

    double selectorStart = 0;
    double selectorWidth = 0;

    if (_selectedValue != -1) {
      final int flexBefore = widget.items
          .take(_selectedValue)
          .fold(0, (sum, item) => sum + item.name.length);
      selectorStart = (flexBefore / totalFlex) * scrollableWidth;
      selectorWidth =
          (widget.items[_selectedValue].name.length / totalFlex) *
          scrollableWidth;
    }

    return {
      "totalFlex": totalFlex.toDouble(),
      "scrollableWidth": scrollableWidth,
      "start": selectorStart,
      "width": selectorWidth,
    };
  }

  void _scrollToSelected({bool isInitial = false}) {
    if (!mounted || !_scrollController.hasClients || _selectedValue == -1) {
      return;
    }

    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final layout = _calculateLayout(renderBox.size.width);
    final double targetOffset =
        (layout["start"]! - (renderBox.size.width / 2) + 20).clamp(
          0.0,
          _scrollController.position.maxScrollExtent,
        );

    if (isInitial) {
      _scrollController.jumpTo(targetOffset);
    } else {
      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = _calculateLayout(constraints.maxWidth);

        return SizedBox(
          height: 35,
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: kSmallPadding),
            child: SizedBox(
              width: layout["scrollableWidth"],
              child: Stack(
                children: [
                  if (_selectedValue != -1)
                    AnimatedPositionedDirectional(
                      start: layout["start"]!,
                      width: layout["width"]!,
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
                    children: List.generate(widget.items.length, (index) {
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
