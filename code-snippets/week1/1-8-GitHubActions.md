# Repository to fork

https://github.com/drsylent/cubix-cloudnative-example-springboot

# Upload artifact snippet (watch for indentation!)

```
    - name: Upload artifact for Docker job
      uses: actions/upload-artifact@v3
      with:
        name: java-app
        path: '${{ github.workspace }}/target/*.jar'
```

# Download artifact snippet (watch for indentation!)

```
    - name: Download artifact from maven job
      uses: actions/download-artifact@v3
      with:
        name: java-app
```
