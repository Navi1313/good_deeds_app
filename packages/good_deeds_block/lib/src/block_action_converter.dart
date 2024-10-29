
import 'package:good_deeds_block/good_deeds_block.dart';
import 'package:json_annotation/json_annotation.dart';

/// {@template block_action_converter}
/// A [JsonConverter] that supports (de)serializing a [BlockAction].
/// {@endtemplate}
class BlockActionConverter
    implements JsonConverter<BlockAction?, Map<String, dynamic>?> {
  /// {@macro block_action_converter}
  const BlockActionConverter();

  @override
  Map<String, dynamic>? toJson(BlockAction? blockAction) =>
      blockAction?.toJson();

  @override
  BlockAction? fromJson(Object? jsonString) => jsonString != null
      ? BlockAction.fromJson(jsonString as Map<String, dynamic>)
      : null;
}
