import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/user_model.dart';
import '../services/secure_storage_service.dart';
import '../services/user_service.dart';
import '../services/notification_service.dart';
import '../constants/route_names.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  User? _currentUser;
  File? _profileImage;
  bool _isLoading = false;
  bool _isEditing = false;
  bool _isSaving = false;
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _fetchUserFromApi();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserFromApi() async {
    setState(() => _isLoading = true);
    try {
      final userService = UserService();
      final userCache = await userService.getCurrentUser();
      if (userCache == null || userCache['id'] == null) {
        _showSnackBar('Usuário não autenticado');
        return;
      }
      final userId = userCache['id'] as int;
      final userData = await userService.getUserById(userId);
      _currentUser = User.fromJson(userData);
      _nameController.text = _currentUser!.name;
      _emailController.text = _currentUser!.email;
      _passwordController.text = '••••••••';
      await _loadProfileImage();
    } catch (e) {
      _showSnackBar('Erro ao carregar dados do usuário: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadProfileImage() async {
    try {
      final storage = SecureStorageService();
      final imagePath = await storage.getProfileImagePath();
      if (imagePath != null) {
        final file = File(imagePath);
        if (await file.exists()) {
          setState(() {
            _profileImage = file;
          });
        }
      }
    } catch (e) {
      print('Erro ao carregar imagem de perfil: $e');
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        print('Cancelando edição - restaurando valores originais');
        _nameController.text = _currentUser?.name ?? '';
      }
    });
  }

  Future<String?> _askPasswordDialog() async {
    final controller = TextEditingController();
    String? result;
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirme sua senha'),
            content: TextField(
              controller: controller,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Senha'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  result = controller.text;
                  Navigator.of(context).pop();
                },
                child: const Text('Confirmar'),
              ),
            ],
          ),
    );
    return result;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final password = await _askPasswordDialog();
    if (password == null || password.isEmpty) {
      _showSnackBar('A senha é obrigatória para confirmar a alteração.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _currentUser = _currentUser?.copyWith(
          name: _nameController.text.trim(),
        );
        _isEditing = false;
      });
      _showSnackBar('Perfil atualizado com sucesso!', isSuccess: true);
    } catch (e) {
      _showSnackBar('Erro ao atualizar perfil: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showChangeImageDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Alterar Foto'),
            content: const Text('Escolha como deseja alterar sua foto:'),
            actions: [
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  _pickImageFromCamera();
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('Câmera'),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  _pickImageFromGallery();
                },
                icon: const Icon(Icons.photo_library),
                label: const Text('Galeria'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
            ],
          ),
    );
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        await _saveAndSetProfileImage(image.path);
      }
    } catch (e) {
      _showSnackBar('Erro ao capturar imagem: $e');
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        await _saveAndSetProfileImage(image.path);
      }
    } catch (e) {
      _showSnackBar('Erro ao selecionar imagem: $e');
    }
  }

  Future<void> _saveAndSetProfileImage(String imagePath) async {
    try {
      final cacheDir = await getTemporaryDirectory();
      final userCacheDir = Directory('${cacheDir.path}/profile_images');

      if (!await userCacheDir.exists()) {
        await userCacheDir.create(recursive: true);
      }

      final fileName =
          'profile_${_currentUser?.id ?? 'user'}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImagePath = '${userCacheDir.path}/$fileName';

      final originalFile = File(imagePath);
      final savedFile = await originalFile.copy(savedImagePath);

      final storage = SecureStorageService();
      await storage.saveProfileImagePath(savedImagePath);

      setState(() {
        _profileImage = savedFile;
      });

      _showSnackBar('Foto atualizada com sucesso!', isSuccess: true);
    } catch (e) {
      _showSnackBar('Erro ao salvar imagem: $e');
    }
  }

  Future<void> _logout() async {
    try {
      await _clearProfileImageCache();

      final notificationService = NotificationService();
      await notificationService.cancelAllNotifications();

      await _userService.logout();

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          RouteNames.signIn,
          (route) => false,
        );
      }
    } catch (e) {
      _showSnackBar('Erro ao fazer logout: $e');
    }
  }

  Future<void> _clearProfileImageCache() async {
    try {
      final cacheDir = await getTemporaryDirectory();
      final userCacheDir = Directory('${cacheDir.path}/profile_images');

      if (await userCacheDir.exists()) {
        await userCacheDir.delete(recursive: true);
      }

      final storage = SecureStorageService();
      await storage.clearProfileImage();
    } catch (e) {
      print('Erro ao limpar cache de imagem de perfil: $e');
    }
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
          ),
          if (_isEditing) ...[
            IconButton(
              onPressed: _isSaving ? null : _saveProfile,
              icon:
                  _isSaving
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.check),
              tooltip: 'Salvar',
            ),
            IconButton(
              onPressed: _isSaving ? null : _toggleEditMode,
              icon: const Icon(Icons.close),
              tooltip: 'Cancelar',
            ),
          ] else
            IconButton(
              onPressed: _toggleEditMode,
              icon: const Icon(Icons.edit),
              tooltip: 'Editar perfil',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildProfileImageSection(),
              const SizedBox(height: 32),

              _buildPersonalDataSection(),
              const SizedBox(height: 24),

              _buildCredentialsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImageSection() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child:
                    _profileImage != null
                        ? Image.file(
                          _profileImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildDefaultAvatar();
                          },
                        )
                        : _buildDefaultAvatar(),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: IconButton(
                  onPressed: _showChangeImageDialog,
                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                  tooltip: 'Alterar foto',
                  iconSize: 20,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          _currentUser?.name ?? 'Usuário',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          _currentUser?.email ?? '',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Icon(
        Icons.person,
        size: 60,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildPersonalDataSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Dados Pessoais',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              enabled: _isEditing,
              decoration: const InputDecoration(
                labelText: 'Nome completo',
                hintText: 'Digite seu nome completo',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor, insira seu nome';
                }
                if (value.trim().length < 2) {
                  return 'O nome deve ter pelo menos 2 caracteres';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCredentialsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Credenciais',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Estes dados não podem ser alterados',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              enabled: false,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                prefixIcon: Icon(Icons.email_outlined),
                filled: true,
                fillColor: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              enabled: false,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Senha',
                prefixIcon: Icon(Icons.lock_outline),
                filled: true,
                fillColor: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
