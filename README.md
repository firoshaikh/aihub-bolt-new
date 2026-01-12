# AIHub Orders - Full Stack Application

A full-stack JWT-based authentication system with Express backend and React frontend, designed to work seamlessly in Bolt/StackBlitz Preview iframe.

## Architecture

- **Frontend**: Vite + React (Port 5173)
- **Backend**: Node.js + Express (Port 3001)
- **Database**: Azure PostgreSQL
- **Auth**: JWT Bearer tokens (no cookies, no sessions)

## Key Features

- JSON-only API responses (no HTML, no redirects)
- JWT-based authentication
- PostgreSQL views for row-level security
- CORS enabled for cross-origin requests
- Works inside Bolt Preview iframe

## Project Structure

```
aihub-bolt-new/
├── backend/
│   ├── server.js          # Express API server
│   └── package.json       # Backend dependencies
├── database/
│   └── schema.sql         # PostgreSQL schema and seed data
├── src/
│   ├── components/
│   │   ├── LoginForm.jsx  # Login component
│   │   └── OrdersList.jsx # Orders display component
│   ├── App.jsx            # Main app component
│   ├── main.jsx           # React entry point
│   └── index.css          # Styles
├── index.html             # HTML entry point
├── vite.config.js         # Vite configuration
├── package.json           # Frontend dependencies
└── .env                   # Environment variables
```

## Setup Instructions

### 1. Environment Variables

Copy `.env.example` to `.env` and fill in your values:

```bash
cp .env.example .env
```

Edit `.env`:
```
DB_HOST=pgsqlfs-tesa-dev-gwc.postgres.database.azure.com
DB_PORT=5432
DB_NAME=aihub-pgsql-db-tesa-dev-gwc
DB_USER=pgsqladmin
DB_PASSWORD=your_actual_password
JWT_SECRET=your_secure_jwt_secret
```

### 2. Database Setup

Run the SQL schema file against your Azure PostgreSQL database:

```bash
psql -h pgsqlfs-tesa-dev-gwc.postgres.database.azure.com \
     -U pgsqladmin \
     -d aihub-pgsql-db-tesa-dev-gwc \
     -f database/schema.sql
```

This will create:
- `users` table
- `orders` table
- `user_orders` view (for row-level security)
- Sample users and orders

### 3. Install Dependencies

Install frontend dependencies:
```bash
npm install
```

Install backend dependencies:
```bash
cd backend
npm install
cd ..
```

### 4. Run the Application

#### Option A: Run Both Services Separately

Terminal 1 (Backend):
```bash
npm run backend
```

Terminal 2 (Frontend):
```bash
npm run dev
```

#### Option B: Development Mode

For backend with auto-reload:
```bash
npm run backend:dev
```

### 5. Access the Application

- Frontend: http://localhost:5173
- Backend API: http://localhost:3001

## API Endpoints

### Authentication

**POST /auth/login**

Login with email and password.

Request:
```json
{
  "email": "admin@example.com",
  "password": "password123"
}
```

Response:
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "admin@example.com"
  }
}
```

### Orders

**GET /api/orders**

Get orders for authenticated user.

Headers:
```
Authorization: Bearer <jwt_token>
```

Response:
```json
[
  {
    "id": 1,
    "user_id": "550e8400-e29b-41d4-a716-446655440000",
    "amount": "99.99",
    "created_at": "2024-01-15T10:30:00Z"
  }
]
```

### Health Check

**GET /health**

Check if backend is running.

Response:
```json
{
  "status": "ok",
  "timestamp": "2024-01-15T10:30:00Z"
}
```

## Sample Credentials

The schema creates two test users:

1. **Admin User**
   - Email: `admin@example.com`
   - Password: `password123`

2. **Regular User**
   - Email: `user@example.com`
   - Password: `password123`

## Database Schema

### Users Table
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT now()
);
```

### Orders Table
```sql
CREATE TABLE orders (
  id SERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES users(id),
  amount NUMERIC(10, 2) NOT NULL,
  created_at TIMESTAMP DEFAULT now()
);
```

### User Orders View
```sql
CREATE VIEW user_orders AS
SELECT *
FROM orders
WHERE user_id = current_setting('app.user_id', true)::uuid;
```

The view filters orders based on `app.user_id` session variable, providing row-level security.

## How It Works

1. **Login Flow**:
   - User enters credentials in React form
   - Frontend sends POST to `/auth/login`
   - Backend validates against database
   - Backend returns JWT token
   - Frontend stores token in localStorage

2. **Authenticated Requests**:
   - Frontend includes JWT in Authorization header
   - Backend verifies JWT signature
   - Backend extracts user_id from JWT
   - Query uses view to filter user's orders

3. **Row-Level Security**:
   - Backend executes: `SET app.user_id = '<user_id>'`
   - View `user_orders` filters by this variable
   - Each user only sees their own orders

## Security Notes

- **Production**: Use bcrypt or argon2 for password hashing
- **Production**: Use strong JWT_SECRET (minimum 32 characters)
- **Production**: Implement token refresh mechanism
- **Production**: Add rate limiting
- **Production**: Enable HTTPS/SSL
- **Demo**: Current implementation uses plaintext passwords

## Troubleshooting

### Backend won't start
- Check if port 3001 is available
- Verify database credentials in `.env`
- Check PostgreSQL connection

### Frontend can't connect to backend
- Ensure backend is running on port 3001
- Check Vite proxy configuration
- Verify CORS is enabled on backend

### Database connection fails
- Verify Azure PostgreSQL firewall rules
- Check SSL requirements
- Confirm credentials are correct

### JWT errors
- Ensure JWT_SECRET is set in `.env`
- Check token format in Authorization header
- Verify token hasn't expired (24h default)

## Development Notes

- Frontend uses Vite proxy to avoid CORS issues during development
- Backend returns JSON only (never HTML)
- No redirects or cookies used
- Works inside iframe environments (Bolt/StackBlitz)
- Session management via JWT tokens

## License

MIT