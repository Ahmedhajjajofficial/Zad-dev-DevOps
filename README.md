# Zed & Antigravity Cloud IDE

Repository for building and operating a cloud-hosted development workspace based on:

- **Kasm Ubuntu base image**
- **Zed editor**
- **code-server extensions/configuration for Antigravity workflows**
- **Optional Cloudflare Tunnel exposure**

## Repository structure

- `Dockerfile.sovereign`: builds the main runtime image.
- `start_zed.sh`: starts Zed with architecture-aware library path handling.
- `configure_antigravity.sh`: installs optional VSIX extensions and writes code-server settings.
- `health_check.sh`: lightweight process watchdog for Zed and code-server.
- `cloudflared_setup.sh`: helper for downloading/installing cloudflared and printing next steps.
- `run_local_zad.sh`: local Docker build/run helper.
- `kasm_app_config.json`: sample Kasm app definition.

## Quick start (local)

# Zad DevOps - التشغيل المرن للحاويات

هذا المشروع يدعم تشغيل بيئة Zed/Code-Server داخل حاويات Docker مع 3 قدرات تشغيلية رئيسية:

1. **الشفاء الذاتي (Self-Healing)** للحاويات والخدمات الداخلية.
2. **تحمّل أحمال العمل (Workload Tolerance)** عبر تشغيل نسخ متعددة تلقائياً.
3. **النقل المؤقت (Temporary Migration)** أثناء الصيانة أو الأعطال لتقليل التوقف.

## ربط التوثيق بالمجلدات والملفات

> جميع الملفات حالياً داخل المجلد الجذر للمشروع `./`.

| المجلد | الملف | الغرض |
|---|---|---|
| `./` | [`run_local_zad.sh`](./run_local_zad.sh) | بناء الصورة وتشغيل حاوية واحدة أو عدة حاويات مع healthcheck وrestart policy. |
| `./` | [`container_resilience.sh`](./container_resilience.sh) | مراقبة كل الحاويات المعلّمة، إصلاح الأعطال تلقائياً، توسعة بسيطة عند الضغط، ونقل مؤقت للصيانة. |
| `./` | [`health_check.sh`](./health_check.sh) | وكيل فحص داخلي يعيد تشغيل Zed وcode-server داخل الحاوية عند التوقف. |
| `./` | [`Dockerfile.sovereign`](./Dockerfile.sovereign) | صورة الأساس الخاصة بالبيئة. |
| `./` | [`start_zed.sh`](./start_zed.sh) | تشغيل Zed بإعدادات متوافقة مع المعمارية. |

## 1) تشغيل الحاويات محلياً مع دعم التحمل

```bash
chmod +x run_local_zad.sh container_resilience.sh health_check.sh
REPLICAS=2 ./run_local_zad.sh
```

متغيرات مهمة:
- `IMAGE_NAME` (الافتراضي: `zad-local`)
- `CONTAINER_NAME` (الافتراضي: `zad-local-server`)
- `PORT` (الافتراضي: `6901`)
- `REPLICAS` (الافتراضي: `1`)
- `DOCKERFILE` (الافتراضي: `Dockerfile.sovereign`)

## 2) تفعيل المراقبة والشفاء الذاتي لكل الحاويات

```bash
./container_resilience.sh monitor
```

- يراقب الحاويات التي تحمل label: `zad.resilience=true`.
- إذا كانت الحاوية `exited` أو `unhealthy` يتم إعادة تشغيلها تلقائياً.
- عند ارتفاع استهلاك CPU عن الحد (`CPU_THRESHOLD`) يمكن تشغيل replica إضافي حتى `MAX_REPLICAS`.

متغيرات تخص المراقبة:
- `LABEL_SELECTOR` (الافتراضي: `zad.resilience=true`)
- `CPU_THRESHOLD` (الافتراضي: `80`)
- `MAX_REPLICAS` (الافتراضي: `3`)
- `CHECK_INTERVAL` (الافتراضي: `30` ثانية)

## 3) النقل المؤقت أثناء الصيانة أو الأعطال

```bash
./container_resilience.sh migrate zad-local-server
```

النتيجة:
- تشغيل حاوية مؤقتة من نفس الصورة.
- إذا كان للحاوية الأصلية port منشور، يتم تشغيل المؤقت على منفذ بديل (`+100`).
- بعدها يتم تحويل الترافيك مؤقتاً (من خلال الـ reverse proxy / load balancer) إلى الحاوية الجديدة لحين انتهاء الصيانة.

## فحوصات سريعة

```bash
./container_resilience.sh list
```

```bash
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
```

<<<<< codex/review-and-clean-up-repository-files
Optional environment variables:

- `IMAGE_NAME` (default: `zad-local`)
- `CONTAINER_NAME` (default: `zad-local-server`)
- `PORT` (default: `6901`)
- `DOCKERFILE` (default: `Dockerfile.sovereign`)

## Cloudflare tunnel helper

The tunnel helper is intentionally non-interactive-safe and does **not** run login/create commands automatically.
---

إذا كانت Docker غير مثبتة:

```bash
TUNNEL_NAME=my-zad \
TUNNEL_HOSTNAME=code.example.com \
./cloudflared_setup.sh
```

Then run the printed `cloudflared tunnel ...` commands manually in an authenticated shell.

## GitHub readiness and safety notes

- Do not commit secrets, tunnel tokens, kubeconfigs, private keys, or generated artifacts.
- Use GitHub Actions secrets for credentials.
- Prefer environment variables for tenant/domain-specific values.
- `.gitignore` includes common local/runtime artifacts for this project.
