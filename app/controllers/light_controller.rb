class LightController < ApplicationController

	def on
		$bridge.all_on
		render :json => {}
	end

	def off
		$bridge.all_off
		render :json => {}
	end

	def color
		r = params["r"].to_i
		g = params["g"].to_i
		b = params["b"].to_i

		if r == 100 && g == 100 && b == 100
			$bridge.white
		else
			$bridge.color(Color::RGB.from_percentage(r, g, b))  
		end		
		render :json => {}
	end

	def brightness
		brightness = params["brightness"].to_i 
		brightness = 2 + 25 * (brightness / 100)
		$bridge.brightness(brightness)   # 明るさ最小
		render :json => {}
	end

	def alexa
		intent = params["request"]["intent"]["name"]
		
		

		case intent
		when "TurnOnLight"
			$bridge.all_on	
			response = {
				"version" => "1.0",
				"response" => {
					"outputSpeech" => {
						"type" => "PlainText",
						"text" => "ok, your light is now on!",
					},
					"shouldEndSession" => true
				}
			}
			render :json => response.to_json

		when "TurnOffLight"
			$bridge.all_off
			response = {
				"version" => "1.0",
				"response" => {
					"outputSpeech" => {
						"type" => "PlainText",
						"text" => "ok, your light is now off!",
					},
					"shouldEndSession" => true
				}
			}
			render :json => response.to_json

		when "AdjustBrightness"
			brightness = params["request"]["intent"]["slots"]["Brightness"]["value"].to_i
			$bridge.brightness(2 + 25 * (brightness / 100))   # 明るさ最小
			response = {
				"version" => "1.0",
				"response" => {
					"outputSpeech" => {
						"type" => "PlainText",
						"text" => "ok, adjusted to #{brightness.to_s}percent!"
					},
					"shouldEndSession" => true
				}
			}
			render :json => response.to_json


		when "DefaultColor"
			$bridge.white
			response = {
				"version" => "1.0",
				"response" => {
					"outputSpeech" => {
						"type" => "PlainText",
						"text" => "ok, set the color back to default!"
					},
					"shouldEndSession" => true
				}
			}
			render :json => response.to_json

		when "AdjustColor"
			r = params["request"]["intent"]["slots"]["Red"]["value"].to_i
			g = params["request"]["intent"]["slots"]["Green"]["value"].to_i
			b = params["request"]["intent"]["slots"]["Blue"]["value"].to_i

			if r == 100 && g == 100 && b == 100
				$bridge.white
			else
				$bridge.color(Color::RGB.from_percentage(r, g, b))  
			end

			response = {
				"version" => "1.0",
				"response" => {
					"outputSpeech" => {
						"type" => "PlainText",
						"text" => "ok, adjusted the color to #{r}, #{g}, #{b}!"
					},
					"shouldEndSession" => true
				}
			}
			render :json => response.to_json	


		when "ToggleTV"
			send_ir_signal( "IR_TV_TOGGLE" )
			response = {
				"version" => "1.0",
				"response" => {
					"outputSpeech" => {
						"type" => "PlainText",
						"text" => "ok, TV is toggled!"
					},
					"shouldEndSession" => true
				}
			}
			render :json => response.to_json	

		else
		end



		pp params

	end


	def send_ir_signal( sig_name ){
		uri = URI.parse(ENV["IR_KIT_ENDPOINT"])
		https = Net::HTTP.new(uri.host, uri.port)
		https.use_ssl = false 
		req = Net::HTTP::Post.new(uri.request_uri)
		req["Content-Type"] = "text/plain"
		req["X-Requested-With"] = "curl"
		req.body = ENV[sig_name]
		res = https.request(req)
	}

end
