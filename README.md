# HMS - Hospital Management System

A CodeIgniter 2.x based Hospital Management System with Docker support for zero-setup development.

## Quick Start

### Prerequisites

- [Docker](https://docs.docker.com/get-docker/) (v20.10+)
- [Docker Compose](https://docs.docker.com/compose/install/) (v2.0+)

### Run the Application

```bash
docker-compose up --build
```

The first run will:
1. Build the PHP/Apache image with required extensions (mysqli, GD)
2. Start a MySQL 5.7 container
3. Auto-create the `hms` database and import the full schema with sample data
4. Serve the app at **http://localhost:8080**

### Stop the Application

```bash
docker-compose down
```

### Stop and Remove All Data

```bash
docker-compose down -v
```

## Default Login Credentials

| Role | Email | Password |
|------|-------|----------|
| Admin | admin@admin.com | admin |
| Doctor | doctor@doctor.com | doctor |
| Patient | patient@patient.com | patient |
| Nurse | nurse@doctor.com | nurse |
| Pharmacist | pharmacist@pharmacist.com | pharmacist |
| Laboratorist | laboratorist@laboratorist.com | laboratorist |
| Accountant | accountant@accountant.com | accountant |

## Configuration

All settings can be customized via environment variables in `docker-compose.yml`:

| Variable | Default | Description |
|----------|---------|-------------|
| `DB_HOST` | `db` | MySQL hostname |
| `DB_PORT` | `3306` | MySQL port |
| `DB_USER` | `root` | MySQL username |
| `DB_PASS` | `hms_password` | MySQL password |
| `DB_NAME` | `hms` | Database name |
| `BASE_URL` | (auto-detect) | Application base URL |

## Project Structure

```
hms/
├── index.php              # Front controller
├── Dockerfile             # PHP 7.4 + Apache image
├── docker-compose.yml     # App + MySQL services
├── docker-entrypoint.sh   # DB init and config script
├── application/           # CodeIgniter application code
│   ├── config/            # Configuration files
│   ├── controllers/       # MVC controllers
│   ├── models/            # MVC models
│   └── views/             # MVC views
├── system/                # CodeIgniter 2.1.3 framework
├── database/              # SQL dump files
│   ├── demo_db.sql        # Demo data
│   └── empty_db.sql       # Schema only
├── uploads/               # File uploads + main schema
│   └── hms.sql            # Full DB schema with data
└── template/              # Frontend assets (CSS, JS, images)
```

## Useful Commands

```bash
# Rebuild after code changes (not needed for PHP changes due to volume mount)
docker-compose up --build

# View logs
docker-compose logs -f app
docker-compose logs -f db

# Access MySQL CLI
docker exec -it hms-db mysql -u root -phms_password hms

# Restart only the app container
docker-compose restart app

# Shell into the app container
docker exec -it hms-app bash
```

## Non-Docker Setup

If you prefer to run without Docker:

1. Install PHP 5.3+ with `mysqli` extension
2. Install MySQL 5.x
3. Create a database named `hms`
4. Import `uploads/hms.sql`
5. Update `application/config/database.php` with your credentials
6. Serve `index.php` from your web server
