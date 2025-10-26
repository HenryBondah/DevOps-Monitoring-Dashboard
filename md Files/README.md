# DevOps Monitoring Dashboard

Complete monitoring system with metrics, logs, and alerts.

## Quick Start

```bash
cd monitoring
docker-compose up -d
```

**First time?** See [SETUP.md](SETUP.md)

## Access
- Grafana: http://localhost:3000 (admin/admin)
- Prometheus: http://localhost:9090
- Alertmanager: http://localhost:9093

## Files
- **SETUP.md** - Installation & setup guide
- **week2.md** - Week 2 progress
- **week3.md** - Week 3 progress
- **week4.md** - Week 4 progress
- **week5.md** - Week 5 progress (current)

## Commands
```bash
docker-compose ps          # Status
docker-compose logs -f     # View logs
docker-compose restart     # Restart
docker-compose down        # Stop
```
