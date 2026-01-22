class ApiConstants {
  // For Genymotion emulator, use 10.0.3.2 to access host machine
  static String get baseUrl {
    // return 'https://rentify-laravel-ee2c76906f53.herokuapp.com/api';
    return 'http://10.0.3.2:8005/api';
  }

  static String get propertiesEndpoint => '$baseUrl/properties';
}
