import 'package:flutter/material.dart';
import 'package:simple_sheet_music/src/constants.dart';
import 'package:simple_sheet_music/src/glyph_metadata.dart';
import 'package:simple_sheet_music/src/glyph_path.dart';
import 'package:simple_sheet_music/src/mixin/debug_render_mixin.dart';
import 'package:simple_sheet_music/src/music_objects/interface/musical_symbol.dart';
import 'package:simple_sheet_music/src/music_objects/interface/musical_symbol_metrics.dart';
import 'package:simple_sheet_music/src/music_objects/interface/musical_symbol_renderer.dart';
import 'package:simple_sheet_music/src/musical_context.dart';
import 'package:simple_sheet_music/src/sheet_music_layout.dart';

import 'time_signature_type.dart';

/// Represents a time signature in sheet music.
class TimeSignature extends MusicalSymbol {
  TimeSignature.twoFour({
    super.color,
    super.margin,
  }) : timeSignatureType = TimeSignatureType.twoFour;

  TimeSignature.twoTwo({
    super.color,
    super.margin,
  }) : timeSignatureType = TimeSignatureType.twoTwo;

  TimeSignature.threeFour({
    super.color,
    super.margin,
  }) : timeSignatureType = TimeSignatureType.threeFour;

  TimeSignature.threeEight({
    super.color,
    super.margin,
  }) : timeSignatureType = TimeSignatureType.threeEight;

  TimeSignature.fourFour({
    super.color,
    super.margin,
  }) : timeSignatureType = TimeSignatureType.fourFour;

  TimeSignature.fourTwo({
    super.color,
    super.margin,
  }) : timeSignatureType = TimeSignatureType.fourTwo;

  TimeSignature.fiveFour({
    super.color,
    super.margin,
  }) : timeSignatureType = TimeSignatureType.fiveFour;

  TimeSignature.sixEight({
    super.color,
    super.margin,
  }) : timeSignatureType = TimeSignatureType.sixEight;

  TimeSignature.sevenEight({
    super.color,
    super.margin,
  }) : timeSignatureType = TimeSignatureType.sevenEight;

  TimeSignature.nineEight({
    super.color,
    super.margin,
  }) : timeSignatureType = TimeSignatureType.nineEight;

  final TimeSignatureType timeSignatureType;

  @override
  double get duration => 0;

  @override
  MusicalSymbolMetrics setContext(
    MusicalContext context,
    GlyphMetadata metadata,
    GlyphPaths paths,
  ) =>
      TimeSignatureMetrics(this, context, metadata, paths);
}

class TimeSignatureMetrics implements MusicalSymbolMetrics {
  const TimeSignatureMetrics(
    this.timeSignature,
    this.context,
    this.metadata,
    this.paths,
  );
  final TimeSignature timeSignature;
  final MusicalContext context;
  final GlyphMetadata metadata;
  final GlyphPaths paths;

  TimeSignatureType get timeSignatureType => timeSignature.timeSignatureType;
  Path get denominatorPath =>
      paths.parsePath(timeSignatureType.denominatorPathKey);
  Path get numeratorPath => paths.parsePath(timeSignatureType.numeratorPathKey);
  Rect get bbox {
    final numeratorBounds = numeratorPath.getBounds();
    final denominatorBounds = denominatorPath.getBounds();

    // Get correct Y positions based on rendering logic
    // 2 means the numerator is 2 staff spaces above the center line
    // -2 means the denominator is 2 staff spaces below the center line
    const numeratorY = -1 * (1 / 2) * 2 * Constants.staffSpace;
    const denominatorY = -1 * (1 / 2) * -2 * Constants.staffSpace;

    const numeratorOffset = Offset(0, numeratorY);
    const denominatorOffset = Offset(0, denominatorY);

    final shiftedNumeratorBounds = numeratorBounds.shift(numeratorOffset);
    final shiftedDenominatorBounds = denominatorBounds.shift(denominatorOffset);

    // Return the union of the two bounding
    return shiftedNumeratorBounds.expandToInclude(shiftedDenominatorBounds);
  }

  @override
  double get lowerHeight => bbox.bottom;

  @override
  double get upperHeight => -bbox.top;

  @override
  double get width => bbox.width;

  @override
  EdgeInsets get margin => timeSignature.margin;

  double get marginLeft => timeSignature.margin.left;

  Color get color => timeSignature.color;

  @override
  MusicalSymbolRenderer renderer(
    SheetMusicLayout layout, {
    required double staffLineCenterY,
    required double symbolX,
  }) =>
      TimeSignatureRenderer(
        this,
        layout,
        staffLineCenterY: staffLineCenterY,
        symbolX: symbolX,
        musicalSymbol: timeSignature,
      );
}

// renders time signature on the sheet music
class TimeSignatureRenderer
    with DebugRenderMixin
    implements MusicalSymbolRenderer {
  const TimeSignatureRenderer(
    this.timeSignature,
    this.layout, {
    required this.staffLineCenterY,
    required this.symbolX,
    required this.musicalSymbol,
  });

  final double staffLineCenterY;
  final double symbolX;
  final TimeSignatureMetrics timeSignature;
  final SheetMusicLayout layout;

  @override
  final MusicalSymbol musicalSymbol;

  Offset get numeratorRenderOffset =>
      Offset(
        symbolX,
        -1 * (1 / 2) * 2 * Constants.staffSpace + staffLineCenterY,
      ) +
      marginOffset;
  Offset get denominatorRenderOffset =>
      Offset(
        symbolX,
        -1 * (1 / 2) * -2 * Constants.staffSpace + staffLineCenterY,
      ) +
      marginOffset;
  Offset get renderOffset => Offset(symbolX, staffLineCenterY) + marginOffset;

  Offset get marginOffset =>
      Offset(timeSignature.marginLeft, 0) / layout.canvasScale;

  Rect get renderArea => timeSignature.bbox.shift(renderOffset);

  Path get numeratorRenderPath =>
      timeSignature.numeratorPath.shift(numeratorRenderOffset);

  Path get denominatorRenderPath =>
      timeSignature.denominatorPath.shift(denominatorRenderOffset);

  @override
  Rect getBounds() => renderArea;

  @override
  bool isHit(Offset position) => renderArea.contains(position);

  @override
  void render(Canvas canvas) {
    final p = Paint()..color = timeSignature.color;

    canvas
      ..drawPath(numeratorRenderPath, p)
      ..drawPath(denominatorRenderPath, p);

    if (layout.debug) {
      renderBoundingBox(canvas, renderArea);
    }
  }
}
