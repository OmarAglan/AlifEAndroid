import "package:code_forge/code_forge.dart";

import "../../../../../constants.dart";

List<CustomCodeSnippet> alifSnippets = [
  CustomCodeSnippet(label: "اطبع", value: "اطبع()", cursorLocations: {5}),
  CustomCodeSnippet(label: "ادخل", value: 'ادخل("")', cursorLocations: {6}),
  CustomCodeSnippet(label: "دالة", value: "دالة ():", cursorLocations: {5}),
  CustomCodeSnippet(
    label: "صنف",
    value: "صنف :\n$kCodeSpaceدالة __تهيئة__(هذا):",
    cursorLocations: {4},
  ),
  CustomCodeSnippet(label: "اذا", value: "اذا :", cursorLocations: {4}),
  CustomCodeSnippet(label: "لكل", value: "لكل  في :", cursorLocations: {4}),
  CustomCodeSnippet(
    label: "حاول",
    value: "حاول:\n$kCodeSpace\nخلل:\n$kCodeSpace",
    cursorLocations: {8},
  ),
  CustomCodeSnippet(label: "بينما", value: "بينما :", cursorLocations: {6}),
  CustomCodeSnippet(label: "خطية", value: "خطية :", cursorLocations: {5}),
  CustomCodeSnippet(label: "تعليق #", value: "# ", cursorLocations: {2}),
];
