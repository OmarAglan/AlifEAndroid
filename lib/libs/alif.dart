import 'package:highlight/src/mode.dart';
import 'package:highlight/src/common_modes.dart';

final alif = Mode(
  refs: {
    // ---------- Strings ----------
    '~string-subst': Mode(
      className: "subst",
      begin: "\\{",
      end: "\\}",
      illegal: "#",
      contains: [
        Mode(ref: '~string'),
        Mode(ref: '~number'),
        Mode(ref: '~meta'),
        // Mode(ref: '~function'),
        Mode(ref: '~boolean')
      ],
    ),
    '~string-doublebrace': Mode(begin: "\\{\\{", relevance: 0),

    '~string': Mode(
      className: "string",
      contains: [BACKSLASH_ESCAPE],
      variants: [
        // python-like
        Mode(
            begin: "(u|b)?r?'''",
            end: "'''",
            contains: [BACKSLASH_ESCAPE, Mode(ref: '~meta')],
            relevance: 10),
        Mode(
            begin: "(u|b)?r?\"\"\"",
            end: "\"\"\"",
            contains: [BACKSLASH_ESCAPE, Mode(ref: '~meta')],
            relevance: 10),

        // alif-style multiline with م
        Mode(begin: "(م)'''", end: "'''", contains: [
          BACKSLASH_ESCAPE,
          Mode(ref: '~meta'),
          Mode(ref: '~string-doublebrace'),
          Mode(ref: '~string-subst'),
        ]),
        Mode(begin: "(م)\"\"\"", end: "\"\"\"", contains: [
          BACKSLASH_ESCAPE,
          Mode(ref: '~meta'),
          Mode(ref: '~string-doublebrace'),
          Mode(ref: '~string-subst'),
        ]),

        // single line
        Mode(begin: "(u|r|ur)'", end: "'", relevance: 10),
        Mode(begin: "(u|r|ur)\"", end: "\"", relevance: 10),
        Mode(begin: "(b|br)'", end: "'"),
        Mode(begin: "(b|br)\"", end: "\""),

        Mode(begin: "(م)'", end: "'", contains: [
          BACKSLASH_ESCAPE,
          Mode(ref: '~string-doublebrace'),
          Mode(ref: '~string-subst'),
        ]),
        Mode(begin: "(م)\"", end: "\"", contains: [
          BACKSLASH_ESCAPE,
          Mode(ref: '~string-doublebrace'),
          Mode(ref: '~string-subst'),
        ]),

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
            // decimal & hex
            begin:
                "(-?)(\\b0[xX][a-fA-F0-9]+|(\\b\\d+(\\.\\d*)?|\\.\\d+)([eE][-+]?\\d+)?)[lLjJ]?"),
        Mode(begin: "(-?)([٠-٩]+(\\.[٠-٩]+)?)"),
      ],
    ),

    // ---------- Operators ----------
    '~operator': Mode(
        className: "operator",
        relevance: 0,
        begin:
            r"(\+|\-|\*|/|%|=|==|!=|>=|<=|<|>|\^|\\\^|\\\\|ليس| او| أو| و )"),

    // ---------- Meta ----------
    '~meta': Mode(className: "meta", begin: "^(>>>|\\.\\.\\.) "),

    // ---------- Boolean ----------
    '~boolean': Mode(
        className: "boolean",
        relevance: 0,
        begin: r"(صح |خطا|خطأ|هذا|_تهيئة_)"),

    // ---------- function ----------
    // '~function': Mode(
    //   className: "function",
    //   relevance: 0,
    //   begin: r"([\u0600-\u06FFa-zA-Z_][\u0600-\u06FFa-zA-Z0-9_]*)\s*\(",
    //   end: r".",
    //   excludeEnd: true,
    //   contains: [
    //     Mode(ref: '~meta'),
    //     Mode(ref: '~number'),
    //     Mode(ref: '~operator'),
    //     Mode(ref: '~boolean'),
    //     Mode(ref: '~function'),
    //     Mode(ref: '~string'),
    //   ],
    // ),
  },
  aliases: ["الف", "alif", "aliflib"],
  keywords: {
    "keyword":
        "اواذا اوإذا اذا إذا والا وإلا صنف دالة استورد عام لاجل لأجل لكل نهاية اطبع ارجع توقف حاول بينما استمر خلل احذف الزمن الرياضيات نوع",
    "literal": "صح عدم خطا خطأ",
  },
  illegal: "(<\\/|->|\\?)|=>",
  contains: [
    Mode(ref: '~meta'),
    Mode(ref: '~number'),
    Mode(ref: '~operator'),
    Mode(ref: '~boolean'),
    // Mode(ref: '~function'),
    Mode(ref: '~string'),
    Mode(beginKeywords: "اذا", relevance: 0),

    // التعليقات
    HASH_COMMENT_MODE,
    Mode(className: "comment", begin: "//", end: r"$"),
    Mode(className: "comment", begin: "--", end: r"$"),

    // دالة وصنف
    Mode(
      variants: [
        Mode(className: "function", begin: "\\bدالة\\b"),
        Mode(className: "class", begin: "\\bصنف\\b"),
      ],
      end: ":",
      illegal: r"[\${=;\n,]",
      contains: [
        UNDERSCORE_TITLE_MODE,
        Mode(
          className: "params",
          begin: "\\(",
          end: "\\)",
          contains: [
            Mode(
                className: "variable",
                begin: r"[\u0600-\u06FF_a-zA-Z][\u0600-\u06FF_a-zA-Z0-9_]*"),
            Mode(ref: '~meta'),
            Mode(ref: '~number'),
            Mode(ref: '~string'),
            Mode(ref: '~operator'),
            Mode(ref: '~boolean'),
            HASH_COMMENT_MODE,
          ],
        ),
        Mode(begin: "->", endsWithParent: true, keywords: "None"),
      ],
    ),

    // Decorators
    Mode(className: "meta", begin: "^[\\t ]*@", end: r"$"),
  ],
);
