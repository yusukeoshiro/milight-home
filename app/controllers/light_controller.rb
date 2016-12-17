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
			brightness = 2 + 25 * (brightness / 100)
			$bridge.brightness(brightness)   # 明るさ最小
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


		end


		else
		end



		pp params

	end

end
