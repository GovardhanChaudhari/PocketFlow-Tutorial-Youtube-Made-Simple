# 1. Use an official Python runtime as a parent image
FROM python:alpine

# 2. Set the working directory in the container
WORKDIR /app

# 3. Install any needed system packages (if required, none identified for now)
# RUN apt-get update && apt-get install -y --no-install-recommends some-package && rm -rf /var/lib/apt/lists/*

# 4. Create a non-root user and group
# Running as non-root is a security best practice
RUN addgroup -S appuser && adduser -S -G appuser -h /app appuser

# 5. Copy the requirements file into the container at /app
COPY requirements.txt ./

# 6. Install any needed packages specified in requirements.txt
# Use --no-cache-dir to reduce image size
RUN pip install --no-cache-dir -r requirements.txt

# 7. Copy the rest of the application code into the container at /app
# Ensure .dockerignore is present to exclude unnecessary files
COPY . .

# 8. Change the ownership of the /app directory to the non-root user
# This allows the user to write output files (output.html, youtube_processor.log)
RUN chown -R appuser:appuser /app

# 9. Switch to the non-root user
USER appuser

# 10. Define environment variables placeholders
# These MUST be provided at runtime (e.g., docker run -e ANTHROPIC_PROJECT_ID=... -e ANTHROPIC_REGION=...)
# Do NOT hardcode secrets here.
ENV ANTHROPIC_REGION=""
ENV ANTHROPIC_PROJECT_ID=""

# 11. Define the command to run the application
# Uses main.py as the entry point. Arguments like --url can be appended when running the container.
ENTRYPOINT ["python", "main.py"]

# 12. Default command (optional)
# If no arguments are provided to `docker run`, main.py will prompt for the URL.
CMD []

