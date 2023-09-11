Except the endpoind of APIs <https://api2-uat.samsassets.com> and <https://api2-dev.samsassets.com>, all the backend management features will only be accessed through Jump Box (20.53.207.135) or VPN in the future. <br>
Now, the backend management features are open to public, and they can be closed anytime, then you only can access to them in the 'virtual network'.

-----

## Links:

### APIs
<https://api2-uat.samsassets.com>

<https://api2-dev.samsassets.com>
### Dev & UAT AKS Dashboard
<https://cluster-devuat.samsassets.com/dashboard>
<br>
Token:<br>
eyJhbGciOiJSUzI1NiIsImtpZCI6IkNWVWtSS3c2ckkyMU81cW4taWZEU1pzelNpZGQxV1BkNk15NFV0a1NENUUifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJha3MtYWRtaW4tdG9rZW4iLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoiYWtzLWFkbWluIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQudWlkIjoiOGQ3YWFhMGEtYmQ5ZC00NmE1LWE5YmItMTMxYzY3ODA5MDQ1Iiwic3ViIjoic3lzdGVtOnNlcnZpY2VhY2NvdW50Omt1YmUtc3lzdGVtOmFrcy1hZG1pbiJ9.nFlN6aMzWIW9dNvFygDNy9w7m32B-mL0swAMsCNtYVuHo8oaT6dZcn79jjBkJBS5knImWnc-r59Ssd7ZBjTLeRB7RautGGmGeY-KjInT8xVTl3mv-tUsayOFoX25beEcg2AHbuULpaLjPVs4nm6wXWy0f3_zObNj9utRMz_owqr2G_MRlIDGDYsBhV9RsfRVv9rc3-cPP2mXXS-Ba_SC08CWsMBBa4_2aXe_99rb-2qy1FbCVpal0zEe3SWXhpcxUB8KguOHwl-tEB9oPZ_EDu68AsZ8vvPgzmrxdWlUa4XWtOdubGF7MGifsH8tT1Y4e1w6hDxB0JQweL22I643wUZdEPdaIkqH_WbKv_L0TmQrY_tVp-aC89rXFVOodMPCsEQxisFJ1CJfpqqynlWvLOm793Ldo-W3aOc4UbJF4J8i2NcEq80-6yiVl6lWnkCeMm8rHGdBWN_puuMSVnIC46KkZNrL-wQiwEuNM4YpxwVgiAPZbJUl_Oh5weeCj4_Jdl-3ttoYsPeSxpQZo1Ak6OlDYrE19jE_VVnaj67NvVoMfovQHLPY3_JlyGcNUjN6YzGYHOwJmOGXRDCYFiQbMgap2N0p_t-wEuEAbQ94rWtAkV51R56ZHfUO4adfGtx51ueKwz-b946IqCLwT5j0r8VHmA5pD4zYYQgBxcoiFBw


### Dev & UAT Linkerd VIZ
<https://linkerd-devuat.samsassets.com><br>
- username: admin
- password: admin
<br>

### Dev & UAT Monitoring - Grafana
<https://grafana-devuat.samsassets.com><br>
- username: admin
- password: p@ssw0rd%-#
<br>

### Dev & UAT Monitoring - Prometheus
This link can only be accessed in the virtual network because there is no password protection. Please use the Jump Box '20.53.207.135' <br>
<prometheus-devuat.samsassets.com><br>
<br>

### Dev & UAT Database Cluster Management
<https://stackgres-devuat.samsassets.com/><br>
- username: admin
- password: 8pqQhMqUZqXQ4BKVdDE8os5Y0wvoZYnggVG3fS1M
<br>

### UAT Axon Server Backend
<https://axon-uat.samsassets.com> <br>

<https://axon-dev.samsassets.com> <br>



### Testing in POSTMAN:
- UAT Auth URL: <https://api2-uat.samsassets.com/api-security/oauth2/authorize>
- UAT Access Token URL: <https://api2-uat.samsassets.com/api-security/oauth2/token>

- DEV Auth URL: <https://api2-dev.samsassets.com/api-security/oauth2/authorize>
- DEV Access Token URL: <https://api2-dev.samsassets.com/api-security/oauth2/token>