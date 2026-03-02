# Zad DevOps - التشغيل المرن للحاويات

هذا المشروع يدعم تشغيل بيئة Zed/Code-Server داخل حاويات Docker مع 3 قدرات تشغيلية رئيسية:

## Architecture
- **Dockerfile.sovereign**: Base container using Kasm for high-performance streaming.
- **start_zed.sh**: Script to launch Zed with low latency.
- **configure_antigravity.sh**: Injects Antigravity identity into code-server.
- **health_check.sh**: Self-healing agent for service reliability.
- **cloudflared_setup.sh**: Zero-Trust tunnel for secure access.
- **run_zed_local.sh**: Build and run the Docker image locally on `localhost`.

## Run Zed image locally
1. Ensure Docker is installed.
2. Run:
   ```bash
   ./run_zed_local.sh
   ```
3. Open:
   ```
   http://localhost:6901
   ```

You can customize with environment variables:

```bash
IMAGE_NAME=my-zed CONTAINER_NAME=my-zed-local PORT=8080 ./run_zed_local.sh
``` 

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
