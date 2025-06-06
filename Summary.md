## What we have read

1. Why cloud
2. What is IAM (Authorisation and Authentication)
3. What is a Security Group
4. What is the purpose of different instance groups
5. What are different protocols and its port
6. Docker lifecycle
7. Write down docker commands
```
Docker build 
docker build -t username/imagename:tag path_to_docker_file
example : docker build -t saigagansatish/product-catalog:v1 .

To List All The Docker Images
docker images

Docker Run
docker run saigagansatish/product-catalog:v1

To see the running containers
docker ps 

To see all the containers 
docker ps -a

How to see logs of a specific container
docker logs container_id

How to invoke inside docker container
docker exec -it container_id /bin/sh

```
8. What is the advantage of multilayer docker file
9. Docker vs Dockerfile vs Kubernetes
10. Terraform Life cycle (init,plan,apply,destroy)
11. What is Statefile in terraform
12. Terraform check whats in file and whats in infra and it overwrites what in file it is done by looking from statefile
13. Statefile management/locking (Because when multiple people are working you need a common place to store state or else same resources will be reapplied)
14. 
