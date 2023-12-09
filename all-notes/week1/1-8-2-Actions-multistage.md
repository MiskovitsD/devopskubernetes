# Placeholders

Fill in the USERNAME in 3 files.

# Create a container locally on your computer, run it and test it

docker-run-from-local script, builds it and runs it, Ctrl+C stops it

Call with Postman

# Extend the GitHub Actions pipeline with containerization

We'll have two jobs - one which creates the JAR, one that creates the Docker container. Rename the file and the job.

Create a new job (duplicate the existing one). Call the original `maven`, the new one `docker`.

We want them to run one after the other:

```yaml
  docker:
    runs-on: ubuntu-latest
    needs: maven
```

We must pass the JAR between the jobs. Have these:

```yaml
    - name: Upload artifact for Docker job
      uses: actions/upload-artifact@v3
      with:
        name: java-app
        path: '${{ github.workspace }}/target/*.jar'
```

```yaml
    - name: Download artifact from maven job
      uses: actions/download-artifact@v3
      with:
        name: java-app
```

Then create the Docker commands. docker-publish-help.txt file has helping commands -> put in the YAML as new commands, fill the placeholders:

```yaml
    - name: Docker login
      run: docker login ghcr.io -u drsylent -p ${{ github.token }}
    - name: Build the Docker image
      run: docker build . --file Dockerfile --tag ghcr.io/drsylent/cubix/cloudnative/demo:actions
    - name: Push the Docker image
      run: docker push ghcr.io/drsylent/cubix/cloudnative/demo:actions
```

# Download the container, run it and test it

docker-run-from-github script - replace the placeholder

Call with Postman/Bruno.
