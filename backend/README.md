# Haushalts-Hero Backend API

Backend API für die Haushalts-Hero iOS-App.

## 🚀 Quick Start

### Prerequisites

- Node.js 20+
- npm 10+

### Installation

```bash
# Install dependencies
npm install

# Copy environment variables
cp .env.example .env

# Generate Prisma Client
npm run prisma:generate

# Run database migrations
npm run prisma:migrate

# (Optional) Seed database
npm run prisma:seed
```

### Development

```bash
# Start development server with hot reload
npm run dev

# Run tests
npm test

# Run tests with coverage
npm run test:coverage

# Lint code
npm run lint
```

### Build & Production

```bash
# Build TypeScript
npm run build

# Start production server
npm start
```

## 📋 API Endpoints

### Base URL

```
Development: http://localhost:3000/api/v1
Production:  https://api.haushalts-hero.com/api/v1
```

### Authentication

```
POST   /auth/register      - Register new user
POST   /auth/login         - Login user
POST   /auth/refresh       - Refresh access token
```

### Users

```
GET    /users/me           - Get current user
PUT    /users/me/settings  - Update user settings
```

### Challenges

```
GET    /challenges         - Get challenge history
POST   /challenges         - Create challenge
GET    /challenges/:id     - Get challenge by ID
DELETE /challenges/:id     - Delete challenge
```

### Quests

```
GET    /quests/active      - Get active quests
PATCH  /quests/:id/progress - Update quest progress
POST   /quests/reset       - Reset weekly quests
```

### Goals

```
GET    /goals/active       - Get active goals
PATCH  /goals/progress     - Update goal progress
```

### Stats

```
GET    /stats/weekly       - Get weekly stats
GET    /stats/monthly      - Get monthly stats
PUT    /stats/weekly       - Update weekly stats
```

### Content

```
GET    /content/coaching-tips    - Get coaching tips
GET    /content/micro-learning   - Get micro-learning modules
GET    /content/seasons/active   - Get active season
GET    /content/seasons          - Get all seasons
```

### Photos

```
POST   /photos/upload      - Upload photo
GET    /photos/:id         - Get photo by ID
DELETE /photos/:id         - Delete photo
```

### Health Check

```
GET    /health             - Server health check
```

## 🗄️ Database

### Prisma Commands

```bash
# Open Prisma Studio (GUI)
npm run prisma:studio

# Create new migration
npx prisma migrate dev --name migration_name

# Reset database
npx prisma migrate reset

# Generate Prisma Client
npm run prisma:generate
```

### Database Schema

- **User**: User accounts with auth
- **Challenge**: Cleaning challenges with scores
- **Quest**: Weekly quests
- **Goal**: Weekly goals
- **WeeklyStats**: Aggregated statistics
- **UserSettings**: User preferences
- **Photo**: Uploaded photos
- **RefreshToken**: JWT refresh tokens

## 🔐 Authentication

### JWT Strategy

**Access Token:**
- Expiration: 15 minutes
- Payload: `{ userId, email }`

**Refresh Token:**
- Expiration: 7 days
- Stored in database for revocation

### Auth Flow

```
1. POST /auth/register → Access + Refresh Token
2. POST /auth/login → Access + Refresh Token
3. Request with Authorization: Bearer <access-token>
4. Access-Token expires → POST /auth/refresh
5. New Access-Token returned
```

## 🧪 Testing

```bash
# Run all tests
npm test

# Run specific test file
npm test -- auth.test.ts

# Watch mode
npm run test:watch

# Coverage report
npm run test:coverage
```

## 📦 Project Structure

```
backend/
├── src/
│   ├── config/           # Configuration files
│   ├── middleware/       # Express middleware
│   ├── routes/           # API routes
│   ├── controllers/      # Route controllers
│   ├── services/         # Business logic
│   ├── validators/       # Zod schemas
│   ├── types/            # TypeScript types
│   └── index.ts          # Server entry point
├── prisma/
│   ├── schema.prisma     # Database schema
│   └── seed.ts           # Database seeding
├── tests/                # Test files
├── uploads/              # Local file storage
├── .env.example          # Environment template
├── package.json
└── tsconfig.json
```

## 🌍 Environment Variables

See `.env.example` for all available configuration options.

## 🚢 Deployment

### Railway.app (Recommended)

1. Connect GitHub repository
2. Add environment variables
3. Deploy automatically on push

### Fly.io

```bash
fly launch
fly deploy
```

### Vercel

```bash
vercel
```

## 📝 License

MIT

## 👨‍💻 Author

AI Agent - Haushalts-Hero Development Team
