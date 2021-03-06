// Copyright (c) 2014, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

/**
 * A library to provide a common interface for and abstraction around source
 * control management (SCM) systems.
 */
library spark.scm;

import 'dart:async';

import 'workspace.dart';

final List<ScmProvider> _providers = [new GitScmProvider()];

/**
 * Returns `true` if the given project is under SCM.
 */
bool isUnderScm(Project project) =>
    _providers.any((provider) => provider.isUnderScm(project));

/**
 * Return all the SCM providers known to the system.
 */
List<ScmProvider> getProviders() => _providers;

/**
 * Return the [ScmProvider] cooresponding to the given type. The only valid
 * value for [type] currently is `git`.
 */
ScmProvider getProviderType(String type) =>
    _providers.firstWhere((p) => p.id == type, orElse: () => null);

/**
 * Returns the [ScmProjectOperations] for the given project, or `null` if the
 * project is not under SCM.
 */
ScmProjectOperations getScmOperationsFor(Project project) {
  for (ScmProvider provider in _providers) {
    if (provider.isUnderScm(project)) {
      return provider.getOperationsFor(project);
    }
  }

  return null;
}

/**
 * A abstract implementation of a SCM provider. This provides a
 * lowest-common-denominator interface. In some cases, it may be necessary to
 * cast to a particular [ScmProvider] implementation in order to get the full
 * range of functionality.
 */
abstract class ScmProvider {
  /**
   * The `id` of this provider, e.g. `git`.
   */
  String get id;

  /**
   * Returns whether the SCM provider is managing the given project. The
   * contract for this method is that it should return quickly.
   */
  bool isUnderScm(Project project);

  /**
   * Return the [ScmProjectOperations] cooresponding to the given [Project].
   */
  ScmProjectOperations getOperationsFor(Project project);
}

/**
 * A class that exports various SCM operations to act on the given [Project].
 */
abstract class ScmProjectOperations {
  final ScmProvider provider;
  final Project project;

  ScmProjectOperations(this.provider, this.project);

  /**
   * Return the SCM status for the given file or folder.
   */
  Future<FileStatus> getFileStatus(Resource resource);
}

/**
 * The possible SCM file statuses (`committed`, `dirty`, or `unknown`).
 */
class FileStatus {
  final FileStatus COMITTED = new FileStatus._('comitted');
  final FileStatus DIRTY = new FileStatus._('dirty');
  final FileStatus UNKNOWN = new FileStatus._('unknown');

  final String _status;

  FileStatus._(this._status);

  String toString() => _status;
}

/**
 * The Git SCM provider.
 */
class GitScmProvider extends ScmProvider {
  Map<Project, ScmProjectOperations> _operations = {};

  GitScmProvider();

  String get id => 'git';

  bool isUnderScm(Project project) {
    return project.getChild('.git') is Folder;
  }

  ScmProjectOperations getOperationsFor(Project project) {
    if (_operations[project] == null) {
      if (isUnderScm(project)) {
        _operations[project] = new GitScmProjectOperations(this, project);
      }
    }

    return _operations[project];
  }
}

/**
 * The Git SCM project operations implementation.
 */
class GitScmProjectOperations extends ScmProjectOperations {

  GitScmProjectOperations(ScmProvider provider, Project project) :
    super(provider, project);

  Future<FileStatus> getFileStatus(Resource resource) {
    // TODO: how to retrieve the git file status?
    return new Future.error('unimplemented - getFileStatus()');
  }
}
