import 'package:flutter/foundation.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Enums
// ─────────────────────────────────────────────────────────────────────────────

enum AnalysisStatus { idle, running, completed }

// ─────────────────────────────────────────────────────────────────────────────
// AnalysisProject
// Spring Boot sends:
// {
//   "name": "first",
//   "url": "https://www.figma.com/...",
//   "versionNumber": 5,
//   "updatedAt": "2026-05-10T02:46:34.564443"
// }
// The same project name can appear multiple times with different versionNumbers.
// We generate a unique id by combining name + versionNumber e.g. "first_v5"
// ─────────────────────────────────────────────────────────────────────────────

class AnalysisProject {
  final String id;            // Generated as "name_vX" e.g. "first_v5"
  final String name;          // Maps from "name"
  final String figmaUrl;      // Maps from "url"
  final int versionNumber;    // Maps from "versionNumber"
  final DateTime lastUpdated; // Maps from "updatedAt"
  final AnalysisStatus status;
  final AnalysisResult? result;

  const AnalysisProject({
    required this.id,
    required this.name,
    required this.figmaUrl,
    required this.versionNumber,
    required this.lastUpdated,
    required this.status,
    this.result,
  });

  factory AnalysisProject.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String;
    // final version = json['versionNumber'] as int;
    final version = int.parse(json['versionNumber'].toString());
    return AnalysisProject(
      id: '${name}_v$version',
      name: name,
      figmaUrl: json['url'] as String,
      versionNumber: version,
      lastUpdated: DateTime.parse(json['updatedAt'] as String),
      status: AnalysisStatus.idle,
      result: null,
    );
  }

  AnalysisProject copyWith({
    String? id,
    String? name,
    String? figmaUrl,
    int? versionNumber,
    DateTime? lastUpdated,
    AnalysisStatus? status,
    AnalysisResult? result,
  }) {
    return AnalysisProject(
      id: id ?? this.id,
      name: name ?? this.name,
      figmaUrl: figmaUrl ?? this.figmaUrl,
      versionNumber: versionNumber ?? this.versionNumber,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      status: status ?? this.status,
      result: result ?? this.result,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AnalysisResult
// ─────────────────────────────────────────────────────────────────────────────

class AnalysisResult {
  final List<NodeModel> nodes;
  final List<ConnectionModel> connections;
  final List<PathModel> paths;
  final List<NodeModel> orphanScreens;
  final List<NodeModel> deadEnds;
  final List<NodeModel> isolatedScreens;

  const AnalysisResult({
    required this.nodes,
    required this.connections,
    required this.paths,
    required this.orphanScreens,
    required this.deadEnds,
    required this.isolatedScreens,
  });

  int get totalScreens => nodes.length;
  int get totalConnections => connections.length;
  int get totalPaths => paths.length;
}

// ─────────────────────────────────────────────────────────────────────────────
// NodeModel
// ─────────────────────────────────────────────────────────────────────────────

class NodeModel {
  final String id;
  final String name;

  const NodeModel({required this.id, required this.name});
}

// ─────────────────────────────────────────────────────────────────────────────
// ConnectionModel
// Represents a directed edge between two nodes (source → target).
// decision holds the condition label on the arrow e.g. "Yes", "No", "Active"
// ─────────────────────────────────────────────────────────────────────────────

class ConnectionModel {
  final String sourceId;
  final String sourceName;
  final String targetId;
  final String targetName;
  final String? decision;

  const ConnectionModel({
    required this.sourceId,
    required this.sourceName,
    required this.targetId,
    required this.targetName,
    this.decision,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// PathModel
// nodes: ordered screen names in the path
// connectors: decision labels between each pair of nodes (length = nodes-1)
// ─────────────────────────────────────────────────────────────────────────────

class PathModel {
  final String id;
  final List<String> nodes;
  final List<String?> connectors;
  final int length;

  const PathModel({
    required this.id,
    required this.nodes,
    required this.connectors,
    required this.length,
  });

  // Example: "Is it wired? --No--> Battery charged? --Yes--> Fetch SIM"
  String get pathDisplay {
    if (nodes.isEmpty) return '';
    final parts = <String>[nodes[0]];
    for (int i = 0; i < connectors.length && i < nodes.length - 1; i++) {
      final connector = connectors[i];
      final label = (connector != null && connector.isNotEmpty)
          ? ' --$connector--> '
          : ' → ';
      parts.add(label);
      parts.add(nodes[i + 1]);
    }
    return parts.join('');
  }
}