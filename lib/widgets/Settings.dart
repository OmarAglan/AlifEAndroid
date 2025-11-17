import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:input_quantity/input_quantity.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  const Settings({super.key, required this.fontSize, required this.autoSave});
  final ValueNotifier<double> fontSize;
  final ValueNotifier<bool> autoSave;
  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.settings, color: Colors.white, size: 25),
            SizedBox(width: 5),
            Text(
              "الإعدادات",
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ScaleTransition(
                    scale: AlwaysStoppedAnimation(1.1),
                    child: InputQty(
                      initVal: widget.fontSize.value,
                      maxVal: 50,
                      minVal: 10,
                      steps: 1,
                      qtyFormProps: QtyFormProps(
                        style: TextStyle(color: Colors.white),
                        enableTyping: false,
                      ),
                      decoration: QtyDecorationProps(border: InputBorder.none),
                      onQtyChanged: (val) async {
                        double newSize;
                        if (val is num) {
                          newSize = val.toDouble();
                        } else {
                          final parsed = double.tryParse(val.toString());
                          if (parsed == null) return;
                          newSize = parsed;
                        }
                        widget.fontSize.value = newSize;
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setDouble('EditorFontSize', newSize);
                      },
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        "(15)",
                        style: TextStyle(color: Colors.grey, fontSize: 15),
                      ),
                      SizedBox(width: 5),
                      Text(
                        "حجم الخط",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Switch(
                    value: widget.autoSave.value,
                    onChanged: (value) async {
                      widget.autoSave.value = value;
                      setState(() {});
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('EditorAutoSave', value);
                    },
                  ),
                  Text(
                    "الحفظ التلقائي",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
