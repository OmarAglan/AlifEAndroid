import 'package:highlight/src/mode.dart';
import 'package:highlight/src/common_modes.dart';

final allModes = [
  Mode(ref: '~string'),
  Mode(ref: '~number'),
  Mode(ref: '~meta'),
  Mode(ref: '~operator'),
  Mode(ref: '~function'),
  HASH_COMMENT_MODE,
];

final alif = Mode(
  refs: {
    // ---------- Strings ----------
    '~string-subst': Mode(
      className: "subst",
      begin: "\\{",
      end: "\\}",
      illegal: "#",
      contains: allModes,
    ),
    '~string-doublebrace': Mode(begin: "\\{\\{", relevance: 0),

    '~string': Mode(
      className: "string",
      contains: [BACKSLASH_ESCAPE],
      variants: [
        // alif-like strings
        Mode(
          begin: "(u|b)?r?'''",
          end: "'''",
          contains: [
            BACKSLASH_ESCAPE,
            Mode(ref: '~meta'),
          ],
          relevance: 10,
        ),
        Mode(
          begin: "(u|b)?r?\"\"\"",
          end: "\"\"\"",
          contains: [
            BACKSLASH_ESCAPE,
            Mode(ref: '~meta'),
          ],
          relevance: 10,
        ),
        Mode(
          begin: "(م)'''",
          end: "'''",
          contains: [
            BACKSLASH_ESCAPE,
            Mode(ref: '~meta'),
            Mode(ref: '~string-doublebrace'),
            Mode(ref: '~string-subst'),
          ],
        ),
        Mode(
          begin: "(م)\"\"\"",
          end: "\"\"\"",
          contains: [
            BACKSLASH_ESCAPE,
            Mode(ref: '~meta'),
            Mode(ref: '~string-doublebrace'),
            Mode(ref: '~string-subst'),
          ],
        ),
        // single line
        Mode(begin: "(u|r|ur)'", end: "'", relevance: 10),
        Mode(begin: "(u|r|ur)\"", end: "\"", relevance: 10),
        Mode(begin: "(b|br)'", end: "'"),
        Mode(begin: "(b|br)\"", end: "\""),
        Mode(
          begin: "(م)'",
          end: "'",
          contains: [
            BACKSLASH_ESCAPE,
            Mode(ref: '~string-doublebrace'),
            Mode(ref: '~string-subst'),
          ],
        ),
        Mode(
          begin: "(م)\"",
          end: "\"",
          contains: [
            BACKSLASH_ESCAPE,
            Mode(ref: '~string-doublebrace'),
            Mode(ref: '~string-subst'),
          ],
        ),
        APOS_STRING_MODE,
        QUOTE_STRING_MODE,
      ],
    ),

    // ---------- Numbers ----------
    '~number': Mode(
      className: "number",
      relevance: 0,
      variants: [
        Mode(begin: "\\b(0b[01]+)[lLjJ]?"),
        Mode(begin: "\\b(0o[0-7]+)[lLjJ]?"),
        Mode(
          begin:
              "(-?)(\\b0[xX][a-fA-F0-9]+|(\\b\\d+(\\.\\d*)?|\\.\\d+)([eE][-+]?\\d+)?)[lLjJ]?",
        ),
        Mode(begin: "(-?)([٠-٩]+(\\.[٠-٩]+)?)"),
      ],
    ),

    // ---------- Operators ----------
    '~operator': Mode(
      className: "operator",
      relevance: 0,
      begin:
          r"(\+|\-|\*|/|%|=|==|!=|>=|<=|<|>|\^|\\\^|\\\\|في|ليس| او| أو| و )",
    ),

    // ---------- Meta ----------
    '~meta': Mode(className: "meta", begin: "^(>>>|\\.\\.\\.) "),

    // ---------- Function (UPDATED) ----------
    '~function': Mode(
      className: "function",
      begin: r"([\u0600-\u06FFa-zA-Z_][\u0600-\u06FFa-zA-Z0-9_]*)\s*\(",
      returnBegin: true,
      end: r"\(",
      excludeEnd: true,
      contains: [
        Mode(
          className: "title",
          begin: r"[\u0600-\u06FFa-zA-Z_][\u0600-\u06FFa-zA-Z0-9_]*",
          relevance: 0,
        ),
      ],
    ),
  },
  aliases: ["الف", "alif", "aliflib"],
  keywords: {
    "keyword":
        "ادخل صحيح مفاتيح اقصى ادنى طول اضف امسح ادرج مفاتيح عشري مصفوفة اطبع مدى صح هذا عدم خطا خطأ اواذا اوإذا اذا إذا والا وإلا صنف دالة استورد عام لاجل لأجل لكل نهاية ارجع توقف حاول بينما استمر خلل احذف الزمن الرياضيات نوع",
    "literal": "صح خطا خطأ هذا",
    "built_in": "ادخل اطبع مصفوفة طول مدى",
  },
  illegal: "(<\\/|->|\\?)|=>",
  contains: allModes,
);
