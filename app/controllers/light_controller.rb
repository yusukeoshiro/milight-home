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
		milight_adjust_color(params["r"].to_i,params["g"].to_i,params["b"].to_i)		
		render :json => {}
	end

	def brightness
		milight_adjust_brightness( params["brightness"].to_i  )
		render :json => {}
	end


	def alexa
		intent = params["request"]["intent"]["name"]

		case intent
		when "TurnOnLight"
			$bridge.all_on
			$bridge.brightness(25)			
			render :json => alexa_response("ok, your light is now on!")

		when "TurnOffLight"
			$bridge.all_off
			render :json => alexa_response("ok, your light is now off!")

		when "AdjustBrightness"
			brightness = params["request"]["intent"]["slots"]["Brightness"]["value"].to_i
			milight_adjust_brightness( brightness )
			render :json => alexa_response("ok, adjusted to #{brightness.to_s}percent!")


		when "DefaultColor"
			$bridge.white
			render :json => alexa_response("ok, set the color back to default!")
		when "AdjustColor"
			r = params["request"]["intent"]["slots"]["Red"]["value"].to_i
			g = params["request"]["intent"]["slots"]["Green"]["value"].to_i
			b = params["request"]["intent"]["slots"]["Blue"]["value"].to_i
			milight_adjust_color( r, g, b )			
			render :json => alexa_response("ok, adjusted the color to #{r}, #{g}, #{b}!")
		when "ToggleTV"
			send_ir_signal( "IR_TV_TOGGLE" )			
			render :json => alexa_response("ok, TV is toggled!")
		when "TurnOffAC"
			send_ir_signal( "IR_AC_OFF" )
			render :json => alexa_response("ok, AC is off!")
		when "TurnOnAC"
			send_ir_signal( "IR_AC_ON" )			
			render :json => alexa_response("ok, AC is on!")
		when "TurnOffEverything"
			send_ir_signal( "IR_AC_OFF" )
			$bridge.all_off			
			render :json => alexa_response( "ok, I've turned off everything!" )				
		else
			render :json => alexa_response( "Command was not found" )				
		end

	end


	# adjust the brightness of milight
	# brightness accepts value between 1 ~ 100
	# NOTE: milight accepts brightness between 2 ~ 25 so conversion is required
	def milight_adjust_brightness( brightness )
		brightness_tmp = 2 + 25 * (brightness.to_f / 100)
		$bridge.brightness(brightness_tmp.to_i)
	end

	# adjust the color r,g,b accept values between 1 ~ 100
	def milight_adjust_color(r,g,b)
		if r == 100 && g == 100 && b == 100
			$bridge.white
		else
			$bridge.color(Color::RGB.from_percentage(r, g, b))  
		end
	end

	# build the response to be sent back to alexa with customized message
	def alexa_response( speech )
		response = {
			"version" => "1.0",
			"response" => {
				"outputSpeech" => {
					"type" => "PlainText",
					"text" => speech,
				},
				"shouldEndSession" => true
			}
		}
		return response.to_json
	end

	# send post request to IR kit with the key name stored in environmental variable
	def send_ir_signal( sig_name )
		uri = URI.parse(ENV["IR_KIT_ENDPOINT"])
		https = Net::HTTP.new(uri.host, uri.port)
		https.use_ssl = false 
		req = Net::HTTP::Post.new(uri.request_uri)
		req["Content-Type"] = "text/plain"
		req["X-Requested-With"] = "curl"
		req.body = ENV[sig_name]
		res = https.request(req)
	end 

end
