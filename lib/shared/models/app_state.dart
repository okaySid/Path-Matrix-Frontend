import 'package:flutter/foundation.dart';
import 'analysis_models.dart';
import 'package:figma_flow_analyzer/core/services/api_service.dart';

class AppState extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isAuthenticated = false;
  String? _error;
  String? _currentProjectId;
  bool _isSidebarCollapsed = false;
  bool _isSyncing = false;
  String? _syncMessage;
  bool _isLoadingAnalysis = false;

  List<AnalysisProject> _allProjects = [];
  List<AnalysisProject> _userProjects = [];
  bool _showingUserProjects = true;

  // ─────────────────────────────────────────────────────────────────────────────
  // Getters
  // ─────────────────────────────────────────────────────────────────────────────

  bool get isAuthenticated => _isAuthenticated;
  String? get error => _error;
  String? get currentProjectId => _currentProjectId;
  bool get isSidebarCollapsed => _isSidebarCollapsed;
  bool get isLoadingAnalysis => _isLoadingAnalysis;
  bool get isSyncing => _isSyncing;
  String? get syncMessage => _syncMessage;
  bool get showingUserProjects => _showingUserProjects;

  List<AnalysisProject> get projects => List.unmodifiable(
      _showingUserProjects ? _userProjects : _allProjects);

  AnalysisProject? get currentProject {
    if (_currentProjectId == null) return null;

    final fromUser = _userProjects.cast<AnalysisProject?>().firstWhere(
      (p) => p?.id == _currentProjectId,
      orElse: () => null,
    );
    final fromAll = _allProjects.cast<AnalysisProject?>().firstWhere(
      (p) => p?.id == _currentProjectId,
      orElse: () => null,
    );

    if (fromUser?.result != null) return fromUser;
    if (fromAll?.result != null) return fromAll;
    return fromUser ?? fromAll;
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Authentication
  // ─────────────────────────────────────────────────────────────────────────────

  Future<bool> login(String username, String password) async {
    try {
      final success = await _apiService.login(username, password);
      if (success) {
        _isAuthenticated = true;
        _error = null;
        await _loadAllLists();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _isAuthenticated = false;
    _currentProjectId = null;
    _allProjects = [];
    _userProjects = [];
    _apiService.clearCredentials();
    notifyListeners();
  }

  void continueAsGuest() async {
    _isAuthenticated = true;
    await _loadAllLists();
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Sign Up
  // Returns success message for green snackbar
  // Throws error message for red snackbar
  // ─────────────────────────────────────────────────────────────────────────────
  Future<String> signUp(String username, String password) async {
    try {
      return await _apiService.signUp(username, password);
    } catch (e) {
      rethrow;
    }
  }

  Future<String> changePassword(
      String currentPassword, String newPassword) async {
    try {
      // return await _apiService.changePassword(currentPassword, newPassword);
      final message = await _apiService.changePassword(currentPassword, newPassword);
      logout(); // ← add this — clears credentials and redirects to login
      return message;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> addAdmin(String username, String password) async {
    try {
      return await _apiService.addAdmin(username, password);
    } catch (e) {
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Sidebar toggle
  // ─────────────────────────────────────────────────────────────────────────────

  void switchToUserProjects() {
    _showingUserProjects = true;
    notifyListeners();
  }

  void switchToAllProjects() {
    _showingUserProjects = false;
    notifyListeners();
  }

  void toggleSidebar() {
    _isSidebarCollapsed = !_isSidebarCollapsed;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Project lists — silent refresh, no snackbar
  // ─────────────────────────────────────────────────────────────────────────────

  Future<void> _loadAllLists() async {
    try {
      final results = await Future.wait([
        _apiService.fetchUserProjects(),
        _apiService.fetchAllProjects(),
      ]);
      _userProjects = results[0];
      _allProjects = results[1];
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Add project
  // Returns the success message from Spring Boot for green snackbar
  // Throws the error message from Spring Boot for red snackbar
  // ─────────────────────────────────────────────────────────────────────────────

  Future<String> addProject(String name, String figmaUrl, String token) async {
    try {
      final message = await _apiService.addNewProject(name, figmaUrl, token);
      await _loadAllLists();
      return message; // caller shows green snackbar with this
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow; // caller shows red snackbar with this
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Delete project
  // Returns the success message from Spring Boot for green snackbar
  // ─────────────────────────────────────────────────────────────────────────────

  Future<String> deleteProject(String projectId) async {
    final index = _userProjects.indexWhere((p) => p.id == projectId);
    if (index == -1) return '';

    final project = _userProjects[index];

    try {
      final message = await _apiService.deleteProject(
          project.figmaUrl, project.versionNumber);

      if (_currentProjectId == projectId) {
        _currentProjectId = null;
      }

      await _loadAllLists();
      return message; // caller shows green snackbar with this
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow; // caller shows red snackbar with this
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Analysis Loading
  // ─────────────────────────────────────────────────────────────────────────────

  Future<void> loadAnalysis(String projectId) async {
    int index = _userProjects.indexWhere((p) => p.id == projectId);
    bool isUserProject = index != -1;

    if (!isUserProject) {
      index = _allProjects.indexWhere((p) => p.id == projectId);
    }
    if (index == -1) return;

    final project =
        isUserProject ? _userProjects[index] : _allProjects[index];

    if (project.result != null) {
      _currentProjectId = projectId;
      notifyListeners();
      return;
    }

    _currentProjectId = projectId;
    _isLoadingAnalysis = true;

    if (isUserProject) {
      _userProjects[index] = project.copyWith(status: AnalysisStatus.running);
    } else {
      _allProjects[index] = project.copyWith(status: AnalysisStatus.running);
    }
    notifyListeners();

    try {
      final result = await _apiService.fetchAnalysis(
        project.figmaUrl,
        project.versionNumber,
      );

      if (isUserProject) {
        _userProjects[index] = project.copyWith(
          status: AnalysisStatus.completed,
          result: result,
        );
      } else {
        _allProjects[index] = project.copyWith(
          status: AnalysisStatus.completed,
          result: result,
        );
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
      if (isUserProject) {
        _userProjects[index] = project.copyWith(status: AnalysisStatus.idle);
      } else {
        _allProjects[index] = project.copyWith(status: AnalysisStatus.idle);
      }
    } finally {
      _isLoadingAnalysis = false;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Sync
  // ─────────────────────────────────────────────────────────────────────────────

  Future<void> syncCurrentProject() async {
    final project = currentProject;
    if (project == null) return;

    _isSyncing = true;
    _syncMessage = null;
    notifyListeners();

    try {
      final message = await _apiService.syncProject(project.figmaUrl);
      _syncMessage = message;
      await _loadAllLists();
    } catch (e) {
      _syncMessage = e.toString();
      rethrow;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<String> fetchRawPaths(String figmaUrl, int version) async {
    return await _apiService.fetchRawPaths(figmaUrl, version);
  }
}
