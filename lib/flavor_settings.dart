class FlavorSettings {
     late String apiBaseUrl;
     static final FlavorSettings _instance = FlavorSettings._internal();

     factory FlavorSettings() {
          return _instance;
     }

     FlavorSettings._internal() {
          // Initialize default values here if needed
          // For example:
          // apiBaseUrl = 'default_value';
     }

     void initializeApiBaseUrl(String baseUrl) {
          apiBaseUrl = baseUrl;
     }
}