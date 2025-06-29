# Serviços da API

Este diretório contém os serviços responsáveis pela comunicação com a API RESTful do projeto.

## Serviços Disponíveis

### ApiService
Serviço base para comunicação HTTP com a API. Fornece métodos para GET, POST, PUT, PATCH e DELETE.

**Características:**
- Configuração automática de headers
- Tratamento de erros padronizado
- Timeout configurável
- Logging de requisições e respostas

### UserService
Gerencia operações relacionadas a usuários.

**Endpoints utilizados:**
- `POST /register` - Registro de usuário
- `POST /login` - Login de usuário
- `GET /api/users` - Listar todos os usuários
- `GET /api/users/{id}` - Buscar usuário por ID
- `PUT /api/users/{id}` - Atualizar usuário
- `DELETE /api/users/{id}` - Deletar usuário
- `GET /api/users/{id}/categories` - Categorias do usuário
- `GET /api/users/{id}/tasks` - Tarefas do usuário

### TaskService
Gerencia operações relacionadas a tarefas.

**Endpoints utilizados:**
- `GET /api/tasks?userId={id}` - Listar tarefas por usuário
- `GET /api/tasks/{id}` - Buscar tarefa por ID
- `POST /api/tasks` - Criar nova tarefa
- `PUT /api/tasks/{id}` - Atualizar tarefa
- `DELETE /api/tasks/{id}` - Deletar tarefa
- `PATCH /api/tasks/{id}/toggle` - Alternar status da tarefa

### CategoryService
Gerencia operações relacionadas a categorias.

**Endpoints utilizados:**
- `GET /api/categories?userId={id}` - Listar categorias por usuário
- `GET /api/categories/{id}` - Buscar categoria por ID
- `POST /api/categories` - Criar nova categoria
- `PUT /api/categories/{id}` - Atualizar categoria
- `DELETE /api/categories/{id}` - Deletar categoria
- `GET /api/categories/{id}/tasks` - Tarefas de uma categoria

### LocationService
Gerencia operações de localização do dispositivo.

**Funcionalidades:**
- Verificação de permissões de localização
- Obtenção da posição atual do dispositivo
- Configuração de precisão de localização

### SecureStorageService
Gerencia o armazenamento seguro de dados do usuário.

**Funcionalidades:**
- Armazenamento de dados do usuário logado
- Gerenciamento de imagem de perfil
- Verificação de status de login
- Limpeza de dados ao logout

## Mudanças Implementadas

### Remoção de Tags
- Removidas todas as referências a tags, conforme especificação do projeto
- Não há mais endpoints ou serviços relacionados a tags

### Autenticação
- Removida autenticação por token
- Os dados do usuário são armazenados localmente após login
- Não há necessidade de enviar tokens nas requisições

### Endpoints Atualizados
- Todos os endpoints foram atualizados para corresponder à nova API
- Adicionado suporte a query parameters para filtrar por usuário
- Implementado endpoint de toggle para tarefas

### Tratamento de Erros
- Melhorado o tratamento de erros com mensagens mais específicas
- Adicionados códigos de status HTTP específicos
- Tratamento padronizado de exceções DioException

## Como Usar

```dart
// Exemplo de uso do UserService
final userService = UserService();
final user = await userService.login('email@example.com', 'password');

// Exemplo de uso do TaskService
final taskService = TaskService();
final tasks = await taskService.getTasks(userId: user['id']);

// Exemplo de uso do CategoryService
final categoryService = CategoryService();
final categories = await categoryService.getCategories(userId: user['id']);
```

## Configuração

Certifique-se de que o arquivo `.env` contenha a variável `API_BASE_URL` apontando para o servidor da API:

```env
API_BASE_URL=http://localhost:8080
``` 