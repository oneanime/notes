jackson的一些配置

```java

objectMapper.configure(JsonParser.Feature.ALLOW_UNQUOTED_CONTROL_CHARS, true);
# 单引号配置，json的标准格式是双引号
 objectMapper.configure(JsonParser.Feature.ALLOW_SINGLE_QUOTES, true) ;
```

```
提取属性的时候，使用asText()，提取的是字符串，直接使用toString()，会多出一对双引号
直接把整个json字符串化，可以使用toString()
```

