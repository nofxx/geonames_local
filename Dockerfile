# Use the official MongoDB image from Docker Hub
FROM mongo:latest

# Set the MONGO_INITDB_ROOT_USERNAME and MONGO_INITDB_ROOT_PASSWORD environment variables
# Replace 'admin' and 'password' with your desired credentials
# ENV MONGO_INITDB_ROOT_USERNAME=admin
# ENV MONGO_INITDB_ROOT_PASSWORD=password

# Expose the default MongoDB port
EXPOSE 27017

# Command to run when the container starts
CMD ["mongod"]