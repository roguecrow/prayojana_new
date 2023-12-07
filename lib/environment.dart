class Environment {
  final String secret;
  Environment(this.secret);
}
class EnvironmentValue {
  static final Environment development = Environment('dev');
  static final Environment production = Environment('prod');
  static final Environment staging = Environment('stage');

}