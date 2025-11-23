# Haushalts-Hero Backend - Deployment Guide

## Prerequisites

- Node.js 20+
- PostgreSQL (for production)
- Git

## Local Development Setup

### 1. Install Dependencies

```bash
cd backend
npm install
```

### 2. Setup Environment

```bash
cp .env.example .env
# Edit .env with your configuration
```

### 3. Setup Database

```bash
# Generate Prisma Client
npm run prisma:generate

# Run migrations
npm run prisma:migrate

# (Optional) Seed database with demo data
npm run prisma:seed
```

### 4. Start Development Server

```bash
npm run dev
```

Server will be available at: http://localhost:3000

## Production Deployment

### Option 1: Railway.app (Recommended)

#### Step 1: Prepare Repository

1. Push backend code to GitHub
2. Ensure all environment variables are in `.env.example`

#### Step 2: Deploy to Railway

1. Visit [Railway.app](https://railway.app)
2. Click "New Project" → "Deploy from GitHub"
3. Select your repository
4. Railway will auto-detect Node.js project

#### Step 3: Configure Environment

Add these environment variables in Railway dashboard:

```
NODE_ENV=production
PORT=3000
DATABASE_URL=<railway-provided-postgres-url>
JWT_ACCESS_SECRET=<generate-strong-secret>
JWT_REFRESH_SECRET=<generate-strong-secret>
CORS_ORIGIN=https://your-frontend-domain.com
```

#### Step 4: Add PostgreSQL

1. In Railway dashboard, click "New"
2. Select "Database" → "PostgreSQL"
3. Railway will automatically set `DATABASE_URL`

#### Step 5: Configure Build

Add to `package.json`:

```json
{
  "scripts": {
    "build": "tsc && npx prisma generate",
    "start": "npx prisma migrate deploy && node dist/index.js"
  }
}
```

#### Step 6: Deploy

```bash
git push origin main
```

Railway will automatically deploy!

#### Step 7: Run Migrations

```bash
# Via Railway CLI
railway run npx prisma migrate deploy
```

### Option 2: Fly.io

#### Step 1: Install Fly CLI

```bash
curl -L https://fly.io/install.sh | sh
```

#### Step 2: Login

```bash
fly auth login
```

#### Step 3: Initialize Fly App

```bash
cd backend
fly launch
```

Follow prompts:
- Choose app name
- Select region
- Don't deploy yet

#### Step 4: Add PostgreSQL

```bash
fly postgres create
fly postgres attach <postgres-app-name>
```

#### Step 5: Set Environment Variables

```bash
fly secrets set JWT_ACCESS_SECRET=<your-secret>
fly secrets set JWT_REFRESH_SECRET=<your-secret>
fly secrets set NODE_ENV=production
```

#### Step 6: Deploy

```bash
fly deploy
```

#### Step 7: Run Migrations

```bash
fly ssh console
cd /app
npx prisma migrate deploy
exit
```

### Option 3: Vercel (Serverless)

⚠️ **Note:** Vercel functions have 10-second timeout on Hobby plan.

#### Step 1: Install Vercel CLI

```bash
npm i -g vercel
```

#### Step 2: Create `vercel.json`

```json
{
  "version": 2,
  "builds": [
    {
      "src": "dist/index.js",
      "use": "@vercel/node"
    }
  ],
  "routes": [
    {
      "src": "/(.*)",
      "dest": "dist/index.js"
    }
  ]
}
```

#### Step 3: Deploy

```bash
vercel
```

#### Step 4: Add PostgreSQL

Use external provider:
- [Supabase](https://supabase.com) (Free tier: 500MB)
- [Neon](https://neon.tech) (Free tier: 3GB)
- [PlanetScale](https://planetscale.com) (Free tier: 5GB)

## Database Migrations

### Creating a Migration

```bash
npm run prisma:migrate -- --name migration_name
```

### Applying Migrations (Production)

```bash
npx prisma migrate deploy
```

### Resetting Database (Development Only!)

```bash
npm run prisma:migrate -- reset
```

## Environment Variables

### Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `NODE_ENV` | Environment | `production` |
| `PORT` | Server port | `3000` |
| `DATABASE_URL` | PostgreSQL connection string | `postgresql://user:pass@host:5432/db` |
| `JWT_ACCESS_SECRET` | JWT access token secret | `<strong-random-string>` |
| `JWT_REFRESH_SECRET` | JWT refresh token secret | `<strong-random-string>` |
| `CORS_ORIGIN` | Allowed CORS origins | `https://app.haushalts-hero.com` |

### Optional Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `JWT_ACCESS_EXPIRATION` | Access token expiration | `15m` |
| `JWT_REFRESH_EXPIRATION` | Refresh token expiration | `7d` |
| `UPLOAD_DIR` | Upload directory | `./uploads` |
| `MAX_FILE_SIZE` | Max file size (bytes) | `10485760` |

## Health Checks

### Check Server Health

```bash
curl https://your-api-domain.com/health
```

Expected response:

```json
{
  "status": "ok",
  "timestamp": "2025-11-23T12:00:00.000Z",
  "environment": "production",
  "version": "v1"
}
```

### Check Database Connection

```bash
curl https://your-api-domain.com/api/v1/content/coaching-tips
```

## Monitoring

### Logs

#### Railway

```bash
# View logs in dashboard or CLI
railway logs
```

#### Fly.io

```bash
fly logs
```

#### Vercel

```bash
vercel logs
```

### Error Tracking

Consider integrating:
- [Sentry](https://sentry.io) - Error tracking
- [LogRocket](https://logrocket.com) - Session replay
- [DataDog](https://datadoghq.com) - APM

## Performance

### Recommended Settings

```env
# Node.js memory limit
NODE_OPTIONS=--max-old-space-size=512

# Connection pooling (Prisma)
DATABASE_URL="postgresql://...?connection_limit=5"
```

### Caching

Consider adding Redis for:
- Session storage
- API response caching
- Rate limiting

## Security Checklist

- [ ] Use strong JWT secrets (minimum 32 characters)
- [ ] Enable HTTPS only
- [ ] Set proper CORS origins
- [ ] Enable rate limiting
- [ ] Use environment variables for secrets
- [ ] Enable Helmet.js security headers
- [ ] Validate all inputs with Zod
- [ ] Use prepared statements (Prisma handles this)
- [ ] Implement proper error handling
- [ ] Don't expose stack traces in production

## Backup

### PostgreSQL Backup (Railway)

```bash
railway run pg_dump $DATABASE_URL > backup.sql
```

### Restore

```bash
railway run psql $DATABASE_URL < backup.sql
```

## Rollback

### Railway

Rollback to previous deployment in dashboard.

### Fly.io

```bash
fly releases
fly deploy --image <previous-image>
```

## Support

For issues:
1. Check server logs
2. Verify environment variables
3. Test database connection
4. Check GitHub Actions status

---

**Last Updated:** 2025-11-23
**Version:** 1.0.0
