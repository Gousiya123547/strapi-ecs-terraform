Docker Swam Cronjobs:

What is Docker Swarm?

Docker Swarm is Docker's native clustering solution that allows you to
manage multiple Docker engines as a single virtual host. It enables high
availability, scalability, and load balancing across nodes.

How to Set Up Docker Swarm?

~ Install Docker (on all nodes) ~ Initialize the Swarm

docker swarm init. \# this returns a join command for worker

~ docker swarm join --token worker

On manager node run : ~ docker node ls

Example:

Deploying a Simple Python HTTP Server in Docker Swarm.

docker swarm init

docker service create \\

--name pyserver \\

--publish 8080:8000 \\

python:3 \\

python -m http.server 8000. \# this will launch a python http server on
port 8000 inside the container.

What is Cronjobs?

A CronJob is a time-based task scheduler commonly used in Unix/Linux
systems to automate commands or scripts on a regular schedule (e.g.,
hourly, daily, weekly).

Unlike Kubernetes — which provides a built-in CronJob resource to
schedule recurring tasks — Docker Swarm has no native feature for
time-based job execution but you can achieve this using external tools
or containers with built-in schedulers.

How to create a Cron Job in Docker Swarm (Reliable ways)

1\. Host Machine Cron + Docker commands.

Use your Linux host’s crontab to run Docker commands at scheduled
intervals.

Example: restrat a service every day at 2am

> ~ crontab -e

0 2 \* \* \* docker service update --force my-service. \# add this line

1\. Build a container image with a cron daemon that runs your task.
example: Dockerfile

> FROM alpine
>
> RUN apk add --no-cache curl
>
> RUN echo "\*/5 \* \* \* \* curl https://example.com" \>
> /etc/crontabs/root CMD \["crond", "-f"\]
>
> Deploy to swarm:

docker service create --name cronjob-example my-cron-image 2. Use
swarm-cronjob

> swarm-cronjob is an open-source community tool created by @crazy-max
> that brings Cron-like scheduling to Docker Swarm. Deploy the
> swarm-cronjob manager service
>
> Setup:
>
> docker service create \\
>
> --name swarm-cronjob \\
>
> --constraint 'node.role==manager' \\
>
> --mount
> type=bind,source=/var/run/docker.sock,destination=/var/run/docker.sock
> \\ crazymax/swarm-cronjob \# this must run on a swarm manager node.
>
> References for swarm-cronjob
>
> 1\. Oficial swarm-cronjob GitHub Repository
> [<u>https://github.com/crazy-max/swarm-cronjob</u>](https://github.com/crazy-max/swarm-cronjob)

2\. Docker oficial Doc
[<u>https://docs.docker.com/engine/swarm/</u>](https://docs.docker.com/engine/swarm/)

3\. Docker Hub - crazymax/swarm-cronjob image
[<u>https://hub.docker.com/r/crazymax/swarm-cronjob</u>](https://hub.docker.com/r/crazymax/swarm-cronjob)

4\. Supercronic GitHub https://github.com/aptible/supercronic
