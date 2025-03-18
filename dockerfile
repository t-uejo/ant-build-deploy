# Stage 1: Antを使用してWARファイルをビルドする
FROM openjdk:21-oraclelinux8 AS build

# 信頼できる証明書をコンテナにコピー
# COPY path/to/your/certificate.cer /etc/pki/ca-trust/source/anchors/

# 証明書を信頼できる証明書ストアに追加
# RUN update-ca-trust

# Antをインストール
RUN microdnf install -y ant

# Tomcatのライブラリをコピー
COPY --from=tomcat:11.0-jdk21-openjdk-slim /usr/local/tomcat/lib /app/tomcat-lib

# プロジェクトファイルをコピー
COPY app/AntWebProject /app/AntWebProject

# 作業ディレクトリを設定
WORKDIR /app/AntWebProject

# Antを使用してプロジェクトをビルド
RUN ant -lib /app/tomcat-lib

# Stage 2: WARファイルをTomcatコンテナにデプロイ
FROM tomcat:11.0-jdk21-openjdk-slim AS deploy

# ビルドステージからWARファイルをコピー
COPY --from=build /app/AntWebProject/dist/AntWebProject.war /usr/local/tomcat/webapps/

# Tomcatを起動
CMD ["catalina.sh", "run"]