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

### Run Unit Tests by Category

#### Authentication Unit Tests
```bash
# Test user registration functionality
bundle exec rspec spec/controllers/auth_controller_spec.rb -e "POST #register"

# Test user login functionality  
bundle exec rspec spec/controllers/auth_controller_spec.rb -e "POST #login"

# Test JWT token generation
bundle exec rspec spec/controllers/auth_controller_spec.rb -e "jwt_token"
```

#### Session Management Unit Tests
```bash
# Test session creation (login)
bundle exec rspec spec/controllers/sessions_controller_spec.rb -e "POST #create"

# Test session destruction (logout)
bundle exec rspec spec/controllers/sessions_controller_spec.rb -e "DELETE #destroy"

# Test current user authentication status
bundle exec rspec spec/controllers/sessions_controller_spec.rb -e "GET #show"

# Test JWT token validation
bundle exec rspec spec/controllers/sessions_controller_spec.rb -e "generate_jwt_token"
```

#### Posts CRUD Unit Tests
```bash
# Test posts listing
bundle exec rspec spec/controllers/posts_controller_spec.rb -e "GET #index"

# Test single post retrieval
bundle exec rspec spec/controllers/posts_controller_spec.rb -e "GET #show"

# Test post creation
bundle exec rspec spec/controllers/posts_controller_spec.rb -e "POST #create"

# Test post updates
bundle exec rspec spec/controllers/posts_controller_spec.rb -e "PATCH #update"

# Test post deletion
bundle exec rspec spec/controllers/posts_controller_spec.rb -e "DELETE #destroy"

# Test authorization for posts
bundle exec rspec spec/controllers/posts_controller_spec.rb -e "authorization"
```

#### Model Unit Tests
```bash
# Test User model validations
bundle exec rspec spec/models/user_spec.rb -e "validations"

# Test User model associations
bundle exec rspec spec/models/user_spec.rb -e "associations"

# Test password authentication
bundle exec rspec spec/models/user_spec.rb -e "password authentication"

# Test Post model validations
bundle exec rspec spec/models/post_spec.rb -e "validations"

# Test Post model associations
bundle exec rspec spec/models/post_spec.rb -e "associations"

# Test factory bot data generation
bundle exec rspec spec/models/ -e "factory"
```

#### Error Handling Unit Tests
```bash
# Test validation errors
bundle exec rspec spec/controllers/ -e "invalid parameters"

# Test authentication errors
bundle exec rspec spec/controllers/ -e "unauthorized"

# Test authorization errors
bundle exec rspec spec/controllers/ -e "not authorized"

# Test missing data errors
bundle exec rspec spec/controllers/ -e "missing"
```

#### Private Method Unit Tests
```bash
# Test controller private methods
bundle exec rspec spec/controllers/auth_controller_spec.rb -e "private methods"
bundle exec rspec spec/controllers/sessions_controller_spec.rb -e "private methods"
bundle exec rspec spec/controllers/posts_controller_spec.rb -e "private methods"
```

### Test Output Examples

#### Running a specific unit test
```bash
# Example: Test user registration
$ bundle exec rspec spec/controllers/auth_controller_spec.rb -e "POST #register"

AuthController
  POST #register
    with valid parameters
      creates a new user
      returns a JWT token
      returns a valid JWT token
    with invalid parameters
      does not create a user
      returns validation errors
    with duplicate email
      returns validation error

Finished in 0.35 seconds
7 examples, 0 failures
```

#### Running tests with detailed documentation format
```bash
# Example: Detailed test output
$ bundle exec rspec spec/models/user_spec.rb --format documentation

User
  validations
    is expected to validate that :email cannot be empty/falsy
    is expected to validate that :email is case-insensitively unique
    is expected to validate that :password cannot be empty/falsy
    is expected to have a secure password, defined on password attribute
  associations
    is expected to have many posts
  factory
    creates a valid user
    creates a user with posts using trait
  password authentication
    authenticates with correct password
    does not authenticate with incorrect password
```

### Test Tags and Filtering

You can also run tests using tags for more precise filtering:

```bash
# Run tests by type
bundle exec rspec --tag type:controller
bundle exec rspec --tag type:model

# Run tests excluding slow tests (if tagged)
bundle exec rspec --tag ~slow

# Run only integration tests (if tagged)
bundle exec rspec --tag integration
```

### Test Coverage

The project includes **105+ tests** covering:

- ✅ **Authentication & Authorization** (39 tests)
- ✅ **API Endpoints** (73 tests)
- ✅ **Model Validations** (32 tests)
- ✅ **Error Handling**
- ✅ **JWT Token Management**
- ✅ **Database Associations**




1. Check the troubleshooting section above
2. Review the test suite for examples
3. Open an issue in the repository

---
