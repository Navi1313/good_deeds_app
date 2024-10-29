
import 'package:good_deeds_block/good_deeds_block.dart';
import 'package:json_annotation/json_annotation.dart';

/// {@template insta_blocks_converter}
/// A [JsonConverter] that supports (de)serializing a `List<InstaBlock>`.
/// {@endtemplate}
class GoodDeedBlocksConverter
    implements JsonConverter<List<GoodDeedBlock>, List<Map<String, dynamic>>> {
  /// {@macro insta_blocks_converter}
  const GoodDeedBlocksConverter();

  @override
  List<GoodDeedBlock> fromJson(List<Map<String, dynamic>> jsonString) {
    return jsonString
        .map((dynamic e) => GoodDeedBlock.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  List<Map<String, dynamic>> toJson(List<GoodDeedBlock> blocks) {
    return blocks.map((b) => b.toJson()).toList();
  }
}
