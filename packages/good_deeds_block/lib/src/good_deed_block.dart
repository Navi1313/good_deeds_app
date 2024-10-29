import 'package:good_deeds_block/good_deeds_block.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

/// {@template insta_block}
/// A reusable Instagram Block which represents a content-based component.
/// {@endtemplate}
@immutable
@JsonSerializable()
abstract class GoodDeedBlock {
  /// {@macro insta_bloc}
  const GoodDeedBlock({required this.type});

  /// The block type key used to identify the type of block/metadata.
  final String type;

  /// Converts current instance to a `Map<String, dynamic>`.
  Map<String, dynamic> toJson();

  // ignore: comment_references
  /// Deserialize [json] into a [InstaBlock] instance.
  // ignore: comment_references
  /// Returns [UnknownBlock] when the [json] is not recognized;
  static GoodDeedBlock fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    switch (type) {
      case PostLargeBlock.identifier:
        return PostLargeBlock.fromJson(json);
    }
    return UnknownBlock();
  }
}
