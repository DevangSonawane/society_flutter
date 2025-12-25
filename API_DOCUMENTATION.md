# SCASA Flutter App - API Documentation

## Overview

The SCASA app uses Supabase as its backend, which provides:
- Authentication
- Database (PostgreSQL)
- Real-time subscriptions
- Storage

## Base Configuration

- **Supabase URL**: Configured via `SUPABASE_URL` in `.env`
- **Anon Key**: Configured via `SUPABASE_ANON_KEY` in `.env`

## Authentication

### Login

```dart
await Supabase.instance.client.auth.signInWithPassword(
  email: email,
  password: password,
);
```

### Logout

```dart
await Supabase.instance.client.auth.signOut();
```

### Current User

```dart
final user = Supabase.instance.client.auth.currentUser;
```

## Database Tables

### Users Table

**Table**: `users`

**Columns**:
- `user_id` (UUID, Primary Key)
- `user_name` (Text)
- `email` (Text, Unique)
- `mobile_number` (Text)
- `password_hash` (Text)
- `role` (Text: 'admin', 'receptionist', 'user')
- `flat_no` (Text, Nullable)
- `created_at` (Timestamp)
- `updated_at` (Timestamp)

**Operations**:
```dart
// Get all users
await SupabaseService.client.from('users').select();

// Get user by ID
await SupabaseService.client.from('users').select().eq('user_id', id).single();

// Create user
await SupabaseService.client.from('users').insert(data);

// Update user
await SupabaseService.client.from('users').update(data).eq('user_id', id);

// Delete user
await SupabaseService.client.from('users').delete().eq('user_id', id);
```

### Residents Table

**Table**: `residents`

**Columns**:
- `id` (UUID, Primary Key)
- `owner_name` (Text)
- `flat_number` (Text)
- `email` (Text)
- `mobile` (Text)
- `status` (Text: 'active', 'inactive')
- `type` (Text: 'owner', 'tenant')
- `residents` (JSONB Array)
- `vehicles` (JSONB Array)
- `documents` (JSONB Array)
- `created_at` (Timestamp)
- `updated_at` (Timestamp)

**Operations**:
```dart
// Get all residents
await SupabaseService.client.from('residents').select().order('created_at', ascending: false);

// Get resident by ID
await SupabaseService.client.from('residents').select().eq('id', id).single();

// Create resident
await SupabaseService.client.from('residents').insert(data);

// Update resident
await SupabaseService.client.from('residents').update(data).eq('id', id);

// Delete resident
await SupabaseService.client.from('residents').delete().eq('id', id);
```

### Complaints Table

**Table**: `complaints`

**Columns**:
- `id` (UUID, Primary Key)
- `title` (Text)
- `description` (Text)
- `status` (Text: 'open', 'in_progress', 'resolved', 'closed')
- `priority` (Text: 'low', 'medium', 'high')
- `resident_id` (UUID, Foreign Key)
- `created_at` (Timestamp)
- `updated_at` (Timestamp)

**Operations**: Similar to residents table

### Permissions Table

**Table**: `permissions`

**Columns**:
- `id` (UUID, Primary Key)
- `resident_id` (UUID, Foreign Key)
- `permission_type` (Text)
- `description` (Text)
- `status` (Text: 'pending', 'approved', 'rejected')
- `start_date` (Date)
- `end_date` (Date, Nullable)
- `created_at` (Timestamp)
- `updated_at` (Timestamp)

### Vendors Table

**Table**: `vendors`

**Columns**:
- `id` (UUID, Primary Key)
- `name` (Text)
- `contact_person` (Text)
- `email` (Text)
- `phone` (Text)
- `address` (Text)
- `services` (Text Array)
- `status` (Text: 'active', 'inactive')
- `created_at` (Timestamp)
- `updated_at` (Timestamp)

### Helpers Table

**Table**: `helpers`

**Columns**:
- `id` (UUID, Primary Key)
- `name` (Text)
- `gender` (Text: 'male', 'female')
- `phone` (Text)
- `address` (Text)
- `role` (Text)
- `status` (Text: 'active', 'inactive')
- `created_at` (Timestamp)
- `updated_at` (Timestamp)

## Error Handling

All repository methods use `SupabaseService.handleError()` for consistent error handling:

```dart
try {
  final response = await SupabaseService.client.from('table').select();
  return processResponse(response);
} catch (e) {
  SupabaseService.handleError(e, 'context');
  return defaultValue;
}
```

## Real-time Subscriptions

Supabase supports real-time subscriptions:

```dart
final subscription = SupabaseService.client
  .from('residents')
  .stream(primaryKey: ['id'])
  .listen((data) {
    // Handle real-time updates
  });
```

## Row Level Security (RLS)

Ensure RLS policies are set up in Supabase:

- Users can only read their own data (for resident role)
- Admins can read/write all data
- Receptionists have limited write access

## Best Practices

1. **Always use SupabaseService**: Don't access Supabase client directly
2. **Handle errors**: Always wrap API calls in try-catch
3. **Use caching**: Cache frequently accessed data
4. **Pagination**: Use `.range()` for large datasets
5. **Filtering**: Use `.eq()`, `.like()`, etc. for queries
6. **Ordering**: Use `.order()` for sorted results

## Example Repository Pattern

```dart
class MyRepository {
  final String _table = 'my_table';

  Future<List<MyModel>> getAll() async {
    try {
      final response = await SupabaseService.client
          .from(_table)
          .select()
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((json) => MyModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      SupabaseService.handleError(e, 'getAll');
      return [];
    }
  }
}
```

## Testing

Mock Supabase responses in tests:

```dart
when(mockSupabase.from('table').select())
    .thenAnswer((_) async => mockData);
```

## Security Notes

- Never expose service role key in client
- Use RLS policies for data access control
- Validate all inputs before sending to API
- Use HTTPS only in production

