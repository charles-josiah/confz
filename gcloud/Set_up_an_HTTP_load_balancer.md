

### Set up an HTTP load balancer

<p>
You will serve the site via nginx web servers, but you want to ensure that the
environment is fault-tolerant.  Create an HTTP load balancer with a managed
instance group of 2 nginx web servers. Use the following code to configure 
the web servers; the team will replace this with their own configuration later.
</p>

```
cat << EOF > startup.sh
  #! /bin/bash
  apt-get update
  apt-get install -y nginx
  service nginx start
  sed -i -- 's/nginx/Google Cloud Platform - '"\$HOSTNAME"'/' /var/www/html/index.nginx-debian.html
EOF
```
  
<p>
  Note: There is a limit to the resources you are allowed to create in your project, 
  so do not create more than 2 instances in your managed instance group. 
  If you do, the lab might end and you might be banned.
</p>


You need to:
<ul>
<li>Create an instance template. Don't use the default machine type. Make sure you specify e2-medium as the machine type.</li>
<li>Create a managed instance group based on the template.</li>
<li>Create a firewall rule named as Firewall rule to allow traffic (80/tcp).</li>
<li>Create a health check.</li>
<li>Create a backend service and add your instance group as the backend to the backend service group with named port (http:80).</li>
<li>Create a URL map, and target the HTTP proxy to route the incoming requests to the default backend service.</li>
<li>Create a target HTTP proxy to route requests to your URL map</li>
<li>Create a forwarding rule.</li>
</ul>	


#### Setup Script 

* Set the default region and zone for all resources

```
gcloud config set compute/region us-central1
 export REGION="us-central1"
gcloud config set compute/zone us-central1-f
 export ZONE="us-central1-f"
```

* Create an HTTP load balancer

```
gcloud compute instance-templates create n-lb-backend-template \
   --region=$REGION \
   --network=default \
   --subnet=default \
   --tags=allow-health-check \
   --machine-type=e2-medium \
   --image-family=debian-11 \
   --image-project=debian-cloud \
   --metadata=startup-script=cat\ \<\<\ EOF\ \>\ startup.sh$'\n'\#\!\ /bin/bash$'\n'apt-get\ update$'\n'apt-get\ install\ -y\ nginx$'\n'service\ nginx\ start$'\n'sed\ -i\ --\ \'s/nginx/Google\ Cloud\ Platform\ -\ \'\"\\\$HOSTNAME\"\'/\'\ /var/www/html/index.nginx-debian.html$'\n'EOF
```

* Create a managed instance group based on the template:
```
gcloud compute instance-groups managed create n-lb-backend-group \
   --template=n-lb-backend-template --size=2 --zone=$ZONE

gcloud compute instance-groups set-named-ports n-lb-backend-group \
    --named-ports http:80 \
    --zone $ZONE
```

* Create the firewall rule.

```
gcloud compute firewall-rules create fw-allow-health-check \
  --network=default \
  --action=allow \
  --direction=ingress \
  --source-ranges=130.211.0.0/22,35.191.0.0/16 \
  --target-tags=allow-health-check \
  --rules=tcp:80

gcloud compute firewall-rules create allow-tcp-rule-241 \
  --network=default \
  --action=allow \
  --direction=ingress \
  --source-ranges=0.0.0.0 \
  --target-tags=allow-health-check \
  --rules=tcp:80
```

* Now that the instances are up and running, set up a global static external IP address that your customers use to reach your load balancer:

```
gcloud compute addresses create n-lb-ipv4-1 \
  --ip-version=IPV4 \
  --global
```

* Create a health check for the load balancer:

```
gcloud compute health-checks create http n-http-basic-check \
  --port 80
```

* Create a backend service:

```
gcloud compute backend-services create n-web-backend-service \
  --protocol=HTTP \
  --port-name=http \
  --health-checks=n-http-basic-check \
  --global
```

* Add your instance group as the backend to the backend service:

```
gcloud compute backend-services add-backend n-web-backend-service \
  --instance-group=n-lb-backend-group \
  --instance-group-zone=$ZONE \
  --global
```

* Create a URL map to route the incoming requests to the default backend service:

```
gcloud compute url-maps create n-web-map-http \
    --default-service n-web-backend-service
```

* Create a target HTTP proxy to route requests to your URL map:

```
gcloud compute target-http-proxies create n-http-lb-proxy \
    --url-map n-web-map-http
```

* Create a global forwarding rule to route incoming requests to the proxy:

```
gcloud compute forwarding-rules create http-content-rule \
   --address=n-lb-ipv4-1\
   --global \
   --target-http-proxy=n-http-lb-proxy \
   --ports=80
```
