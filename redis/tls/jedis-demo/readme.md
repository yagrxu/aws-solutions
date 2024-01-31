# Redis TLS

```shell
redis-cli -u redis://$REDIS_HOST:$REDIS_PORT --tls --user $REDIS_USER --pass $REDIS_PASS
redis> set mykey "Hello"
OK
redis> get mykey
"Hello"
```

```java
Jedis jedis = new Jedis(String.format("%s://%s:%s", System.getenv("REDIS_PROTOCOL"),System.getenv("REDIS_HOST"),System.getenv("REDIS_PORT")));
try{

    jedis.auth(System.getenv("REDIS_USER"), System.getenv("REDIS_PASS"));
    // System.out.println(jedis.ping());
    return jedis.get(key);
}
finally {
    jedis.close();
}
```
