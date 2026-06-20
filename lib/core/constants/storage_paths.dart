abstract final class StoragePaths {
  static String userRoot(String userId) => 'users/$userId';

  static String profileImages(String userId) => '${userRoot(userId)}/profile';

  static String diseaseImages(String userId) =>
      '${userRoot(userId)}/disease_reports';

  static String cropImages(String userId) => '${userRoot(userId)}/crops';

  static String cropImageUploads(String userId) =>
      '${userRoot(userId)}/cropImages';
}
