```
$> gem install travis
$> travis login
$> travis encrypt <CODE CLIMATE TEST REPORTER ID>
```

add to travis.yml:
```
addons:
  code_climate:
    repo_token:
      secure: "pdpKV..."
```
