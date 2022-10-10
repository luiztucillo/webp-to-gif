import 'package:webp_to_gif/models/image_model.dart';
import 'package:webp_to_gif/services/google_auth_client.dart';
import 'package:googleapis/drive/v3.dart' as drive;

class DriveApi {
  final _baseFolderName = 'app_gif_gallery_bkp_folder';
  late drive.DriveApi driveApi;
  drive.File? _baseFolder;

  DriveApi(GoogleAuthClient client) : driveApi = drive.DriveApi(client);

  Future<drive.File?> _getBaseFolder() async {

    if (_baseFolder != null) {
      return _baseFolder;
    }

    DateTime now = DateTime.now();
    String fmt = "${now.year.toString()}${now.month.toString().padLeft(2,'0')}${now.day.toString().padLeft(2,'0')}${now.hour.toString().padLeft(2,'0')}${now.minute.toString().padLeft(2,'0')}${now.second.toString().padLeft(2,'0')}";

    final file = drive.File(
        name: '$_baseFolderName-$fmt',
        mimeType: 'application/vnd.google-apps.folder',
    );

    _baseFolder = await driveApi.files.create(file);

    return _baseFolder;
  }

  Future<drive.File?> getFolder(String folderName) async {
    final file = drive.File(
      name: folderName,
      mimeType: 'application/vnd.google-apps.folder',
      parents: [(await _getBaseFolder())!.id!],
    );

    try {
      return await driveApi.files.create(file);
    } catch (e) {
      return null;
    }
  }

  Future<void> clean() async {
    driveApi.files.delete((await _getBaseFolder())!.id!);
  }

  Future<void> createFile(ImageModel img, drive.File driveFolder) async {
    final Stream<List<int>> mediaStream = img.file.openRead();
    final media = drive.Media(mediaStream, img.file.lengthSync());
    await driveApi.files.create(
      drive.File(name: img.file.path, parents: [driveFolder.id!]),
      uploadMedia: media,
    );
  }
}
