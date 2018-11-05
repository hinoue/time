# time

Keeps track of time worked on various projects throughout the day.

## Examples

```
> ./t in 9:00(accounting-meeting)
09:00- (accounting-meeting) (0:01)
---
Default                          0.01
=====================================
Total                            0.01
```

```
> ./t out 17:00
09:00-10:00 (accounting-meeting) (01:00:00)
10:00-13:00 (shapiro-account) (03:00:00)
14:00-17:00 (price-account) (03:00:00)
---
accounting-meeting             1.00
shapiro-account                3.00
price-account                  3.00
===================================
Total                          7.00
```

```
./t 10:00-12:00 "1:00-3:00(lunch-with-client)"
0:00-12:00 (Default) (02:00:00)
01:00-03:00 (lunch-with-client) (03:00:00)
---
10:00-12:00 (Default)
01:00-03:00 (lunch-with-client)
Total: 5.0
```

