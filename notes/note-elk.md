|  es   | concept |
|:------:|:------:|
|cluster|  整个集群，完备默认的数据|
|node| 集群中的一个节点，一般指一个进程|
|shared|分片，一个节点上的数据通过hash分片存储，默认5片|
|index| 数据库中的database|
|type(6.x中允许建一个，7.x中被废弃)|数据库中的table|
|document|相当于数据库中的每一行数据|
|field|相当于字段、属性|

### Get
|  es   | concept |
|:------:|:------:|
|/_cat/health?v|查看集群状态|
|/_cat/indices?v|查看index|

```
GET /movie_index/_search
{
  "query": {
    "match_all": {}
  }
}
// 条件查询
GET /movie_index/_search
{
  "query": {
    "match": {
    "FIELD": "TEXT"
}
  }
}
// 短语查询，不拆查询条件
GET /movie_index/_search
{
  "query": {
    "match_phrase": {
      "FIELD": "PHRASE"
    }
  }
}
```

### DELETE
```
DELETE /[index]
```
### PUT
```
PUT /movie_index
PUT /movie_index/_doc/1
{
  "id":"1",
  "name":"qweqw"
}
GET /movie_index/_doc/1
覆盖更新
PUT /movie_index/_doc/1
{
  "id":"2"
}

```
### POST(更新某个字段，不存在会添加)
```
POST /movie_index/_update/1
{
  "doc":{
    "id":"2"
  }
}
```

