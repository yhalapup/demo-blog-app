FROM nginx:1.25-bookworm

# Install dependencies
RUN apt-get update -qq && apt-get -y install apache2-utils

ARG SERVER_NAME
ENV SERVER_NAME ${SERVER_NAME}

# establish where Nginx should look for files
ENV APP_ROOT /usr/src/app

# Set our working directory inside the image
WORKDIR $APP_ROOT

# create log directory
RUN mkdir log && chown -R nginx:nginx log

# copy over static assets
COPY --from=ruby-challenge.app.prod:latest --chown=nginx:nginx  $APP_ROOT/public public/

# Copy Nginx config template
COPY --chown=nginx:nginx ./docker/nginx.conf /tmp/docker.nginx

# substitute variable references in the Nginx config template for real values from the environment
# put the final config in its place
RUN envsubst '$SERVER_NAME $APP_ROOT' < /tmp/docker.nginx > /etc/nginx/conf.d/default.conf

RUN echo "/tmp/docker.nginx"
RUN cat /tmp/docker.nginx

RUN echo $APP_ROOT
RUN echo $SERVER_NAME
RUN /bin/sh -c "echo hello"
RUN echo "/etc/nginx/conf.d/default.conf"
RUN cat /etc/nginx/conf.d/default.conf


# permissions and nginx user for tightened security
RUN chown -R nginx:nginx $APP_ROOT && chmod -R 755 $APP_ROOT && \
        chown -R nginx:nginx /var/cache/nginx && \
        chown -R nginx:nginx /var/log/nginx && \
        chmod -R 755 /var/log/nginx; \
        chown -R nginx:nginx /etc/nginx/conf.d
RUN touch /var/run/nginx.pid && chown -R nginx:nginx /var/run/nginx.pid

# # Uncomment to keep the nginx logs inside the container - Leave commented for logging to stdout and stderr
# RUN mkdir -p /var/log/nginx
# RUN unlink /var/log/nginx/access.log \
#     && unlink /var/log/nginx/error.log \
#     && touch /var/log/nginx/access.log \
#     && touch /var/log/nginx/error.log \
#     && chown nginx /var/log/nginx/*log \
#     && chmod 644 /var/log/nginx/*log

USER nginx

EXPOSE 8000

CMD [ "nginx", "-g", "daemon off;" ]
