require 'qiniu'
require 'curb'
require 'hmac-sha1'
require 'base64'
 
Qiniu.establish_connection! :access_key => 'your pkey',
                            :secret_key => 'your skey'
 
@access_key = Qiniu::Config.settings[:access_key]
@secre_key = Qiniu::Config.settings[:secret_key]
#@mac        = Qiniu::Auth::Digest::Mac.new(@access_key, @secret_key)

key = ARGV[0]
encode_key = key.gsub(/\//, '%2F')
#puts key
# generate a manage_token
path      = "/pfop/"
body      = "bucket=meow-videos&key=#{encode_key}&fops=avthumb%2Fmpegts&notifyURL=www.test.com&force=1"
signature = path + "\n" + body
#manage_token = Qiniu::AccessToken.generate_encoded_digest(signature)
hmac      = HMAC::SHA1.new(@secre_key)
hmac.update(signature)
sign =  Qiniu::Utils.urlsafe_base64_encode(hmac.digest)
manage_token = @access_key + ":" + sign 
# build post
http = Curl.post("http://api.qiniu.com/pfop/", 
	{
		:bucket    => 'meow-videos',
                :key       => key,
		:fops      => 'avthumb/mpegts',
		:notifyURL => 'www.test.com',
		:force     => 1
	}) do |curl|
  		curl.headers['Content-Type']  = 'application/x-www-form-urlencoded'
  		curl.headers['Authorization'] =  "QBox " + manage_token
	end
puts http.status
#c = Curl::Easy.http_post("http://api.qiniu.com/pfop",
                        # Curl::PostField.content('thing[bucket]', 'meow-videos'),
                        # Curl::PostField.content('thing[key]', 'FgTom7voGXNkGa8NPzZdUQF6dXFZ'),
			# Curl::PostField.content('thing[fops]', 'avthumb/mpegts'),
			# Curl::PostField.content('thing[notifyURL]', 'www.test.com')
			#)
