import 'package:flutter/material.dart';
import 'package:qlutter/src/common/widget/inherited_dependencies.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Dependencies
class Dependencies {
  Dependencies();

  /// The state from the closest instance of this class.
  factory Dependencies.of(BuildContext context) =>
      InheritedDependencies.of(context);

  // / App metadata
  // late final AppMetadata metadata;

  /// Shared preferences
  late final SharedPreferences sharedPreferences;

  /// Database
  // late final Database database;

  /// API Client
  // late final Dio dio;

  /// Levels repository
  // late final IInvoicesRepository invoicesRepository;

  /// Organizations repository
  // late final IOrganizationsRepository organizationsRepository;
}
