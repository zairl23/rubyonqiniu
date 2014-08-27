require 'qiniu'
require 'curb'
require 'hmac-sha1'
require 'base64'

Qiniu.establish_connection! :access_key => 'HB04jRe1L4AF7Gqowub1RY1i4KHPjf4ilAHKl3EK',
                            :secret_key => 'pItuMvQH94hMqfUYHaU2fpelU17HiCfB3TSiui7K'

@access_key  = Qiniu::Config.settings[:access_key]
@secret_key  = Qiniu::Config.settings[:secret_key]
#@mac        = Qiniu::Auth::Digest::Mac.new(@access_key, @secret_key)
bucket       = "meow8"
#save_bucket  = "meow-films"
save_bucket = "bameow-ts"

File.open('keys_fails', 'a+') do |fail|
File.open('keys.txt', 'r') do |line|
	while key = line.gets
		if (key != '') 
			key = key.rstrip()
		end
		encode_key      = key.gsub(/\//, '%2F')
		save_key        = key + ".ts"
		encode_save_key = save_key.gsub(/\//, '%2F')
		saveas          = Qiniu::Utils.encode_entry_uri(save_bucket, save_key)
		save_thumbnail  = key + "-thumbnail.jpg"
		thumbnail       = Qiniu::Utils.encode_entry_uri(save_bucket, save_thumbnail)
		fops            = "avthumb/ts/vcodec/libx264/acodec/libfaac/vb/600k|saveas/" + saveas + ";vframe/jpg/offset/0/w/480/h/480|saveas/" + thumbnail
        #fops            = "avthumb/ts|saveas/" + saveas
		encode_fops     = fops.gsub('/', '%2F').gsub('|', '%7C').gsub('=', '%3D').gsub(';', '%3B')
		puts encode_fops
		#encode_fops     = ('avthumb/ts|saveas/' + saveas).gsub(/\//, '%2F')
		puts key
		# generate a manage_token
		path            = "/pfop/"
		body            = "bucket=#{bucket}&key=#{encode_key}&fops=#{encode_fops}&notifyURL=www.test.com&force=1"
		signature       = path + "\n" + body
		#manage_token = Qiniu::AccessToken.generate_encoded_digest(signature)
		hmac            = HMAC::SHA1.new(@secret_key)
		hmac.update(signature)
		sign            = Qiniu::Utils.urlsafe_base64_encode(hmac.digest)
		manage_token    = @access_key + ":" + sign
		
		# build post
		http = Curl.post("http://api.qiniu.com/pfop/",
        	{
                	:bucket    => bucket,
                	:key       => key,
                	:fops      => fops,
                	:notifyURL => 'www.test.com',
                	:force     => 1
       		 }) do |curl|
               		curl.headers['Content-Type']  = 'application/x-www-form-urlencoded'
                	curl.headers['Authorization'] =  "QBox " + manage_token
        	end
		status = http.status
		puts status
		if (status != '200')
			fail.write(key)
			fail.write("\n")	
		end
		#i(http.status != 200)
		
	end	
end
end
