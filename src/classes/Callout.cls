public class Callout {
	public String data { get; set; }

	public Callout() {
		run();
	}

	private void run(){
		try {
			Map<String, String> search = ApexPages.currentPage().getParameters();

			String req64 = search.get('req64');
			Blob reqBlob = EncodingUtil.base64Decode(req64);
			String reqJSON = reqBlob.toString();

			Request req = (Request) JSON.deserialize(reqJSON, Request.class);
			System.debug('req: ' + JSON.serializePretty(req));
			HttpRequest httpReq = req.generate();
			System.debug('httpReq: ' + httpReq);
			Http http = new Http();
			HttpResponse httpRes = http.send(httpReq);

			System.debug('httpRes: ' + httpRes);
			System.debug('httpRes.status: ' + httpRes.getStatus());
			System.debug('httpRes.statusCode: ' + httpRes.getStatusCode());
			System.debug('httpRes.body: ' + httpRes.getBody());

			Response res = new Response();
			res.setBody(httpRes.getBody());
			res.setStatus(httpRes.getStatus());
			res.setStatusCode(httpRes.getStatusCode());
			for(String key :httpRes.getHeaderKeys()){
				if(String.isEmpty(key)) continue;
				res.setHeader(key, httpRes.getHeader(key));
			}

			data = JSON.serialize(res);
			System.debug(data);
		} catch (Exception ex){
			System.debug(ex);
			System.debug('ex.message: ' + ex.getMessage());
			System.debug('ex.stackTrace: ' + ex.getStackTraceString());
		}
	}

	public static HttpResponse send(Request req){
		PageReference ref = Page.Callout;
		Map<String, String> search = ref.getParameters();

		String reqJSON = JSON.serialize(req);
		Blob reqBlob = Blob.valueOf(reqJSON);
		String req64 = EncodingUtil.base64Encode(reqBlob);

		search.put('req64', req64);

		Blob resBlob = ref.getContent();
		String resJSON = resBlob.toString();
		Response res = (Response) JSON.deserialize(resJSON, Response.class);
		return res.generate();
	}

	public class Request {
		String body;
		Boolean compressed;
		String endpoint;
		Map<String, String> header;
		String method;
		Integer timeout;

		public Request(){
			compressed = false;
			header = new Map<String, String>();
		}

		public HttpRequest generate(){
			HttpRequest req = new HttpRequest();
			req.setMethod(this.method);
			req.setEndpoint(this.endpoint);
			if(!String.isEmpty(this.body)) req.setBody(this.body);
			req.setCompressed(this.compressed);
			if(this.timeout != null) req.setTimeout(this.timeout);
			for(String key :this.header.keySet()){
				req.setHeader(key, this.header.get(key));
			}

			return req;
		}

		public String getBody(){
			return this.body;
		}

		public Blob getBodyAsBlob(){
			return Blob.valueOf(this.body);
		}

		public Boolean getCompressed(){
			return this.compressed;
		}

		public String getEndpoint(){
			return this.endpoint;
		}

		public Map<String, String> getHeader(){
			return this.header;
		}

		public String getHeader(String key){
			return this.header.get(key);
		}

		public String getMethod(){
			return this.method;
		}

		public void setBody(String body){
			this.body = body;
		}

		public void setBodyAsBlob(Blob body){
			setBody(body.toString());
		}

		public void setBody(Object body){
			setBody(JSON.serialize(body));
		}

		public void setCompressed(Boolean flag){
			this.compressed = flag;
		}

		public void setEndpoint(String endpoint){
			this.endpoint = endpoint;
		}

		public void setHeader(String key, String value){
			this.header.put(key, value);
		}

		public void setMethod(String method){
			this.method = method;
		}

		public void setTimeout(Integer timeout){
			this.timeout = timeout;
		}
	}

	public class Response {
		String body;
		Map<String, String> header;
		String status;
		Integer statusCode;

		public Response(){
			this.header = new Map<String, String>();
		}

		public HttpResponse generate(){
			HttpResponse res = new HttpResponse();
			res.setBody(this.body);
			res.setStatus(this.status);
			res.setStatusCode(this.statusCode);
			for(String key :this.header.keySet()){
				res.setHeader(key, this.header.get(key));
			}
			return res;
		}

		public String getBody(){
			return this.body;
		}

		public Blob getBodyAsBlob(){
			return Blob.valueOf(this.body);
		}

		public String getHeader(String key){
			return this.header.get(key);
		}

		public List<String> getHeaderKeys(){
			return new List<String>(this.header.keySet());
		}

		public String getStatus(){
			return this.status;
		}

		public Integer getStatusCode(){
			return this.statusCode;
		}

		public void setBody(String body){
			this.body = body;
		}

		public void setBodyAsBlob(Blob body){
			setBody(body.toString());
		}

		public void setHeader(String key, String value){
			this.header.put(key, value);
		}

		public void setStatus(String status){
			this.status = status;
		}

		public void setStatusCode(Integer statusCode){
			this.statusCode = statusCode;
		}
	}
}
