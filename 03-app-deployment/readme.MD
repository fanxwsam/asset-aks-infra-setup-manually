In the root directory of this project, run command:

```
mvn clean package -P build-docker-image
```

```
helm install asset-uat  . -f uat.yaml
helm install asset-prod . -f prod.yaml
```


```
helm upgrade asset-uat . -f uat.yaml
helm upgrade asset-prod . -f prod.yaml
```



API:

Auth:

Zipkin:
