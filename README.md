# Health Check Web Application

## Overview
This project implements a web application in Go that provides a RESTful API to perform health checks. The application inserts records into a database table to track health check timestamps and ensures proper HTTP status codes for API responses.

## Features
- Implements a `/healthz` endpoint for health checks.
- Inserts a record into a health check database table on each API call.
- Returns appropriate HTTP status codes based on the success or failure of the insert operation.
- Enforces API constraints such as method restrictions, response caching, and request validation.
- Containerized using Docker and integrated with Jenkins for automated builds and deployments.

## Directory Structure
```
.
├── cmd
│   ├── webapp
│   │   ├── main.go
├── internal
│   ├── config
│   │   ├── config.go
│   ├── database
│   │   ├── db.go
│   ├── handlers
│   │   ├── health.go
├── Dockerfile
├── go.mod
├── go.sum
├── Jenkinsfile
├── Jenkinsfile.commitlint
```


## RESTful API Details
### Endpoint: `/healthz`
- **Method:** `GET`
- **Request Payload:** None (400 Bad Request if any payload is provided)
- **Response:**
  - `200 OK` if the health check record is successfully inserted into the database.
  - `503 Service Unavailable` if the insert operation fails.
  - `405 Method Not Allowed` for any HTTP method other than `GET`.
- **Headers:**
  - `Cache-Control: no-cache`

## Database Schema
A single table is required for health checks:

### `health_checks` Table
| Column    | Type        | Constraints       |
|-----------|------------|------------------|
| check_id  | INT        | PRIMARY KEY, AUTO_INCREMENT |
| datetime  | TIMESTAMP  | NOT NULL, DEFAULT UTC NOW() |

## Deployment & CI/CD
- The application is containerized using Docker.
- A Jenkins job (configured using Jenkins DSL) builds and pushes multi-platform container images to a private Docker Hub repository.
- A webhook triggers the Jenkins job upon new commits.
- Semantic versioning (semver) is used for container image tags.
- `Jenkinsfile` defines the CI/CD pipeline for automated builds and deployments.
- `Jenkinsfile.commitlint` enforces conventional commit messages for better commit history.

## Running the Application Locally
### Prerequisites
- Go installed
- Docker installed
- PostgreSQL database setup

### Steps
1. Clone the repository:
   ```sh
   git clone <repo-url>
   cd <repo-directory>
   ```
2. Configure the database connection in `internal/config/config.go`.
3. Run the application:
   ```sh
   go run cmd/webapp/main.go
   ```

## Running with Docker
1. Build the Docker image:
   ```sh
   docker build -t <image-name> .
   ```
2. Run the container:
   ```sh
   docker run -p 8080:8080 <image-name>
   ```

## API Testing
You can test the API using `curl`:
```sh
curl -X GET http://localhost:8080/healthz -H "Cache-Control: no-cache"
```
Expected response:
- `200 OK` (if the record is successfully inserted)
- `503 Service Unavailable` (if insertion fails)

## References
- [Go Programming Language](https://golang.org/)
- [Docker Documentation](https://docs.docker.com/)
- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
