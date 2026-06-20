import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../shared/models/analysis_models.dart';
import '../constants/env.dart';
import 'api_exception.dart';

class ApiService {
  static const String _baseUrl = Env.baseUrl;

  String? _username;
  String? _password;

  void setCredentials(String username, String password) {
    _username = username;
    _password = password;
  }

  void clearCredentials() {
    _username = null;
    _password = null;
  }

  Map<String, String> get _authHeaders {
    if (_username == null || _password == null) return {};
    final credentials = '$_username:$_password';
    final encoded = base64Encode(utf8.encode(credentials));
    return {
      'Authorization': 'Basic $encoded',
      'Content-Type': 'application/json',
    };
  }

  Map<String, String> get _authHeadersForSignUp {
   
    return {
      'Content-Type': 'application/json',
    };
  }

  
  Map<String, dynamic> _parseWrapper(http.Response response) {
  if (response.statusCode == 401) {
    throw ApiException(
      message: 'Unauthorized. Please log in again.',
      statusCode: 401,
    );
  }

  if (response.statusCode != 200 && response.statusCode != 201) {
    // Try to read message from response body
    try {
      final map = jsonDecode(response.body) as Map<String, dynamic>;
      throw ApiException(
        message: map['message'] ?? 'Request failed.',
        statusCode: response.statusCode,
        body: map,
      );
    } catch (e) {
      if (e is ApiException) rethrow; // don't wrap ApiException again
      throw ApiException(
        message: response.body.isNotEmpty
            ? response.body
            : 'Request failed. Status: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }

  final Map<String, dynamic> map = jsonDecode(response.body);
  final success = map['success'] as bool? ?? false;

  if (!success) {
    throw ApiException(
      message: map['message'] ?? 'Operation failed',
      statusCode: response.statusCode,
      body: map,
    );
  }

  return map;
}
  // Map<String, dynamic> _parseWrapper(http.Response response) {
  //   if (response.statusCode == 401) {
  //     throw Exception('Unauthorized. Please log in again.');
  //   }

  //   if (response.statusCode != 200 && response.statusCode != 201) {
  //     // Non-success HTTP status — try to parse body for message
  //     try {
  //       final map = jsonDecode(response.body) as Map<String, dynamic>;
  //       throw Exception(map['message'] ?? 'Request failed. Status: ${response.statusCode}');
  //     } catch (_) {
  //       throw Exception(response.body.isNotEmpty
  //           ? response.body
  //           : 'Request failed. Status: ${response.statusCode}');
  //     }
  //   }

  //   // HTTP 200/201 — parse the wrapper
  //   final Map<String, dynamic> map = jsonDecode(response.body);
  //   final success = map['success'] as bool? ?? false;

  //   if (!success) {
  //     // success: false — throw the message so UI can show red snackbar
  //     throw ApiException(
  //       message: map['message'],
  //       statusCode: response.statusCode ?? 400,
  //       // body: response.data,
  //     );
  //   }

  //   return map; // success: true — caller reads map['data'] and map['message']
  // }

  // ─────────────────────────────────────────────────────────────────────────────
  // Login
  // POST /auth/login
  // ─────────────────────────────────────────────────────────────────────────────
  Future<bool> login(String username, String password) async {
    final url = Uri.parse('$_baseUrl/auth/login');
    final credentials = '$username:$password';
    final encoded = base64Encode(utf8.encode(credentials));

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Basic $encoded',
        'Content-Type': 'text/plain',
      },
    );

    if (response.statusCode == 200) {
      setCredentials(username, password);
      return true;
    } else if (response.statusCode == 401) {
      throw Exception('Invalid username or password');
    } else {
      throw Exception('Login failed. Status: ${response.statusCode}');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Change Password
  // POST /api/update/password
  // ─────────────────────────────────────────────────────────────────────────────
  Future<String> changePassword(
      String currentPassword, String newPassword) async {
    final url = Uri.parse('$_baseUrl/api/update/password');
    final response = await http.post(
      url,
      headers: _authHeaders,
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );
    final map = _parseWrapper(response);
    return map['message'] as String? ?? 'Password updated successfully';
  }


Future<String> fetchRawPaths(String figmaUrl, int version) async {
    final url = Uri.parse('$_baseUrl/api/paths').replace(
      queryParameters: {
        'url': figmaUrl,
        'version': version.toString(),
      },
    );
    final response = await http.get(url, headers: _authHeaders);

    if (response.statusCode == 200) {
      // Return the raw body string — no parsing, no transformation
      return response.body;
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please log in again.');
    } else {
      throw Exception('Export failed. Status: ${response.statusCode}');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Add Admin
  // POST /api/add/admin
  // Only admins can successfully call this — backend enforces it
  // ─────────────────────────────────────────────────────────────────────────────
  Future<String> addAdmin(String username, String password) async {
    final url = Uri.parse('$_baseUrl/api/add/admin');
    final response = await http.post(
      url,
      headers: _authHeaders,
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );
    final map = _parseWrapper(response);
    return map['message'] as String? ?? 'Admin created successfully';
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Sign Up
  // POST /api/add/user
  // Returns success message for green snackbar
  // Throws error message for red snackbar
  // ─────────────────────────────────────────────────────────────────────────────
  Future<String> signUp(String username, String password) async {
    final url = Uri.parse('$_baseUrl/api/add/user');
    final response = await http.post(
      url,
      headers: _authHeadersForSignUp,
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );
    final map = _parseWrapper(response);
    return map['message'] as String? ?? 'Account created successfully';
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Fetch projects owned by the logged-in user
  // GET /api/user/project
  // No snackbar — silent fetch on login/refresh
  // ─────────────────────────────────────────────────────────────────────────────
  Future<List<AnalysisProject>> fetchUserProjects() async {
    final url = Uri.parse('$_baseUrl/api/user/project');
    final response = await http.get(url, headers: _authHeaders);
    final map = _parseWrapper(response);
    final List<dynamic> jsonList = map['data'] as List<dynamic>;
    return jsonList.map((json) => AnalysisProject.fromJson(json)).toList();
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Fetch all projects in the database
  // GET /api/get/project
  // No snackbar — silent fetch on login/refresh
  // ─────────────────────────────────────────────────────────────────────────────
  Future<List<AnalysisProject>> fetchAllProjects() async {
    final url = Uri.parse('$_baseUrl/api/get/project');
    final response = await http.get(url, headers: _authHeaders);
    final map = _parseWrapper(response);
    final List<dynamic> jsonList = map['data'] as List<dynamic>;
    return jsonList.map((json) => AnalysisProject.fromJson(json)).toList();
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Fetch analysis for a specific project version
  // GET /api/paths?url=...&version=...
  // No snackbar — result shown directly in workspace
  // ─────────────────────────────────────────────────────────────────────────────
  Future<AnalysisResult> fetchAnalysis(String figmaUrl, int version) async {
    final url = Uri.parse('$_baseUrl/api/paths').replace(
      queryParameters: {
        'url': figmaUrl,
        'version': version.toString(),
      },
    );
    final response = await http.get(url, headers: _authHeaders);
    final map = _parseWrapper(response);
    final List<dynamic> rawPaths = map['data'] as List<dynamic>;
    return _parseAnalysisResult(rawPaths);
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Add new project
  // POST /api/add/url
  // Returns message string for green snackbar on success
  // Throws message string for red snackbar on failure
  // ─────────────────────────────────────────────────────────────────────────────
  Future<String> addNewProject(String name, String figmaUrl, String token) async {
    final url = Uri.parse('$_baseUrl/api/add/url');
    final response = await http.post(
      url,
      headers: _authHeaders,
      body: jsonEncode({
        'name': name,
        'url': figmaUrl,
        'token': token,
        'version': 1,
      }),
    );
    final map = _parseWrapper(response); // throws if success: false
    return map['message'] as String? ?? 'Project added successfully';
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Delete project
  // DELETE /api?url=...&version=...
  // Returns message string for green snackbar on success
  // ─────────────────────────────────────────────────────────────────────────────
  Future<String> deleteProject(String figmaUrl, int version) async {
    final url = Uri.parse('$_baseUrl/api').replace(
      queryParameters: {
        'url': figmaUrl,
        'version': version.toString(),
      },
    );
    final response = await http.delete(url, headers: _authHeaders);
    final map = _parseWrapper(response);
    return map['message'] as String? ?? 'Project deleted successfully';
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Sync project to latest Figma version
  // POST /api/sync?url=...
  // Returns message string for green snackbar on success
  // ─────────────────────────────────────────────────────────────────────────────
  Future<String> syncProject(String figmaUrl) async {
    final url = Uri.parse('$_baseUrl/api/sync').replace(
      queryParameters: {'url': figmaUrl},
    );
    final response = await http.post(url, headers: _authHeaders);
    final map = _parseWrapper(response);
    return map['message'] as String? ?? 'Sync completed';
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Parse raw path steps into AnalysisResult
  // ─────────────────────────────────────────────────────────────────────────────
  AnalysisResult _parseAnalysisResult(List<dynamic> rawPaths) {
    final nodeNames = <String>{};
    final connections = <ConnectionModel>[];
    final paths = <PathModel>[];

    for (int pathIndex = 0; pathIndex < rawPaths.length; pathIndex++) {
      final List<dynamic> steps = rawPaths[pathIndex];
      final pathNodeNames = <String>[];
      final pathConnectors = <String?>[];

      for (int stepIndex = 0; stepIndex < steps.length; stepIndex++) {
        final step = steps[stepIndex] as Map<String, dynamic>;
        final fromNode = step['fromNode'] as String;
        final toNode = step['toNode'] as String;
        final decision = step['decision'] as String? ?? '';

        nodeNames.add(fromNode);
        nodeNames.add(toNode);

        connections.add(ConnectionModel(
          sourceId: fromNode,
          sourceName: fromNode,
          targetId: toNode,
          targetName: toNode,
          decision: decision.isNotEmpty ? decision : null,
        ));

        if (stepIndex == 0) pathNodeNames.add(fromNode);
        pathNodeNames.add(toNode);
        pathConnectors.add(decision.isNotEmpty ? decision : null);
      }

      final dedupedNodes = <String>[];
      final dedupedConnectors = <String?>[];

      for (int i = 0; i < pathNodeNames.length; i++) {
        final node = pathNodeNames[i];
        if (dedupedNodes.isEmpty || dedupedNodes.last != node) {
          dedupedNodes.add(node);
          if (i < pathConnectors.length) {
            dedupedConnectors.add(pathConnectors[i]);
          }
        }
      }

      while (dedupedConnectors.length >= dedupedNodes.length) {
        dedupedConnectors.removeLast();
      }
      while (dedupedConnectors.length < dedupedNodes.length - 1) {
        dedupedConnectors.add(null);
      }

      paths.add(PathModel(
        id: 'path_${pathIndex + 1}',
        nodes: dedupedNodes,
        connectors: dedupedConnectors,
        length: dedupedNodes.length,
      ));
    }

    final nodes =
        nodeNames.map((name) => NodeModel(id: name, name: name)).toList();

    final uniqueConnections = <String, ConnectionModel>{};
    for (final conn in connections) {
      final key = '${conn.sourceId}->${conn.targetId}';
      uniqueConnections[key] = conn;
    }

    final allTargets =
        uniqueConnections.values.map((c) => c.targetId).toSet();
    final orphans =
        nodes.where((n) => !allTargets.contains(n.id)).toList();

    final allSources =
        uniqueConnections.values.map((c) => c.sourceId).toSet();
    final deadEnds =
        nodes.where((n) => !allSources.contains(n.id)).toList();

    final isolated = nodes
        .where((n) =>
            !allSources.contains(n.id) && !allTargets.contains(n.id))
        .toList();

    return AnalysisResult(
      nodes: nodes,
      connections: uniqueConnections.values.toList(),
      paths: paths,
      orphanScreens: orphans,
      deadEnds: deadEnds,
      isolatedScreens: isolated,
    );
  }
}
