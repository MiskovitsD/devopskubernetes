# Kustomize changes

Since the recording of the practice exercise, 
some features have changed in Kustomize.

The version I have currently (bundled in kubectl, with Docker Desktop):

```
Client Version: v1.28.2
Kustomize Version: v5.0.4-0.20230601165947-6ce0bf390ce3
```

You can check it with `kubectl version --client`.

If the major version of Kustomize is 4 (example: `Kustomize Version: v4.5.7`), then everything will work, just like in the video.
The last kubectl that uses this Kustomize version is 1.26.11 - you can install it if you feel like it is easier for you.

However I recommend applying the changes below instead - after all, probably you will encounter these new syntaxes.
These changes also work with version 4 of Kustomize.

# Breaking changes

These changes MUST be applied, as without these, the commands will not work.

## Patching with strategic merge, using patches

In the video, we use this:

```yaml
patches:
- patch-replicacount.yaml
```

This is an old styling of patching that got removed in version 5 of Kustomize. Instead, use this:

```yaml
patches:
- path: patch-replicacount.yaml
```

Just simply add the path in front of the file name.

# Deprecated changes

These changes are recommended to be done, as later on these might stop functioning.
Currently only a warning message will appear for these.

## Using bases

For the overlays/variants, the base was defined with the help of `bases`, like this:

```yaml
bases:
- ../../base
```

This is deprecated, and now it is recommended to add this to the resources:

```yaml
resources:
- ../../base
```
