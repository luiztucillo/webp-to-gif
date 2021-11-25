import 'package:webp_to_gif/models/image_model.dart';
import 'package:webp_to_gif/repositories/folder_repository.dart';
import 'package:webp_to_gif/repositories/image_repository.dart';
import 'package:webp_to_gif/services/google_auth_client.dart';
import 'package:googleapis/drive/v3.dart' as drive;

class DriveApi {
  final _baseFolderName = 'app_gif_gallery_bkp_folder';
  late drive.DriveApi driveApi;
  drive.File? _baseFolder;

  DriveApi(GoogleAuthClient client) : driveApi = drive.DriveApi(client);

  Future<drive.File?> _getBaseFolder() async {
    if (_baseFolder == null) {
      final result = await driveApi.files.list(
        q: "mimeType='application/vnd.google-apps.folder' AND name='$_baseFolderName'",
        spaces: 'drive',
        corpora: 'user',
      );

      if (result.files == null || result.files!.isEmpty) {
        final file = drive.File(
            name: _baseFolderName,
            mimeType: 'application/vnd.google-apps.folder');
        _baseFolder = await driveApi.files.create(file);
      } else {
        _baseFolder = result.files!.first;
      }
    }

    return _baseFolder;
  }

  Future<drive.File> _getFolder(String folderName) async {
    final result = await driveApi.files.list(
      q: "mimeType='application/vnd.google-apps.folder' AND name='$folderName'",
      spaces: 'drive',
      corpora: 'user',
    );

    if (result.files == null || result.files!.isEmpty) {
      final file = drive.File(
        name: folderName,
        mimeType: 'application/vnd.google-apps.folder',
        parents: [(await _getBaseFolder())!.id!],
      );
      return await driveApi.files.create(file);
    }

    for (var fd in result.files!) {
      return fd;
    }

    return result.files!.first;
  }

  Future<void> sync() async {
    final folders = await FolderRepository().list();
    driveApi.files.delete((await _getBaseFolder())!.id!);
    _baseFolder = null;

    for (var fd in folders) {
      final driveFolder = await _getFolder(fd.path);
      final files = await ImageRepository().list(fd);
      for (ImageModel img in files) {
        final Stream<List<int>> mediaStream = img.file.openRead();
        final media = drive.Media(mediaStream, img.file.lengthSync());
        await driveApi.files.create(
          drive.File(name: img.file.path, parents: [driveFolder.id!]),
          uploadMedia: media,
        );
      }
    }
  }
}
