# Changelog

## [1.0.0] - 2025-01-XX

### Adicionado
- Suporte completo à nova API RESTful
- Endpoints atualizados para corresponder à nova estrutura
- Tratamento de erros melhorado com códigos de status específicos
- Documentação completa dos serviços

### Alterado
- **ApiService**: Adicionado método PATCH e melhorado tratamento de erros
- **UserService**: 
  - Endpoints atualizados para `/register` e `/login`
  - Removida autenticação por token
  - Adicionados métodos para gerenciar usuários
  - Adicionados métodos para buscar categorias e tarefas por usuário
- **TaskService**:
  - Endpoints atualizados para usar query parameters
  - Adicionado método `toggleTask` usando PATCH
  - Retorno tipado para Map<String, dynamic>
- **CategoryService**:
  - Endpoints atualizados para usar query parameters
  - Adicionado método para buscar tarefas por categoria
  - Retorno tipado para Map<String, dynamic>
- **Task Model**:
  - Removido campo `category` (string)
  - Adicionado campo `categoryId` (int?)
  - Adicionado campo `userId` (int)
- **Category Model**:
  - Adicionado campo `userId` (int)
  - Adicionado campo `createdAt` (DateTime)
  - Adicionado campo `taskCount` (int?)
  - Adicionado método `copyWith`

### Removido
- Todas as referências a tags (não utilizadas no projeto)
- Autenticação por token
- Endpoints relacionados a tags
- Campo `category` string do modelo Task

### Quebrado
- **TaskDialog**: Agora requer `userId` como parâmetro obrigatório
- **HomePage**: Removidas referências a `task.category`
- Criação de Task agora requer `userId`

### Técnico
- Melhorado tratamento de exceções DioException
- Adicionados códigos de status HTTP específicos
- Padronização de retornos dos serviços
- Documentação atualizada com exemplos de uso

## Configuração Necessária

Certifique-se de configurar a variável de ambiente `API_BASE_URL` no arquivo `.env`:

```env
API_BASE_URL=http://localhost:8080
```

## Migração

Para migrar de versões anteriores:

1. Atualize todas as chamadas para `TaskDialog` incluindo o parâmetro `userId`
2. Remova referências a `task.category` em favor de `task.categoryId`
3. Atualize a criação de objetos Task para incluir `userId`
4. Configure a variável de ambiente `API_BASE_URL` 