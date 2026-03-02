# Zad DevOps - التشغيل المرن للحاويات

هذا المشروع يدعم تشغيل بيئة Zed/Code-Server داخل حاويات Docker مع 3 قدرات تشغيلية رئيسية:

1. **الشفاء الذاتي (Self-Healing)** للحاويات والخدمات الداخلية.
2. **تحمّل أحمال العمل (Workload Tolerance)** عبر تشغيل نسخ متعددة تلقائياً.
3. **النقل المؤقت (Temporary Migration)** أثناء الصيانة أو الأعطال لتقليل التوقف.

## Implementation Details
The project follows the "Mr. Robot" (Mr. Hajjaj Edition) standards for rapid production and infrastructure dominance.


## Local Deployment (Antigravity Container)
To publish and run the Antigravity Docker image on a local server:

```bash
./deploy_antigravity_local.sh
```

Optional environment overrides:

```bash
IMAGE_NAME=zed-antigravity \
CONTAINER_NAME=antigravity-local \
HOST_PORT=6901 \
CONTAINER_PORT=6901 \
./deploy_antigravity_local.sh
```

This script will:
1. Build the image from `Dockerfile.sovereign`.
2. Remove any existing container with the same name.
3. Run the container in detached mode with `--restart unless-stopped`.
4. Print running status and exposed port mapping.
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

---

إذا كانت Docker غير مثبتة:

```bash
sudo apt-get update && sudo apt-get install -y docker.io
```
