# AGENTS.md

Guidance for AI agents working in this repository.

## What this is

Search Restaurant — a sample app with three clients and one backend:

- `django/searchrestaurant/` — Django REST API (the actively maintained part)
- `android/` — Android client
- `ios/` — iOS client
- `v2/` — newer experiment

Agent work almost always means the **Django backend**. The mobile
clients are sample code; see **Mobile clients** below before touching
them.

## Mobile clients

- `android/` — modernized to Gradle 8 / AGP 8 / AndroidX / SDK 35.
  Changes were made without an Android SDK and are **not build-verified**
  — see [android/UPGRADING.md](android/UPGRADING.md). Verify in Android
  Studio (JDK 17) before relying on it.
- `ios/` — still **Swift 2 (2016)**, not upgraded. A Swift 2→5/6 upgrade
  is interactive (Xcode-only); the concrete plan is in
  [ios/UPGRADING.md](ios/UPGRADING.md). Do not attempt a blind rewrite.

## Backend: setup & run

Runs on **Python 3.13 + Django 4.2.28**. Older Python is unsupported
(several deps need 3.12+ fixes).

```bash
cd django/searchrestaurant
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver
```

## Verify before claiming done

```bash
cd django/searchrestaurant
python manage.py check                       # must exit 0
python manage.py makemigrations --check --dry-run   # must exit 0 (no drift)
python manage.py spectacular --file /tmp/schema.yml # OpenAPI schema must build
```

A clean-venv `pip install -r requirements.txt` must succeed with no
`pip check` conflicts.

## Key facts

- DB: SQLite (`db.sqlite3`), dev-only. `DEBUG=True`, secret key hardcoded
  in `settings.py` — it's a sample, not production.
- API docs: Swagger UI at `/docs/`, OpenAPI at `/schema/`, served by
  **drf-spectacular**. (Replaced unmaintained `drfdocs`.)
- API contract: see `API_DOC.md`. Main endpoint `/api/v1/`.
- External calls: `search/views.py` hits Google Geocoding + Foursquare;
  keys are placeholders in `settings.py`.
- URLConf uses `re_path` (regex). `search/urls.py` sets `app_name`.

## Conventions

- Pin exact versions in `requirements.txt`; keep them Python-3.13 +
  Django-4.2 compatible.
- Don't introduce schema migrations for cosmetic warnings (e.g. don't
  add `DEFAULT_AUTO_FIELD` unless asked — it forces a PK-type migration).
- Don't touch `android/`, `ios/`, `v2/` for backend tasks.
- Existing debug `print()` calls in `search/views.py` are pre-existing;
  leave them unless the task is about them.

## Commit / PR style

- No AI-attribution footers or `Co-Authored-By` trailers — commits
  should read as human-authored. Keep substance (what/why, test plan).
