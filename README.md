# محرر لغة الف للاندرويد

## تعديل المكتبات
1. في ملف reg_exp.dart
    - `C:\Users\{{USERNAME}}\AppData\Local\Pub\Cache\hosted\pub.dev\flutter_code_editor-0.3.4\lib\src\code\reg_exp.dart`

    ```dart
    class RegExps {
    static final wordSplit = RegExp(r'[^_a-zA-Z0-9\u0600-\u06FF]+');
    }
    ```
2. في ملف common_modes.dart استبدل اخر ثلاث متغيرات
    - `C:\Users\{{USERNAME}}\AppData\Local\Pub\Cache\hosted\pub.dev\highlight-0.7.0\lib\src\common_modes.dart`

    ```dart
    final TITLE_MODE = Mode(
    className: "title", begin: "[\\u0600-\\u06FFa-zA-Z]\\w*", relevance: 0);
    final UNDERSCORE_TITLE_MODE = Mode(
        className: "title",
        begin: "[\\u0600-\\u06FFa-zA-Z_][\\u0600-\\u06FFa-zA-Z0-9_]*",
        relevance: 0);
    final METHOD_GUARD = Mode(
        begin: "\\.\\s*[\\u0600-\\u06FFa-zA-Z_][\\u0600-\\u06FFa-zA-Z0-9_]*",
        relevance: 0);
    ```

3. في ملف highlight.dart استبدل هذا السطر في الاغلب في السطر 105
    - `C:\Users\{{USERNAME}}\AppData\Local\Pub\Cache\hosted\pub.dev\highlight-0.7.0\lib\src\highlight.dart`

    ```dart
        mode.lexemesRe = _langRe(mode.lexemes ?? r'[\u0600-\u06FF\w]+', true);
    ```

## للبناء
```bash
flutter build apk --split-per-abi
```