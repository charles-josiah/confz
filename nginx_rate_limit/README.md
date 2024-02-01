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

## Lets Test :D 

Start nginx on docker
```docker run -v ./etc/nginx:/etc/nginx -v ./var/www/html:/var/www/html   -p 80:80 nginx_rate_limit```

location /api/low
Limits: 1 request/seq
Burst: 3 request/seq 


lnx_client: 
$ ab -c 1 -n 1 http://172.31.234.41/api/low/test1
# 1 connection and 1 concorrent connection

server_log: 
172.31.234.11 - - [31/Jan/2024:13:51:49 +0000] "GET /api/low/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"

lnx_client:
ab -c 1 -n 5 http://172.31.234.41/api/low/test1
# 5 connection and 1 concorrent connection

server_log
172.31.234.11 - - [31/Jan/2024:13:54:11 +0000] "GET /api/low/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:13:54:12 +0000] "GET /api/low/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:13:54:13 +0000] "GET /api/low/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:13:54:14 +0000] "GET /api/low/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:13:54:15 +0000] "GET /api/low/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"

ab -c 5 -n 15 http://172.31.234.41/api/low/test1
# 15 connection and 5 concorrent connection

Ratelimit has to the job
172.31.234.11 - - [31/Jan/2024:13:54:11 +0000] "GET /api/low/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:13:54:12 +0000] "GET /api/low/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:13:54:13 +0000] "GET /api/low/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:13:54:14 +0000] "GET /api/low/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:13:54:15 +0000] "GET /api/low/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:13:57:49 +0000] "GET /api/low/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:13:57:49 +0000] "GET /api/low/test1 HTTP/1.0" 503 197 "-" "ApacheBench/2.3"
2024/01/31 13:57:49 [error] 20#20: *17 limiting requests, excess: 3.992 by zone "low", client: 172.31.234.11, server: localhost, request: "GET /api/low/test1 HTTP/1.0", host: "172.31.234.41"
2024/01/31 13:57:49 [error] 20#20: *19 limiting requests, excess: 3.990 by zone "low", client: 172.31.234.11, server: localhost, request: "GET /api/low/test1 HTTP/1.0", host: "172.31.234.41"
172.31.234.11 - - [31/Jan/2024:13:57:49 +0000] "GET /api/low/test1 HTTP/1.0" 503 197 "-" "ApacheBench/2.3"
2024/01/31 13:57:49 [error] 20#20: *20 limiting requests, excess: 3.986 by zone "low", client: 172.31.234.11, server: localhost, request: "GET /api/low/test1 HTTP/1.0", host: "172.31.234.41"
2024/01/31 13:57:49 [error] 20#20: *21 limiting requests, excess: 3.986 by zone "low", client: 172.31.234.11, server: localhost, request: "GET /api/low/test1 HTTP/1.0", host: "172.31.234.41"
172.31.234.11 - - [31/Jan/2024:13:57:49 +0000] "GET /api/low/test1 HTTP/1.0" 503 197 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:13:57:49 +0000] "GET /api/low/test1 HTTP/1.0" 503 197 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:13:57:49 +0000] "GET /api/low/test1 HTTP/1.0" 503 197 "-" "ApacheBench/2.3"
2024/01/31 13:57:49 [error] 20#20: *22 limiting requests, excess: 3.980 by zone "low", client: 172.31.234.11, server: localhost, request: "GET /api/low/test1 HTTP/1.0", host: "172.31.234.41"
2024/01/31 13:57:49 [error] 20#20: *23 limiting requests, excess: 3.978 by zone "low", client: 172.31.234.11, server: localhost, request: "GET /api/low/test1 HTTP/1.0", host: "172.31.234.41"
172.31.234.11 - - [31/Jan/2024:13:57:49 +0000] "GET /api/low/test1 HTTP/1.0" 503 197 "-" "ApacheBench/2.3"
2024/01/31 13:57:49 [error] 20#20: *24 limiting requests, excess: 3.972 by zone "low", client: 172.31.234.11, server: localhost, request: "GET /api/low/test1 HTTP/1.0", host: "172.31.234.41"
172.31.234.11 - - [31/Jan/2024:13:57:49 +0000] "GET /api/low/test1 HTTP/1.0" 503 197 "-" "ApacheBench/2.3"
2024/01/31 13:57:49 [error] 20#20: *25 limiting requests, excess: 3.971 by zone "low", client: 172.31.234.11, server: localhost, request: "GET /api/low/test1 HTTP/1.0", host: "172.31.234.41"
172.31.234.11 - - [31/Jan/2024:13:57:49 +0000] "GET /api/low/test1 HTTP/1.0" 503 197 "-" "ApacheBench/2.3"
2024/01/31 13:57:49 [error] 20#20: *26 limiting requests, excess: 3.966 by zone "low", client: 172.31.234.11, server: localhost, request: "GET /api/low/test1 HTTP/1.0", host: "172.31.234.41"
172.31.234.11 - - [31/Jan/2024:13:57:49 +0000] "GET /api/low/test1 HTTP/1.0" 503 197 "-" "ApacheBench/2.3"
2024/01/31 13:57:49 [error] 20#20: *27 limiting requests, excess: 3.966 by zone "low", client: 172.31.234.11, server: localhost, request: "GET /api/low/test1 HTTP/1.0", host: "172.31.234.41"
172.31.234.11 - - [31/Jan/2024:13:57:49 +0000] "GET /api/low/test1 HTTP/1.0" 503 197 "-" "ApacheBench/2.3"
2024/01/31 13:57:49 [error] 21#21: *28 limiting requests, excess: 3.958 by zone "low", client: 172.31.234.11, server: localhost, request: "GET /api/low/test1 HTTP/1.0", host: "172.31.234.41"
172.31.234.11 - - [31/Jan/2024:13:57:49 +0000] "GET /api/low/test1 HTTP/1.0" 503 197 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:13:57:50 +0000] "GET /api/low/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:13:57:51 +0000] "GET /api/low/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:13:57:52 +0000] "GET /api/low/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"





 ab -c 1 -n 30 http://172.31.234.41/api/high/test1









 ab -c 31  -n 60 http://172.31.234.41/api/high/test1
172.31.234.11 - - [31/Jan/2024:14:09:06 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:09:06 +0000] "GET /api/high/test1 HTTP/1.0" 503 197 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:09:06 +0000] "GET /api/high/test1 HTTP/1.0" 503 197 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:09:06 +0000] "GET /api/high/test1 HTTP/1.0" 503 197 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:09:06 +0000] "GET /api/high/test1 HTTP/1.0" 503 197 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:09:06 +0000] "GET /api/high/test1 HTTP/1.0" 503 197 "-" "ApacheBench/2.3"
2024/01/31 14:09:06 [error] 20#20: *594 limiting requests, excess: 20.890 by zone "high", client: 172.31.234.11, server: localhost, request: "GET /api/high/test1 HTTP/1.0", host: "172.31.234.41"
2024/01/31 14:09:06 [error] 22#22: *582 limiting requests, excess: 20.890 by zone "high", client: 172.31.234.11, server: localhost, request: "GET /api/high/test1 HTTP/1.0", host: "172.31.234.41"
2024/01/31 14:09:06 [error] 23#23: *589 limiting requests, excess: 20.890 by zone "high", client: 172.31.234.11, server: localhost, request: "GET /api/high/test1 HTTP/1.0", host: "172.31.234.41"
2024/01/31 14:09:06 [error] 23#23: *595 limiting requests, excess: 20.890 by zone "high", client: 172.31.234.11, server: localhost, request: "GET /api/high/test1 HTTP/1.0", host: "172.31.234.41"
2024/01/31 14:09:06 [error] 22#22: *590 limiting requests, excess: 20.890 by zone "high", client: 172.31.234.11, server: localhost, request: "GET /api/high/test1 HTTP/1.0", host: "172.31.234.41"
172.31.234.11 - - [31/Jan/2024:14:09:06 +0000] "GET /api/high/test1 HTTP/1.0" 503 197 "-" "ApacheBench/2.3"
2024/01/31 14:09:06 [error] 21#21: *593 limiting requests, excess: 20.890 by zone "high", client: 172.31.234.11, server: localhost, request: "GET /api/high/test1 HTTP/1.0", host: "172.31.234.41"
2024/01/31 14:09:06 [error] 22#22: *597 limiting requests, excess: 20.890 by zone "high", client: 172.31.234.11, server: localhost, request: "GET /api/high/test1 HTTP/1.0", host: "172.31.234.41"
2024/01/31 14:09:06 [error] 23#23: *592 limiting requests, excess: 20.890 by zone "high", client: 172.31.234.11, server: localhost, request: "GET /api/high/test1 HTTP/1.0", host: "172.31.234.41"
172.31.234.11 - - [31/Jan/2024:14:09:06 +0000] "GET /api/high/test1 HTTP/1.0" 503 197 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:09:06 +0000] "GET /api/high/test1 HTTP/1.0" 503 197 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:09:06 +0000] "GET /api/high/test1 HTTP/1.0" 503 197 "-" "ApacheBench/2.3"
2024/01/31 14:09:06 [error] 21#21: *591 limiting requests, excess: 20.890 by zone "high", client: 172.31.234.11, server: localhost, request: "GET /api/high/test1 HTTP/1.0", host: "172.31.234.41"
2024/01/31 14:09:06 [error] 22#22: *596 limiting requests, excess: 20.890 by zone "high", client: 172.31.234.11, server: localhost, request: "GET /api/high/test1 HTTP/1.0", host: "172.31.234.41"
172.31.234.11 - - [31/Jan/2024:14:09:06 +0000] "GET /api/high/test1 HTTP/1.0" 503 197 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:09:06 +0000] "GET /api/high/test1 HTTP/1.0" 503 197 "-" "ApacheBench/2.3"
2024/01/31 14:09:06 [error] 20#20: *598 limiting requests, excess: 20.880 by zone "high", client: 172.31.234.11, server: localhost, request: "GET /api/high/test1 HTTP/1.0", host: "172.31.234.41"
172.31.234.11 - - [31/Jan/2024:14:09:06 +0000] "GET /api/high/test1 HTTP/1.0" 503 197 "-" "ApacheBench/2.3"
2024/01/31 14:09:06 [error] 20#20: *599 limiting requests, excess: 20.780 by zone "high", client: 172.31.234.11, server: localhost, request: "GET /api/high/test1 HTTP/1.0", host: "172.31.234.41"
172.31.234.11 - - [31/Jan/2024:14:09:06 +0000] "GET /api/high/test1 HTTP/1.0" 503 197 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:09:06 +0000] "GET /api/high/test1 HTTP/1.0" 503 197 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:09:06 +0000] "GET /api/high/test1 HTTP/1.0" 503 197 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:09:06 +0000] "GET /api/high/test1 HTTP/1.0" 503 197 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:09:06 +0000] "GET /api/high/test1 HTTP/1.0" 503 197 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:09:06 +0000] "GET /api/high/test1 HTTP/1.0" 503 197 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:09:06 +0000] "GET /api/high/test1 HTTP/1.0" 503 197 "-" "ApacheBench/2.3"
2024/01/31 14:09:06 [error] 21#21: *603 limiting requests, excess: 20.770 by zone "high", client: 172.31.234.11, server: localhost, request: "GET /api/high/test1 HTTP/1.0", host: "172.31.234.41"
2024/01/31 14:09:06 [error] 20#20: *604 limiting requests, excess: 20.770 by zone "high", client: 172.31.234.11, server: localhost, request: "GET /api/high/test1 HTTP/1.0", host: "172.31.234.41"
2024/01/31 14:09:06 [error] 22#22: *602 limiting requests, excess: 20.770 by zone "high", client: 172.31.234.11, server: localhost, request: "GET /api/high/test1 HTTP/1.0", host: "172.31.234.41"
2024/01/31 14:09:06 [error] 23#23: *607 limiting requests, excess: 20.770 by zone "high", client: 172.31.234.11, server: localhost, request: "GET /api/high/test1 HTTP/1.0", host: "172.31.234.41"
2024/01/31 14:09:06 [error] 22#22: *605 limiting requests, excess: 20.770 by zone "high", client: 172.31.234.11, server: localhost, request: "GET /api/high/test1 HTTP/1.0", host: "172.31.234.41"
2024/01/31 14:09:06 [error] 20#20: *601 limiting requests, excess: 20.770 by zone "high", client: 172.31.234.11, server: localhost, request: "GET /api/high/test1 HTTP/1.0", host: "172.31.234.41"
2024/01/31 14:09:06 [error] 21#21: *606 limiting requests, excess: 20.770 by zone "high", client: 172.31.234.11, server: localhost, request: "GET /api/high/test1 HTTP/1.0", host: "172.31.234.41"
2024/01/31 14:09:06 [error] 20#20: *600 limiting requests, excess: 20.770 by zone "high", client: 172.31.234.11, server: localhost, request: "GET /api/high/test1 HTTP/1.0", host: "172.31.234.41"
2024/01/31 14:09:06 [error] 22#22: *608 limiting requests, excess: 20.760 by zone "high", client: 172.31.234.11, server: localhost, request: "GET /api/high/test1 HTTP/1.0", host: "172.31.234.41"
172.31.234.11 - - [31/Jan/2024:14:09:06 +0000] "GET /api/high/test1 HTTP/1.0" 503 197 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:09:06 +0000] "GET /api/high/test1 HTTP/1.0" 503 197 "-" "ApacheBench/2.3"
2024/01/31 14:09:06 [error] 22#22: *609 limiting requests, excess: 20.760 by zone "high", client: 172.31.234.11, server: localhost, request: "GET /api/high/test1 HTTP/1.0", host: "172.31.234.41"
172.31.234.11 - - [31/Jan/2024:14:09:06 +0000] "GET /api/high/test1 HTTP/1.0" 503 197 "-" "ApacheBench/2.3"
2024/01/31 14:09:06 [error] 20#20: *610 limiting requests, excess: 20.680 by zone "high", client: 172.31.234.11, server: localhost, request: "GET /api/high/test1 HTTP/1.0", host: "172.31.234.41"
172.31.234.11 - - [31/Jan/2024:14:09:06 +0000] "GET /api/high/test1 HTTP/1.0" 503 197 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:09:06 +0000] "GET /api/high/test1 HTTP/1.0" 503 197 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:09:06 +0000] "GET /api/high/test1 HTTP/1.0" 503 197 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:09:06 +0000] "GET /api/high/test1 HTTP/1.0" 503 197 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:09:06 +0000] "GET /api/high/test1 HTTP/1.0" 503 197 "-" "ApacheBench/2.3"
2024/01/31 14:09:06 [error] 23#23: *613 limiting requests, excess: 20.670 by zone "high", client: 172.31.234.11, server: localhost, request: "GET /api/high/test1 HTTP/1.0", host: "172.31.234.41"
2024/01/31 14:09:06 [error] 22#22: *612 limiting requests, excess: 20.670 by zone "high", client: 172.31.234.11, server: localhost, request: "GET /api/high/test1 HTTP/1.0", host: "172.31.234.41"
2024/01/31 14:09:06 [error] 20#20: *614 limiting requests, excess: 20.670 by zone "high", client: 172.31.234.11, server: localhost, request: "GET /api/high/test1 HTTP/1.0", host: "172.31.234.41"
2024/01/31 14:09:06 [error] 21#21: *615 limiting requests, excess: 20.670 by zone "high", client: 172.31.234.11, server: localhost, request: "GET /api/high/test1 HTTP/1.0", host: "172.31.234.41"
2024/01/31 14:09:06 [error] 22#22: *611 limiting requests, excess: 20.670 by zone "high", client: 172.31.234.11, server: localhost, request: "GET /api/high/test1 HTTP/1.0", host: "172.31.234.41"
172.31.234.11 - - [31/Jan/2024:14:09:06 +0000] "GET /api/high/test1 HTTP/1.0" 503 197 "-" "ApacheBench/2.3"
2024/01/31 14:09:06 [error] 20#20: *616 limiting requests, excess: 20.670 by zone "high", client: 172.31.234.11, server: localhost, request: "GET /api/high/test1 HTTP/1.0", host: "172.31.234.41"
172.31.234.11 - - [31/Jan/2024:14:09:06 +0000] "GET /api/high/test1 HTTP/1.0" 503 197 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:09:06 +0000] "GET /api/high/test1 HTTP/1.0" 503 197 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:09:06 +0000] "GET /api/high/test1 HTTP/1.0" 503 197 "-" "ApacheBench/2.3"
2024/01/31 14:09:06 [error] 21#21: *617 limiting requests, excess: 20.660 by zone "high", client: 172.31.234.11, server: localhost, request: "GET /api/high/test1 HTTP/1.0", host: "172.31.234.41"
2024/01/31 14:09:06 [error] 23#23: *620 limiting requests, excess: 20.660 by zone "high", client: 172.31.234.11, server: localhost, request: "GET /api/high/test1 HTTP/1.0", host: "172.31.234.41"
2024/01/31 14:09:06 [error] 23#23: *619 limiting requests, excess: 20.660 by zone "high", client: 172.31.234.11, server: localhost, request: "GET /api/high/test1 HTTP/1.0", host: "172.31.234.41"
172.31.234.11 - - [31/Jan/2024:14:09:06 +0000] "GET /api/high/test1 HTTP/1.0" 503 197 "-" "ApacheBench/2.3"
2024/01/31 14:09:06 [error] 23#23: *618 limiting requests, excess: 20.660 by zone "high", client: 172.31.234.11, server: localhost, request: "GET /api/high/test1 HTTP/1.0", host: "172.31.234.41"
172.31.234.11 - - [31/Jan/2024:14:09:06 +0000] "GET /api/high/test1 HTTP/1.0" 503 197 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:09:06 +0000] "GET /api/high/test1 HTTP/1.0" 503 197 "-" "ApacheBench/2.3"
2024/01/31 14:09:06 [error] 22#22: *621 limiting requests, excess: 20.600 by zone "high", client: 172.31.234.11, server: localhost, request: "GET /api/high/test1 HTTP/1.0", host: "172.31.234.41"
2024/01/31 14:09:06 [error] 22#22: *623 limiting requests, excess: 20.590 by zone "high", client: 172.31.234.11, server: localhost, request: "GET /api/high/test1 HTTP/1.0", host: "172.31.234.41"
2024/01/31 14:09:06 [error] 23#23: *624 limiting requests, excess: 20.590 by zone "high", client: 172.31.234.11, server: localhost, request: "GET /api/high/test1 HTTP/1.0", host: "172.31.234.41"
172.31.234.11 - - [31/Jan/2024:14:09:06 +0000] "GET /api/high/test1 HTTP/1.0" 503 197 "-" "ApacheBench/2.3"
2024/01/31 14:09:06 [error] 22#22: *622 limiting requests, excess: 20.590 by zone "high", client: 172.31.234.11, server: localhost, request: "GET /api/high/test1 HTTP/1.0", host: "172.31.234.41"
172.31.234.11 - - [31/Jan/2024:14:09:06 +0000] "GET /api/high/test1 HTTP/1.0" 503 197 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:09:06 +0000] "GET /api/high/test1 HTTP/1.0" 503 197 "-" "ApacheBench/2.3"
2024/01/31 14:09:06 [error] 23#23: *626 limiting requests, excess: 20.570 by zone "high", client: 172.31.234.11, server: localhost, request: "GET /api/high/test1 HTTP/1.0", host: "172.31.234.41"
172.31.234.11 - - [31/Jan/2024:14:09:06 +0000] "GET /api/high/test1 HTTP/1.0" 503 197 "-" "ApacheBench/2.3"
2024/01/31 14:09:06 [error] 23#23: *625 limiting requests, excess: 20.570 by zone "high", client: 172.31.234.11, server: localhost, request: "GET /api/high/test1 HTTP/1.0", host: "172.31.234.41"
172.31.234.11 - - [31/Jan/2024:14:09:06 +0000] "GET /api/high/test1 HTTP/1.0" 503 197 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:09:06 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:09:06 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:09:06 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:09:06 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:09:06 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:09:07 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:09:07 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:09:07 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:09:07 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:09:07 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:09:07 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:09:07 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:09:07 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:09:07 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:09:07 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:09:08 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:09:08 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:09:08 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:09:08 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:09:08 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"


ab -c 19  -n 60 http://172.31.234.41/api/high/test1
172.31.234.11 - - [31/Jan/2024:14:11:49 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:11:49 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:11:49 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:11:49 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:11:49 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:11:50 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:11:50 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:11:50 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:11:50 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:11:50 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:11:50 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:11:50 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:11:50 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:11:50 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:11:50 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:11:51 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:11:51 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:11:51 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:11:51 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:11:51 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:11:51 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:11:51 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:11:51 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:11:51 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:11:51 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:11:52 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:11:52 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:11:52 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:11:52 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:11:52 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:11:52 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:11:52 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:11:52 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:11:52 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:11:52 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:11:53 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:11:53 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:11:53 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:11:53 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:11:53 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:11:53 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:11:53 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:11:53 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:11:53 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:11:53 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:11:54 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:11:54 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:11:54 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:11:54 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:11:54 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:11:54 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:11:54 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:11:54 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:11:54 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:11:54 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:11:55 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:11:55 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:11:55 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:11:55 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:11:55 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"

 ab -c 20  -n 60 http://172.31.234.41/api/high/test1
172.31.234.11 - - [31/Jan/2024:14:12:38 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:12:38 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:12:38 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:12:38 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:12:38 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:12:38 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:12:39 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:12:39 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:12:39 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:12:39 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:12:39 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:12:39 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:12:39 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:12:39 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:12:39 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:12:39 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:12:40 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:12:40 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:12:40 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:12:40 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:12:40 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:12:40 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:12:40 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:12:40 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:12:40 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:12:40 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:12:41 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:12:41 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:12:41 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:12:41 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:12:41 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:12:41 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:12:41 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:12:41 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:12:41 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:12:41 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:12:42 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:12:42 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:12:42 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:12:42 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:12:42 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:12:42 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:12:42 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:12:42 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:12:42 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:12:42 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:12:43 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:12:43 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:12:43 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:12:43 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:12:43 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:12:43 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:12:43 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:12:43 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:12:43 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:12:43 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:12:44 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:12:44 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:12:44 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"
172.31.234.11 - - [31/Jan/2024:14:12:44 +0000] "GET /api/high/test1 HTTP/1.0" 404 335 "-" "ApacheBench/2.3"

ab -c 1 -n 10 -H  "User-Agent: Bingbot" http://172.31.234.41/api/user
172.31.234.11 - - [31/Jan/2024:14:25:00 +0000] "GET /api/user HTTP/1.0" 499 0 "-" "Bingbot"
172.31.234.11 - - [31/Jan/2024:14:25:09 +0000] "GET /api/user HTTP/1.0" 404 335 "-" "Bingbot"
172.31.234.11 - - [31/Jan/2024:14:25:10 +0000] "GET /api/user HTTP/1.0" 404 335 "-" "Bingbot"
172.31.234.11 - - [31/Jan/2024:14:25:11 +0000] "GET /api/user HTTP/1.0" 404 335 "-" "Bingbot"
172.31.234.11 - - [31/Jan/2024:14:25:12 +0000] "GET /api/user HTTP/1.0" 404 335 "-" "Bingbot"
172.31.234.11 - - [31/Jan/2024:14:25:13 +0000] "GET /api/user HTTP/1.0" 404 335 "-" "Bingbot"
172.31.234.11 - - [31/Jan/2024:14:25:14 +0000] "GET /api/user HTTP/1.0" 404 335 "-" "Bingbot"
172.31.234.11 - - [31/Jan/2024:14:25:15 +0000] "GET /api/user HTTP/1.0" 404 335 "-" "Bingbot"
172.31.234.11 - - [31/Jan/2024:14:25:16 +0000] "GET /api/user HTTP/1.0" 404 335 "-" "Bingbot"
172.31.234.11 - - [31/Jan/2024:14:25:17 +0000] "GET /api/user HTTP/1.0" 404 335 "-" "Bingbot"
172.31.234.11 - - [31/Jan/2024:14:25:18 +0000] "GET /api/user HTTP/1.0" 404 335 "-" "Bingbot"

 ab -c 4 -n 10 -H  "User-Agent: Bingbot" http://172.31.234.41/api/user
172.31.234.11 - - [31/Jan/2024:14:39:44 +0000] "GET /api/user HTTP/1.0" 404 335 "-" "Bingbot"
172.31.234.11 - - [31/Jan/2024:14:39:44 +0000] "GET /api/user HTTP/1.0" 503 197 "-" "Bingbot"
172.31.234.11 - - [31/Jan/2024:14:39:44 +0000] "GET /api/user HTTP/1.0" 503 197 "-" "Bingbot"
2024/01/31 14:39:44 [error] 23#23: *1513 limiting requests, excess: 2.994 by zone "bot_limit", client: 172.31.234.11, server: localhost, request: "GET /api/user HTTP/1.0", host: "172.31.234.41"
2024/01/31 14:39:44 [error] 20#20: *1512 limiting requests, excess: 2.994 by zone "bot_limit", client: 172.31.234.11, server: localhost, request: "GET /api/user HTTP/1.0", host: "172.31.234.41"
172.31.234.11 - - [31/Jan/2024:14:39:44 +0000] "GET /api/user HTTP/1.0" 503 197 "-" "Bingbot"
2024/01/31 14:39:44 [error] 23#23: *1514 limiting requests, excess: 2.990 by zone "bot_limit", client: 172.31.234.11, server: localhost, request: "GET /api/user HTTP/1.0", host: "172.31.234.41"
2024/01/31 14:39:44 [error] 23#23: *1515 limiting requests, excess: 2.988 by zone "bot_limit", client: 172.31.234.11, server: localhost, request: "GET /api/user HTTP/1.0", host: "172.31.234.41"
172.31.234.11 - - [31/Jan/2024:14:39:44 +0000] "GET /api/user HTTP/1.0" 503 197 "-" "Bingbot"
2024/01/31 14:39:44 [error] 23#23: *1516 limiting requests, excess: 2.985 by zone "bot_limit", client: 172.31.234.11, server: localhost, request: "GET /api/user HTTP/1.0", host: "172.31.234.41"
172.31.234.11 - - [31/Jan/2024:14:39:44 +0000] "GET /api/user HTTP/1.0" 503 197 "-" "Bingbot"
172.31.234.11 - - [31/Jan/2024:14:39:44 +0000] "GET /api/user HTTP/1.0" 503 197 "-" "Bingbot"
2024/01/31 14:39:44 [error] 23#23: *1517 limiting requests, excess: 2.983 by zone "bot_limit", client: 172.31.234.11, server: localhost, request: "GET /api/user HTTP/1.0", host: "172.31.234.41"
2024/01/31 14:39:44 [error] 23#23: *1518 limiting requests, excess: 2.980 by zone "bot_limit", client: 172.31.234.11, server: localhost, request: "GET /api/user HTTP/1.0", host: "172.31.234.41"
172.31.234.11 - - [31/Jan/2024:14:39:44 +0000] "GET /api/user HTTP/1.0" 503 197 "-" "Bingbot"
172.31.234.11 - - [31/Jan/2024:14:39:45 +0000] "GET /api/user HTTP/1.0" 404 335 "-" "Bingbot"
172.31.234.11 - - [31/Jan/2024:14:39:46 +0000] "GET /api/user HTTP/1.0" 404 335 "-" "Bingbot"



ab -c 4 -n 10 -H  "User-Agent: FazNada.xyz" http://172.31.234.41/api/user

172.31.234.11 - - [31/Jan/2024:15:04:10 +0000] "GET /api/user HTTP/1.0" 404 335 "-" "FazNada.xyz"
172.31.234.11 - - [31/Jan/2024:15:04:10 +0000] "GET /api/user HTTP/1.0" 404 335 "-" "FazNada.xyz"
172.31.234.11 - - [31/Jan/2024:15:04:10 +0000] "GET /api/user HTTP/1.0" 404 335 "-" "FazNada.xyz"
172.31.234.11 - - [31/Jan/2024:15:04:10 +0000] "GET /api/user HTTP/1.0" 404 335 "-" "FazNada.xyz"
172.31.234.11 - - [31/Jan/2024:15:04:10 +0000] "GET /api/user HTTP/1.0" 404 335 "-" "FazNada.xyz"
172.31.234.11 - - [31/Jan/2024:15:04:10 +0000] "GET /api/user HTTP/1.0" 404 335 "-" "FazNada.xyz"
172.31.234.11 - - [31/Jan/2024:15:04:10 +0000] "GET /api/user HTTP/1.0" 404 335 "-" "FazNada.xyz"
172.31.234.11 - - [31/Jan/2024:15:04:10 +0000] "GET /api/user HTTP/1.0" 404 335 "-" "FazNada.xyz"
172.31.234.11 - - [31/Jan/2024:15:04:10 +0000] "GET /api/user HTTP/1.0" 404 335 "-" "FazNada.xyz"
172.31.234.11 - - [31/Jan/2024:15:04:10 +0000] "GET /api/user HTTP/1.0" 404 335 "-" "FazNada.xyz"



 ab -c 4 -n 10 -H  "User-Agent: Bingbot" http://172.31.234.41/api/user

172.31.234.11 - - [31/Jan/2024:15:04:21 +0000] "GET /api/user HTTP/1.0" 404 335 "-" "Bingbot"
2024/01/31 15:04:21 [error] 21#21: *28 limiting requests, excess: 2.995 by zone "bot_limit", client: 172.31.234.11, server: localhost, request: "GET /api/user HTTP/1.0", host: "172.31.234.41"
2024/01/31 15:04:21 [error] 20#20: *29 limiting requests, excess: 2.995 by zone "bot_limit", client: 172.31.234.11, server: localhost, request: "GET /api/user HTTP/1.0", host: "172.31.234.41"
172.31.234.11 - - [31/Jan/2024:15:04:21 +0000] "GET /api/user HTTP/1.0" 503 197 "-" "Bingbot"
172.31.234.11 - - [31/Jan/2024:15:04:21 +0000] "GET /api/user HTTP/1.0" 503 197 "-" "Bingbot"
172.31.234.11 - - [31/Jan/2024:15:04:21 +0000] "GET /api/user HTTP/1.0" 503 197 "-" "Bingbot"
2024/01/31 15:04:21 [error] 20#20: *30 limiting requests, excess: 2.990 by zone "bot_limit", client: 172.31.234.11, server: localhost, request: "GET /api/user HTTP/1.0", host: "172.31.234.41"
2024/01/31 15:04:21 [error] 20#20: *31 limiting requests, excess: 2.989 by zone "bot_limit", client: 172.31.234.11, server: localhost, request: "GET /api/user HTTP/1.0", host: "172.31.234.41"
172.31.234.11 - - [31/Jan/2024:15:04:21 +0000] "GET /api/user HTTP/1.0" 503 197 "-" "Bingbot"
2024/01/31 15:04:21 [error] 20#20: *33 limiting requests, excess: 2.984 by zone "bot_limit", client: 172.31.234.11, server: localhost, request: "GET /api/user HTTP/1.0", host: "172.31.234.41"
2024/01/31 15:04:21 [error] 20#20: *32 limiting requests, excess: 2.984 by zone "bot_limit", client: 172.31.234.11, server: localhost, request: "GET /api/user HTTP/1.0", host: "172.31.234.41"
172.31.234.11 - - [31/Jan/2024:15:04:21 +0000] "GET /api/user HTTP/1.0" 503 197 "-" "Bingbot"
172.31.234.11 - - [31/Jan/2024:15:04:21 +0000] "GET /api/user HTTP/1.0" 503 197 "-" "Bingbot"
172.31.234.11 - - [31/Jan/2024:15:04:21 +0000] "GET /api/user HTTP/1.0" 503 197 "-" "Bingbot"
2024/01/31 15:04:21 [error] 20#20: *34 limiting requests, excess: 2.980 by zone "bot_limit", client: 172.31.234.11, server: localhost, request: "GET /api/user HTTP/1.0", host: "172.31.234.41"
172.31.234.11 - - [31/Jan/2024:15:04:22 +0000] "GET /api/user HTTP/1.0" 404 335 "-" "Bingbot"
172.31.234.11 - - [31/Jan/2024:15:04:23 +0000] "GET /api/user HTTP/1.0" 404 335 "-" "Bingbot"


