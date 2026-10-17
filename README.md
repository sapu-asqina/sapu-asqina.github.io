# Katalog Produk — GitHub Pages

Halaman katalog produk (statis, satu file `index.html`).

## Cara publish ke GitHub Pages (personal site)

Repo harus bernama `<username>.github.io` agar tampil di `https://<username>.github.io/`.

### Opsi A — otomatis (PowerShell)

Buka PowerShell di folder ini, lalu jalankan:

```powershell
powershell -ExecutionPolicy Bypass -File .\deploy.ps1
```

Script akan:
1. Membuat commit
2. Meminta Anda login GitHub (sekali saja)
3. Membuat repo `<username>.github.io`
4. Push, lalu mencetak URL situs Anda

### Opsi B — manual

```powershell
git init -b main
git add -A
git commit -m "Add product catalog"
gh auth login
gh repo create <username>.github.io --public --source=. --remote=origin --push
```

Setelah push, buka **Settings → Pages** di repo dan pastikan:
- Source: **Deploy from a branch**
- Branch: **main**, folder **/(root)**

## Catatan
- Entry file wajib bernama `index.html` (sudah).
- Edit `index.html` untuk mengubah produk/harga, lalu commit & push lagi.
