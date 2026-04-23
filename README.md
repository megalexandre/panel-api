# README

to start project
bin/rails s -b 0.0.0.0 -p 3000

## Docker (build, run, push)

Build image:

```bash

docker push alexandreqrz/api-panel:latest
```

Run with PostgreSQL env vars:

```bash
docker run --rm -p 3000:80 \
	-e RAILS_MASTER_KEY=your_master_key \
	-e POSTGRES_HOST=host.docker.internal \
	-e POSTGRES_PORT=5432 \
	-e POSTGRES_DB=api_dashboard_production \
	-e POSTGRES_USER=postgres \
	-e POSTGRES_PASSWORD=postgres \
	alexandreqrz/api-panel:tagname
```

If you prefer, set only `DATABASE_URL` instead of `POSTGRES_*`:

```bash
docker run --rm -p 3000:80 \
	-e RAILS_MASTER_KEY=your_master_key \
	-e DATABASE_URL=postgres://postgres:postgres@host.docker.internal:5432/api_dashboard_production \
	alexandreqrz/api-panel:tagname
```