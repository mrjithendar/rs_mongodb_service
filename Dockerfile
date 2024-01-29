# Use the official MongoDB image from Docker Hub
FROM mongo:latest
RUN         mkdir /app
WORKDIR     /app
COPY catalogue.js catalogue.js
COPY users.js users.js
# Copy a custom MongoDB configuration file to disable authentication
COPY mongod.conf /etc/mongod.conf

CMD mongod < catalogue.js
CMD mongod < users.js

# Run MongoDB with the custom configuration file
CMD ["mongod", "--config", "/etc/mongod.conf"]