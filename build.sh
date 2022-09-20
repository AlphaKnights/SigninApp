npm run build
docker build . -t ak-signin
docker stop ak-signin
docker rm ak-signin
docker run --name ak-signin -d -p 8082:80 ak-signin:latest