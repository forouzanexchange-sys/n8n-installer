<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=gradient&customColorList=6,11,20&height=220&section=header&text=n8n%20Installer&fontSize=70&fontColor=ffffff&animation=twinkling&fontAlignY=38&desc=One-Click%20n8n%20with%20Auto%20SSL%20%26%20Advanced%20Security&descAlignY=58&descSize=18" width="100%"/>

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04%20%7C%2024.04-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)](https://ubuntu.com/)
[![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![n8n](https://img.shields.io/badge/n8n-EA4B71?style=for-the-badge&logo=n8n&logoColor=white)](https://n8n.io/)
[![Caddy](https://img.shields.io/badge/Caddy-1F88C0?style=for-the-badge&logo=caddy&logoColor=white)](https://caddyserver.com/)

<br>

**نصب خودکار و امن n8n روی سرور شخصی شما**
*همراه با SSL خودکار، Fail2ban، و بهینه‌سازی برای استریم داده‌های زنده*

[نصب سریع](#-نصب-سریع) · [ویژگی‌ها](#-ویژگی‌ها) · [پیش‌نیازها](#-پیش‌نیازها) · [دستورات مفید](#-دستورات-مفید) · [امنیت](#-امنیت)

</div>

---

## ✨ ویژگی‌ها

<table>
<tr>
<td width="50%">

### 🐳 استقرار خودکار
- نصب خودکار **Docker** و **Docker Compose**
- آخرین نسخه پایدار **n8n**
- وب‌سرور سبک **Caddy** به عنوان Reverse Proxy
- نصب idempotent (اجرای مجدد خراب نمی‌شه)

</td>
<td width="50%">

### 🔐 امنیت پیشرفته
- **SSL خودکار** با Let's Encrypt
- **Fail2ban** برای جلوگیری از حملات brute-force
- **SSH Hardening** (غیرفعال‌سازی ورود با پسورد)
- `chmod 600` روی فایل‌های حاوی کلید API

</td>
</tr>
<tr>
<td width="50%">

### ⚡ بهینه‌سازی جریان داده
- پشتیبانی از **Server-Sent Events (SSE)**
- `flush_interval -1` برای جریان زنده بدون تأخیر
- مناسب برای وب‌هوک‌ها و اتوماسیون‌های real-time

</td>
<td width="50%">

### 🤖 پشتیبانی AI
- اتصال به **OpenRouter** یا **OpenAI**
- کلید API به صورت خودکار تنظیم می‌شود
- آماده برای workflowهای هوش مصنوعی

</td>
</tr>
</table>

---

## ⚡ نصب سریع

فقط کافیه این یه دستور رو روی VPS تازه و تمیز (Ubuntu 22.04 یا 24.04) اجرا کنی:

```bash
curl -fsSL https://raw.githubusercontent.com/forouzanexchange-sys/n8n-installer/main/install.sh -o install.sh && bash -n install.sh && sudo bash install.sh
```

اسکریپت به صورت تعاملی ازت اینا رو می‌پرسه:

| # | سؤال | توضیح |
|---|------|-------|
| ۱ | 🌐 **دامنه/زیردامنه** | مثل `n8n.yourdomain.com` |
| ۲ | 📧 **ایمیل** | برای SSL (Let's Encrypt) |
| ۳ | ⏰ **منطقه زمانی** | پیش‌فرض `Asia/Tehran` |
| ۴ | 🔑 **کلید OpenRouter / OpenAI** | اختیاری |
| ۵ | 🌐 **AI Base URL** | پیش‌فرض `https://openrouter.ai/api/v1` |

---

## 📋 پیش‌نیازها

<div align="center">

| مورد | حداقل | توصیه‌شده |
|:---:|:---:|:---:|
| 🐧 **سیستم‌عامل** | Ubuntu 22.04 | Ubuntu 24.04 |
| 💾 **رم** | 1 GB | 2 GB |
| 💿 **فضا** | 5 GB | 10 GB |
| 🌐 **دامنه** | A Record به IPv4 | A + AAAA |
| 🔓 **پورت‌ها** | 80, 443 | 22, 80, 443 |

</div>

### 🌐 تنظیم DNS

قبل از اجرا، مطمئن شو رکورد DNS دامنه‌ت به IP سرور اشاره می‌کنه:

```
نوع: A (یا AAAA برای IPv6)
نام: n8n
مقدار: IP سرور VPS
TTL: خودکار
```

---

## 🛠️ دستورات مفید

بعد از نصب، می‌تونی از این دستورات استفاده کنی:

```bash
# مشاهده لاگ‌های زنده
cd /opt/n8n-docker && docker compose logs -f

# ری‌استارت سرویس‌ها
cd /opt/n8n-docker && docker compose restart

# توقف سرویس‌ها
cd /opt/n8n-docker && docker compose down

# بروزرسانی به آخرین نسخه
cd /opt/n8n-docker && docker compose pull && docker compose up -d

# وضعیت کانتینرها
docker ps
```

---

## 📁 ساختار پروژه

```
/opt/n8n-docker/
├── Caddyfile              # پیکربندی Reverse Proxy
├── docker-compose.yml     # تعریف سرویس‌ها
└── volumes/
    ├── caddy_data/        # گواهی‌های SSL
    ├── caddy_config/      # پیکربندی Caddy
    └── n8n_data/          # داده‌های n8n
```

---

## 🔐 امنیت

اسکریپت این کارها رو **به صورت خودکار** انجام می‌ده:

- ✅ **UFW**: فقط پورت‌های 22، 80، 443 باز می‌شن
- ✅ **Fail2ban**: IP های مشکوک رو بلاک می‌کنه
- ✅ **SSH Hardening**: ورود با پسورد غیرفعال، فقط کلید
- ✅ **File Permissions**: فایل `docker-compose.yml` با `chmod 600` محافظت می‌شه

### ⚠️ هشدار مهم درباره SSH

اسکریپت **فقط زمانی** پسورد SSH رو غیرفعال می‌کنه که یه SSH Key از قبل روی سرور نصب شده باشه. اگه کلید نداشته باشی، اسکریپت بهت هشدار می‌ده و از این مرحله رد می‌شه تا **قفل نشی**.

> 💡 **نکته:** همیشه قبل از اجرای اسکریپت، مطمئن شو که به **کنسول وب هاستینگ** دسترسی داری، تا اگه SSH قطع شد، بتونی از اون راه وارد بشی.

---

## 🔧 تغییرات پس از نصب

### 🔄 عوض کردن دامنه

```bash
sudo nano /opt/n8n-docker/Caddyfile
# دامنه رو تغییر بده
cd /opt/n8n-docker && docker compose restart caddy
```

### 🔑 عوض کردن کلید API

```bash
sudo nano /opt/n8n-docker/docker-compose.yml
# کلید رو تغییر بده
cd /opt/n8n-docker && docker compose up -d
```

---

## ❓ عیب‌یابی

<details>
<summary><b>🔴 صفحه n8n باز نمی‌شه</b></summary>

- مطمئن شو دامنه به IP سرور اشاره می‌کنه: `dig AAAA your-domain.com +short`
- لاگ Caddy رو ببین: `cd /opt/n8n-docker && docker compose logs caddy`
- مطمئن شو پورت‌های 80 و 443 از بیرون قابل دسترسن

</details>

<details>
<summary><b>🟡 خطای 502 Bad Gateway</b></summary>

- مطمئن شو n8n در حال اجراست: `docker ps`
- اگه تازه راه افتاده، ۳۰ ثانیه صبر کن (n8n داره migrations انجام می‌ده)
- اگه بازم مشکل داره: `docker restart n8n-app`

</details>

<details>
<summary><b>🟠 SSL دریافت نشد</b></summary>

- مطمئن شو دامنه به IP سرور اشاره می‌کنه
- اگه دامنه تو Cloudflare هست، موقتاً پروکسی (ابر نارنجی) رو خاموش کن
- مطمئن شو پورت 80 از بیرون قابل دسترسیه

</details>

<details>
<summary><b>🔵 نمی‌تونم با SSH وصل بشم</b></summary>

- اگه SSH Key نداری، از **کنسول وب هاستینگ** وارد شو
- فایل `/etc/ssh/sshd_config` رو ویرایش کن و `PasswordAuthentication yes` رو از حالت کامنت در بیار
- `systemctl restart ssh` رو بزن

</details>

---

## 📜 مجوز

این پروژه تحت مجوز **MIT** منتشر شده است.

---

<div align="center">

### ✦ نویسندگان اسکریپت ✦

<table>
<tr>
<td align="center" width="50%">

### 🌟 کیومرث فروزان

*معمار و طراح اسکریپت*

</td>
<td align="center" width="50%">

### 🌟 آرش

*توسعه‌دهنده و پیاده‌ساز*

</td>
</tr>
</table>

<br>

⭐ اگه این پروژه به کارت اومد، یه ستاره بده

</div>
