# Haushalts-Hero Backend API - Implementierungsplan

**Version:** 1.0
**Datum:** 2025-11-19
**Ziel:** Vollständige Backend-Integration für iOS-App

---

## 1. Übersicht

### Technologie-Stack

**Backend:**
- **Runtime:** Node.js 20+
- **Framework:** Express.js 4.18+
- **Database:** SQLite (Development) / PostgreSQL (Production)
- **ORM:** Prisma 5.0+
- **Auth:** JWT (jsonwebtoken)
- **Validation:** Zod
- **File Storage:** Local (Development) / S3 (Production)
- **Testing:** Jest + Supertest

**Warum diese Stack:**
- ✅ Schnelle Entwicklung
- ✅ TypeScript-Support
- ✅ Prisma = Type-Safety + Migrations
- ✅ Leicht deploybar (Vercel, Railway, Fly.io)
- ✅ Kompatibel mit Frontend-Architektur

---

## 2. Phasen-Übersicht

| Phase | Beschreibung | Aufwand | Priorität |
|-------|--------------|---------|-----------|
| **Phase 7.1** | Backend-Setup & Database | 1 Tag | HIGH |
| **Phase 7.2** | Auth & User-Management | 1 Tag | HIGH |
| **Phase 7.3** | Challenge-Endpoints | 2 Tage | HIGH |
| **Phase 7.4** | Quests & Goals-Endpoints | 1 Tag | HIGH |
| **Phase 7.5** | Stats & Content-Endpoints | 1 Tag | MEDIUM |
| **Phase 7.6** | Photo-Upload (S3/Local) | 1 Tag | MEDIUM |
| **Phase 7.7** | iOS RemoteRepository | 2 Tage | HIGH |
| **Phase 7.8** | Testing & Deployment | 1 Tag | HIGH |

**Gesamt:** 10 Tage (beschleunigt auf ~6-8 Stunden für MVP)

---

## 3. API-Struktur

### Base URL
```
Development: http://localhost:3000/api/v1
Production: https://api.haushalts-hero.com/api/v1
```

### Endpoints (25 total)

#### **Auth** (3 Endpoints)
```
POST   /auth/register
POST   /auth/login
POST   /auth/refresh
```

#### **Users** (2 Endpoints)
```
GET    /users/me
PUT    /users/me/settings
```

#### **Challenges** (4 Endpoints)
```
GET    /challenges
POST   /challenges
GET    /challenges/:id
DELETE /challenges/:id
```

#### **Quests** (3 Endpoints)
```
GET    /quests/active
PATCH  /quests/:id/progress
POST   /quests/reset
```

#### **Goals** (2 Endpoints)
```
GET    /goals/active
PATCH  /goals/progress
```

#### **Stats** (3 Endpoints)
```
GET    /stats/weekly
GET    /stats/monthly
PUT    /stats/weekly
```

#### **Content** (4 Endpoints)
```
GET    /content/coaching-tips
GET    /content/micro-learning
GET    /content/seasons/active
GET    /content/seasons
```

#### **Photos** (3 Endpoints)
```
POST   /photos/upload
GET    /photos/:id
DELETE /photos/:id
```

#### **Health** (1 Endpoint)
```
GET    /health
```

---

## 4. Database-Schema (Prisma)

### User
```prisma
model User {
  id            String    @id @default(uuid())
  email         String    @unique
  passwordHash  String
  createdAt     DateTime  @default(now())
  updatedAt     DateTime  @updatedAt

  challenges    Challenge[]
  quests        Quest[]
  goals         Goal[]
  weeklyStats   WeeklyStats[]
  settings      UserSettings?
}
```

### Challenge
```prisma
model Challenge {
  id              String    @id @default(uuid())
  userId          String
  user            User      @relation(fields: [userId], references: [id])

  category        String    // mirror, toilet, room
  beforePhotoUrl  String
  afterPhotoUrl   String
  timestamp       DateTime  @default(now())

  // Score
  overallScore    Int
  subscores       Json      // Array of subscores
  confidence      Float
  explanation     String
  heatmapData     Json?

  createdAt       DateTime  @default(now())
}
```

### Quest
```prisma
model Quest {
  id              String    @id @default(uuid())
  userId          String
  user            User      @relation(fields: [userId], references: [id])

  title           String
  description     String
  category        String?
  targetCount     Int
  currentProgress Int       @default(0)
  rewardPoints    Int
  weekStart       DateTime

  createdAt       DateTime  @default(now())
  updatedAt       DateTime  @updatedAt
}
```

### Goal
```prisma
model Goal {
  id            String    @id @default(uuid())
  userId        String
  user          User      @relation(fields: [userId], references: [id])

  title         String
  targetPoints  Int
  currentPoints Int       @default(0)
  weekStart     DateTime

  createdAt     DateTime  @default(now())
  updatedAt     DateTime  @updatedAt
}
```

### WeeklyStats
```prisma
model WeeklyStats {
  id                  String    @id @default(uuid())
  userId              String
  user                User      @relation(fields: [userId], references: [id])

  weekStart           DateTime
  challengesCompleted Int
  averageScore        Float
  categoryCounts      Json
  totalPoints         Int

  createdAt           DateTime  @default(now())
}
```

### UserSettings
```prisma
model UserSettings {
  id                    String    @id @default(uuid())
  userId                String    @unique
  user                  User      @relation(fields: [userId], references: [id])

  enableHapticFeedback  Boolean   @default(true)
  enableSoundEffects    Boolean   @default(true)
  showHeatmapByDefault  Boolean   @default(false)

  updatedAt             DateTime  @updatedAt
}
```

### Photo
```prisma
model Photo {
  id        String    @id @default(uuid())
  userId    String
  url       String
  path      String    // S3 path or local path
  size      Int       // bytes
  mimeType  String

  createdAt DateTime  @default(now())
}
```

---

## 5. Authentifizierung

### JWT-Strategie

**Access Token:**
- Expiration: 15 Minuten
- Payload: { userId, email }

**Refresh Token:**
- Expiration: 7 Tage
- Stored in DB (für Revocation)

**Flow:**
```
1. POST /auth/register → Access + Refresh Token
2. POST /auth/login → Access + Refresh Token
3. Request mit Authorization: Bearer <access-token>
4. Access-Token abgelaufen → POST /auth/refresh
5. Neuer Access-Token zurück
```

---

## 6. Validierung (Zod)

**Beispiel: Challenge-Creation**
```typescript
const challengeSchema = z.object({
  category: z.enum(['mirror', 'toilet', 'room']),
  beforePhotoUrl: z.string().url(),
  afterPhotoUrl: z.string().url(),
  score: z.object({
    overallScore: z.number().int().min(0).max(100),
    subscores: z.array(z.object({
      name: z.string(),
      value: z.number().int().min(0).max(100),
      weight: z.number().min(0).max(1),
    })),
    confidence: z.number().min(0).max(1),
    explanation: z.string(),
  }),
});
```

---

## 7. Error-Handling

**Standard-Error-Format:**
```json
{
  "error": {
    "code": "UNAUTHORIZED",
    "message": "Invalid or expired token",
    "details": {}
  }
}
```

**Error-Codes:**
- `UNAUTHORIZED` (401)
- `FORBIDDEN` (403)
- `NOT_FOUND` (404)
- `VALIDATION_ERROR` (400)
- `INTERNAL_ERROR` (500)
- `CONFLICT` (409) - z.B. Email bereits existiert

---

## 8. Projekt-Struktur

```
backend/
├── src/
│   ├── config/
│   │   └── database.ts
│   ├── middleware/
│   │   ├── auth.ts
│   │   ├── errorHandler.ts
│   │   └── validation.ts
│   ├── routes/
│   │   ├── auth.routes.ts
│   │   ├── challenges.routes.ts
│   │   ├── quests.routes.ts
│   │   ├── goals.routes.ts
│   │   ├── stats.routes.ts
│   │   ├── content.routes.ts
│   │   └── photos.routes.ts
│   ├── controllers/
│   │   ├── auth.controller.ts
│   │   ├── challenges.controller.ts
│   │   ├── quests.controller.ts
│   │   ├── goals.controller.ts
│   │   ├── stats.controller.ts
│   │   ├── content.controller.ts
│   │   └── photos.controller.ts
│   ├── services/
│   │   ├── auth.service.ts
│   │   ├── challenge.service.ts
│   │   ├── quest.service.ts
│   │   ├── goal.service.ts
│   │   ├── stats.service.ts
│   │   └── storage.service.ts
│   ├── validators/
│   │   └── schemas.ts
│   ├── types/
│   │   └── index.ts
│   └── index.ts
├── prisma/
│   ├── schema.prisma
│   └── seed.ts
├── tests/
│   ├── auth.test.ts
│   ├── challenges.test.ts
│   └── ...
├── uploads/ (local file storage)
├── .env.example
├── package.json
├── tsconfig.json
└── README.md
```

---

## 9. iOS-Integration

### RemoteRepository.swift

```swift
class RemoteRepository: AppRepository {
    private let apiClient: APIClient
    private let authManager: AuthenticationManager

    func getChallengeHistory(limit: Int?) async throws -> [Challenge] {
        let endpoint = "/challenges?limit=\(limit ?? 100)"
        let response: ChallengeListResponse = try await apiClient.get(endpoint)
        return response.challenges.map { $0.toDomain() }
    }

    func saveChallengeHistory(_ challenge: Challenge) async throws {
        let endpoint = "/challenges"
        let body = ChallengeCreateRequest(from: challenge)
        let response: ChallengeResponse = try await apiClient.post(endpoint, body: body)
    }
}
```

### APIClient.swift

```swift
class APIClient {
    private let baseURL = "http://localhost:3000/api/v1"
    private let session = URLSession.shared
    private let authManager: AuthenticationManager

    func get<T: Decodable>(_ endpoint: String) async throws -> T {
        let url = URL(string: baseURL + endpoint)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(authManager.accessToken)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(httpResponse.statusCode)
        }

        return try JSONDecoder().decode(T.self, from: data)
    }
}
```

---

## 10. Deployment

### Option 1: Railway.app (Empfohlen für MVP)
- ✅ Kostenlos (Startup-Plan: $5/Monat)
- ✅ PostgreSQL inklusive
- ✅ Auto-Deploy via GitHub
- ✅ Environment-Variables
- ✅ Logs & Monitoring

### Option 2: Fly.io
- ✅ Kostenlos (3 kleine Maschinen)
- ✅ Global CDN
- ✅ PostgreSQL via Supabase

### Option 3: Vercel (Serverless)
- ✅ Kostenlos (Hobby-Plan)
- ❌ Keine Websockets
- ❌ Funktioniert mit PostgreSQL (extern)

---

## 11. Testing

### Unit-Tests (Jest)
```typescript
describe('ChallengeController', () => {
  it('should create a challenge', async () => {
    const response = await request(app)
      .post('/api/v1/challenges')
      .set('Authorization', `Bearer ${token}`)
      .send(validChallenge)
      .expect(201);

    expect(response.body.id).toBeDefined();
    expect(response.body.overallScore).toBe(85);
  });
});
```

### Integration-Tests
```typescript
describe('Auth Flow', () => {
  it('should register, login, and access protected route', async () => {
    // Register
    const registerRes = await request(app)
      .post('/api/v1/auth/register')
      .send({ email, password });

    expect(registerRes.status).toBe(201);

    // Login
    const loginRes = await request(app)
      .post('/api/v1/auth/login')
      .send({ email, password });

    expect(loginRes.body.accessToken).toBeDefined();

    // Access protected route
    const meRes = await request(app)
      .get('/api/v1/users/me')
      .set('Authorization', `Bearer ${loginRes.body.accessToken}`);

    expect(meRes.status).toBe(200);
  });
});
```

---

## 12. Nächste Schritte

### Implementierungs-Reihenfolge:

1. ✅ **Backend-Setup** (15 Min)
   - Express + TypeScript
   - Prisma + SQLite
   - Basic Server

2. ✅ **Auth-System** (30 Min)
   - JWT-Middleware
   - Register/Login/Refresh

3. ✅ **Challenge-Endpoints** (45 Min)
   - CRUD-Operations
   - Validation

4. ✅ **Quests/Goals** (30 Min)
   - Quest-Management
   - Goal-Progress

5. ✅ **Stats/Content** (30 Min)
   - Weekly/Monthly Stats
   - Static Content

6. ✅ **Photo-Upload** (30 Min)
   - Local File-Storage
   - Multer Integration

7. ✅ **iOS RemoteRepository** (1 Stunde)
   - APIClient
   - RemoteRepository
   - AuthenticationManager

8. ✅ **Testing** (30 Min)
   - Integration-Tests
   - Deployment-Test

**Gesamt:** ~4-5 Stunden für MVP

---

## 13. Success-Criteria

| Kriterium | Ziel |
|-----------|------|
| **API-Endpoints** | 25/25 implementiert |
| **Tests** | 80%+ Coverage |
| **Response-Time** | <200ms (p95) |
| **Auth** | JWT funktioniert |
| **iOS-Integration** | RemoteRepository funktioniert |
| **Deployment** | Live auf Railway/Fly.io |

---

**Erstellt von:** AI Agent
**Start:** Jetzt sofort
**Geschätzte Fertigstellung:** 4-5 Stunden

---

Ich starte jetzt mit der Implementierung! 🚀
