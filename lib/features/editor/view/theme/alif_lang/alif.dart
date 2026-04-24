import "package:re_highlight/re_highlight.dart";
import "keywords.dart";
export "alif_snippets.dart";

final allModes = [
  Mode(ref: "~string"),
  Mode(ref: "~number"),
  Mode(ref: "~meta"),
  Mode(ref: "~operator"),
  Mode(ref: "~function"),
  HASH_COMMENT_MODE,
];

final alif = Mode(
  refs: {
    // ---------- Strings ----------
    "~string-subst": Mode(
      className: "subst",
      begin: "\\{",
      end: "\\}",
      illegal: "#",
      contains: allModes,
    ),
    "~string-doublebrace": Mode(begin: "\\{\\{", relevance: 0),

    "~string": Mode(
      className: "string",
      contains: [BACKSLASH_ESCAPE],
      variants: [
        Mode(
          begin: "(م)'''",
          end: "'''",
          contains: [
            BACKSLASH_ESCAPE,
            Mode(ref: "~meta"),
            Mode(ref: "~string-doublebrace"),
            Mode(ref: "~string-subst"),
          ],
        ),
        Mode(
          begin: "(م)\"\"\"",
          end: "\"\"\"",
          contains: [
            BACKSLASH_ESCAPE,
            Mode(ref: "~meta"),
            Mode(ref: "~string-doublebrace"),
            Mode(ref: "~string-subst"),
          ],
        ),
        Mode(
          begin: "(م)'",
          end: "'",
          contains: [
            BACKSLASH_ESCAPE,
            Mode(ref: "~string-doublebrace"),
            Mode(ref: "~string-subst"),
          ],
        ),
        Mode(
          begin: "(م)\"",
          end: "\"",
          contains: [
            BACKSLASH_ESCAPE,
            Mode(ref: "~string-doublebrace"),
            Mode(ref: "~string-subst"),
          ],
        ),
        Mode(
          className: "string",
          begin: "'",
          end: "'",
          contains: [BACKSLASH_ESCAPE],
        ),
        Mode(
          className: "string",
          begin: "\"",
          end: "\"",
          contains: [BACKSLASH_ESCAPE],
        ),
      ],
    ),

    // ---------- Numbers ----------
    "~number": Mode(
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
    "~operator": Mode(
      className: "operator",
      relevance: 0,
      begin: "($operatorPattern)",
    ),

    // ---------- Meta ----------
    "~meta": Mode(className: "meta", begin: "^(>>>|\\.\\.\\.) "),

    // ---------- Function ----------
    "~function": Mode(
      className: "function",
      begin: r"([\u0600-\u06FFa-zA-Z_][\u0600-\u06FFa-zA-Z0-9_]*)\(",
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
    "\$pattern":
        r"[\u0600-\u06FF_][\u0600-\u06FFa-zA-Z0-9_]*|[a-zA-Z_][a-zA-Z0-9_]*|__\w+__",
    "keyword": alifKeywords.join(" "),
    "literal": alifLiterals.join(" "),
    "built_in": alifBuiltIns.join(" "),
  },
  illegal: "(<\\/|->|\\?)|=>",
  contains: allModes,
);
