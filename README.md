# Blog Demo API

A Ruby on Rails API application for managing blog posts with user authentication and authorization.

## Features

- 🔐 **JWT Authentication** - Secure user registration and login
- 👤 **Session Management** - Login/logout with token-based authentication
- 📝 **Blog Posts CRUD** - Create, read, update, and delete blog posts
- 🛡️ **Authorization** - Role-based access control with Pundit
- 🧪 **Comprehensive Testing** - Full RSpec test suite with 105+ tests
- 🐘 **PostgreSQL Database** - Production-ready database setup

## Tech Stack

- **Ruby** 3.3.0+
- **Rails** 8.0.2
- **PostgreSQL** 14+
- **JWT** for authentication
- **Pundit** for authorization
- **RSpec** for testing
- **FactoryBot** for test data
- **BCrypt** for password hashing

## Prerequisites

Make sure you have the following installed on your system:

- Ruby 3.3.0 or higher
- PostgreSQL 14 or higher
- Bundler gem
- Git

## Installation

### 1. Clone the Repository

```bash
git clone <repository-url>
cd blog_demo
```

### 2. Install Ruby Dependencies

```bash
# Install bundler if you don't have it
gem install bundler

# Install all gems
bundle install
```

### 3. Database Setup

#### Configure Database

Make sure PostgreSQL is running on your system. Update `config/database.yml` if needed with your PostgreSQL credentials.

#### Create and Setup Database

```bash
# Create databases
rails db:create

# Run migrations
rails db:migrate

# Seed the database (optional)
rails db:seed
```

### 4. Generate Credentials

```bash
# Generate Rails credentials (if not already present)
EDITOR="code --wait" rails credentials:edit
```

Make sure your `config/credentials.yml.enc` contains a `secret_key_base`.

## Running the Application

### Start the Server

```bash
# Development server
rails server

# Or using the shorthand
rails s

# Server will start on http://localhost:3000
```

### Background Jobs (if applicable)

```bash
# Start background job processing
rails jobs:work
```

## API Endpoints

### Authentication

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/register` | Register a new user |
| POST | `/login` | Login user (legacy endpoint) |
| POST | `/sessions` | Login user |
| DELETE | `/sessions` | Logout user |
| GET | `/sessions` | Get current user info |

### Blog Posts

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/posts` | List all posts | ✅ |
| GET | `/posts/:id` | Get specific post | ✅ |
| POST | `/posts` | Create new post | ✅ |
| PUT/PATCH | `/posts/:id` | Update post | ✅ |
| DELETE | `/posts/:id` | Delete post | ✅ |

### Example API Usage

#### Register a new user
```bash
curl -X POST http://localhost:3000/register \
  -H "Content-Type: application/json" \
  -d '{"auth": {"email": "user@example.com", "password": "password123"}}'
```

#### Login
```bash
curl -X POST http://localhost:3000/sessions \
  -H "Content-Type: application/json" \
  -d '{"email": "user@example.com", "password": "password123"}'
```

#### Create a post (with authentication)
```bash
curl -X POST http://localhost:3000/posts \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{"post": {"title": "My Post", "body": "Post content"}}'
```

## Testing

The project includes a comprehensive test suite with RSpec.

### Run All Tests

```bash
# Run the complete test suite
bundle exec rspec

# Run with detailed output
bundle exec rspec --format documentation

# Run with progress format
bundle exec rspec --format progress
```

### Run Specific Tests

```bash
# Run controller tests
bundle exec rspec spec/controllers/

# Run model tests
bundle exec rspec spec/models/

# Run specific controller tests
bundle exec rspec spec/controllers/auth_controller_spec.rb
bundle exec rspec spec/controllers/sessions_controller_spec.rb
bundle exec rspec spec/controllers/posts_controller_spec.rb

# Run specific test with line number
bundle exec rspec spec/controllers/auth_controller_spec.rb:16
```

### Test Coverage

The project includes **105+ tests** covering:

- ✅ **Authentication & Authorization** (39 tests)
- ✅ **API Endpoints** (73 tests)
- ✅ **Model Validations** (32 tests)
- ✅ **Error Handling**
- ✅ **JWT Token Management**
- ✅ **Database Associations**

## Development

### Database Operations

```bash
# Reset database
rails db:reset

# Drop database
rails db:drop

# Create fresh database
rails db:create db:migrate

# Run migrations
rails db:migrate

# Rollback last migration
rails db:rollback

# Check migration status
rails db:migrate:status
```

### Generate New Components

```bash
# Generate a new controller
rails generate controller ControllerName

# Generate a new model
rails generate model ModelName field:type

# Generate a migration
rails generate migration MigrationName
```

### Console Access

```bash
# Rails console
rails console

# Or shorthand
rails c
```

### Check Routes

```bash
# Display all routes
rails routes

# Search for specific routes
rails routes | grep posts
```

## Production Deployment

### Environment Variables

Make sure to set the following environment variables in production:

```bash
RAILS_ENV=production
SECRET_KEY_BASE=your_secret_key
DATABASE_URL=your_database_url
```

### Database Setup in Production

```bash
# Set environment
export RAILS_ENV=production

# Create and migrate database
rails db:create
rails db:migrate

# Precompile assets (if using any)
rails assets:precompile
```

### Using Docker (Optional)

```bash
# Build Docker image
docker build -t blog_demo .

# Run container
docker run -p 3000:3000 blog_demo
```

## Troubleshooting

### Common Issues

1. **Database Connection Error**
   ```bash
   # Check if PostgreSQL is running
   brew services start postgresql
   # or
   sudo systemctl start postgresql
   ```

2. **Bundle Install Fails**
   ```bash
   # Update bundler
   gem update bundler
   
   # Clear bundle cache
   bundle clean --force
   ```

3. **Migration Errors**
   ```bash
   # Reset database
   rails db:drop db:create db:migrate
   ```

4. **Test Failures**
   ```bash
   # Reset test database
   RAILS_ENV=test rails db:reset
   ```

### Logs

```bash
# Check development logs
tail -f log/development.log

# Check test logs
tail -f log/test.log
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run the test suite (`bundle exec rspec`)
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

If you encounter any issues or have questions, please:

1. Check the troubleshooting section above
2. Review the test suite for examples
3. Open an issue in the repository

---

**Happy coding! 🚀**
