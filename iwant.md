**process a fpop in meow8 bucket in piliang**

in here:

	http://developer.qiniu.com/docs/v6/api/overview/fop/persistent-fop.html


	POST /pfop/ HTTP/1.1
	Host: api.qiniu.com  
	Content-Type: application/x-www-form-urlencoded  
	Authorization: <AccessToken>  
	bucket=<bucket>&key=<key>&fops=<fop1>;<fop2>...<fopN>&notifyURL=<persistentNotifyUrl>

so i should build this requets using ruby

build a curl post using ruby

first build config with AK and SK
Qiniu.establish_connection! :access_key => <YOUR_APP_ACCESS_KEY>,
                            :secret_key => <YOUR_APP_SECRET_KEY>

A example for uploading

	@access_key = Qiniu::Conf.settings[:access_key]
	@secret_key = Qiniu::Conf.settings[:secret_key]
	@mac = Qiniu::Auth::Digest::Mac.new(@access_key, @secret_key)

	base_url = Qiniu::Rs.make_base_url("a.qiniudn.com", "down.jpg")
	get_policy = Qiniu::Rs::GetPolicy.new
	get_policy.Expires = 1000
	url = get_policy.make_request(base_url, @mac)


a process image 

iv = Qiniu::Fop::ImageView.new
iv.height = 100
iv.width = 40
returl = iv.make_request @image_url
puts returl

 
# 批量获取文件信息：Qiniu::Rs::Client.BatchStat()

@rs_cli = Qiniu::Rs::Client.new(@mac)

# 批量获取文件信息

to_stat = []
@keys.each do | key |
    to_stat << Qiniu::Rs::EntryPath.new(@bucket1, key)
end
code, res = @rs_cli.BatchStat(to_stat)

@rs_cli = Qiniu::Rs::Client.new(@mac)

