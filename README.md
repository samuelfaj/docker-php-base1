## Usage

1. Build the Docker image:

```sh
docker build -t your-image-name .
```

2. Run a container with the built image:

```sh
docker run -it --rm -v ${PWD}:/workspace your-image-name
```

This command will run the container and mount your current working directory to the /workspace directory within the container. The -it flag ensures that you can interact with the terminal, and the --rm flag removes the container when you exit.

3. Once inside the container, you can use the installed tools (e.g., terraform, aws, gcloud) to perform your development tasks.

## Customizing
Feel free to modify the Dockerfile to add, remove, or change the versions of the tools according to your needs. Remember to rebuild the image after making any changes to the Dockerfile.

## Contributing
If you find any issues, bugs, or have suggestions for improvement, please create an issue or submit a pull request on GitHub. Your contribution is

------

docker buildx build --platform linux/amd64 -t samuelfaj/docker-php-base1:latest .
docker push samuelfaj/docker-php-base1:latest