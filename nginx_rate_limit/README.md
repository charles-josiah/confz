# NGINX Rate Limit Example

## Objective

This configuration aims to demonstrate the functionality of rate limiting in NGINX. <br>
It includes examples of rate limits based on low, medium, and high thresholds, as well as rate limiting based on the User-Agent of the request. <br>
All demonstrations are encapsulated within the same file and can be configured within the specified context. <br>

```nginx

map $http_user_agent $limit_bots {
  default 0;
  ~*(Googlebot|Bingbot) 1;
}

limit_req_zone $binary_remote_addr zone=low:10m rate=1r/s;
limit_req_zone $binary_remote_addr zone=high:10m rate=10r/s;
limit_req_zone $binary_remote_addr zone=bot_limit:10m rate=1r/s;


location /api/low {
  limit_req zone=low burst=3
  proxy_pass http://backend;
}
location /api/high {
  limit_req zone=high burst=20;
  proxy_pass http://backend;
}
location /api/user {
  limit_req zone=bot_limit burst=2;
  proxy_pass http://backend;
}
```

All requests are directed to a reverse proxy and respond with generic API content. 
Adjust the configurations to suit your specific requirements.

