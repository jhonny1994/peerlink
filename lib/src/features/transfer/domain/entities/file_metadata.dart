import 'package:freezed_annotation/freezed_annotation.dart';

part 'file_metadata.freezed.dart';
part 'file_metadata.g.dart';

/// Metadata about a file being transferred
@freezed
abstract class FileMetadata with _$FileMetadata {
  const factory FileMetadata({
    required String name,
    required int size,
    required String mimeType,
    required String hash,
  }) = _FileMetadata;

  factory FileMetadata.fromJson(Map<String, dynamic> json) =>
      _$FileMetadataFromJson(json);
}
