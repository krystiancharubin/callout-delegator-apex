# Apex Callout Delegator [![Deploy to Salesforce](https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png)](https://githubsfdeploy.herokuapp.com)

Apex Callout Delegator is a proof of concept library that allows performing Callouts after DML in a Synchronous Context.

### Related Blogs and Articles

* [Apex Callout Delegator - Bypass System.CalloutException](http://www.soliantconsulting.com/blog/2016/09/apex-callout-delegator)

### Example

In this example we are going to create a `Case` and insert a `Post` in an external system containing the `Case.Id`.

```java
// Post Model
class Post {
  public String title;
  public String body;
  public Integer userId;
}

// Insert a Case
Case record = new Case();
insert record;

// Post Data
Post post = new Post();
post.title = 'Case Created';
post.body = 'Id: ' + record.Id;
post.userId = 1;
```

Our endpoint requires URL Encoded data, so here is a basic `urlEncode` method we will use to send the `Post` data.

```java
// Helper method for URL Encoding an Object
public String urlEncode(Object oData){
  String sData = JSON.serialize(oData);
  Map<String, Object> data = (Map<String, Object>)
    JSON.deserializeUntyped(sData);
  List<String> formData = new List<String>();
  for(String key :data.keySet()){
    Object value = data.get(key);
    String sValue = String.valueOf(value);
    String eValue = EncodingUtil.urlEncode(sValue, 'UTF-8')
    formData.add(key + '=' + eValue);
  }
  return String.join(formData, '&');
}
```

In the snippet below we are using the standard `Http*` classes, but as expected this will throw the `System.CalloutException` since we are performing an HTTP request after a DML operation.

```java
HttpRequest req = new HttpRequest();
req.setEndpoint('https://jsonplaceholder.typicode.com/posts');
req.setMethod('POST');
req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
req.setBody(urlEncode(post));
HttpResponse res = new Http().send(req);  // System.CalloutException
```
We can easily swap out the `Http*` classes for their corresponding `Callout*` classes which yields the snippet below. With this code the HTTP request will complete successfully returning a standard `HttpResponse`

```java
Callout.Request req = new Callout.Request();
req.setEndpoint('https://jsonplaceholder.typicode.com/posts');
req.setMethod('POST');
req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
req.setBody(urlEncode(post));
HttpResponse res = Callout.send(req);
```

## License

The MIT License (MIT)

Copyright (c) 2016 Krystian Charubin

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
