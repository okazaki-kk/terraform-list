# Go-HappyHelming
This is go application to echo Happy Helming.

技術書典6で頒布した「自作アプリをHelm化して簡単デプロイ」のサンプルアプリのリポジトリです

# Usage

Docker Image Build

```
docker build -t govargo/happy-helming .
```

Docker Image Run

```
docker run -d --rm -p 8080:8080 govargo/happy-helming
```

Echo Happy Helming!

```
curl http://<Your Host>:8080/<Your Name>
```
